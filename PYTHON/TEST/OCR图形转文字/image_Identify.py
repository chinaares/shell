#!/usr/bin/env python
# -*- coding: UTF-8 -*-
# 引入文字识别OCR SDK
from aip import AipOcr
import json

# 定义常量
APP_ID = '10105277'
API_KEY = 'x2jIlVmCNHh86vUr7swadk8x'
SECRET_KEY = 'dOdhaVkfwFb4PB288fbv64E15HP87Xqu'

# 初始化ApiOcr对象
aipOcr = AipOcr(APP_ID, API_KEY, SECRET_KEY)

# 读取图片
def get_file_content(filePath):
    with open(filePath, 'rb') as fp:
        return fp.read()

options = {
  'detect_direction': 'true',
  'language_type': 'CHN_ENG',
}
# 调用通用文字识别接口
result = aipOcr.basicGeneral(get_file_content('11.png'),options)
#json_str = json.dumps(result,sort_keys=True, indent=4, separators=(',', ': '))
#print json_str.decode('unicode_escape')
#print result.keys()
#print result['words_result']
words = []
for keys in result['words_result']:
    for key in keys:
        words.append(keys[key])

print words[1]