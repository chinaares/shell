#!/usr/bin/env python
# -*- coding: UTF-8 -*-
import urllib2
import urllib
import requests
e = 'UM_distinctid=15dcef604c284a-049fa39ce998a5-791238-100200-15dcef604c3610;CNZZDATA1000383938=1474064877-1504588711-%7C1504680901;timezone=8;username=kinghu;password=8fcd060594ce0d54e34f6b9b3a63b753;addinfo=%7B%22dishtml5%22%3A0%2C%22chkadmin%22%3A1%2C%22chkarticle%22%3A1%2C%22levelname%22%3A%22%5Cu7ba1%5Cu7406%5Cu5458%22%2C%22userid%22%3A%221%22%2C%22useralias%22%3A%22kinghu%22%7D'
username = 'kinghu'
password = 'Qiushuai5602935'
#url='http://www.kinghu.cc/zb_system/cmd.php?act=verify'
url='http://www.kinghu.cc/zb_system/login.php'
data ={'btnPost':'登录','username':username,'savedate':'0','password':password,'dishtml5':'0'}
cookies = {}
for line in e.split(';'):
    key, value = line.split('=', 1)
    cookies[key] = value
#print cookies
s= requests.get(url,cookies=cookies)
b = s.text
file_object = open('king.html', 'w')
file_object.write(b)
file_object.close()
