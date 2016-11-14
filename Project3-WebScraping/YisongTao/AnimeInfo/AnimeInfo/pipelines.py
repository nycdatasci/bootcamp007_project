# -*- coding: utf-8 -*-

# Define your item pipelines here
#
# Don't forget to add your pipeline to the ITEM_PIPELINES setting
# See: http://doc.scrapy.org/en/latest/topics/item-pipeline.html
from scrapy.exporters import CsvItemExporter
from scrapy.exporters import JsonLinesItemExporter
import json

class CSVPipeline(object):
	def __init__(self):
		self.filename = 'AnimeInfo.csv'

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
#####CSVPipeline not used in settings.py, using Json instead to preserve data structure.


class JsonPipeline(object):
	def __init__(self):
		self.filename = 'AnimeInfo12.json'

	def open_spider(self, spider):
		self.file = open(self.filename, 'ab')
		self.exporter = JsonLinesItemExporter(self.file)
		self.exporter.start_exporting()

	def close_spider(self, spider):
		self.exporter.finish_exporting()
		self.file.close()

	def process_item(self, item, spider):
		j_str = json.dumps(dict(item))
		j_obj = json.loads(j_str)
		self.exporter.export_item(j_obj)
		return item
