# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class whoItem(scrapy.Item):
    # define the fields for your item here like:
    # name = scrapy.Field()
	country = scrapy.Field()
	total_population = scrapy.Field()
    	gnipc = scrapy.Field()
    	life_ex_birth_mf = scrapy.Field()
    	p_dying_five = scrapy.Field()
    	p_15_60_mf = scrapy.Field()
    	health_per_capita = scrapy.Field()
	expend_health_GDP = scrapy.Field()
#    expend_health_GDP = scrapy.Field()
#    pass
    
