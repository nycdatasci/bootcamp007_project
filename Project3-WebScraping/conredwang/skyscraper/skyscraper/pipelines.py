# -*- coding: utf-8 -*-

# author : Conred Wang
# title : Wed scraping using Scrapy.  Code 2 of 3.  pipelines.py

class WriteItemPipeline(object):
	def __init__(self):
		self.filename = 'tall.txt'

	def open_spider(self, spider):
		self.file = open(self.filename, 'wb')
		
	def close_spider(self, spider):
		self.file.close()

# Building Name (blgname) contains unicode (for example, "u2016"/double-vertical-line, "u2022"/bullet, etc),
# which will cause exception when applying str().  Use "encode('ascii','ignore')", instead of str(), to solve the issue.

	def process_item(self, item, spider):
		line =  str(item['hgtRank']) + '|' +  str(item['hgtFeet']) + '|' + \
				item['blgName'].encode('ascii','ignore') + '|' +  str(item['blgCity']) + '|' + \
				str(item['blgCountry']) + '|' + str(item['blgFloor']) + '|' +  str(item['blgPurpose']) + '|' + \
				str(item['isMultiPurpose']) + '|' + \
				str(item['forOffice']) + '|' +  str(item['forResidential']) + '|' + \
				str(item['forHotel']) + '|' +  str(item['forRetail']) + '|' + \
				str(item['yrPropose']) + '|' +  str(item['yrStart']) + '|' + str(item['yrComplete']) + '|' + \
				str(item['tmProposeStart']) + '|' +  str(item['tmProposeComplete']) + '|' + str(item['tmStartComplete']) + '\n'
#				following line, building url, is for debug purpose.
#				str(item['blgUrl']) + '\n'
		self.file.write(line)
		return item
