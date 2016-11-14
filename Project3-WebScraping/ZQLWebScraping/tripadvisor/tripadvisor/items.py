# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class TripadvisorItem(scrapy.Item):
    # define the fields for your item here like:
    # name = scrapy.Field()
    # hotel_id = scrapy.Field()
    # price = scrapy.Field()
    # price_range = scrapy.Field()
    # review_score = scrapy.Field()
    # services = scrapy.Field()
    # location = scrapy.Field()
    # hotel_class = scrapy.Field()
    hotel_name = scrapy.Field()
    price_range = scrapy.Field()
    # price = scrapy.Field()
    address = scrapy.Field()
    review_score = scrapy.Field()
    review_tag = scrapy.Field()
    services = scrapy.Field()
    hotel_star = scrapy.Field()
    pass
    
