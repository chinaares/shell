#!/bin/sh 
#auto backup mysql 
#wugk  2015-12-2 
#Define PATH定义变量
BAKDIR=/data/backup/mysql/`date +%Y-%m-%d` 
MYSQLDB="sns_db" 
MYSQLPW="123passwd" 
MYSQLUSR="root" 
#must use root user run scripts 必须使用root用户运行，$UID为系统变量
if [ $UID -ne 0 ] #UID不等于0时
then 
   echo This script must use the root user ! ! ! 
   sleep 2 
   exit 0 
fi 
#Define DIR and mkdir DIR 判断目录是否存在，不存在则新建
if [ ! -d $BAKDIR ]
then 
   mkdir -p $BAKDIR 
else 
   echo This is $BAKDIR exists.... 
fi 
#Use mysqldump backup mysql 使用mysqldump备份数据库,which 一下mysqldump的运行目录，如果不是在/usr/bin下，就要改下
/usr/bin/mysqldump -u$MYSQLUSR -p$MYSQLPW -d $MYSQLDB >$BAKDIR/$MYSQLDB.sql 
cd $BAKDIR
tar -czf  $MYSQLDB.tar.gz *.sql 
#查找备份目录下以.sql结尾的文件并删除
find . -type f -name "*.sql" | xargs rm -rf
#如何数据库备份成功，则打印成功，并删除备份目录30天以前的目录
[ $? -eq 0 ] && echo "This `date +%Y-%m-%d` MySQL BACKUP is SUCCESS"
cd /data/backup/mysql/
find . -type d  -mtime +30 |xargs rm -rf
echo "The mysql backup successfully"