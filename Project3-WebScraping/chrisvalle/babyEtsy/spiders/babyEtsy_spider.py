# -*- coding: utf-8 -*-
import scrapy
from babyEtsy.items import BabyetsyItemA
import time


class mySpider(scrapy.Spider):
    name = "etsySpider2"
    allowed_urls = ["https://www.etsy.com"]
    start_urls = ['https://www.etsy.com/c/accessories/baby-accessories/baby-carriers-and-wraps?explicit=1&locationQuery=6252001']


    def parse(self, response):
        # start_urls = ['https://www.etsy.com/c/accessories/baby_accessories/baby_carriers_and_wraps?explicit=1&locationQuery=6252001&page=101']
    	#start_urls = ['https://www.etsy.com/c/accessories/baby-accessories/baby-carriers-and-wraps?explicit=1&locationQuery=6252001']
        start_page_number = 101
        last_page_number = 150
        #print "=" * 50
        #print "start spider"
        #page_urls = [start_urls[0] + "&page=" + str(pageNumber) for pageNumber in range(1, last_page_number + 1)]
        #page_urls = [start_urls[0] + "&page=" + str(pageNumber) for pageNumber in range(1, last_page_number + 1)]
        page_urls = [(self.start_urls[0] + "&page=" + str(pageNumber)) for pageNumber in range(1, last_page_number + 1)]

        for page_url in page_urls:
            yield scrapy.Request(page_url,
                                    callback=self.parse_listing_results_page)

    def parse_listing_results_page(self, response):
    	# print "parse result page"
    	# time.sleep(2)
    	ids = response.xpath('//div[@class="block-grid-item listing-card position-relative parent-hover-show"]/@data-palette-listing-id').extract()
    	print len(ids)
        	
        for id in ids:
        	url = "https://www.etsy.com/listing/" + id
        	yield scrapy.Request(url, callback=self.parse_listing_contents)


    def parse_listing_contents(self, response):
        item = BabyetsyItemA()
        item['product'] = response.xpath('//span[@itemprop ="name"]/text()').extract()[0]
        item['price'] = response.xpath('//span[@id="listing-price"]/meta[@itemprop="price"]/@content').extract()[0]
        item['shopName'] = response.xpath('//span[@itemprop="title"]/text()').extract()[0]        
        item['shopLocation'] = response.xpath('//div[@id="shop-info"]/text()[last()]').extract()[0]
        item['itemCount'] = response.xpath('//span[@class="count-number"]/text()').extract()[0]
        item['feedback'] = response.xpath('//a[@href="#reviews"]/text()').extract()[0]
        # item['favorited'] = response.xpath('//*[@id="item-overview"]/ul/li[6]/a/text()').extract()[0]
        item['listDate'] = response.xpath('//*[@id="fineprint"]/ul/li[1]/text()[last()]').extract()[0]
        item['views'] = response.xpath('//*[@id="fineprint"]/ul/li[2]/text()').extract()[0]
        #color = response.xpath('//*[@id="variations"]/div/div[2]/select[@class="variation"]').extract()
        #relitemTag = response.xpath('//div[@id="tags"]/ul[@id="listing-tag-list"]/a[@href="https://www.etsy.com/c/accessories?ref=l2"]').extract()

        yield item

        
