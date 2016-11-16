


class WriteItemPipeline(object):

	def __init__(self):
		self.filename = 'AmazonCondoms.txt'

	def open_spider(self, spider):
		self.file = open(self.filename, 'wb')
		
	def close_spider(self, spider):
		self.file.close()

	def process_item(self, item, spider):
		line = str(item['asin']) + '\n'
		self.file.write(line)
		return item