__author__ = 'KINGHU'

#!/bin/evn python
#_*_ coding:utf-8 _*_

#下载图片

import urllib
from bs4 import BeautifulSoup
import requests
import os
import sys

def get_content(url):
    """ doc. """
    headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.90 Safari/537.36'}
    html = requests.get(url, headers=headers)
    print(html.encoding)
    content = html.text
    #print content
    return content

def get_images(info):
    soup = BeautifulSoup(info,'html.parms')
    link = soup.find_all('img', border='0')
    images_code = []
    for i in link:
        images_1 = i.get('src')
        images_code.append(images_1)
    #print images_code
    i = 1
    tilte = soup.find('h1',id='subject_tpc').string
    print tilte
    os.mkdir(tilte)
    for image_url in images_code:
        hz = os.path.splitext(image_url)[1]
        basname = tilte + '\\'+ str(i) + hz
        print basname
        try:
            urllib.urlretrieve(image_url, basname)
        except Exception,e:
                print u'跳过异常！'
                continue
        print image_url,'下载完成!'
        i += 1

if __name__ == '__main__':
    #reload(sys)
    #sys.setdefaultencoding('utf8')
    url = 'http://x2.pix378.pw/pw/htm_data/15/1709/768367.html'
    info = get_content(url)
    get_images(info)