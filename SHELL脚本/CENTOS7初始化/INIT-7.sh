#!/bin/bash
#CENTOS7初始化设置


function init(){
	###############################
	systemctl stop firewalld.service  
	systemctl disable firewalld.service
	systemctl status firewalld.service
	###############################
	yum -y install wget epel-release dos2unix
	cd /etc/yum.repos.d/
	mv CentOS-Base.repo CentOS-Base.repo.`date +%Y%m%d_%S`bak
	wget -O CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
	wget -O epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
	yum clean all
	yum makecache
	###############################
	yum -y install vim npdate lrzsz iptables-services iptables unzip lsof net-tools gcc make cmake curl-devel bzip2 bzip2-devel libtool glibc gd gd-devel python-devel
	yum -y update
	###############################
	systemctl start iptables  
	systemctl status iptables 
	systemctl enable iptables 
	###############################
	vimrc_ts=`grep 'set ts=4' /etc/vimrc`
	if [ ! -n "${vimrc_ts}" ];then
		sed -i '3 aset ts=4' /etc/vimrc
		echo "VIM Set up!"
	else
		echo "VIM ts=4 is already exists!"
	fi
	chmod 777 /etc/rc.d/rc.local
}
# function Renamed_Network_card(){
# 	net_file=/etc/sysconfig/network-scripts/ifcfg-eth*
# 	if [ ! -f ${net_file} ];then
# 		name=`ip a |awk -F : '{print $2}'|sed 's/ //g'|grep ens*`
# 		cd /etc/sysconfig/network-scripts/
# 		n=0
# 		for i in $name;
# 		do
# 			sed -i "s/${i}/eth${n}/g" ifcfg-${i}
# 			mv ifcfg-${i} ifcfg-eth${n}
# 			((n=n+1))
# 		done
# 		sed -i 's/rhgb/net.ifnames=0 biosdevname=0 rhgb/' /etc/default/grub
# 		/usr/sbin/grub2-mkconfig -o /boot/grub2/grub.cfg	
# 		#echo "The script has been executed,and system will reboot!"
# 		#sleep 3
# 		#reboot
# 	else
# 		echo "eth0 or eth1 already exists,pass! "
# 	fi
# }

function limits_config(){ #修改打开的文件数
	cat > /etc/rc.d/rc.local << EOF
	#!/bin/bash

	touch /var/lock/subsys/local
	ulimit -SHn 1024000
EOF

	sed -i "/^ulimit -SHn.*/d" /etc/rc.d/rc.local
	echo "ulimit -SHn 1024000" >> /etc/rc.d/rc.local

	sed -i "/^ulimit -s.*/d" /etc/profile
	sed -i "/^ulimit -c.*/d" /etc/profile
	sed -i "/^ulimit -SHn.*/d" /etc/profile
	 
	cat >> /etc/profile << EOF
	ulimit -c unlimited
	ulimit -s unlimited
	ulimit -SHn 1024000
EOF
	 
	source /etc/profile
	ulimit -a
	cat /etc/profile | grep ulimit

	if [ ! -f "/etc/security/limits.conf.bak" ]; then
	    cp /etc/security/limits.conf /etc/security/limits.conf.bak
	fi

	cat > /etc/security/limits.conf << EOF
	* soft nofile 1024000
	* hard nofile 1024000
	* soft nproc  1024000
	* hard nproc  1024000
	hive   - nofile 1024000
	hive   - nproc  1024000
EOF

	if [ ! -f "/etc/security/limits.d/20-nproc.conf.bak" ]; then
	    cp /etc/security/limits.d/20-nproc.conf /etc/security/limits.d/20-nproc.conf.`date +%Y%m%d_%S`bak
	fi

	cat > /etc/security/limits.d/20-nproc.conf << EOF
	*          soft    nproc     409600
	root       soft    nproc     unlimited
EOF
	sleep 1
}

function selinux_config(){ #关闭SELINUX disable selinux
	sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
	setenforce 0
	sleep 1
}


function ipv6_config(){ # 关闭ipv6  disable the ipv6
	echo "NETWORKING_IPV6=no">/etc/sysconfig/network
	echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
	echo 1 > /proc/sys/net/ipv6/conf/default/disable_ipv6
	echo "127.0.0.1   localhost   localhost.localdomain">/etc/hosts
	#sed -i 's/IPV6INIT=yes/IPV6INIT=no/g' /etc/sysconfig/network-scripts/ifcfg-enp0s8
	for line in $(ls -lh /etc/sysconfig/network-scripts/ifcfg-* | awk '{print $9}')  
	do
		if [ -f  $line ];then
	        sed -i 's/IPV6INIT=yes/IPV6INIT=no/g' $line
	        #echo $i
		fi
	done
}

function time_set(){ #设置时间同步
	yum -y install ntp
	service ntpd start
	chkconfig --level 35 ntpd on
	rm -f /etc/localtime
	cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

	cat > /etc/sysconfig/clock << EOF
	ZONE="Asia/Shanghai"
	UTC=false
	ARC=false
EOF

	cat > /etc/ntp.conf << EOF
	server 128.138.140.44 prefer
	server 132.163.4.102
	server ntp.fudan.edu.cn
	server time-a.nist.gov
	server asia.pool.ntp.org
	driftfile /var/db/ntp.drift
EOF

	ntpdate asia.pool.ntp.org >/dev/null 2>&1
	/sbin/hwclock --systohc
	echo "时间同步成功！"
}

function optimized(){
	cat << EOF
	+-------------------------------------------------+
	|               optimizer is done                 |
	|   it is recommond to restart this server !       |
	|             Please Reboot system                |
	+-------------------------------------------------+
EOF
	echo "The script has been executed,and system will reboot!"
	sleep 3
	reboot
}


if [[ `whoami` = "root" && `cat /etc/redhat-release | awk -F "release" '{print $2}' |awk -F "." '{print $1}' |sed 's/ //g'` = "7" && `uname -i` = "x86_64" ]];then
	cat << EOF
	+---------------------------------------+
	|   Your system is CentOS 7 x86_64      |
	|           start optimizing            |
	+---------------------------------------+
EOF
	sleep 5
	init
	sleep 5
	time_set
	limits_config
	sleep 5
	selinux_config
	sleep 5
	ipv6_config
	#sleep 5
	#Renamed_Network_card
	sleep 5
	optimized
else
	echo "Not root privileges or centos7,the script will exit!"
	exit 1
fi
