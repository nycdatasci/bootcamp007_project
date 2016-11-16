# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class BabyetsyItemA(scrapy.Item):
	shopName =  scrapy.Field()
	product =  scrapy.Field()
	price =  scrapy.Field()
	shopLocation =  scrapy.Field()
	itemCount =  scrapy.Field()
	feedback =  scrapy.Field()
	favorited =  scrapy.Field()
	relitemTag =  scrapy.Field()
	listDate =  scrapy.Field()
	views =  scrapy.Field()
	color =  scrapy.Field()