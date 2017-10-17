#swarm方式安装
docker service create \
--mode global \
--network monitoring \
--mount type=bind,src=/,dst=/rootfs:ro \
--mount type=bind,src=/var/run,dst=/var/run:rw \
--mount type=bind,src=/sys,dst=/sys:ro \
--mount type=bind,src=/var/lib/docker/,dst=/var/lib/docker:ro \
--publish 8090:8080  \
--name cadvisor \
google/cadvisor:latest


#单节点安装，且influxdb不是用docker安装
docker run \
--volume=/:/rootfs:ro \
--volume=/var/run:/var/run:rw \
--volume=/sys:/sys:ro \
--volume=/var/lib/docker/:/var/lib/docker:ro \
-p 8080:8080 \
--detach=true \
--name=cadvisor \
google/cadvisor:latest \
-storage_driver=influxdb \
-storage_driver_db=cadvisor \
-storage_driver_host=10.10.10.103:8086

#单节点安装，且influxdb是用docker安装
docker run \
--volume=/:/rootfs:ro \
--volume=/var/run:/var/run:rw \
--volume=/sys:/sys:ro \
--volume=/var/lib/docker/:/var/lib/docker:ro \
-p 8080:8080 \
--detach=true \
--link influxsrv:influxsrv \
--name=cadvisor \
google/cadvisor:latest \
-storage_driver=influxdb \
-storage_driver_db=cadvisor \
-storage_driver_host=influxsrv:8086