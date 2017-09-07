#!/usr/bin/env python
# -*- coding: UTF-8 -*-
from urllib2 import Request, urlopen
import urllib

username = '517834203@qq.com'
password = 'qs5602935'

url='https://accounts.douban.com/login'  
data={'redir':'http://www.douban.com',  
      'form_email':username,  
      'form_password':password,  
      'remember':'on'}  

#获得验证码id  
captchid=req.get('http://www.douban.com/j/new_captcha',headers=headers).content  
#得到验证码  
captchurl='http://douban.com/misc/captcha?size=m&id='+captchid  
#下面三步为显示验证码  
f=cStringIO.StringIO(urllib2.urlopen(captchurl).read())  
img=Image.open(f)  
img.show()  
#输入验证码  
codeimg=raw_input('plz input the veritify cpde:')  
data['captcha-solution']=codeimg  
data['captcha_id']=captchid  
s=req.post(url,data=data,headers=headers)  


file_object = open('111.html', 'w')
file_object.write(s)
file_object.close()