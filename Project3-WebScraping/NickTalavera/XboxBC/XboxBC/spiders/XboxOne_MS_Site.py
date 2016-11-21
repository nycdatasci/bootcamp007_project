import scrapy
from scrapy.selector import Selector
from XboxBC.items import XboxOne_MS_Site_Item
import re
import math
import datetime
import time

class XboxOne_MS_Site(scrapy.Spider):
    name = "XboxOne_MS_Site"
    allowed_domains = ['microsoft.com']
    start_urls = (
        'https://www.microsoft.com/en-us/store/top-paid/games/xbox?s=store&skipitems=0',
    )

    def parse(self, response):
        print "=" * 50
        numberOfPages = response.xpath('//*[@id="productPlacementList"]/div/p[1]/small/text()').extract()[0]
        numberOfPages = int(math.floor(float(re.findall("[0-9]+", numberOfPages)[-1])/90))
        print "=" * 50
        for j in range(0,numberOfPages+1):
            next_page = 'https://www.microsoft.com/en-us/store/top-paid/games/xbox?s=store&skipitems=' + str(j*90)
            print(next_page)
            print("Page" + str(j))
            yield scrapy.Request(next_page, callback=self.xbPageFind)

    def xbPageFind(self, response):
        baseURL = "https://www.microsoft.com"
        rows_in_big_table = response.xpath('//*[@id="productPlacementList"]/div/div/section/a')
        for i, onerow in enumerate(rows_in_big_table):
            xOne_item = XboxOne_MS_Site_Item()
            gameName = onerow.xpath('div/h3/text()').extract()[0]
            gameUrl = onerow.xpath('@href')
            if len(gameUrl) != 0:
                gameUrl = gameUrl[0].extract().strip()
                gameUrl = baseURL + gameUrl
            price = onerow.xpath('div[2]/div[2]/span/text()')
            if len(price) == 0:
                price = onerow.xpath('div[2]/div[2]/span[1]/s/text()')
            if len(price) != 0:
                price = price[0].extract().strip()
            priceGold = onerow.xpath('div[2]/div[2]/span[1]/span[2]/text()').extract()
            if len(priceGold) > 0:
                priceGold = priceGold[0]
            today = datetime.date.today()
            dayRecorded = time.strftime("%x")
            xboxRating = onerow.xpath('div[2]/div[1]/p/span[1]/text()').extract()[0]
            xOne_item['gameName'] = gameName
            xOne_item['gameUrl'] = gameUrl
            xOne_item['price'] = price
            xOne_item['priceGold'] = priceGold
            xOne_item['dayRecorded'] = dayRecorded
            xOne_item['xboxRating'] = xboxRating
            yield xOne_item
            print "=" * 50
