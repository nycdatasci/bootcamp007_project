# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class Wsj01Item(scrapy.Item):
	title = scrapy.Field()
	sections = scrapy.Field()
	authors = scrapy.Field()
	date = scrapy.Field()
	# comments = scrapy.Field()
	blurb = scrapy.Field()
	paragraphs = scrapy.Field()

   # RDate = scrapy.Field()
   # Title = scrapy.Field()
   # PBudget = scrapy.Field()
   # DomesticG = scrapy.Field()
   # WorldwideG = scrapy.Field()