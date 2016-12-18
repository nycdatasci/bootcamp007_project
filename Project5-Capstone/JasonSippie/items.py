# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class RealEstateItem(scrapy.Item):
    rowID = scrapy.Field()
    zipCode = scrapy.Field()
    cityName = scrapy.Field()
    countyName = scrapy.Field()
    streetName  = scrapy.Field()
    streetAddr = scrapy.Field()
    residentName  = scrapy.Field()
    residentAge = scrapy.Field()
    residentRace = scrapy.Field()
    residentGender = scrapy.Field()
    addrQuery = scrapy.Field()

