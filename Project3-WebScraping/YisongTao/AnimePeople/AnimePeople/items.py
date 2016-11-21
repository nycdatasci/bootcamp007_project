# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class AnimePeopleItem(scrapy.Item):
    # define the fields for your item here like:
    # name = scrapy.Field()
    anime_people = scrapy.Field()
    anime_people_fav = scrapy.Field()
    anime_people_info = scrapy.Field()
    #pass
