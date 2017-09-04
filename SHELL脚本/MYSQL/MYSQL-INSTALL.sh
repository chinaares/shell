#!/bin/bash
if [ ! -n `rpm -qa | grep mysql* | head -1` ];then
	echo '下载安装mysql-community-release-el7-5.noarch.rpm包'
	#安装这个包后，会获得两个mysql的yum repo源：/etc/yum.repos.d/mysql-community.repo，/etc/yum.repos.d/mysql-community-source.repo。
	rpm -Uvh http://repo.mysql.com/mysql-community-release-el7-5.noarch.rpm
	echo '安装mysql'
	yum -y install mysql-server mysql mysql-devel
	chown -R root:root /var/lib/mysql
	service mysqld restart
	mysql -uroot mysql -e "update user set password=password('123456') where user='root'"
	service mysqld restart
else
	echo '卸载自带mysql'
	yum -y remove mysql*
fi