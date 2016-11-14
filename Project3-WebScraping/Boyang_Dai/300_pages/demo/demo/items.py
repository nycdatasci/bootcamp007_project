# -*- coding: utf-8 -*-

from scrapy import Item, Field

class AmazonCondomItem(Item):
	asin = Field()