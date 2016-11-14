# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

from scrapy import Item, Field

class scrapeCPU(Item):
    # define the fields for your item here like:
    # name = scrapy.Field()
    productname = Field()
    brand = Field()
    series = Field()
    name = Field()
    socket = Field()
    corename = Field()
    core = Field()
    freq = Field()
    l3cache = Field()
    l2cache = Field()
    power = Field()
    rating = Field()
    price = Field()
    url = Field()
    rank = Field()

class scrapeGPU(Item):
    productname = Field()
    brand = Field()
    model = Field()
    chipmake = Field()
    gpu = Field()
    coreclock = Field()
    boostclock = Field()
    memoryclock = Field()
    memorysize = Field()
    memoryinterface = Field()
    memorytype = Field()
    price = Field()
    rating = Field()
    url = Field()
    rank = Field()



