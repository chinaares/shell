jboss7.1.1 + apache2.4+mod_cluster

��mod_cluster��������mod_cluster���
http://mod-cluster.jboss.org/mod_cluster/downloads/1-2-0-Final

���������ص�1.2.0Final�汾
�������ص�ַ���£�
http://downloads.jboss.org/mod_cluster//1.2.0.Final/mod_cluster-1.2.0.Final-hpux-parisc2-ssl.tar.gz
�����������Ǽ�����Apache��mod_cluster�ģ�����Apache�������Ͳ��õ�����װApache�������ǰ�Ͱ�װ��Apache����ж�ص�����Ȼ�ᱨ��
������

10.10.10.100  Apache+mod_cluster

10.10.10.102  jboss7������

10.10.10.103  jboss7������


jboss����װ�Ͳ���˵��

1��Apache��������

#��ѹ����Ŀ¼��
tar zxf mod_cluster-1.2.0.Final-linux2-x64-ssl.tar.gz /
cd /opt/jboss/httpd/httpd/
vim conf/httpd.conf
���������޸�
Listen 80 #ȷ��������80�˿�
#ServerName www.example.com:80  ȥ��ע�ͷ�������Ϊ��ǰApache��IP:80
�������ļ��������һ����mod_cluster������
# MOD_CLUSTER_ADDS
# Adjust to you hostname and subnet.
<IfModule manager_module>
  Listen 10.10.10.100:5555  #����ĳɵ�ǰApache��IP
  ManagerBalancerName mycluster
  <VirtualHost 10.10.10.100:5555> #ͬ��
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
����Apache����
/opt/jboss/httpd/sbin/apachectl start
ps -ef |grep httpd  #�鿴��������û��

jboss������

jboss��װ·��Ϊ��/usr/local/jboss-as-7

cd /usr/local/jboss-as-7/standalone/configuration

��Ĭ�ϵ�standalone.xml�����ݣ�
mv standalone.xml standalone.xml.bak
copyһ��full-ha�������ļ���������Ϊstandalone.xml
cp standalone-full-ha.xml standalone.xml
vim standalone.xml
�ҵ�
<server xmlns="urn:jboss:domain:1.2">
��Ϊ��
<server name="node03" xmlns="urn:jboss:domain:1.2">
�ҵ�
<subsystem xmlns="urn:jboss:domain:web:1.1" default-virtual-server="default-host" native="false">
��Ϊ��
<subsystem xmlns="urn:jboss:domain:web:1.1" default-virtual-server="default-host" native="false" instance-id="${jboss.node.name}">

�ҵ�
<mod-cluster-config advertise-socket="modcluster">
��Ϊ��
<mod-cluster-config advertise-socket="modcluster" proxy-list="10.10.10.100:5555">
����Ĵ����ַ������Apache�ĵ�ַһ��

�������ļ������е� 127.0.0.1��ַ��Ϊ��ǰjboss�������ĵ�ַ����������������ļ��иģ�Ҳ�����������ű��󣬸���������:
sh /usr/local/jboss-as-7/bin/standalone.sh -b 10.10.10.102 -bmanagement 10.10.10.102
-b ָ���󶨵�ip��ַ
-bmanagement ָ����̨�󶨵�IP��ַ











