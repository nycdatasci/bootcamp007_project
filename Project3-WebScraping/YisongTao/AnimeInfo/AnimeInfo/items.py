# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class AnimeInfoItem(scrapy.Item):
    # define the fields for your item here like:
    # name = scrapy.Field()
    anime_title = scrapy.Field()
    anime_synopsis = scrapy.Field()
    anime_background = scrapy.Field()
    anime_type = scrapy.Field()
    anime_episodes = scrapy.Field()
    anime_status = scrapy.Field()
    anime_aired = scrapy.Field()
    anime_premiered = scrapy.Field()
    anime_producers = scrapy.Field()
    anime_studios = scrapy.Field()
    anime_genres = scrapy.Field()
    anime_rating = scrapy.Field()
    anime_score = scrapy.Field()
    anime_ranked = scrapy.Field()
    anime_popularity = scrapy.Field()
    anime_members = scrapy.Field()
    anime_favorites = scrapy.Field()
    anime_mainactors = scrapy.Field()
    anime_related = scrapy.Field()
    anime_staff = scrapy.Field()