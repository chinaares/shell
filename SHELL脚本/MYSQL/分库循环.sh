#!/bin/bash
#全量备份，分库循环备份
MYSQL_U="root"     #用户
MYSQL_P="123456"   #密码
MYSQL_CMD="mysql -u${MYSQL_U} -p${MYSQL_P}"
MYSQL_DUMP="mysqldump -u${MYSQL_U} -p${MYSQL_P}"
BACKUP_PATH=/data/backup/$(date +%F)
if [ ! d ${BACKUP_PATH} ]
then
	mkdir -p ${BACKUP_PATH}
else 
	echo This is $BAKDIR exists....
fi
for database in `${MYSQL_CMD} -e "show databases;"|sed '1,2d'|egrep -v "mysql|schema"`   #在mysql库中读取当前有多少个数据库，即使新增也能备份到，sed删除第一行和第二行和egrep是过滤掉带schema的系统数据库
do
	${MYSQL_DUMP} ${database} | gzip  >  ${BACKUP_PATH}/${database}.sql.gz
done
[ $? -eq 0 ] && echo "MySQL BACKUP is SUCCESS"
find ${BACKUP_path} -type d  -mtime +30 |xargs rm -rf