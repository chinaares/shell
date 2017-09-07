# -*- coding: utf-8 -*-
import scrapy
from scrapy.http import Request
import re
from taobao.items import TaobaoItem
import urllib2,urllib
import ssl
import requests
class TbSpider(scrapy.Spider):
    name = "tb"
    allowed_domains = ["taobao.com"]
    start_urls = ['https://taobao.com/']

    def parse(self, response):
        key = "坚果"
        for i in range(0,30):#定义爬虫页数
            url = "https://s.taobao.com/search?q="+str(key)+"&commend=all&search_type=item&s="+str(44*i)
            yield Request(url=url,callback=self.page2)
        pass
    def page2(self,response):
        body=response.body.decode("utf-8","ignore")
        patid='"nid":"(.*?)"'
        patprice='"view_price":"(.*?)"'
        patname='"raw_title":"(.*?)"'
        pataddress='"item_loc":"(.*?)"'
        allid=re.compile(patid).findall(body)#商品Id集合
        allprice=re.compile(patprice).findall(body)#商品价格集合
        allname=re.compile(patname).findall(body)#商品名称集合
        alladdress=re.compile(pataddress).findall(body)#商户地址集合
        for j in range(0,len(allid)):
            thisid = allid[j]
            price = allprice[j]
            name = allname[j]
            address = alladdress[j]
            url1="https://item.taobao.com/item.htm?id="+str(thisid)
            yield Request(url=url1,callback=self.next,meta={'price':price,'name':name,'address':address,'itemid':thisid})

    def next(self,response):
        item = TaobaoItem()
        item["title"] = response.meta['name']
        item["link"] = response.url
        item["price"] = response.meta['price']
        item["address"] = response.meta['address']
        thisid = response.meta['itemid']
        #由于淘宝、天猫某些信息采用Ajax加载，且加载方式不同，故加以区分
        if 'tmall.com' in item["link"]:
            MonthlySalesurl = "https://mdskip.taobao.com/core/initItemDetail.htm?itemId=%s&callback=setMdskip" % thisid
            referer = "https://detail.tmall.com/item.htm"
            patjsonp = '{"sellCount":(.*?),'
            commenturl = "https://dsr-rate.tmall.com/list_dsr_info.htm?itemId=" + str(thisid)
            pat = '"rateTotal":(.*?),'
        else:
            MonthlySalesurl = "https://detailskip.taobao.com/service/getData/1/p1/item/detail/sib.htm?itemId=%s&modules=dynStock,qrcode,viewer,price,contract,duty,xmpPromotion,delivery,activity,fqg,zjys,couponActivity,soldQuantity&callback=onSibRequestSuccess" % thisid
            referer = "https://item.taobao.com/item.htm"
            patjsonp = '{"confirmGoodsCount":(.*?),'
            commenturl = "https://rate.taobao.com/detailCount.do?callback=jsonp100&itemId=" + str(thisid)
            pat = '"count":(.*?)}'
        hd = {
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.36',
                'referer': referer
             }
        jsonp = requests.get(MonthlySalesurl, headers=hd).text  # 获取源码
        sellCount = re.compile(patjsonp).findall(jsonp)
        item["Sales"] = sellCount
        #print sellCount
        #ssl._create_default_https_context = ssl._create_unverified_context
        page = urllib2.urlopen(commenturl)
        commentdata = page.read()
        item["comment"] = re.compile(pat).findall(commentdata)
        yield item
        #print item