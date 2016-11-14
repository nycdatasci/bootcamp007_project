# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class TvshowsItem(scrapy.Item):
    # define the fields for your item here like:
    # name = scrapy.Field()
    show_name = scrapy.Field()
    status = scrapy.Field()
    network = scrapy.Field()
    language = scrapy.Field()
    genre = scrapy.Field()
    tv_db_score = scrapy.Field()

    # year_season = scrapy.Field()
    # current_rating = scrapy.Field()
    casts = scrapy.Field()
    # genre1 = scrapy.Field()
    # genre2 = scrapy.Field()
    pass


class TomatoItem(scrapy.Item):
    name_season = scrapy.Field()
    # num_episode = scrapy.Field()
    tomatometer = scrapy.Field()
    aud_score = scrapy.Field()


class UrlItem(scrapy.Item):
    # show_name = scrapy.Field()
    show_url = scrapy.Field()


class ImdbItem(scrapy.Item):
    show_name = scrapy.Field()
    imdb_rating = scrapy.Field()

class Tmt2Item(scrapy.Item):
    show_name = scrapy.Field()
    avg_aud_score = scrapy.Field()
