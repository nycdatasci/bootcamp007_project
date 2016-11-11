# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class BabyetsyItem(scrapy.Item):
	shopName =  scrapy.Field()
	productName =  scrapy.Field()
	productPrice =  scrapy.Field()
	shopLocation =  scrapy.Field()
	allItemCount =  scrapy.Field()
	itemDetails =  scrapy.Field()
	feedback =  scrapy.Field()
	favorited =  scrapy.Field()
	relitemTag =  scrapy.Field()