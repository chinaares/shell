Scout和Datadog提供集中监控和报警系统，然而他们都是被托管的服务，大规模部署的话成本会很突出。

如果你需要一个自托管、集中指标的服务，你可以考虑sensu open source monitoring framework。

要运行Sensu服务器可以使用hiroakis/docker-sensu-server容器。

这个容器会安装sensu-server、uchiwa Web界面、Redis、rabbitmq-server以及sensu-api。不幸的是sensu不支持Docker。

但是，使用插件系统，您可以配置支持容器指标以及状态检查。



在开启sensu服务容器之前，你必须定义一个可以加载到服务器中检查。创建一个名为check-docker.json的文件并添加以下内容到此文件，这个文件是通过数据卷挂载到容器中。这个文件告诉Sensu服务器在所有有docker标签的客户端上每十秒运行一个名为load-docker-metrics.sh的脚本。

vim check-docker.json
	{
	"checks": {
	"load_docker_metrics": {
	  "type": "metric",
	  "command": "load-docker-metrics.sh",
	  "subscribers": [
	    "docker"
	  ],
	  "interval": 10
	}
	}
	}
运行这个监控容器
docker run -d --name sensu-server -p 3000:3000 -p 4567:4567 -p 5671:5671 -p 15672:15672 -v /root/check-docker.json:/etc/sensu/conf.d/check-docker.json hiroakis/docker-sensu-server

现在，您可以使用上面的命令通过我们的检查配置文件来运行Sensu服务器Docker容器。

一旦你运行该命令，你就可以在浏览器输入http://YOUR_SERVER_IP:3000来访问uchiwa界面。

这样Sensu服务器就开启了，你就可以对每个运行有我们的Docker容器的主机上开启sensu客户端。你告诉容器将有一个名为load-docker-metrics.sh的脚本，所以让我们创建脚本，并将其放到我们的客户端容器内。创建该文件并添加如下所示的文本，将HOST_NAME替换为您的主机的逻辑名称。下面的脚本是为运行容器、所有容器以及镜像而使用Docker远程API来拉取元数据。然后它打印出来sensu的键值标示的值。该sensu服务器将读取标准输出并收集这些指标。这个例子只拉取这三个值，但根据需要，你可以使脚本尽可能详细。请注意，你也可以添加多个检查脚本，如thos，只要早前在服务配置文件中你引用过它们。你也可以定义你想要检查运行Docker容器数量降至三个以下的失败。你还可以使检查通过从检查脚本返回一个非零值失败。

yum -y install nc
vim load-docker-metrics.sh
#!/bin/bash
set -e

# Count all running containers
running_containers=$(echo -e "GET /containers/json HTTP/1.0\r\n"|nc -U /var/run/docker.sock|tail -n 1|python -m json.tool|grep \"Id\"|wc -l)
# Count all containers
total_containers=$(echo -e "GET /containers/json?all=1 HTTP/1.0\r\n"|nc -U /var/run/docker.sock|tail -n 1|python -m json.tool|grep \"Id\"|wc -l)

# Count all images
total_images=$(echo -e "GET /images/json HTTP/1.0\r\n"|nc -U /var/run/docker.sock	|tail -n 1|python -m json.tool|grep \"Id\"|wc -l)

echo "docker.$HOSTNAME.running_containers ${running_containers}"
echo "docker.$HOSTNAME.total_containers ${total_containers}"
echo "docker.$HOSTNAME.total_images ${total_images}"

if [ ${running_containers} -lt 3 ]; then
exit 1;
fi

现在你已经定义了Docker载入指标检查，那就需要使用usman/sensu-client容器来启动sensu客户端。您可以使用如下所示的命令启动sensu客户端。需要注意的是，容器必须以privileged来运行以便能够访问Unix sockets，它必须有Docker socket挂载以及你上面定义的load-docker-metrics.sh脚本。确保load-docker-metrics.sh脚本在你的主机的权限标记为可执行。

容器也需要将
SENSU_SERVER_IP、
RABIT_MQ_USER、
RABIT_MQ_PASSWORD、
CLIENT_NAME、
CLIENT_IP
作为参数，请指定这些参数到您设置的值。其中RABIT_MQ_USER与RABIT_MQ_PASSWORD默认值是sensu和password。

docker pull usman/sensu-client

docker run -d --name sensu-client --privileged \
-v /root/load-docker-metrics.sh:/etc/sensu/plugins/load-docker-metrics.sh  \
-v /var/run/docker.sock:/var/run/docker.sock \
usman/sensu-client 10.10.10.102 sensu password IP_100 10.10.10.100