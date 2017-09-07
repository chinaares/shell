#!/bin/evn python
#_*_ coding:utf-8 _*_

#下载图片

import urllib
from bs4 import BeautifulSoup
import os
import requests

def get_content(url):
    headers = {'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.36'}
    html = requests.get(url, headers = headers)
    content = html.text
    html.close()
    return content

def download_images(content):
    soup = BeautifulSoup(content)
    #根据抓取的内容，定制规则，过滤
    image_list = soup.find_all('img', class_='zoom')
    images = []
    for i in image_list:
        image_base_rul = 'http://www.99rebbs7.com/'+i.get('file')
        images.append(image_base_rul)
    i = 1
    #windows系统 保存路径
    dir_name = 'D:\\' + soup.find('span',id='thread_subject').string
    os.mkdir(dir_name)
    for image_url in images:
        name_houzhui = os.path.splitext(image_url)[1]
        basname = dir_name + '\\'+ str(i) + name_houzhui
        #print basname
        urllib.urlretrieve(image_url, basname)
        print image_url,'下载完成!'
        i += 1

if __name__ == '__main__':
    url = 'http://www.99rebbs7.com/forum.php?mod=viewthread&tid=140965&extra=page%3D1%26filter%3Dtypeid%26typeid%3D246'
    content = get_content(url)
    download_images(content)