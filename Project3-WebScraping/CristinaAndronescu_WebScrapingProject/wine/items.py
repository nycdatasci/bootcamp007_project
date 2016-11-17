# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class WineItem(scrapy.Item):
    # define the fields for your item here like:
    # name = scrapy.Field()
    name_year = scrapy.Field()
    name_location = scrapy.Field()
    alch_s = scrapy.Field()
    alch = scrapy.Field()
    wtype = scrapy.Field()
    rating_name = scrapy.Field()
    rating_score = scrapy.Field()
    price = scrapy.Field()
    winemaker_notes = scrapy.Field()
    wcritical_acclaim1 = scrapy.Field()
    wcritical_acclaim2 = scrapy.Field()
    wcritical_acclaim3 = scrapy.Field()
    wcritical_acclaim4 = scrapy.Field()
    wcritical_acclaim5 = scrapy.Field()
    #critical_acclaim = scrapy.Field()