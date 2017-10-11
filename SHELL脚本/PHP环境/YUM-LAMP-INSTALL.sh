#!/bin/bash

if [[ `whoami` = "root" && `cat /etc/redhat-release | awk -F "release" '{print $2}' |awk -F "." '{print $1}' |sed 's/ //g'` = "7" && `uname -i` = "x86_64" ]];then
	echo '开始安装LAMP'
	yum -y install epel-release
	yum -y remove php.x86_64 php-cli.x86_64 php-common.x86_64 php-gd.x86_64 php-ldap.x86_64 php-mbstring.x86_64 php-mcrypt.x86_64 php-MySQL.x86_64 php-pdo.x86_64
	rpm -Uvh https://mirror.webtatic.com/yum/el7/epel-release.rpm
	rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm
	#mysql的安装源
	rpm -Uvh http://repo.mysql.com/mysql-community-release-el7-5.noarch.rpm
	yum -y install php70w php70w-mysql php70w-mbstring php70w-gd  php70w-mcrypt php70w-ldap mysql-server mysql mysql-devel
	chown -R root:root /var/lib/mysql
	service mysqld restart
	mysql -uroot mysql -e "update user set password=password('123456') where user='root'"
	service httpd restart
else 
	echo "Not root privileges or centos7,the script will exit!"
	exit 1
fi





