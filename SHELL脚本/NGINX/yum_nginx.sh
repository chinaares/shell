centos7系统库中默认是没有nginx的rpm包的，所以我们自己需要先更新下rpm依赖库
(1)使用yum安装nginx需要包括Nginx的库，安装Nginx的库
rpm -Uvh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm

(2)使用下面命令安装nginx
yum install nginx

(3)启动Nginx
service nginx start
或
systemctl start nginx.service