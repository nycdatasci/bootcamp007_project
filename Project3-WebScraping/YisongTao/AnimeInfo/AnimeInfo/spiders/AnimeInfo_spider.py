import scrapy
import json
from scrapy.selector import Selector
from AnimeInfo.items import AnimeInfoItem

#### edited for txt files
f = open('url_list12.txt', 'r')
#next(f) ####skip first line, only for csv file
url_list = []
for line in f:
	url_list.append(line.strip().split("\"")[1])
f.close()


class AnimeInfoSpider(scrapy.Spider):
	name = 'AnimeInfo_spider'
	allowed_urls =['myanimelist.net']
	start_urls = ['https://myanimelist.net']

	

	def parse(self, response):
		page_urls = url_list
		#page_urls = ["https://myanimelist.net/anime/25345/Rance_01__Hikari_wo_Motomete_The_Animation"]
		for page_url in page_urls:
			yield scrapy.Request(page_url,
				callback = self.parse_info_page)

	def parse_info_page(self, response):
		item = AnimeInfoItem()
		anime_title = response.xpath('//*[@id="contentWrapper"]/div[1]/h1/span/text()').extract()[0]
		anime_synopsis = response.xpath('//*[@id="content"]/table/tr/td[2]/div[1]/table/tr[1]/td/span/text()').extract()
		anime_synopsis = reduce(lambda x, y: x+y, anime_synopsis, '')
		anime_synopsis = ' '.join(anime_synopsis.split('\r\n'))
		anime_background = response.xpath('//*[@id="content"]/table/tr/td[2]/div[1]/table/tr[1]/td/text()').extract()
		anime_background = ''.join(anime_background)
		related_list = response.xpath('//table[@class="anime_detail_related_anime"]/tr').extract()
		anime_related = dict()
		if related_list != []:
			for related in related_list:
				temp = Selector(text = related).xpath('//text()').extract()
				anime_related[temp[0]] = temp[1:]
		mainactors_list = response.xpath('//*[@id="content"]/table/tr/td[2]/div[1]/table/tr[2]/td/table').extract()	
		anime_mainactors = list()
		i = 0
		if len(mainactors_list)!=0:
			for actors in mainactors_list:
				if related_list != []:
					if i > 0 and i < 5:
						temp = Selector(text = actors).xpath('//a/text()').extract()
						if len(temp)==2:
							anime_mainactors.append(temp[1])
				else:
					if i < 4:
						temp = Selector(text = actors).xpath('//a/text()').extract()
						if len(temp)==2:
							anime_mainactors.append(temp[1])
				i = i + 1
		
		info_list = response.xpath('//*[@id="content"]/table/tr/td[1]/div/div').extract()
		anime_type = None
		anime_episodes = None
		anime_status = None
		anime_aired = None
		anime_premiered = None
		anime_producers = None
		anime_studios = None
		anime_genres = None
		anime_rating = None
		anime_score = response.xpath('//div[@class="fl-l score"]/text()').extract()[0]
		anime_score = anime_score.strip()
		anime_ranked = None
		anime_popularity = None
		anime_members = None
		anime_favorites = None
		for info in info_list:
			if Selector(text = info).xpath('//span/text()').extract() == [u'Type:']:
				if len(Selector(text = info).xpath('//a/text()').extract()) > 0:
					anime_type = Selector(text = info).xpath('//a/text()').extract()[0]
				else:
					anime_type = Selector(text = info).xpath('//text()').extract()[2].strip()
				#print "===="*20
				#print anime_type
			if Selector(text = info).xpath('//span/text()').extract() == [u'Episodes:']:
				anime_episodes = Selector(text = info).xpath('//text()').extract()[2]
			if Selector(text = info).xpath('//span/text()').extract() == [u'Status:']:
				anime_status = Selector(text = info).xpath('//text()').extract()[2]
			if Selector(text = info).xpath('//span/text()').extract() == [u'Aired:']:
				anime_aired = Selector(text = info).xpath('//text()').extract()[2]
			if Selector(text = info).xpath('//span/text()').extract() == [u'Premiered:']:
				if len(Selector(text = info).xpath('//a/text()').extract()) > 0:
					anime_premiered = Selector(text = info).xpath('//a/text()').extract()[0]
			if Selector(text = info).xpath('//span/text()').extract() == [u'Producers:']:
				anime_producers = Selector(text = info).xpath('//a/text()').extract()
			if Selector(text = info).xpath('//span/text()').extract() == [u'Studios:']:
				anime_studios = Selector(text = info).xpath('//a/text()').extract()
			if Selector(text = info).xpath('//span/text()').extract() == [u'Genres:']:
				anime_genres = Selector(text = info).xpath('//a/text()').extract()
			if Selector(text = info).xpath('//span/text()').extract() == [u'Rating:']:
				anime_rating = Selector(text = info).xpath('//text()').extract()[2]
			#if Selector(text = info).xpath('//span/text()').extract()[0] == u'Score:':
				#anime_score = Selector(text = info).xpath('//span/text()').extract()[1]
			if Selector(text = info).xpath('//span/text()').extract() == [u'Ranked:']:
				anime_ranked = Selector(text = info).xpath('//text()').extract()[2]
			if Selector(text = info).xpath('//span/text()').extract() == [u'Popularity:']:
				anime_popularity = Selector(text = info).xpath('//text()').extract()[2]
			if Selector(text = info).xpath('//span/text()').extract() == [u'Members:']:
				anime_members = Selector(text = info).xpath('//text()').extract()[2]
			if Selector(text = info).xpath('//span/text()').extract() == [u'Favorites:']:
				anime_favorites = Selector(text = info).xpath('//text()').extract()[2]

		item['anime_title'] = anime_title
		item['anime_synopsis'] = anime_synopsis
		item['anime_background'] = anime_background
		item['anime_related'] = anime_related
		item['anime_mainactors'] = anime_mainactors
		item['anime_type'] = anime_type
		item['anime_episodes'] = anime_episodes.strip()
		item['anime_status'] = anime_status.strip()
		item['anime_aired'] = anime_aired.strip()
		item['anime_premiered'] = anime_premiered
		item['anime_producers'] = anime_producers
		item['anime_studios'] = anime_studios
		item['anime_genres'] = anime_genres
		item['anime_rating'] = anime_rating.strip()
		item['anime_score'] = anime_score
		item['anime_ranked'] = anime_ranked.strip()
		item['anime_popularity'] = anime_popularity.strip()
		item['anime_members'] = anime_members.strip()
		item['anime_favorites'] = anime_favorites.strip()

		staff_url = response.url + '/characters'
		request = scrapy.Request(staff_url, callback = self.parse_staff)
		request.meta['item'] = item

		yield request

	def parse_staff(self, response):
		item = response.meta['item']
		staff_list = response.xpath('//*[@id="content"]/table/tr/td[2]/div[1]/table').extract()
		anime_staff = dict()
		if len(staff_list) > 0:
			staff_list = staff_list[-1]
			name_list = Selector(text = staff_list).xpath('//a/text()').extract()
			title_list = Selector(text = staff_list).xpath('//small/text()').extract()
			for i in range(len(title_list)):
				titles = title_list[i].encode("ascii", "ignore").split(',')
				for title in titles:
					title_text = title.strip()
					anime_staff[title_text] = name_list[i]
		item['anime_staff'] = anime_staff
		yield item


