#!/bin/bash

#PXE批量安装
#Client向PXE Server上的DHCP发送IP地址请求消息，DHCP检测Client是否合法（主要是检测Client的网卡MAC地址），如果合法则返回Client的IP地址，同时将启动文件pxelinux.0的位置信息一并传送给Client
#Client向PXE Server上的TFTP发送获取pxelinux.0请求消息， TFTP接收到消息之后再向Client发送pxelinux.0大小信息，试探Client是否满意，当TFTP收到Client发回的同意大小信息之后，正式向Client发送pxelinux.0
#Client执行接收到的pxelinux.0文件
#Client向TFTP Server发送针对本机的配置信息文件（在TFTP 服务的pxelinux.cfg目录下）， TFTP将配置文件发回Client，继而Client根据配置文件执行后续操作
#Client向TFTP发送Linux内核请求信息， TFTP接收到消息之后将内核文件发送给Client
#Client向TFTP发送根文件请求信息， TFTP接收到消息之后返回Linux根文件系统
#Client启动Linux内核
#Client下载安装源文件，读取自动化安装脚本


yum -y install dhcp tftp httpd
#添加dhcp配置
vim /etc/dhcp/dhcpd.conf
	subnet 192.168.199.0 netmask 255.255.255.0 {                #--> 定义网段
	  range 192.168.199.10 192.168.196.40;                      #--> 定义分配IP范围
	  option routers 192.168.199.1;                             #--> 配置路由
	  filename "pxelinux.0";                                    #--> 启动文件名称
	  next-server 192.168.199.201;                              #--> dhcp服务器地址                           
	}
#################################################
systemctl enable dhcpd
systemctl start dhcpd

systemctl start httpd

#修改tftp配置，默认是禁止，改为启动
vim /etc/xinetd.d/tftp
	disable         = yes
	#yes  改为  no
#################################################
systemctl enable tftpd.socket
systemctl enable tftpd
systemctl start tftpd
systemctl start tftpd.socket


#复制客户机启动的引导和内核
mkdir /var/www/html/{centos7,ks}
mkdir /var/lib/tftpboot/pxelinux.cfg
cp /var/www/html/centos7/isolinux/isolinux.cfg  pxelinux.cfg/default
cp /usr/share/syslinux/menu.c32 /usr/share/syslinux/pxelinux.0  ./
cp /var/www/html/centos7/isolinux/vmlinuz /var/www/html/centos7/isolinux/initrd.img ./

#修改启动菜单
vim /var/lib/tftpboot/pxelinux.cfg/default

	default menu.c32
	timeout 600
	menu title PXE CentOS Linux 7 Install Menu

	label linux
	  menu label ^Auto-install CentOS Linux 7
	  menu default
	  kernel vmlinuz
	  append initrd=initrd.img ks=http://192.168.199.201/ks/ks.cfg      

	label local
	  menu label Boot from ^local drive
	  localboot 0xffff
#################################################################