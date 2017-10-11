# -*- coding=utf-8 -*-
import xlwt
import MySQLdb
import warnings
import datetime
import sys

reload(sys)
#sys.setdefaultencoding('utf8')

warnings.filterwarnings("ignore")

mysqlDb_config = {
    'host': 'MysqlHostOuterIp',
    'user': 'MysqlUser',
    'passwd': 'MysqlPass',
    'port': 50512,
    'db': 'Tv_event'
}

today = datetime.date.today()
yesterday = today - datetime.timedelta(days=1)
tomorrow = today + datetime.timedelta(days=1)


def getDB(dbConfigName):
    dbConfig = eval(dbConfigName)
    try:
        conn = MySQLdb.connect(host=dbConfig['host'], user=dbConfig['user'], passwd=dbConfig['passwd'],
                               port=dbConfig['port'])
        conn.autocommit(True)
        curr = conn.cursor()
        curr.execute("SET NAMES utf8");
        curr.execute("USE %s" % dbConfig['db']);

        return conn, curr
    except MySQLdb.Error, e:
        print "Mysql Error %d: %s" % (e.args[0], e.args[1])
        return None, None


def mysqlData2excel(dbConfigName, selectSql, exportPath, exportName):
    # 边框的定义
    borders = xlwt.Borders()
    borders.left = 1
    borders.right = 1
    borders.top = 1
    borders.bottom = 1
    borders.bottom_colour = 0x3A
    # Initialize a style for frist row
    style_fristRow = xlwt.XFStyle()
    font = xlwt.Font()
    font.name = 'Times New Roman'
    font.bold = True
    font.colour_index = 1
    style_fristRow.font = font

    badBG = xlwt.Pattern()
    badBG.pattern = badBG.SOLID_PATTERN
    badBG.pattern_fore_colour = 6
    style_fristRow.pattern = badBG

    style_fristRow.borders = borders

    # Initialize a style for data row
    style_dataRow = xlwt.XFStyle()
    font = xlwt.Font()
    font.name = u'隶变-简 常规体'
    font.bold = False
    style_dataRow.font = font

    style_dataRow.borders = borders

    conn, curr = getDB(dbConfigName)
    curr.execute(selectSql)
    datas = curr.fetchall()
    fields = curr.description
    workbook = xlwt.Workbook()
    sheet = workbook.add_sheet('tableSheet_message', cell_overwrite_ok=True)

    # 写上字段信息
    for field in range(0, len(fields)):
        sheet.write(0, field, fields[field][0], style_fristRow)

        # 获取并写入数据段信息
    row = 1
    col = 0
    for row in range(1, len(datas) + 1):
        for col in range(0, len(fields)):
            sheet.write(row, col, u'%s' % datas[row - 1][col], style_dataRow)

    workbook.save(r'{exportPath}/{exportName}.xls'.format(exportPath=exportPath, exportName=exportName))

    curr.close()
    conn.close()


# Batch Test
dbConfigName = 'mysqlDb_config'
selectSql = "SELECT uid,name,phone_num,qq,area,created_time FROM match_apply where match_id = 83 order by created_time desc;"
exportPath = '/Users/nisj/Desktop/'
exportName = 'mysqlDataDownload'
mysqlData2excel(dbConfigName, selectSql, exportPath, exportName)
