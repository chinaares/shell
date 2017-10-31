#!/bin/bash
printhelp() {

echo "
Usage: ./CentOS-pptp-setup.sh [OPTION]
If you are using custom password , Make sure its more than 8 characters. Otherwise it will generate random password for you. 
If you trying set password only. It will generate Default user with Random password. 
example: ./CentOS-pptp-setup.sh -u myusr -p mypass
Use without parameter [ ./CentOS-pptp-setup.sh ] to use default username and Random password
  -u,    --username             Enter the Username
  -p,    --password             Enter the Password
"
}

while [ "$1" != "" ]; do
  case "$1" in
    -u    | --username )             NAME=$2; shift 2 ;;
    -p    | --password )             PASS=$2; shift 2 ;;
    -h    | --help )            echo "$(printhelp)"; exit; shift; break ;;
  esac
done

# Check if user is root
[ $(id -u) != "0" ] && { echo -e "\033[31mError: You must be root to run this script\033[0m"; exit 1; } 

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
clear

[ ! -e '/usr/bin/curl' ] && yum -y install curl

VPN_IP=`curl ipv4.icanhazip.com`
VPN_LOCAL="10.10.10.103"
VPN_REMOTE="10.10.10.110-200"
clear

if [ -f /etc/redhat-release -a -n "`grep ' 7\.' /etc/redhat-release`" ];then
        #CentOS_REL=7
	if [ ! -e /etc/yum.repos.d/epel.repo ];then
		cat > /etc/yum.repos.d/epel.repo << EOF
[epel]
name=Extra Packages for Enterprise Linux 7 - \$basearch
#baseurl=http://download.fedoraproject.org/pub/epel/7/\$basearch
mirrorlist=https://mirrors.fedoraproject.org/metalink?repo=epel-7&arch=\$basearch
failovermethod=priority
enabled=1
gpgcheck=0
EOF

fi
        for Package in wget make openssl gcc-c++ ppp pptpd iptables iptables-services 
        do
                yum -y install $Package
        done
        echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf
elif [ -f /etc/redhat-release -a -n "`grep ' 6\.' /etc/redhat-release`" ];then
        #CentOS_REL=6
        for Package in wget make openssl gcc-c++ iptables ppp 
        do
                yum -y install $Package
        done
	sed -i 's@net.ipv4.ip_forward.*@net.ipv4.ip_forward = 1@g' /etc/sysctl.conf
	rpm -Uvh http://poptop.sourceforge.net/yum/stable/rhel6/pptp-release-current.noarch.rpm
	yum -y install pptpd
else
        echo -e "\033[31mDoes not support this OS, Please contact the author! \033[0m"
        exit 1
fi

sysctl -p

[ -z "`grep '^localip' /etc/pptpd.conf`" ] && echo "localip $VPN_LOCAL" >> /etc/pptpd.conf # Local IP address of your VPN server
[ -z "`grep '^remoteip' /etc/pptpd.conf`" ] && echo "remoteip $VPN_REMOTE" >> /etc/pptpd.conf # Scope for your home network

if [ -z "`grep '^ms-dns' /etc/ppp/options.pptpd`" ];then
	echo "ms-dns 61.139.2.69" >> /etc/ppp/options.pptpd
	echo "ms-dns 8.8.8.8" >> /etc/ppp/options.pptpd
fi

#no liI10oO chars in password

LEN=$(echo ${#PASS})

if [ -z "$PASS" ] || [ $LEN -lt 8 ] || [ -z "$NAME"]
then
   P1=`cat /dev/urandom | tr -cd abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789 | head -c 3`
   P2=`cat /dev/urandom | tr -cd abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789 | head -c 3`
   P3=`cat /dev/urandom | tr -cd abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789 | head -c 3`
   PASS="$P1-$P2-$P3"
fi

if [ -z "$NAME" ]
then
   NAME="vpn"
fi

cat >> /etc/ppp/chap-secrets <<END
$NAME pptpd $PASS *
END

ETH=`route | grep default | awk '{print $NF}'`
[ -z "`grep '1723 -j ACCEPT' /etc/sysconfig/iptables`" ] && iptables -I INPUT 4 -p tcp -m state --state NEW -m tcp --dport 1723 -j ACCEPT
[ -z "`grep 'gre -j ACCEPT' /etc/sysconfig/iptables`" ] && iptables -I INPUT 5 -p gre -j ACCEPT 
iptables -t nat -A POSTROUTING -o $ETH -j MASQUERADE
iptables -I FORWARD -p tcp --syn -i ppp+ -j TCPMSS --set-mss 1356
service iptables save
sed -i 's@^-A INPUT -j REJECT --reject-with icmp-host-prohibited@#-A INPUT -j REJECT --reject-with icmp-host-prohibited@' /etc/sysconfig/iptables 
sed -i 's@^-A FORWARD -j REJECT --reject-with icmp-host-prohibited@#-A FORWARD -j REJECT --reject-with icmp-host-prohibited@' /etc/sysconfig/iptables 
service iptables restart
chkconfig iptables on
service pptpd restart
chkconfig pptpd on
clear

echo -e "You can now connect to your VPN via your external IP \033[32m${VPN_IP}\033[0m"

echo -e "Username: \033[32m${NAME}\033[0m"
echo -e "Password: \033[32m${PASS}\033[0m"