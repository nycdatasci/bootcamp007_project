# -*- coding: utf-8 -*-

# Define your item pipelines here
#
# Don't forget to add your pipeline to the ITEM_PIPELINES setting
# See: http://doc.scrapy.org/en/latest/topics/item-pipeline.html

import codecs
import json
import time
import sheetapi

FILE_PATH = '../'


class CSVWriterPipeline(object):

    @classmethod
    def from_crawler(cls, crawler):
        settings = crawler.settings
        file_name = settings.get("FILE_NAME")
        return cls(file_name)

    def __init__(self, filename=None):
        if filename is None:
            self.filename = time.strftime("%Y-%m-%d%Z%H-%M-%S") + '.json'
        else:
            self.filename = filename

    def open_spider(self, spider):
        self.jsonfile = codecs.open(FILE_PATH + self.filename, mode='wb', encoding='utf-8-sig')

    def close_spider(self, spider):
        self.jsonfile.close()

    def process_item(self, item, spider):
        line = json.dumps(dict(item)) + '\n'
        self.jsonfile.write(line)
        return item


class SpreadSheetPipeline(object):

    def open_spider(self, spider):
        spreadsheetId = '1ehyrPPRnIYU-CLuU4E17JQn74b8WEHlFGTa9D-KckUU'
        sheet = 'Sheet4'
        self.sheet = sheetapi.SheetWriter(spreadsheetId, sheet)

    def close_spider(self, spider):
        del self.sheet

    def process_item(self, item, spider):
        self.sheet.write(item)
        return item


class PostcrossingPipeline(object):
    def process_item(self, item, spider):
        pass
        # return item
