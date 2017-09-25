#!/usr/bin/env python
# -*- coding: UTF-8 -*-
import xlwt
from datetime import datetime

def set_style(name,height,bold=False):
  style = xlwt.XFStyle() # 初始化样式
  font = xlwt.Font() # 为样式创建字体
  font.name = name # 'Times New Roman'
  font.bold = bold
  font.color_index = 4
  font.height = height
  # borders= xlwt.Borders()
  # borders.left= 6
  # borders.right= 6
  # borders.top= 6
  # borders.bottom= 6
  style.font = font
  # style.borders = borders
  return style
style0 = xlwt.easyxf('font: name Times New Roman, color-index red, bold on', num_format_str='#,##0.00')
style1 = xlwt.easyxf(num_format_str='D-MMM-YY')

wb = xlwt.Workbook()
ws = wb.add_sheet(u'数据监控')
ws.write_merge(0, 0, 0, 10, u'2017年09月16日 川航B2C网站监控数据',style0)
ws.write(1, 0, u'1)',set_style('Times New Roman',220,True))
ws.write_merge(1, 1, 1, 2, u'QUNAR(去哪儿)',set_style('Times New Roman',220,True))
row1 = [u'调用总次数', u'成功返回结果次数', u'返回总报错', u'返回业务报错', u'返回系统报错', u'总失败比例', u'业务报错失败比例', u'系统报错失败比例']
for i in range(0,len(row1)):
    ws.write(1, i+3, row1[i],set_style('Times New Roman',420,True))

wb.save('example.xls')































# ws.write(0, 0, 1234.56)
# ws.write(1, 0, datetime.now(),style1)
# ws.write(2, 0, 1)
# ws.write(2, 1, 1)
# ws.write(2, 3, xlwt.Formula("A3+B3"))