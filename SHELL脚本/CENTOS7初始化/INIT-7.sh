#!/bin/bash
#CENTOS7初始化设置

function init(){
	###############################
	systemctl stop firewalld.service  
	systemctl disable firewalld.service
	systemctl status firewalld.service
	###############################
	yum -y install wget epel-release dos2unix && cd /etc/yum.repos.d/
	mv CentOS-Base.repo CentOS-Base.repo.`date +%Y%m%d_%S`bak
	wget -O CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
	wget -O epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
	yum clean all && yum makecache
	###############################
	yum -y update
	yum -y install vim ntpdate lrzsz iptables-services iptables unzip lsof net-tools gcc make cmake curl-devel bzip2 bzip2-devel libtool glibc gd gd-devel python-devel
	###############################
	#systemctl start iptables  
	#systemctl status iptables 
	#systemctl enable iptables 
	###############################
	chmod 777 /etc/rc.d/rc.local
}

function limits_config(){ #修改打开的文件数
	sed -i "/^ulimit -SHn.*/d" /etc/rc.d/rc.local
	echo "ulimit -SHn 65536" >> /etc/rc.d/rc.local
	sed -i "/^ulimit -s.*/d" /etc/profile
	sed -i "/^ulimit -c.*/d" /etc/profile
	sed -i "/^ulimit -SHn.*/d" /etc/profile
	cat >> /etc/profile <<-'EOF'
	ulimit -c unlimited
	ulimit -s unlimited
	ulimit -SHn 65536
	EOF
	source /etc/profile
	ulimit -a
	cat /etc/profile | grep ulimit

	if [ ! -f "/etc/security/limits.conf.bak" ]; then
	    cp /etc/security/limits.conf /etc/security/limits.conf.bak
	fi

	cat > /etc/security/limits.conf <<-'EOF'
	* soft nofile 65536
	* hard nofile 65536
	* soft nproc  65536
	* hard nproc  65536
	hive   - nofile 65536
	hive   - nproc  65536
	EOF

	if [ ! -f "/etc/security/limits.d/20-nproc.conf.bak" ]; then
	    cp /etc/security/limits.d/20-nproc.conf /etc/security/limits.d/20-nproc.conf.`date +%Y%m%d_%S`bak
	fi

	cat > /etc/security/limits.d/20-nproc.conf <<-'EOF'
	*          soft    nproc     65536
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
	#echo "NETWORKING_IPV6=no">/etc/sysconfig/network
	echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
	echo 1 > /proc/sys/net/ipv6/conf/default/disable_ipv6
	# 禁用整个系统所有接口的IPv6
	echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
	sysctl -p /etc/sysctl.conf 
	# 禁用某一个指定接口的IPv6(例如：eth0, lo)
	# net.ipv6.conf.lo.disable_ipv6 = 1
	# net.ipv6.conf.eth0.disable_ipv6 = 1
}

function time_set(){ #设置时间同步
	yum -y install ntp
	service ntpd start
	chkconfig --level 35 ntpd on
	rm -f /etc/localtime
	cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

	cat <<-'EOF' > /etc/sysconfig/clock 
	ZONE="Asia/Shanghai"
	UTC=false
	ARC=false
	EOF

	cat <<-'EOF' > /etc/ntp.conf 
	server 128.138.140.44 prefer
	server 132.163.4.102
	server ntp.fudan.edu.cn
	server time-a.nist.gov
	server asia.pool.ntp.org
	driftfile /var/db/ntp.drift
	EOF

	ntpdate asia.pool.ntp.org >/dev/null 2>&1
	/sbin/hwclock --systohc
	echo '*/30 * * * *  root ntpdate asia.pool.ntp.org >/dev/null 2>&1' >> /etc/crontab
	service crond restart
	echo "时间同步成功！"
}

function kernel_update(){
	rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
	rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
	#rpm -Uvh http://www.elrepo.org/elrepo-release-6-8.el6.elrepo.noarch.rpm #6.8
	yum -y --enablerepo=elrepo-kernel install  kernel-ml-devel kernel-ml
	#grep 'title' /etc/grub.conf |awk '{print $3}' #6.8
	#sed -i 's/default=1/default=0/' /etc/grub.conf
	grub2-set-default 0
}

function optimized(){
	cat <<-'EOF'
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


if [ -f /etc/redhat-release ] && [ -n "`grep ' 7\.' /etc/redhat-release`" ] && [ $(id -u) = "0" ];then
	cat <<-'EOF'
	+---------------------------------------+
	|         Your system is CentOS 7       |
	|           start optimizing            |
	+---------------------------------------+
	EOF
	sleep 5
	init
	sleep 5
	#time_set
	limits_config
	sleep 5
	selinux_config
	sleep 5
	ipv6_config
	sleep 5
	#kernel_update
	sleep 5
	optimized
else
	echo "Not root privileges or centos7,the script will exit!"
	exit 1
fi
