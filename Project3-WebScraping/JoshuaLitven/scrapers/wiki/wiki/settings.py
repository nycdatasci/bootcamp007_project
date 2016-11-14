# -*- coding: utf-8 -*-

# Scrapy settings for wiki project
#
# For simplicity, this file contains only settings considered important or
# commonly used. You can find more settings consulting the documentation:
#
#     http://doc.scrapy.org/en/latest/topics/settings.html
#     http://scrapy.readthedocs.org/en/latest/topics/downloader-middleware.html
#     http://scrapy.readthedocs.org/en/latest/topics/spider-middleware.html

BOT_NAME = 'wiki'

SPIDER_MODULES = ['wiki.spiders']
NEWSPIDER_MODULE = 'wiki.spiders'

ITEM_PIPELINES = {
    'wiki.pipelines.WriteItemPipeline': 100
}
