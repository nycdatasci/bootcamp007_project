# -*- coding: utf-8 -*-

# Define your item pipelines here
#
# Don't forget to add your pipeline to the ITEM_PIPELINES setting
# See: http://doc.scrapy.org/en/latest/topics/item-pipeline.html

from scrapy.exporters import CsvItemExporter


class WriteItemPipeline(object):
        
    def __init__(self):
            self.filename = 'StarbucksStores.txt'

    def open_spider(self, spider):
            self.csvfile = open(self.filename, 'wb')
            self.exporter = CsvItemExporter(self.csvfile, fields_to_export = ['StoreId', 'Name', 'PhoneNumber', 'Longitude', 'Latitude', 'Address', 'Amenities', 'AmenitiesCarto', 'StoreNameUrl', 'Url',  'CL', 'WA', 'WF', 'CD', 'DR', 'LB', 'GO', 'FZ', 'XO', 'LU', 'RW', 'PS', 'CS', 'MX', 'VS', 'NB', 'SQ', 'EM', 'BA', 'WT', 'hrs24', 'DT', 'AmeOther'])
            self.exporter.start_exporting()
            
    def close_spider(self, spider):
            self.exporter.finish_exporting()
            self.csvfile.close()

    def process_item(self, item, spider):
            self.exporter.export_item(item)
            
            return item
