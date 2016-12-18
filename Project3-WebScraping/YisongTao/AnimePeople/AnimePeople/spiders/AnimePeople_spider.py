import scrapy
import json
from scrapy.selector import Selector
from AnimePeople.items import AnimePeopleItem

f = open('actor_director.txt', 'r')
#next(f) ####skip first line, only for csv file
url_list = []
for line in f:
	url_list.append(line.strip().split("\"")[1])
f.close()

class AnimePeopleSpider(scrapy.Spider):
	name = 'AnimePeople_spider'
	allowed_urls =['myanimelist.net']
	start_urls = ['https://myanimelist.net']

	

	def parse(self, response):
		page_urls = url_list
		#page_urls = ["https://myanimelist.net/people/15481/MONACA"]
		for page_url in page_urls:
			yield scrapy.Request(page_url,
				callback = self.parse_info_page)

	def parse_info_page(self, response):
		item = AnimePeopleItem()
		people_fav = None
		more_info = None
		anime_people = response.xpath('//*[@class="h1"]/text()').extract()[0]
		infolist = response.xpath('//*[@id="content"]/table/tr/td/div').extract()
		for i in range(len(infolist)):
			if Selector(text = infolist[i]).xpath('//span/text()').extract() == [u'Member Favorites:']:
				people_fav = Selector(text = infolist[i]).xpath('//text()').extract()[1].strip()
			if Selector(text = infolist[i]).xpath('//span/text()').extract() == [u'More:']:
				more_info = Selector(text = infolist[i+1]).xpath('//text()').extract()
				more_info = reduce(lambda x, y: x+y, more_info, '')
				more_info = ' '.join(more_info.split('\r\n'))

		item['anime_people'] = anime_people
		item['anime_people_fav'] = people_fav
		item['anime_people_info'] = more_info
		

		yield item

