#!/bin/bash
#分库分表备份数据库
MYSQL_U="root"
MYSQL_P="123456"
MYSQL_CMD="mysql -u${MYSQL_U} -p${MYSQL_P}"
MYSQL_DUMP="mysqldump -u${MYSQL_U} -p${MYSQL_P}"
BACKUP_PATH=/data/backup/$(date +%F)


for database in `${MYSQL_CMD} -e "show databases;"|sed '1,2d'|egrep -v "mysql|schema"`
do
	if [ ! -d ${BACKUP_PATH}/${database} ]
	then
		mkdir -p ${BACKUP_PATH}/${database}
	else 
		echo This is $BAKDIR exists....
	fi
	for table in  `${MYSQL_CMD} -e "show tables from ${database};"|sed '1d'`
		do
			
			${MYSQL_DUMP} ${database} ${tables} | gzip  >  ${BACKUP_PATH}/${database}/${table}.sql.gz 
		done
done
[ $? -eq 0 ] && echo "MySQL BACKUP is SUCCESS"
find ${BACKUP_path} -type d  -mtime +30 |xargs rm -rf