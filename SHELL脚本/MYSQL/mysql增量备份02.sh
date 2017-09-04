#!/bin/bash
##每个星期日凌晨3:00执行完全备份脚本
#   0 3 * * 0 /bin/sh -x /root/Mysql-FullyBak.sh >/dev/null 2>&1
#周一到周六凌晨3:00做增量备份
#   0 3 * * 1-6 /bin/sh -x /root/Mysql-DailyBak.sh >/dev/null 2>&1
#
BakDir=/data/backup/daily  #增量备份时复制mysql-bin.00000*的目标目录，提前手动创建这个目录
if [ ! -d ${BakDir} ]
then
	mkdir -p ${BakDir}
else
	echo This is ${BakDir} exists.... 
fi
BinDir=/usr/local/mysql/data  #mysql的数据目录
LogFile=/data/backup/bak.log  #用于记录增量备份的操作日志
if [ ! -f ${LogFile} ]
then
	touch ${LogFile}
else
	echo This is ${LogFile} exists.... 
fi
BinFile=/usr/local/mysql/data/mysql-bin.index #mysql的index文件路径，放在数据目录下的
MYSQL_user="root"
MYSQL_pass="123456"
/usr/local/mysql/bin/mysqladmin -u${MYSQL_user} -p${MYSQL_pass} flush-logs
#这个是用于产生新的mysql-bin.00000*文件
Counter=`wc -l $BinFile |awk '{print $1}'`
NextNum=0
#这个for循环用于比对$Counter,$NextNum这两个值来确定文件是不是存在或最新的
for file in `cat ${BinFile}`
do
    base=`basename ${file}`
    #basename用于截取mysql-bin.00000*文件名，去掉./mysql-bin.000005前面的./
    NextNum=`expr ${NextNum} + 1`
    if [ ${NextNum} -eq ${Counter} ]
    then
        echo ${base} skip! >> ${LogFile} #新增加的mysql-bin.00000*日志，不复制到备份目录下，跳过
    else
        dest=${BakDir}/${base}
        if (test -e ${dest})
        #test -e用于检测目标文件是否存在，存在就写exist!到$LogFile去
        then
            echo ${base} exist! >> ${LogFile}
        else
            cp -r ${BinDir}/${base} ${BakDir}
            echo ${base} copyed！ >> ${LogFile}
        fi
    fi
done
echo `date +"%Y年%m月%d日 %H:%M:%S"`  Incremental backup success！ >> $LogFile
echo "增量备份成功！"