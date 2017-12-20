#管理主机ip地址
#互相之间端口开放
#集群管理节点需要使用tcp 2377端口
#普通节点通讯使用tcp 和udp的7946端口
#覆盖型网络流量端口tcp和udp的4789,50端口

docker search swarm

docker pull swarm

#初始化swarm
docker swarm init --listen-addr 10.10.10.103
docker swarm init --advertise-addr 10.10.10.103
	
#加入一个swarm集群
docker swarm join     --token SWMTKN-1-0ux8b4mzhxupnt3f0vguxrzq3uv8h64k3ltyxke9guaiycwa4y-8puwxggswkie3j6a9h5mc1ia6     10.10.10.103:2377

查看加入manager的token
docker swarm join-token manager

#把此节点作为manager
docker swarm join     --token SWMTKN-1-0ux8b4mzhxupnt3f0vguxrzq3uv8h64k3ltyxke9guaiycwa4y-7etyifgr19vwsgkh5tfqo2d7t     10.10.10.103:2377


#把manager降级为work节点(manager必须先降为work，才能删除)
docker node demote ovpf1u9pf9f8819fyana416s7    
docker node rm ovpf1u9pf9f8819fyana416s7

#查看群节点info
docker node ls 
			ID                            HOSTNAME            STATUS              AVAILABILITY        MANAGER STATUS
		lwd9l5m4n57iewcbywlbqpniv     	docker-node1		  Ready               Active              
		ovpf1u9pf9f8819fyana416s7     	jenkins-swarm     	  Ready               drain              
		u3bvqc7v209c66sybdrphiy9y *   	dcoker-node2      	  Ready               Active              Leader

#设置manager：jenkins-swarm   不参与调度（drain：不参与，Active：参与，pause：暂停）
docker node update --availability drain jenkins-swarm

#设置node的标签，标签名为：foo，类似于别名概念
docker node update --label-add foo docker-node1
#类似于归类的概念
docker node update --label-add type=queue docker-node1   #这里定义的tpye=queue 后面在create限制条件使用[--constraint 'node.labels.type=queue']
#新创建overlay网络，名为：nginx_network
docker network create --driver overlay nginx_network
dcoker network ls
		NETWORK ID          NAME                DRIVER              SCOPE
		42e899374349        bridge              bridge              local
		42285c3fa048        docker_gwbridge     bridge              local
		415c466735eb        host                host                local
		q8g896jsngwi        ingress             overlay             swarm  #内置的
		r1t6i4ovtqi3        nginx_network       overlay             swarm  #新建的
		e325d34ce8cf        none                null                local

	
docker service create --detach=false --constraint 'node.labels.type=queue' --replicas 2 --network nginx_network --name web-nginx -p 8080:80 nginx:latest
--detach=false	：默认添加
--constraint 'node.labels.type==Web' ：选择特定node便签来调度
--replicas 1	：设置调度的任务量，启动几个容器,副本
--network nginx_network	：设置网络环境
--name web-nginx	：设置容器名
-p 8080:80	：设置端口映射宿主机8080端口映射到容器80端口
nginx:latest	：选择启动的docker镜像
--mount type=volume,src=<VOLUME-NAME>,dst=<CONTAINER-PATH>,volume-driver=<DRIVER>,volume-opt=<KEY0>=<VALUE0>,volume-opt=<KEY1>=<VALUE1>#挂载到数据卷上
--mount type=bind,src=<VOLUME-NAME>,dst=<CONTAINER-PATH> #挂载到宿主机上


docker service ps <容器名>

--constraint 参数
node.id	节点ID	node.id == 2ivku8v2gvtg4
node.hostname	节点主机名	node.hostname！= node-2
node.role	节点角色	node.role == manager
node.labels	用户定义的节点标签	node.labels.security == high
engine.labels	Docker Engine的标签	engine.labels.operatingsystem == ubuntu 14.04 或 node.labels.type==Web（type类）


