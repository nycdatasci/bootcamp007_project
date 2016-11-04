# from scrapy.selector import HtmlXPathSelector
# from scrapy.spider import BaseSpider
#
# from w3lib.html import remove_tags
# from XboxBC.items import StationScraperItem
#
# class WikipediaXB360Exclusive(BaseSpider):
#     name = "WikipediaXB360Exclusive"
#     allowed_domains = ['wikipedia.org']
#
#     def parse(self, response):
#         hxs = HtmlXPathSelector(response)
#         items = []
#         stations = hxs.select("//body//table[@class='wikitable']//tr")
#         for station in stations:
#             item = StationScraperItem()
