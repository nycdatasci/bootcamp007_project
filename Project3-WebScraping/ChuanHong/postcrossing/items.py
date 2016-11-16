# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class CountryItem(scrapy.Item):
    code = scrapy.Field()
    country = scrapy.Field()
    members = scrapy.Field()
    postcards = scrapy.Field()
    population = scrapy.Field()


class PostcardItem(scrapy.Item):
    ## Card:
    img_url = scrapy.Field()
    card_url = scrapy.Field()
    distance = scrapy.Field()
    travel_time = scrapy.Field()
    ## From:
    from_user = scrapy.Field()
    from_country = scrapy.Field()
    from_date = scrapy.Field()
    from_lat = scrapy.Field()
    from_lng = scrapy.Field()
    ## To:
    to_user = scrapy.Field()
    to_country = scrapy.Field()
    to_date = scrapy.Field()
    to_lat = scrapy.Field()
    to_lng = scrapy.Field()




