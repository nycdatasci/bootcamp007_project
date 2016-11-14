from lxml import html  
import csv,os,json
import requests
from exceptions import ValueError
from time import sleep
from scrapy import Spider
from scrapy.selector import Selector
from demo.items import AmazonCondomItem
import scrapy

temp = []
for pg in range(1, 300):
    pg = str(pg)
    url_link = 'https://www.amazon.com/s/ref=sr_pg_2?rh=n%3A3760901%2Cn%3A3777371%2Cn%3A3777411%2Cn%3A10786691%2Ck%3Acondom&page=' + pg + '&keywords=condom&ie=UTF8&qid=1478376635'  
    temp.append(url_link)

class ScrapySpider(Spider):
    name = 'testing_spider'

    def start_requests(self):
    	urls = temp
    	for url in urls:
    		yield scrapy.Request(url=url, callback=self.parse)
    
    def parse(self, response):
       rows = response.xpath('//div[@id="atfResults"]/ul/li').extract()

       print len(rows)
       for row in rows:
       
            # Get the Asin numner:
            asin = Selector(text = row).xpath('//@data-asin').extract()[0]
            item = AmazonCondomItem()
            item['asin'] = asin.encode('ascii','ignore')

            print asin
            
            yield item



