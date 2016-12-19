# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy

class FlightclubItem(scrapy.Item):
        # Product URL
        url = scrapy.Field()
        # Brand
        brand = scrapy.Field()
        # Product Name
        product_name = scrapy.Field()
        # Price
        price = scrapy.Field()
        # Image
        image = scrapy.Field()
