# -*- coding: utf-8 -*-

# Define your item pipelines here
#
# Don't forget to add your pipeline to the ITEM_PIPELINES setting
# See: http://doc.scrapy.org/en/latest/topics/item-pipeline.html
import json

class TvshowsPipeline(object):
    def __init__(self):
        self.filename = 'Tvshows.csv'

    def open_spider(self, spider):
        self.file = open(self.filename, 'wb')

    def close_spider(self, spider):
        self.file.close()

    def process_item(self, item, spider):
        line = str(item['show_name'][0]) + ',' + str(item['status'][0]) + ',' + str(item['network'][0]) + ','\
                + ',' + str(item['language'][0]) + '\n'
        self.file.write(line)
        return item

class JsonTVNamePipeline(object):

    def open_spider(self, spider):
        self.file = open('tv_name.json', 'wb')

    def close_spider(self, spider):
        self.file.close()

    def process_item(self, item, spider):
        line = json.dumps(dict(item)) + "\n"
        self.file.write(line)
        return item

class TvPipeline(object):
    def process_item(self, item, spider):
        return item