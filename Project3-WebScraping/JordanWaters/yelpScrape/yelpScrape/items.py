# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class YelpItem(scrapy.Item):
    # define the scrapy.Fields for your item here like:
    userId = scrapy.Field()
    restaurant = scrapy.Field()
    stars= scrapy.Field()
    text = scrapy.Field()
