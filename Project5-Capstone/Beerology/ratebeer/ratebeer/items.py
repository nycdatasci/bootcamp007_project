# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class BeerItem(scrapy.Item):
    # define the fields for your item here like:
    beer_rank = scrapy.Field()
    beer_name = scrapy.Field()
    # beer_url = scrapy.Field()
    brewer = scrapy.Field()
    review_count = scrapy.Field()
    overall_score = scrapy.Field()
    state = scrapy.Field()

    beer_img = scrapy.Field()
    beer_style = scrapy.Field()
    style_score = scrapy.Field()
    mean = scrapy.Field()
    wgt_avg = scrapy.Field()
    ibu = scrapy.Field()
    est_cal = scrapy.Field()
    abv = scrapy.Field()
    beer_desc = scrapy.Field()
    pass

class ReviewItem(scrapy.Item):
    beer_name = scrapy.Field()
    user_rating = scrapy.Field()
    aroma = scrapy.Field()
    appearance = scrapy.Field()
    taste = scrapy.Field()
    palate = scrapy.Field()
    overall = scrapy.Field()
    user_name = scrapy.Field()
    user_info = scrapy.Field()
    review = scrapy.Field()
    state = scrapy.Field()

