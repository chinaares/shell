TC 无需安装,Linux 内核自带
例:将vpn IP地址段192.168.1.0/24 上传下载限速为 5M
将以下内容添加到/etc/ppp/ip-up文件exit 0上面。

down=5Mbit
upload=5Mbit
iprange=192.168.1.0/24
#down
/sbin/tc qdisc add dev $1 root handle 2:0 htb
/sbin/tc class add dev $1 parent 2:1 classid 2:10 htb rate $down
/sbin/tc class add dev $1 parent 2:2 classid 2:11 htb rate 1024kbps
/sbin/tc qdisc add dev $1 parent 2:10 handle 1: sfq perturb 1
/sbin/tc filter add  dev $1 protocol ip parent 2:0  u32 match ip dst 192.168.1.0/24  flowid 2:10
#upload
/sbin/tc qdisc add dev $1 handle ffff: ingress
/sbin/tc filter add dev $1 parent ffff: protocol ip  u32 match ip dst \
   $iprange police  rate $upload burst 100k drop flowid 2:11

说明:$1为网络设备接口名称,如ppp0,ppp1......
       第4行建立qdisc队列
       第5行建立类,限速5M
       第7行为了不使一个会话永占带宽,添加随机公平队列sfq
       第8行建立过滤器规则,对192.168.1.0/24下载限速为5M
       第10-12行限制192.168.1.0/24上传限速为5M

删除所有 TC 限速规则
    # tc qdisc del dev ppp0 root

显示qdisc队列状态
    # tc -s -d qdisc show dev ppp0

显示class类状态
    # tc -s -d class show dev ppp0
 
显示filter规则状态
    # tc -s -d filter show dev ppp0