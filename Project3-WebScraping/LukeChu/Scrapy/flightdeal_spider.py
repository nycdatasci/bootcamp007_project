from scrapy import Spider
from scrapy.selector import Selector

class FlightDealSpider(Spider):
	name = "flightdeal"
	allowed_domains = ["theflightdeal.com"]
	start_url = ["http://www.theflightdeal.com/category/flight-deals/"]


	def parse(self, response):
    		pass
    	# blocks = Selector(response).xpath('id('main')/x:div/x:div[1]/x:div')

    	# for block in blocks:







