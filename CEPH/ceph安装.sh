第一步：
准备5台虚拟机,内核统一升级到4.13
192.168.199.200      docker-swarm=admin-node      (该主机用于管理，后续的ceph-deploy工具都在该主机上进行操作)
192.168.199.202      docker-node2=node1           (监控节点)
192.168.199.203      docker-node3=node2           (osd.0节点)
192.168.199.172      docker-node5=node3           (osd.1节点)
192.168.199.204      docker-node6=client-node     (客服端，主要利用它挂载ceph集群提供的存储进行测试)

第二步：
修改docker-swarm=admin-node节点/etc/hosts文件，增加一下内容
192.168.199.202  docker-node2 
192.168.199.203  docker-node3 
192.168.199.172  docker-node5
192.168.199.204  docker-node6
说明：ceph-deploy工具都是通过主机名与其他节点通信。修改主机名的命令为：【hostnamectl set-hostname "新的名字"】

每个节点安装依赖：
sudo yum install -y yum-plugin-priorities
sudo yum install *argparse* -y
sudo yum install -y yum-utils && sudo yum-config-manager --add-repo https://dl.fedoraproject.org/pub/epel/7/x86_64/ && sudo yum install --nogpgcheck -y epel-release && sudo rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7 && sudo rm /etc/yum.repos.d/dl.fedoraproject.org*

第三步：
分别为5台主机存储创建用户myceph:(给myceph用户添加root权限)
创建用户
adduser -d /home/myceph -m myceph
设置密码
echo '123456' | passwd --stdin myceph
 
设置root权限
echo "myceph ALL = (root) NOPASSWD:ALL"  |  tee /etc/sudoers.d/myceph
chmod 0440 /etc/sudoers.d/myceph

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
配置admin-node与其他节点ssh无密码root权限访问其它节点。
第一步：在admin-node主机上执行命令：
ssh-keygen -t rsa   #直接敲三次回城键即可

第二步：将第一步的key复制至其他节点
ssh-copy-id myceph@docker-node2
ssh-copy-id myceph@docker-node3
ssh-copy-id myceph@docker-node5
ssh-copy-id myceph@docker-node6

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
为admin-node节点安装ceph-deploy
第一步：增加ceph的yum配置文件
vim /etc/yum.repos.d/ceph.repo
添加以下内容：
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%官方仓库%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[Ceph]
name=Ceph packages for $basearch
baseurl=http://download.ceph.com/rpm-jewel/el7/$basearch
enabled=1
gpgcheck=1
type=rpm-md
gpgkey=https://download.ceph.com/keys/release.asc
priority=1

[Ceph-noarch]
name=Ceph noarch packages
baseurl=http://download.ceph.com/rpm-jewel/el7/noarch
enabled=1
gpgcheck=1
type=rpm-md
gpgkey=https://download.ceph.com/keys/release.asc
priority=1

[ceph-source]
name=Ceph source packages
baseurl=http://download.ceph.com/rpm-jewel/el7/SRPMS
enabled=1
gpgcheck=1
type=rpm-md
gpgkey=https://download.ceph.com/keys/release.asc
priority=1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%阿里云仓库%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[Ceph]
name=Ceph packages base
baseurl=http://mirrors.aliyun.com/ceph/rpm-jewel/el7/x86_64/
enabled=1
gpgcheck=1
type=rpm-md
gpgkey=http://mirrors.aliyun.com/ceph/keys/release.asc
priority=1

[Ceph-noarch]
name=Ceph noarch packages
baseurl=http://mirrors.aliyun.com/ceph/rpm-jewel/el7/noarch/
enabled=1
gpgcheck=1
type=rpm-md
gpgkey=http://mirrors.aliyun.com/ceph/keys/release.asc
priority=1

[ceph-source]
name=Ceph source packages
baseurl=http://mirrors.aliyun.com/ceph/rpm-jewel/el7/SRPMS/
enabled=1
gpgcheck=1
type=rpm-md
gpgkey=http://mirrors.aliyun.com/ceph/keys/release.asc
priority=1
#####################################################################
yum clean all
yum makecache

第二步：更新软件源并按照ceph-deploy，时间同步软件
yum -y update &&  yum -y install ceph-deploy 
每个节点安装时间服务
yum install ntp ntpupdate ntp-doc


4、关闭所有节点的防火墙以及安全选项(在所有节点上执行）以及其他一些步骤
systemctl stop firewall.service
systemctl stop iptables.service
setenforce 0


5、以前面创建的ceph用户在admin-node节点上创建目录
mkdir -p /home/myceph/my-cluster
cd /home/myceph/my-cluster

6、创建集群
 
第一步：执行以下命令创建以docker-node2为监控节点的集群。
ceph-deploy new docker-node2

把 Ceph.conf配置文件里的默认副本数从 3 改成 2 ，这样只有两个 OSD 也可以达到 active + clean 状态。把下面这行加入 [global] 段：
osd pool default size = 2
 
第二步：利用ceph-deploy为节点安装ceph
ceph-deploy install docker-swarm docker-node2 docker-node3 docker-node5 docker-node6
yum -y install ceph ceph-radosgw
第三步：初始化监控节点并收集keyring：
ceph-deploy mon create-initial


在osd节点服务器添加一块10G硬盘，不分区

查看新添加的硬盘信息
ceph-deploy disk list pxe-node4
用ceph-deploy在执行一次，删除分区操作
ceph-deploy disk zap pxe-node4:sdb
创建osd节点
ceph-deploy --overwrite-conf osd create pxe-node4:/dev/sdb

把管理节点的ceph.conf和ceph.client.admin.keyring文件发送到集群各个节点
ceph-deploy admin pxe-node1 pxe-node2 pxe-node3 pxe-node4

如果节点有了ceph.conf，就要用下面命令，覆盖方式发送，只发送ceph.conf！
ceph-deploy --overwrite config push pxe-node1 pxe-node2 pxe-node3 pxe-node4

df 查看挂载信息
文件系统                   1K-块    已用     可用 已用% 挂载点
devtmpfs                  484612       0   484612    0% /dev
tmpfs                     497032       0   497032    0% /dev/shm
tmpfs                     497032    6800   490232    2% /run
tmpfs                     497032       0   497032    0% /sys/fs/cgroup
/dev/mapper/centos-root 18307072 2209820 16097252   13% /
/dev/sda1                 508588  190472   318116   38% /boot
tmpfs                      99408       0    99408    0% /run/user/0
/dev/sdb1                5231596   34836  5196760    1% /var/lib/ceph/osd/ceph-1

可以看到/dev/sdb1挂载目录是/var/lib/ceph/osd/ceph-1

监控集群状态
ceph -w





添加元数据服务器
ceph-deploy mds create docker-node3

用全新一台服务器当做ceph-client服务器，使用ceph管理节点安装，这里我用docker-node6当做ceph客户端
在管理节点上，通过 ceph-deploy 把 Ceph 安装到 ceph-client 节点。
ceph-deploy install docker-node6

在管理节点上，用 ceph-deploy 把 Ceph 配置文件和 ceph.client.admin.keyring 拷贝到 ceph-client 。
ceph-deploy admin ceph-client
（ceph-deploy 工具会把密钥环复制到 /etc/ceph 目录，要确保此密钥环文件有读权限 sudo chmod +r /etc/ceph/ceph.client.admin.keyring）

配置块设备
在 ceph-client 节点上创建一个块设备 image 。
rbd create foo --size 4096

块设备在map时会报错，去掉一些选项
sudo rbd feature disable foo exclusive-lock, object-map, fast-diff, deep-flatten

在 ceph-client 节点上，把 image 映射为块设备。
sudo rbd map foo --name client.admin

在 ceph-client 节点上，创建文件系统后就可以使用块设备了。
sudo mkfs.ext4 -m0 /dev/rbd/rbd/foo

在 ceph-client 节点上挂载此文件系统。
sudo mkdir /mnt/ceph-block-device
sudo mount /dev/rbd/rbd/foo /mnt/ceph-block-device
cd /mnt/ceph-block-device

此时就可以上传数据什么的了，可以df -h  看看挂在情况