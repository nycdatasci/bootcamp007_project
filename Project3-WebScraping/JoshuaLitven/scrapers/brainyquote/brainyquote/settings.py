# -*- coding: utf-8 -*-

# Scrapy settings for brainyquote project
#
# For simplicity, this file contains only settings considered important or
# commonly used. You can find more settings consulting the documentation:
#
#     http://doc.scrapy.org/en/latest/topics/settings.html
#     http://scrapy.readthedocs.org/en/latest/topics/downloader-middleware.html
#     http://scrapy.readthedocs.org/en/latest/topics/spider-middleware.html

BOT_NAME = 'brainyquote'

SPIDER_MODULES = ['brainyquote.spiders']
NEWSPIDER_MODULE = 'brainyquote.spiders'

ITEM_PIPELINES = {
    'brainyquote.pipelines.WriteItemPipeline': 200
}

MONGODB_SERVER = "localhost"
MONGODB_PORT = 27017
MONGODB_DB = "brainyquote"
MONGODB_COLLECTION = "quotes"

LOG_LEVEL = 'WARNING'  # to only display errors
