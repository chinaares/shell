
#配置虚拟机
virt-install -n test-kvmbase -r 1024 --disk /home/KVM/test-kvmbase.img,size=8 --network bridge=br0 --os-type=linux --os-variant=rhel7 --cdrom /home/iso/CentOS-7-x86_64-Minimal-1611.iso --vnc --vncport=5910 --vnclisten=0.0.0.0


-r:设置内存大小
-n:设置虚机名称
--disk:设置虚机目录
size：设置硬盘大小
--network：设置网络模式（网桥模式）
--os-type:设置系统类型
--cdrom：指定镜像目录
--vnc：设置通过vnc查看虚拟机
--vncport:vnc连接端口
--vnclisten：vnc监听ip
--autostart：设置虚机开机自启
--vcpus：设置虚机cpu数量
