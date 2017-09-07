# -*- coding: utf-8 -*-
import MySQLdb as mdb
class TaobaoPipeline(object):
    def __init__(self):
        self.conn = mdb.connect(host='10.10.10.101', user='kinghu', passwd='kinghu', db='TB_Crawl', port=3306)

    def process_item(self, item, spider):
        try:
            title = item["title"]#商品标题
            link = item["link"]#商品链接
            price = item["price"]#商品价格
            Sales = item["Sales"][0]#商品月销量
            comment = item["comment"][0]#商品评论数
            address = item["address"]#商户地址
            sql = "INSERT INTO taobao(title,link,price,Sales,comment,address)VALUES('%s','%s','%s',%s,%s,'%s')"%(title,link,price,Sales,comment,address)
            print sql
            cur = self.conn.cursor()
            cur.execute(sql)
            self.conn.commit()
            cur.close()
        except Exception as e:
            pass
    def close_spider(self):
            self.conn.close()