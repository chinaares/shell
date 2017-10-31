#!/bin/bash
ip=192.168.199.190
iprange=10.10.10.0/24
ETH=`route | grep default | awk '{print $NF}'`

function vpn_install(){
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
    left=$ip
    #自己的外网Ip地址
    leftprotoport=17/1701
    right=%any
    rightprotoport=17/%any
EOF

#配置预共享密匙文件
sed -i 's/include/#include/' /etc/ipsec.secrets && echo '$ip %any: PSK "123456789"' >> /etc/ipsec.secrets
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
listen-addr = $ip
 #本机外网网卡IP
ipsec saref = yes
[lns default]
ip range = 10.10.10.128-10.10.10.200
local ip = 10.10.10.2
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
echo '$NAME      *  $PASS *' >> /etc/ppp/chap-secrets
systemctl start xl2tpd 
systemctl enable xl2tpd
}

#防火墙设置
function iptables_set(){
    iptables -F INPUT
    iptables -Z INPUT
    iptables -P INPUT ACCEPT
    iptables -A INPUT -m state --state INVALID -j DROP
    iptables -A INPUT -p icmp -j ACCEPT
    iptables -A INPUT -i lo -j ACCEPT
    iptables -A INPUT -p tcp -m state --state NEW,RELATED,ESTABLISHED -m tcp --dport 22 -j ACCEPT
    iptables -A INPUT -p tcp -m state --state NEW,RELATED,ESTABLISHED -m tcp --dport 80 -j ACCEPT
    iptables -A INPUT -p tcp -m state --state NEW,RELATED,ESTABLISHED -m tcp --dport 1723 -j ACCEPT
    iptables -A INPUT -p gre -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT
    iptables -A INPUT -p udp -m policy --dir in --pol ipsec -m udp --dport 1701 -j ACCEPT
    iptables -A INPUT -p udp -m udp --dport 1701 -j ACCEPT
    iptables -A INPUT -p udp -m udp --dport 500 -j ACCEPT
    iptables -A INPUT -p udp -m udp --dport 4500 -j ACCEPT
    iptables -A INPUT -p esp -j ACCEPT
    iptables -A INPUT -m policy --dir in --pol ipsec -j ACCEPT
    iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
    iptables -A INPUT -j REJECT --reject-with icmp-host-prohibited
    iptables -F FORWARD
    iptables -Z FORWARD
    iptables -P FORWARD ACCEPT
    iptables -A FORWARD -m state --state INVALID -j DROP
    #iptables -A FORWARD -m policy --dir in --pol ipsec -j ACCEPT
    iptables -A FORWARD -d $iprange -j ACCEPT
    iptables -A FORWARD -s $iprange -j ACCEPT
    iptables -A FORWARD -i ppp+ -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT
    iptables -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
    iptables -A FORWARD -j REJECT --reject-with icmp-host-prohibited
    iptables -F OUTPUT
    iptables -Z OUTPUT
    iptables -P OUTPUT ACCEPT
    iptables -A OUTPUT -m state --state INVALID -j DROP
    iptables -F -t nat
    iptables -Z -t nat
    iptables -t nat -A POSTROUTING -s $iprange -o $ETH -j MASQUERADE
    #上网设置
    iptables -t nat -A POSTROUTING -s $iprange -j SNAT --to-source $ip

    service iptables save
    service iptables restart

}
if [[ `whoami` = "root" && `cat /etc/redhat-release | awk -F "release" '{print $2}' |awk -F "." '{print $1}' |sed 's/ //g'` = "7" && `uname -i` = "x86_64" ]];then
    NAME=$1 && PASS=$2
    if [[ "$1" = "" ]];then 
        echo 'example:sh vpn.sh username password '
        exit 1
    else
        vpn_install
        iptables_set
    fi
else
    echo "Not root privileges or centos7,the script will exit!"
    exit 1
fi