# -*- coding: utf-8 -*-

# Define your item pipelines here
#
# Don't forget to add your pipeline to the ITEM_PIPELINES setting
# See: http://doc.scrapy.org/en/latest/topics/item-pipeline.html
from scrapy.exporters import CsvItemExporter

class CSVPipeline(object):
	def __init__(self):
		self.filename = 'AnimeReviews.csv'

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
