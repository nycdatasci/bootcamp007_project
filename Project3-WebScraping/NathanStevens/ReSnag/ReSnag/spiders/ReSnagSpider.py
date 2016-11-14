# -*- coding: utf-8 -*-
"""
Created on Sun Nov 06 14:04:14 2016

@author: nathan
"""

import scrapy
from ReSnag.items import ReSnagItem

# define the number of years, from start to 1 more than 
# last that we want to download. Select ony 3 at a time otherwise
# it doesn't work well at all
YEAR_RANGE = range(2000,2004)

#YEAR_RANGE = [2003]

# class BnbspiderSpider(scrapy.Spider):
class ReSnagSpider(scrapy.Spider):
    name = "resnag_spider"
    allowed_domains = ["nsf.gov"]
    start_urls = (
        'https://nsf.gov/awardsearch/download.jsp',
    )
    
    # go to earch link in the page and process the url to download
    # the zip file containong all the awards    
    def parse(self, response):
        # get all the download links
        hrefs = response.xpath('//div[@class="downloadcontent"]/p/a/@href').extract()
        
        for href in hrefs:
            url = response.urljoin(href)
            
            # this could all be done with "any" function as well
            for year in YEAR_RANGE:            
                if str(year) in url:            
                    yield scrapy.Request(url, callback = self.parse_download)
    
    # we need to store the body and url so we can download the data
    def parse_download(self, response):
        item = ReSnagItem()
        item['body'] = response.body
        item['url'] = response.url
        
        return item