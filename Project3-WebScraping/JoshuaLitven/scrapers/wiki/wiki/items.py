# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html
from scrapy import Item, Field


class WikiItem(Item):
    # define the fields for your item here like:
    # name = scrapy.Field()
    image_url = Field()
    death_date = Field()
    death_date_raw = Field()
    birth_date = Field()
    birth_date_raw = Field()
    curid = Field()
