# -*- coding: UTF-8 -*-
import time

import psutil

from ptyhon操作mysql import insert_sql

while 1:
    traff_sent0 = psutil.net_io_counters()[0]
    traff_recv0 = psutil.net_io_counters()[1]
    time.sleep(10)
    traff_sent1 = psutil.net_io_counters()[0]
    traff_recv1 = psutil.net_io_counters()[1]
    traff_sent = float(traff_sent1 - traff_sent0) / 1024.0
    traff_recv = float(traff_recv1 - traff_recv0) / 1024.0
    #print '上传速度:%.2fKB'%traff_sent
    #print '下载速度:%.2fKB\n'%traff_recv
    insert_sql.sql_insert(traff_recv, traff_sent)
    print '执行成功'

