# -*- coding: utf-8 -*-
import scrapy
import json
from scrapy.selector import Selector
from FlightClub.items import FlightclubItem
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

class FlightclubSpider(scrapy.Spider):
    name = "flightclubspider"
    allowed_urls = ['http://www.flightclub.com']
    start_urls = ["https://www.flightclub.com/men?id=446&p=1"]

    def parse(self, response):
        print 'Parsing Data for FlightClub...'


        #pages-dropdown dropdown
        get_num_pages = response.xpath('//*[@id="toolbar-header"]/div[1]/div/span[2]/text()').extract()
        num_pages = int(get_num_pages[0].split()[1])
        url_list = []
        for i in range(0,num_pages):
          url_list.append('http://www.flightclub.com/men?id=446&p=' + str(i+1))

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

        product_url = response.xpath('//ul[@class="products-grid mb-padding"]/li/a/@href').extract()
        brand  = response.xpath('//div[@class="item-container"]/h2/text()').extract()
        product_name =  response.xpath('//div[@class="item-container"]/p/text()').extract()
        price = response.xpath('//div[@class="item-container"]//div//div/span/span/text()').extract()
        image = response.xpath('//div[@class="item-container"]/span/img/@src').extract()

        for i in range(0,len(product_url)):
            item = FlightclubItem()

            item['url'] = product_url[i]
            item['brand'] = brand[i]
            item['product_name'] = product_name[i]
            item['price'] = price[i]
            item['image'] = image[i]
            yield item


