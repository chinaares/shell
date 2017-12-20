#1.下载mysql的repo源
mkdir /app && cd /app
#wget http://repo.mysql.com/mysql-community-release-el7-5.noarch.rpm
wget https://repo.mysql.com//mysql57-community-release-el7-11.noarch.rpm

#2.安装mysql57-community-release-el7-11.noarch.rpm包

rpm -ivh mysql57-community-release-el7-11.noarch.rpm
#安装这个包后，会获得两个mysql的yum repo源：/etc/yum.repos.d/mysql-community.repo，/etc/yum.repos.d/mysql-community-source.repo。

#3.安装mysql
yum install mysql-server mysql mysql-devel

#根据提示安装就可以了,不过安装完成后没有密码,需要重置密码

#4.重置mysql密码 mysql -u root

#登录时有可能报这样的错：ERROR 2002 (HY000): Can‘t connect to local MySQL server through socket ‘/var/lib/mysql/mysql.sock‘ (2)，原因是/var/lib/mysql的访问权限问题。下面的命令把/var/lib/mysql的拥有者改为当前用户：

chown -R root:root /var/lib/mysql

#重启mysql服务

service mysqld restart

#接下来登录重置密码：
mysql -uroot mysql -e "update user set password=password('123456') where user='root'"
#mysql -u root  
# mysql > use mysql;
# mysql > update user set password=password('123456') where user='root';
# mysql > exit;