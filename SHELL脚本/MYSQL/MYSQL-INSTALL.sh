#!/bin/bash
#安装mysql5.7
if [ -z `rpm -qa | grep mysql | head -1` ];then #-z 表示空
	echo '下载安装mysql57-community-release-el7-11.noarch.rpm包'
	#安装这个包后，会获得两个mysql的yum repo源：/etc/yum.repos.d/mysql-community.repo，/etc/yum.repos.d/mysql-community-source.repo。
	#rpm -Uvh http://repo.mysql.com/mysql-community-release-el7-5.noarch.rpm
	rpm -Uvh https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm
	echo '安装mysql5.7'
	yum -y install mysql-server mysql mysql-devel
	#chown -R root:root /var/lib/mysql
	echo 'skip-grant-tables' >> /etc/my.cnf
	service mysqld restart
	#mysql -uroot mysql -e "update user set password=password('123456') where user='root'" 5.6密码还是password
	mysql -uroot mysql -e "update user set authentication_string = password('123456'), password_expired = 'N', password_last_changed = now() where user = 'root'"
	sed -i 's/skip-grant-tables/#skip-grant-tables/' /etc/my.cnf
	service mysqld restart
	echo 'mysql5.7用户root，密码123456'
else
	echo '卸载自带mysql'
	for i in `rpm -qa | grep mysql`;
	do	
		yum -y remove $i
		
	done
fi