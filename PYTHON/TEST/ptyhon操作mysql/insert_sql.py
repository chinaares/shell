#!/usr/bin/python
# -*- coding: UTF-8 -*-
import MySQLdb

def sql_insert(download, upload):
    db = MySQLdb.connect("10.10.10.103","admin","admin","test" )
    cursor = db.cursor()
    sql = "INSERT INTO Network_traffic(download_speed,upload_speed) VALUES(%.2f,%.2f)"%(download,upload)
    #print sql
    try:
       cursor.execute(sql)
       db.commit()
    except:
       db.rollback()
    db.close()

if __name__ == '__main__':
    print '不单独执行！'