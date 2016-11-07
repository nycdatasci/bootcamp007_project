# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

#import scrapy
from scrapy import Item, Field

class StarbucksItem(Item):
    # define the fields for your item here like:
    # name = scrapy.Field()
    StoreId = Field(serializer=str)
    Name = Field(serializer=str)
    PhoneNumber = Field(serializer=str)
    Coordinates = Field(serializer=str)
    Address = Field(serializer=str)
    Features = Field(serializer=str)
    Slug = Field(serializer=str)
