#!/usr/bin/python
# -*- coding: UTF-8 -*-
import MySQLdb
# 打开数据库连接
db = MySQLdb.connect("10.10.10.103","admin","admin","test")
# 使用cursor()方法获取操作游标
cursor = db.cursor()
# SQL 查询语句
sql = "SELECT * FROM Network_traffic"
try:
   # 执行SQL语句
   cursor.execute(sql)
   # 获取所有记录列表
   results = cursor.fetchall()
   nu1 = 0
   nu2 = 0
   for row in results:
      id_ = row[0]
      u_traffic = row[1]
      nu1 = nu1 + u_traffic
      d_traffic = row[2]
      nu2 = nu2 + d_traffic
   print '下载总量:%.2fKB'%nu2,'\n上传总量:%.2fKB'%nu1
except:
   print "Error: unable to fecth data"
db.close()