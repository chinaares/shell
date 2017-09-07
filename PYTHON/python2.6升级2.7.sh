查看python的版本
[plain] view plain copy print?
#python  -V    
Python 2.6.6  

1.下载Python-2.7.3
[plain] view plain copy print?
#wget http://python.org/ftp/python/2.7.3/Python-2.7.3.tar.bz2  

2.解压
[plain] view plain copy print?
#tar -jxvf Python-2.7.3.tar.bz2  

3.更改工作目录
[plain] view plain copy print?
#cd Python-2.7.3  

4.安装
[plain] view plain copy print?
#./configure  
#make all             
#make install  
#make clean  
#make distclean  

5.查看版本信息
[plain] view plain copy print?
#/usr/local/bin/python2.7 -V  

6.建立软连接，使系统默认的 python指向 python2.7
[plain] view plain copy print?
#mv /usr/bin/python /usr/bin/python2.6.6  
#ln -s /usr/local/bin/python2.7 /usr/bin/python  

7.重新检验Python 版本
[plain] view plain copy print?
#python -V  

8解决系统 Python 软链接指向 Python2.7 版本后，因为yum是不兼容 Python 2.7的，所以yum不能正常工作，我们需要指定 yum 的Python版本
[plain] view plain copy print?
#vi /usr/bin/yum  

将文件头部的
#!/usr/bin/python

改成
#!/usr/bin/python2.6.6

http://www.zhangchun.org/the-centos6-3-upgrade-python-to-2-7-3-
这篇教程就到这里了，但是不久就突然发现输入法图标不见了，然后打字没有候选框！iBus 崩了！再次进行搜索，又是版本问题抓狂 iBus也是不支持Python2.7的啊！
于是。。。

9.配置iBus
分别用 vi 打开下面两个文件，找到 exec python 那一行，把exec python 改为 exec python2.6 保存，退出。iBus在重启后就恢复正常了！是不是很开心？
[plain] view plain copy print?
#vi /usr/bin/ibus-setup  
[plain] view plain copy print?
#vi/usr/libexec/ibus-ui-gtk 