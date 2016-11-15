# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

from scrapy import Item, Field


class BrainyQuoteItem(Item):
    body = Field()
    tags = Field()
    author = Field()


class SearchResultItem(Item):
    author = Field()
    results = Field()
    num_results = Field()
