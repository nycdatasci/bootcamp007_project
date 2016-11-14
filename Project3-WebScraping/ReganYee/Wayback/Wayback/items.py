# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy

class WaybackItem(scrapy.Item):
    titles = scrapy.Field()
    upvotes = scrapy.Field()
    comments = scrapy.Field()
    subreddit = scrapy.Field()
    url = scrapy.Field()
    submit_datetime = scrapy.Field()
    snapshot_datetime = scrapy.Field()
    snapshot_date = scrapy.Field()
    snapshot_time = scrapy.Field()
    submitter = scrapy.Field()
    rank = scrapy.Field()
