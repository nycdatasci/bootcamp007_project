# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy

# this is used is the pi
class ReSnagItem(scrapy.Item):    
    url = scrapy.Field()
    body = scrapy.Field()
    path = scrapy.Field()
    fileCount = scrapy.Field()
    awards = scrapy.Field()

# this items get saved to the database in the mongoDB pipeline    
class AwardItem(scrapy.Item):
    Title = scrapy.Field()
    Date = scrapy.Field()
    Amount = scrapy.Field()
    Division = scrapy.Field()
    Investigator = scrapy.Field()
    Institution = scrapy.Field()
    Abstract = scrapy.Field()
    AwardId = scrapy.Field()
    Keywords = scrapy.Field()    