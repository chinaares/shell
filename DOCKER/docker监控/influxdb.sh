
#安装influxdata
wget https://dl.influxdata.com/influxdb/releases/influxdb-1.3.6.x86_64.rpm
sudo yum localinstall influxdb-1.3.6.x86_64.rpm

curl -i -XPOST 'http://10.10.10.103:8086/query?db=mydb' --data-urlencode "q=SELECT * FROM cpu ORDER BY time DESC LIMIT 3"


show measurements

SELECT value FROM rx_bytes WHERE container_name='cadvisor' and time < 1508142044661096831

show users ; 显示用户
create user “username” with password ‘password’ 创建用户
create user “username” with password ‘password’ with all privileges 创建管理员权限的用户
drop user ‘username’ 删除用户
SET PASSWORD FOR admin =’influx@gpscloud’



create user "ca_user" with password 'ca_password'
CREATE USER "cadvisor" WITH PASSWORD 'cadvisor'
grant all privileges on cadvisor to cadvisor

grant WRITE on cadvisor to cadvisor
grant READ on cadvisor to cadvisor