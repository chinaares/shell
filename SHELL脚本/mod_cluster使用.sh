jboss7.1.1 + apache2.4+mod_cluster

在mod_cluster官网下载mod_cluster软件
http://mod-cluster.jboss.org/mod_cluster/downloads/1-2-0-Final

我这里下载的1.2.0Final版本
具体下载地址如下：
http://downloads.jboss.org/mod_cluster//1.2.0.Final/mod_cluster-1.2.0.Final-hpux-parisc2-ssl.tar.gz
这个软件包，是集成了Apache和mod_cluster的，所以Apache服务器就不用单独安装Apache，如果提前就安装了Apache，请卸载掉！不然会报错
环境：

10.10.10.100  Apache+mod_cluster

10.10.10.102  jboss7服务器

10.10.10.103  jboss7服务器


jboss服务安装就不用说了

1、Apache服务器中

#解压到根目录下
tar zxf mod_cluster-1.2.0.Final-linux2-x64-ssl.tar.gz /
cd /opt/jboss/httpd/httpd/
vim conf/httpd.conf
按照如下修改
Listen 80 #确保监听在80端口
#ServerName www.example.com:80  去掉注释符，并改为当前Apache的IP:80
在配置文件的最后，有一段是mod_cluster的配置
# MOD_CLUSTER_ADDS
# Adjust to you hostname and subnet.
<IfModule manager_module>
  Listen 10.10.10.100:5555  #这里改成当前Apache的IP
  ManagerBalancerName mycluster
  <VirtualHost 10.10.10.100:5555> #同上
    <Location />
     Order deny,allow
     #Deny from all
     Allow from all
    </Location>
    KeepAliveTimeout 300
    MaxKeepAliveRequests 0
    #ServerAdvertise on http://@IP@:6666
    AdvertiseFrequency 5
    #AdvertiseSecurityKey secret
    #AdvertiseGroup 224.0.1.105:23364  
    EnableMCPMReceive
    <Location /mod_cluster_manager>
       SetHandler mod_cluster-manager
       Order deny,allow
       #Deny from all
       Allow from all
    </Location>
  </VirtualHost>
</IfModule>
启动Apache服务
/opt/jboss/httpd/sbin/apachectl start
ps -ef |grep httpd  #查看服务启动没有

jboss中配置

jboss安装路径为：/usr/local/jboss-as-7

cd /usr/local/jboss-as-7/standalone/configuration

把默认的standalone.xml，备份，
mv standalone.xml standalone.xml.bak
copy一份full-ha的配置文件，重命名为standalone.xml
cp standalone-full-ha.xml standalone.xml
vim standalone.xml
找到
<server xmlns="urn:jboss:domain:1.2">
改为：
<server name="node03" xmlns="urn:jboss:domain:1.2">
找到
<subsystem xmlns="urn:jboss:domain:web:1.1" default-virtual-server="default-host" native="false">
改为：
<subsystem xmlns="urn:jboss:domain:web:1.1" default-virtual-server="default-host" native="false" instance-id="${jboss.node.name}">

找到
<mod-cluster-config advertise-socket="modcluster">
改为：
<mod-cluster-config advertise-socket="modcluster" proxy-list="10.10.10.100:5555">
这里的代理地址必须是Apache的地址一样

把配置文件中所有的 127.0.0.1地址改为当前jboss服务器的地址，如果不想在配置文件中改，也可以在启动脚本后，跟参数如下:
sh /usr/local/jboss-as-7/bin/standalone.sh -b 10.10.10.102 -bmanagement 10.10.10.102
-b 指定绑定的ip地址
-bmanagement 指定后台绑定的IP地址











