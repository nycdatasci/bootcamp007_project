import scrapy
import json
from babyEtsy.items import BabyetsyItem

class mySpider(scrapy.Spider):
    name = "etsySpider"
    allowed_domains = ["https://www.etsy.com"]
    start_urls = ['https://www.etsy.com/c/accessories/baby-accessories/baby-carriers-and-wraps?explicit=1&locationQuery=6252001']


    def parse(self, response):
        last_page_number = 5
        print "=" * 50
        print "start spider"
        page_urls = [start_urls[0] + "?page=" + str(pageNumber) for pageNumber in range(1, last_page_number + 1)]
        for page_url in page_urls:
                yield scrapy.Request(page_url, 
                                    callback=self.parse_listing_results_page)

    def parse_listing_results_page(self, response):
        for id in response.xpath('//div[@class="block-grid-item listing-card position-relative parent-hover-show"]/@data-palette-listing-id').extract():
        	url = "https://www.etsy.com/listing/" + id
        	yield scrapy.Request(url, callback=self.parse_listing_contents)

    def parse_listing_contents(self, response):
    	print "We get to the detail page"
    	pass
