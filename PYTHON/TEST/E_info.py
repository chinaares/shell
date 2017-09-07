#!/usr/bin/python
# -*- coding: UTF-8 -*-
import os
import sys
import time
from prettytable import PrettyTable

staff_list = 'info'


def query_info():
    while 1:
        print u"查询条件：工号、姓名、部门、职位\n"
        try:
            user_input = raw_input(u'输入查询内容:\n').strip()
        except (KeyboardInterrupt, EOFError):
            sys.exit(u"程序退出!")
        if len(user_input) == 0:
            os.system('clear')
            continue
        else:
            tabx = PrettyTable(["工号", "姓名", "部门", "职位","薪资"])
            tabx.align["工号"] = "1"
            tabx.padding_width = 1
            n = 0
            m = 0
            for line in c:
                x = line.split()
                m += 1
                if user_input == x[0] or user_input == x[1]:
                    tabx.add_row(x)
                else:
                    n += 1
            #'print 'm',m,'n',n'
            if n >= m:
                print u'输入的值无效!'
            else:
                print(u'查询结果如下:\n')
                print tabx
                f.close()
        break


def delet_info():
    pass
# while 1:
# 	try:
# 		Id_input = input(u'输入删除ID号:\n').strip()
# 	except (KeyboardInterrupt,EOFError):
# 		sys.exit("\n\033[31m程序退出\033[0m")
# 	if len(Id_input) == 0:
# 		os.system('clear')
# 		continue
# 	else:
# 		f_change=open(staff_list,'r+', encoding='UTF-8')
# 		flist=f_change.readlines()
# 		n = 0
# 		err = 0
# 		for Del_line in flist:
# 			x = Del_line.split()
# 			n = n + 1
# 			if Id_input == x[0]:
# 				cmd =  "sed -i '%dd' /app/py/contact_list.txt" % (n)
# 				os.system(cmd)
# 				print(u"删除成功!")
# 				break
# 			else:
# 				err = err + 1
# 		f_change.close()
# 		#print err,n
# 		if err >= n:
# 			print(u"无效ID，检查后再输入...")
# 	break

def add_info():
    pass


def update_info():
    pass


# while 1:
# 	print("修改数据是以ID为主键...\n")
# 	try:
# 		Update_input = input('输入ID号:\n').strip()
# 	except (KeyboardInterrupt,EOFError):
# 		sys.exit("\n\033[31m程序退出\033[0m")
# 	if len(Update_input) == 0:
# 		os.system('clear')
# 		continue
# 	else:
# 		f_change=open(staff_list,'r+', encoding='UTF-8')
# 		flist=f_change.readlines()
# 		n = 0
# 		for line1 in flist:
# 			x = line1.split()
# 			n = n + 1
# 			if Update_input == x[0]:
# 				old_1 = input(u'输入修改前的内容:\n').strip()
# 				if len(old_1) == 0:
# 					os.system('clear')
# 					continue
# 				else:
# 					new_1 = input(u'输入修改后的内容:\n').strip()
# 					new_str = line1.replace(old_1,new_1)
# 					flist[n-1] = new_str
# 					f_change=open(staff_list,'w+', encoding='UTF-8')
# 					f_change.writelines(flist)
# 					f_change.close()
# 			else:
# 				print(u"无效ID，检查后再输入")
# 				break
# 	f = open(staff_list,'r+', encoding='UTF-8')
# 	c = f.readlines()
# 	tabx = PrettyTable(["工号", "姓名", "部门", "职位","薪资"])
# 	tabx.align["工号"] = "1"
# 	tabx.padding_width = 1
# 	for line in c:
# 		x = line.split()
# 		if Update_input == x[0]:
# 			tabx.add_row(x)
# 	print(tabx)
# 	f.close()

def show_menu():
    cmds = {
        '0': query_info, '1': delet_info, '2': add_info, '3': update_info, '4': quit
    }
    prompt = """\033[32m-----------------------------
(0): 查询员工
(1): 删除员工
(2): 添加员工 
(3): 更新员工
(4): 退出
-----------------------------\033[0m
Please Input Your Choice: """
    while 1:
        try:
            choice = str(input(prompt)).strip()[0]
        except (KeyboardInterrupt, EOFError):
            sys.exit("\n\033[31m程序退出\033[0m")
        except IndexError:
            print(u"\033[31m无效输入，请重新输入!!!\033[0m")
            continue
        if choice not in '01234':
            print(u"\033[31m无效输入，请重新输入!!!\033[0m")
            continue
        if choice == '4':
            break
        cmds[choice]()


if __name__ == '__main__':
    f = open(staff_list, 'r+')
    c = f.readlines()
    print show_menu()
