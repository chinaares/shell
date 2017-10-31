wget https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana-4.5.2-1.x86_64.rpm 
sudo yum  localinstall grafana-4.5.2-1.x86_64.rpm 

vim /etc/yum.repos.d/grafana.repo
[grafana]
name=grafana
baseurl=https://packagecloud.io/grafana/stable/el/6/$basearch
repo_gpgcheck=1
enabled=1
gpgcheck=1
gpgkey=https://packagecloud.io/gpg.key https://grafanarel.s3.amazonaws.com/RPM-GPG-KEY-grafana
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt




#运行grafana，且influxdb不是docker运行
docker run -d \
  -p 3000:3000 \
  -e INFLUXDB_HOST=10.10.10.103 \
  -e INFLUXDB_PORT=8086 \
  -e INFLUXDB_NAME=cadvisor \
  -e INFLUXDB_USER=cadvisor \
  -e INFLUXDB_PASS=cadvisor \
  --name=grafana \
  grafana/grafana

#运行grafana，且influxdb是docker运行
docker run -d \
  -p 3000:3000 \
  -e INFLUXDB_HOST=locaol \
  -e INFLUXDB_PORT=8086 \
  -e INFLUXDB_NAME=cadvisor \
  -e INFLUXDB_USER=cadvisor \
  -e INFLUXDB_PASS=cadvisor \
  --link influxsrv:influxsrv \
  --name grafana \
  grafana/grafana



cpu 查询：
SELECT derivative(mean("value"), 10s) FROM "cpu_usage_total" WHERE container_name='cadvisor' AND $timeFilter GROUP BY time($interval), container_name fill(previous)
 
网络 i/o 查询：
tx：
SELECT derivative(mean("value"), 10s) FROM "tx_bytes" WHERE container_name='cadvisor' AND $timeFilter GROUP BY time($interval), container_name fill(previous)

AND time >= '1508142041734726174' AND time <= '1508142042766035620'

rx：
SELECT derivative(mean("value"), 10s) FROM "rx_bytes" WHERE container_name='cadvisor' AND $timeFilter GROUP BY time($interval), container_name fill(previous)
 
文件系统使用及limit：
fs
SELECT mean("value") FROM "fs_usage" WHERE container_name='cadvisor' AND container_name='cadvisor' AND $timeFilter GROUP BY time($interval), "container_name" fill(previous)
limit
SELECT mean("value") FROM "fs_limit" WHERE container_name='cadvisor'  AND $timeFilter GROUP BY time($interval), "container_name" fill(previous)