# -*- coding: utf-8 -*-

# Define your item pipelines here
#
# Don't forget to add your pipeline to the ITEM_PIPELINES setting
# See: http://doc.scrapy.org/en/latest/topics/item-pipeline.html

from scrapy.exceptions import DropItem
from scrapy.exporters import CsvItemExporter

# class TripadvisorPipeline(object):
#     def process_item(self, item, spider):
#     	price = scrapy.Field()
#         return item

class DuplicatesPipeline(object):

    def __init__(self):
        self.ids_seen = set()
        


class WriteItemPipeline(object):

    def __init__(self):
        self.filename = 'tripadvisor.csv'

    def open_spider(self, spider):
        self.csvfile = open(self.filename, 'wb')
        self.exporter = CsvItemExporter(self.csvfile)
        self.exporter.start_exporting()

    def close_spider(self, spider):
        self.exporter.finish_exporting()
        self.csvfile.close()

    def process_item(self, item, spider):
        self.exporter.export_item(item)
        return item