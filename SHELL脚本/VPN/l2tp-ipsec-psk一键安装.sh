yum install -y make gcc gmp-devel xmlto bison flex xmlto libpcap-devel lsof vim-enhanced man
yum install libreswan

wget http://dl.fedoraproject.org/pub/epel/7/x86_64/Packages/x/xl2tpd-1.3.8-2.el7.x86_64.rpm
rpm -ivh xl2tpd-1.3.8-2.el7.x86_64.rpm

#添加l2tp_psk.conf文件
cat > /etc/ipsec.d/l2tp_psk.conf  <<EOF
conn L2TP-PSK-NAT
    rightsubnet=vhost:%priv
    also=L2TP-PSK-noNAT
conn L2TP-PSK-noNAT
    authby=secret
    pfs=no
    auto=add
    keyingtries=3
    dpddelay=30
    dpdtimeout=120
    dpdaction=clear
    rekey=no
    ikelifetime=8h
    keylife=1h
    type=transport
    left=192.168.199.190
    #自己的外网Ip地址
    leftprotoport=17/1701
    right=%any
    rightprotoport=17/%any
EOF

#配置预共享密匙文件
sed -i 's/include/#include/' /etc/ipsec.secrets && echo '192.168.199.190 %any: PSK "123456789"' >> /etc/ipsec.secrets
#192.168.199.190是外网IP，PSK是预存共享密匙



#修改内核支持
cat >> /etc/sysctl.conf  <<EOF
vm.swappiness = 0
net.ipv4.neigh.default.gc_stale_time=120
net.ipv4.conf.all.rp_filter=0
net.ipv4.conf.default.rp_filter=0
net.ipv4.conf.default.arp_announce = 2
net.ipv4.conf.all.arp_announce=2
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 1024
net.ipv4.tcp_synack_retries = 2
net.ipv4.conf.lo.arp_announce=2
net.ipv4.ip_forward = 1
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.default.accept_source_route = 0
EOF

sysctl -p
ipsec setup start
ipsec verify
systemctl start ipsec
systemctl enable ipsec

#修改xl2tpd主配置文件
cat > /etc/xl2tpd/xl2tpd.conf  <<EOF
[global]
listen-addr = 192.168.199.190
 #本机外网网卡IP
ipsec saref = yes
[lns default]
ip range = 192.168.10.128-192.168.10.200
local ip = 192.168.10.2
require chap = yes
refuse pap = yes
require authentication = yes
name = xl2tp-VPN
ppp debug = yes
pppoptfile = /etc/ppp/options.xl2tpd
length bit = yes
EOF
#修改xl2tpd配置文件的DNS：
sed -i 's/ms-dns  8.8.8.8/ms-dns  61.139.2.69/' /etc/ppp/options.xl2tpd
#添加用户名
echo 'kinghu88      *  123456789 *' >> /etc/ppp/chap-secrets
systemctl start xl2tpd 
systemctl enable xl2tpd