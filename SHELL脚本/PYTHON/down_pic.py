#!/bin/evn python
#_*_ coding:utf-8 _*_

#下载图片

import urllib
from bs4 import BeautifulSoup
import os


def get_content(url):
    """ doc. """
    html = urllib.urlopen(url)
    content = html.read()
    html.close()
    return content

def get_images(info):
    soup = BeautifulSoup(info)
    img_list = soup.find_all('img', class_='zoom')
    images_code = []
    for i in img_list:
        #print i
        images_1 = 'http://www.99rebbs7.com/'+i.get('file')
        images_code.append(images_1)
    #print images_code.count()
    i = 1
    dir_name = 'D:\\' + soup.find('span',id='thread_subject').string
    os.mkdir(dir_name)
    for image_url in images_code:
        hz = os.path.splitext(image_url)[1]
        basname = dir_name + '\\'+ str(i) + hz
        print basname
        urllib.urlretrieve(image_url, basname)
        print image_url,'下载完成!'
        i += 1

if __name__ == '__main__':
    url = 'http://www.99rebbs7.com/forum.php?mod=viewthread&tid=140965&extra=page%3D1%26filter%3Dtypeid%26typeid%3D246'
    info = get_content(url)
    get_images(info)