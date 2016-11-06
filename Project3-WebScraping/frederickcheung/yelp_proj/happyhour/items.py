# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class YelpItem(scrapy.Item):
    # define the scrapy.Fields for your item here like:
    name = scrapy.Field()
    url = scrapy.Field()
    address= scrapy.Field()
    phone = scrapy.Field()
    # rating = scrapy.Field()
    price_rating = scrapy.Field()
    
