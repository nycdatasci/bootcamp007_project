# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class BillboardItem(scrapy.Item):
    # define the fields for your item here like:
    # name = scrapy.Field()

    current_week = scrapy.Field()
    song = scrapy.Field()
    artist = scrapy.Field()
    last_week = scrapy.Field()
    peak_position = scrapy.Field()
    wks_on_chart = scrapy.Field()

    pass
