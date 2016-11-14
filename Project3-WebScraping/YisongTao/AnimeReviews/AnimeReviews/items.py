# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class AnimereviewsItem(scrapy.Item):
	anime_title = scrapy.Field()
	review_time = scrapy.Field()
	reviewer = scrapy.Field()
	rating = scrapy.Field()
	review_text = scrapy.Field()
	pic_url = scrapy.Field()
	anime_url = scrapy.Field()
    # define the fields for your item here like:
    # name = scrapy.Field()

class AnimeItem(scrapy.Item):
	anime_title = scrapy.Field()
	anime_score = scrapy.Field()
	anime_synopsis = scrapy.Field()
	anime_background =scrapy.Field()
	anime_type = scrapy.Field()
	anime_episodes = scrapy.Field()
	anime_status = scrapy.Field()
	anime_aired = scrapy.Field()
	anime_premiered = scrapy.Field()
	anime_studios = scrapy.Field()
	anime_rating = scrapy.Field()
	anime_ranked = scrapy.Field()
	anime_popularity = scrapy.Field()
	anime_members = scrapy.Field()
	anime_favorites = scrapy.Field()
