# -*- coding: utf-8 -*-

# Define your item pipelines here
#
# Don't forget to add your pipeline to the ITEM_PIPELINES setting
# See: http://doc.scrapy.org/en/latest/topics/item-pipeline.html


#class WhoPipeline(object):
from scrapy.exporters import CsvItemExporter
class WriteItemPipeline(object):

	def __init__(self):
        	self.filename = 'listing.csv'

	def open_spider(self, spider):
        	self.file =  = open(self.filename, 'wb')
	        self.exporter = CsvItemExporter(self.csvfile)
        	self.exporter.start_exporting()

	def close_spider(self, spider):
	        self.exporter.finish_exporting()
	        self.csvfile.close()

	def process_item(self, item, spider):
	        self.exporter.export_item(item)
#                line = str(item['total_population'][0]) + '\t' + str(item['gnipc'][0])\
#                                + '\t' + str(item['life_ex_birth_m'][0]) + '\t'\
#                                + str(item['life_ex_birth_f'][0])  + '\t'\
#                                + str(item['p_dying_five'][0])  + '\t'\
#				+ str(item['p_15_60_m'][0])  + '\t'\
#				+ str(item['p_15_60_f'][0])  + '\t'\
#				+ str(item['health_per_capita'][0]) + '\t'\
#				+ str(item['expend_health_GD'][0]) + '\n'
#		self.file.write(line)
	return item

#    def process_item(self, item, spider):
#        return item
