数据卷容器(基于ubuntu镜像)：
docker run -itd -v /dbdata --name dbdata ubuntu


docker run -d -v /dbdata --name dbdata ubuntu

#创建一个数据卷容器，
#数据卷容器名：--name dbdata
#数据卷容器目录(是容器内部的，不是宿主机):-v /dbdata
#数据卷容器(后台运行)：-itd


数据卷容器，其它容器可以挂载，类似nas文件共享

挂载命令：--volumes-from
例子: docker run -it --volumes-from dbdata --name db1 ubuntu




备份
docker run --volumes-from dbdata -v $(pwd):/backup --name worker ubuntu tar cvf /backup/backup1.tar /dbdata
--volumes-from dbdata ：挂在数据卷容器 dbdata
-v $(pwd):/backup ：把容器/backup目录，挂在到宿主机当前目录下【$(pwd)】
--name worker ubuntu ：创建名为worker的容器，基于ubuntu
tar cvf /backup/backup.tar /dbdata ：这台命令是在容器启动后执行