import scrapy
import json
from scrapy.selector import Selector
from AnimeReviews.items import AnimereviewsItem
last_page = 1789

class AnimeReviewsSpider(scrapy.Spider):
	name = 'AnimeReviews_spider'
	allowed_urls =['myanimelist.net']
	start_urls = ['https://myanimelist.net/reviews.php?t=anime']

	

	def parse(self, response):
		page_urls = [response.url + "&p=" + str(pageNumber) for pageNumber in range(1, last_page+1)]
		#page_urls = ['https://myanimelist.net/reviews.php?t=anime']
		for page_url in page_urls:
			yield scrapy.Request(page_url,
				callback = self.parse_reviews_page)

	def parse_reviews_page(self, response):
		item = AnimereviewsItem()
		reviews = response.xpath('//*[@class="borderDark pt4 pb8 pl4 pr4 mb8"]').extract()       #each page displays 50 reviews

		for review in reviews:
			anime_title = Selector(text = review).xpath('//div[1]/a[1]/strong/text()').extract()
			anime_url = Selector(text = review).xpath('//a[@class="hoverinfo_trigger"]/@href').extract()
			anime_url = map(lambda x: 'https://myanimelist.net'+ x ,anime_url)
			review_time = Selector(text = review).xpath('//*[@style="float: right;"]/text()').extract()[0]
			reviewer_name = Selector(text = review).xpath('//div[2]/table/tr/td[2]/a/text()').extract()
			rating = Selector(text = review).xpath('//div[2]/table/tr/td[3]/div[2]/text()').extract()
			for i in range(len(rating)):
				rating_temp = rating[i]
				rating[i] = rating_temp.split(" ")[1]
			review_text = Selector(text = review).xpath('//*[@class="spaceit textReadability word-break"]').extract()
			for i in range(len(review_text)):
				text = Selector(text = review_text[i]).xpath('//text()').extract()
				#print "----"*20
				#print len(text)
				#print text[0], 0
				#print text[1], 1
				#print text[2], 2
				#print text[3], 3
				#print text[4], 4
				#print text[5], 5
				#print text[43], 43
				text = text[43:]            #review texts start at 44th
				text = reduce(lambda x, y: (x+y).strip(), map(lambda x: x.encode('ascii','ignore'), text), ' ')
				#review_text[i] = text
				if Selector(text = review_text[i]).xpath('//span[@style="display: none;"]').extract():
					# print Selector(text = review_text[i]).xpath('//span[@style="display: none;"]').extract()
					text1 = (Selector(text = review_text[i]).xpath('//span[@style="display: none;"]/text()').extract()[0]).encode('ascii','ignore')
					text = text + text1
				#text = re.search('more picsOverall[0-9]Story[0-9]Animation[0-9]Sound[0-9]Character[0-9]Enjoyment[0-9](.+?)', text).group(1)
				review_text[i] = text
				# print text
				# temp_text = "%r"%text
				# m = re.search(r'</table>\\n\\t\\t</div>(.+?)</div>$', temp_text[1:-1])
				# review_text[i] = m.group(1)
				# if m is not None: 
				# 	review_text[i] = m.group(1)
				# else:
				# 	m = re.search(r'</table>\\n\\t\\t</div>(.+?)<span', temp_text[1:-1])
				# 	n = re.search(r'<span.+?>(.+?)</span>', temp_text[1:-1])
				# 	review_text[i] = m.group(1) + n.group(1)

			#review = review.replace("\\", "\\\\")
			#review = re.search(r'</table>(.+?) </div>$', review).group(1)
			pic_url = Selector(text = review).xpath('//div[3]/div[1]/div[1]/a/img/@data-src').extract()
			#print len(anime_title)
			item['anime_title'] = anime_title
			item['anime_url'] = anime_url
			item['review_time'] = review_time
			item['reviewer'] = reviewer_name
			item['rating'] = rating
			item['review_text'] = review_text
			item['pic_url'] = pic_url
			yield item

		
		

		


#Selector(text = response.xpath('//*[@class="borderDark pt4 pb8 pl4 pr4 mb8"]').extract()[0]).xpath('//div[1]/a[1]/strong/text()').extract()
#Selector(text = response.xpath('//*[@class="borderDark pt4 pb8 pl4 pr4 mb8"]').extract()[0]).xpath('//*[@style="float: right;"]/text()').extract()
#//*[@id="content"]/div[3]/div[3]
