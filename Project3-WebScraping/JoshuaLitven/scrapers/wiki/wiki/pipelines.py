# -*- coding: utf-8 -*-
from scrapy.exporters import CsvItemExporter

class WriteItemPipeline(object):

    def __init__(self):
        self.filename = '../data/wiki_pages.csv'

    def open_spider(self, spider):
        self.file = open(self.filename, 'wb')
        self.exporter = CsvItemExporter(self.file)
        self.exporter.start_exporting()

    def close_spider(self, spider):
        self.exporter.finish_exporting()
        self.file.close()

    def process_item(self, item, spider):
        self.exporter.export_item(item)
        return item
