# -*- coding: utf-8 -*-
BOT_NAME = 'demo'

SPIDER_MODULES = ['demo.spiders']
NEWSPIDER_MODULE = 'demo.spiders'

DOWNLOAD_DELAY = 3

ITEM_PIPELINES = {'demo.pipelines.WriteItemPipeline': 100, }