# -*- coding: utf-8 -*-
import scrapy
import json
from scrapy.selector import Selector
from footlocker.items import FootlockerItem
import logging
from scrapy.utils.log import configure_logging

configure_logging(install_root_handler=False)
logging.basicConfig(
    filename='log.txt',
    filemode = 'a',
    format='%(levelname)s: %(message)s',
    level=logging.DEBUG
)

logger = logging.getLogger('myLog')

class FootlockerSpider(scrapy.Spider):
    name = "footlockerspider"

    allowed_urls = ['http://www.footlocker.com']
    start_urls = ["http://www.footlocker.com/Shoes/_-_/N-rj?Rpp=180&Nao=0&cm_PAGE=0"]

    def parse(self, response):
        print 'Parsing Data for Footlocker...'


        #pages-dropdown dropdown
        get_num_pages = response.xpath('//*[@id="endecaResultsWrapper"]/div[3]/div/div[3]/a[4]/text()').extract()
        num_pages = int(get_num_pages[0])

        url_list = []
        for i in range(0,num_pages):
            x = i * 180
            url_list.append('http://www.footlocker.com/Shoes/_-_/N-rj?Rpp=180&Nao=' + str(x) + '&cm_PAGE=' + str(x))

        print "=" * 50
        print  "Number of URLs: %d" %len(url_list)

        for url in url_list:
            yield scrapy.Request(url=url, dont_filter=True, callback=self.parseData)

    def parseData(self, response):
        # For each item container, extract!:
        # Product URL
        # Brand
        # Product Name
        # Price
        # Image
        
        if response.status == 302:
            self.logger.debug("(parse_page) response: status=%d, URL=%s" % (response.status, response.url))
            yield scrapy.Request(
                response.urljoin(response.headers['Location']), callback=self.parseData, dont_filter=True)
        

        
        product_url = response.xpath('//*[@id="endeca_search_results"]/ul/li/a/@href').extract()
        product_name =  response.xpath('//*[@id="endeca_search_results"]/ul/li/a/@title').extract()
        price = response.xpath('//*[@id="endeca_search_results"]/ul/li/p[@class="product_price"]').extract()
        image = response.xpath('//*[@id="endeca_search_results"]/ul/li/a/img/@src').extract()

        for i in range(0,len(product_url)):
            item = FootlockerItem()

            item['url'] = product_url[i]
            item['product_name'] = product_name[i]
            item['price'] = price[i]
            item['image'] = image[i]
            yield item