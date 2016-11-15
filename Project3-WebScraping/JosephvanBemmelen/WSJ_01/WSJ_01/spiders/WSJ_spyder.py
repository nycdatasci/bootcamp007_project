from scrapy import Spider
from scrapy.selector import Selector
from scrapy import Request
from scrapy.selector import HtmlXPathSelector
from scrapy.http import FormRequest, Request
from WSJ_01.items import Wsj01Item



class WSJ_Spider(Spider):
	name = "WSJ_spider"
	allowed_urls = ['http://www.wsj.com/']
	start_urls = ['https://id.wsj.com/access/pages/wsj/us/signin.html?mg=inert-wsj&mg=id-wsj']

	def parse(self, response):
		return [FormRequest.from_response(response,
                    formdata={'username': 'yosefvb@gmail.com', 'password': 'yvb123'},
                    callback=self.after_login)]

	def after_login(self, response):
		print "after login"
	    # check login succeed before going on
		# if "authentication failed" in response.body:
		# 	self.log("Login failed", level=log.ERROR)
	 #    	return
		# else:
		return Request(url="http://www.wsj.com/search/term.html?KEYWORDS=the&page=1&isAdvanced=true&daysback=90d&andor=AND&sort=date-desc&source=wsjarticle",
	               callback=self.parse_searchpage)
		
	def parse_searchpage(self, response):
		print "=" * 50
		print "parsing main result page"
		for i in range(1,999,1):
			url = 'http://www.wsj.com/search/term.html?KEYWORDS=the&page='+str(i)+'&isAdvanced=true&daysback=90d&andor=AND&sort=date-desc&source=wsjarticle'
			yield Request(url, callback=self.parse_main_result_page)

	def parse_main_result_page(self, response):
		rows = response.xpath('//ul[@class="items hedSumm"]/li').extract()
		for row in rows:

			url = Selector(text=row).xpath('//h3[@class="headline"]/a/@href').extract()[0]
			url = 'http://www.wsj.com' + url
			yield Request(url, callback=self.parse_post_page)

	def parse_post_page(self, response):
		item = Wsj01Item()
		title = response.xpath('//h1[@class="wsj-article-headline"]/text()').extract()
		sections = response.xpath('//a[contains(@itemprop, "item")]/text()').extract()
		authors = response.xpath('//span[contains(@class, "name")]/text()').extract()
		date = response.xpath('//time[contains(@class, "timestamp")]/text()').extract()
		# comments = 
		blurb = response.xpath('//h2[contains(@class, "sub-head")]/text()').extract()
		paragraphs = response.xpath('//p/text()').extract()
		
		item['title'] = title
		item['sections'] = sections
		item['authors'] = authors
		item['date'] = date
		item['blurb'] = blurb
		item['paragraphs'] = paragraphs

		yield item