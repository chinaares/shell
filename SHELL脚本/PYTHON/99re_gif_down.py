#!/bin/evn python
#_*_ coding:utf-8 _*_
import urllib
from bs4 import BeautifulSoup
import os



def get_content(url):
    """ doc. """
    html = urllib.urlopen(url)
    content = html.read()
    html.close()
    return content

def get_url(info):
    soup = BeautifulSoup(info)
    info_list = soup.find_all('a', class_='s xst')
    dict_list = {}
    list_url = []
    list_name = []
    m = 0
    for i in info_list:
        url_info = 'http://www.99rebbs7.com/' + i.get('href')
        list_url.append(url_info)
        name_list = i.string
        list_name.append(name_list)
        dict_list[name_list] = url_info
        m = m + 1
    return dict_list
    #return list_url,list_name

def get_images():
    zd = get_url(info)
    for key in  zd:
        url1 = zd[key]
        url2 = get_content(url1)
        soup = BeautifulSoup(url2)
        img_list = soup.find_all('img', class_='zoom')
        images_list = []
        for i in img_list:
            file_url = i.get('file')
            try:
                images_1 = 'http://www.99rebbs7.com/' + file_url
            except Exception,e:
                print u'跳过异常！'
                continue
            images_list.append(images_1)
        if len(images_list) <= 0:
            print '[' + key + ']--' + str(len(images_list)),'张图,跳过!'
            continue
        else:
            i = 1
            dir_name = 'D:\\GIF\\' + soup.find('span',id='thread_subject').string
            #print dir_name
            if os.path.exists(dir_name):
                print '[' + key + ']' + u"--此套图已下载，跳过！"
                continue
            else:
                os.mkdir(dir_name)
                print '[' + key + ']' + u"--开始下载..."
                for image_url in images_list:
                    hz = os.path.splitext(image_url)[1]
                    basname = dir_name + '\\'+ str(i) + hz
                    #print basname
                    urllib.urlretrieve(image_url, basname)
                    print image_url,'下载完成!'
                    i += 1

if __name__ == '__main__':
    url = 'http://www.99rebbs7.com/forum.php?mod=forumdisplay&fid=165&page=1&filter=typeid&typeid=246'
    info = get_content(url)
    get_images()