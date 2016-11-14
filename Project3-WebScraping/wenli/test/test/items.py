# -*- coding: utf-8 -*-

import scrapy


class TestItem(scrapy.Item):
    title = scrapy.Field()
    speaker = scrapy.Field()
    ted_info = scrapy.Field()
    duration = scrapy.Field()
    filmed_date = scrapy.Field()
    upload_date = scrapy.Field()
    subtitle = scrapy.Field()
    total_views = scrapy.Field()
    speaker_desc = scrapy.Field()
    similar_topics = scrapy.Field()
    url_og = scrapy.Field()
    related_talk1 = scrapy.Field()
    related_talk2 = scrapy.Field()
    related_talk3 = scrapy.Field()
    related_talk4 = scrapy.Field()
    related_talk5 = scrapy.Field()
    related_talk6 = scrapy.Field()
    comment_num = scrapy.Field()
    imgs_url = scrapy.Field()
    speaker_img_url = scrapy.Field()
