#!/bin/bash
function vpn_install(){
yum install -y make gcc gmp-devel xmlto bison flex xmlto libpcap-devel lsof vim-enhanced man
yum install -y libreswan
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
    left=$IP
    #自己的外网Ip地址
    leftprotoport=17/1701
    right=%any
    rightprotoport=17/%any
EOF

#配置预共享密匙文件
sed -i 's/include/#include/' /etc/ipsec.secrets
cat >> /etc/ipsec.secrets <<END
$IP %any: PSK "123456789" #192.168.199.190是外网IP，PSK是预存共享密匙
END


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
systemctl start ipsec
systemctl enable ipsec

#修改xl2tpd主配置文件

#sed -i 's/; ipsec saref = yes/ipsec saref = yes/' /etc/xl2tpd/xl2tpd.conf
cp -rf /etc/xl2tpd/xl2tpd.conf /etc/xl2tpd/xl2tpd.conf.`date +%Y%m%d_%S`bak
cat > /etc/xl2tpd/xl2tpd.conf  <<EOF
;
; This is a minimal sample xl2tpd configuration file for use
; with L2TP over IPsec.
;
; The idea is to provide an L2TP daemon to which remote Windows L2TP/IPsec
; clients connect. In this example, the internal (protected) network 
; is 192.168.1.0/24.  A special IP range within this network is reserved
; for the remote clients: 192.168.1.128/25
; (i.e. 192.168.1.128 ... 192.168.1.254)
;
; The listen-addr parameter can be used if you want to bind the L2TP daemon
; to a specific IP address instead of to all interfaces. For instance,
; you could bind it to the interface of the internal LAN (e.g. 192.168.1.98
; in the example below). Yet another IP address (local ip, e.g. 192.168.1.99)
; will be used by xl2tpd as its address on pppX interfaces.

[global]
  listen-addr = $IP
;
; requires openswan-2.5.18 or higher - Also does not yet work in combination
; with kernel mode l2tp as present in linux 2.6.23+
  ipsec saref = yes
; Use refinfo of 22 if using an SAref kernel patch based on openswan 2.6.35 or
;  when using any of the SAref kernel patches for kernels up to 2.6.35.
; saref refinfo = 30
;
; force userspace = yes
;
; debug tunnel = yes

[lns default]
  ip range = $IPRANGE2
  local ip = $LOCALIP
  require chap = yes
  refuse pap = yes
  require authentication = yes
  name = LinuxVPNserver
  ppp debug = yes
  pppoptfile = /etc/ppp/options.xl2tpd
  length bit = yes
EOF
#修改xl2tpd配置文件的DNS：
sed -i 's/ms-dns  8.8.8.8/ms-dns  61.139.2.69/' /etc/ppp/options.xl2tpd
#添加用户名
cat >> /etc/ppp/chap-secrets <<END
$NAME * $PASS *
END
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
    iptables -A FORWARD -d $IPRANGE -j ACCEPT
    iptables -A FORWARD -s $IPRANGE -j ACCEPT
    iptables -A FORWARD -i ppp+ -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT
    iptables -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
    iptables -A FORWARD -j REJECT --reject-with icmp-host-prohibited
    iptables -F OUTPUT
    iptables -Z OUTPUT
    iptables -P OUTPUT ACCEPT
    iptables -A OUTPUT -m state --state INVALID -j DROP
    iptables -F -t nat
    iptables -Z -t nat
    iptables -t nat -A POSTROUTING -s $IPRANGE -o $ETH -j MASQUERADE
    #上网设置
    iptables -t nat -A POSTROUTING -s $IPRANGE -j SNAT --to-source $IP

    service iptables save
    service iptables restart

}
if [ -f /etc/redhat-release ] && [ -n "`grep ' 7\.' /etc/redhat-release`" ] && [ $(id -u) = "0" ];then
    IP=`ip a | grep inet | grep -v inet6 | grep -v 127 | sed 's/^[ \t]*//g' | cut -d ' ' -f2|awk -F / '{print $1}'`
    IPRANGE=172.16.16.0/24
    IPRANGE2=172.16.16.128-172.16.16.200
    LOCALIP=172.16.16.2
    ETH=`route | grep default | awk '{print $NF}'`
    NAME=$1 && PASS=$2
    LEN=$(echo ${#PASS})
    if [ -z "$PASS" ] || [ $LEN -lt 8 ] || [ -z "$NAME" ];then
       echo '密码小于8位'
       exit 1
    else
        vpn_install
        iptables_set
        ipsec verify && lsof -i:1701
        echo 'VPN帐号：' $NAME && echo 'VPN密码：' $PASS

    fi
elif [ -f /etc/redhat-release ] && [ -n "`grep ' 6\.' /etc/redhat-release`" ] && [ $(id -u) = "0" ];then
    echo "centos6可能不兼容，请使用centos7！"
    exit 1
else
    echo "请使用centos7系统安装此脚本！"
    exit 1
fi