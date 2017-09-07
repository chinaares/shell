#!/usr/bin/python
# -*- coding: UTF-8 -*-
"""
在Python中，实例的变量名如果以__开头，就变成了一个私有变量（private），只有内部可以访问，外部不能访问！
self.__name 这个变量是个私有变量，不允许外部修改
"""

class Student(object):
    def __init__(self, name, sorce, sex):
        self.__name = name
        self.__sorce = sorce
        self.sex = sex

    def print_sorce(self):
        print self.__name + '成绩为：', self.__sorce

    def get_name(self): #得到私有变量，并返回
        return self.__name

    def set_name(self,name):
        self.__name = name
b = Student('kinghu', 100, '男')

print b.get_name() #得到私有变量的值
#b.set_name('帅哥') #修改私有变量的值
b.print_sorce()