#!/usr/bin/env python
# -*- coding: UTF-8 -*-
#抓淘宝数据
import requests
import re
import sys
from bs4 import BeautifulSoup


url = u'https://s.taobao.com/search'
#q=docker 是商品名，s=1是第几个商品
payload = {'q':'情趣内衣','s':'1'}
headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.90 Safari/537.36'}
file1 = open('macbook_pro.txt','w')
reload(sys)
sys.setdefaultencoding('utf8')
for k in range(0,1):
    payload['s'] = 44 * k + 1
    ht = requests.get(url, params=payload, headers=headers)
    print ht.url
    content1 = ht.text
    print content1
    title = re.findall(r'"raw_title":"([^"]+)"', content1, re.I)
    price = re.findall(r'"view_price":"([^"]+)"', content1, re.I)
    loc = re.findall(r'"item_loc":"([^"]+)"', content1, re.I)
    sales = re.findall(r'"view_sales":"([^"]+)"', content1, re.I)
    comment = re.findall(r'"comment_count":"([^"]+)"', content1, re.I)
    x = len(title)
    for i in range(0, x):
        #a = str(k*44+i+1) + u'商品名：' + title[i] + '\n' + u'价格：' + price[i] + '\n' + u'卖家所在地：' + loc[i] + '\n' + u'销量：'+ sales[i] + '\n' + u'评论：' + comment[i] +'\n\n'
        con = u'商品名：' + title[i] + '\n' + u'价格：' + price[i] + '\n' + u'卖家所在地：' + loc[i] + '\n' + u'销量：' + sales[i] + '\n\n'
        print con
        file1.write(con)

file1.close()
print '抓取完成！'














# soup = BeautifulSoup(content1,"lxml")
# print soup.prettify()
# #div_list = soup.find_all('img')
#
# print lab