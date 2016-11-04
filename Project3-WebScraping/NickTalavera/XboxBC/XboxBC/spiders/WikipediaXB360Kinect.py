# from scrapy.selector import HtmlXPathSelector
# from scrapy.spider import BaseSpider
#
# from w3lib.html import remove_tags
# from XboxBC.items import WikipediaXB360KinectItem
#
# class WikipediaXB360Kinect(BaseSpider):
#     name = "WikipediaXB360Kinect"
#     allowed_domains = ['en.wikipedia.org']
#
#     start_urls = (
#         "https://en.wikipedia.org/wiki/List_of_video_game_exclusives_(seventh_generation)",
#     )
#
#     def parse(self, response):
#         base_link = 'https://en.wikipedia.org'
#         # rows_in_big_table = response.xpath("/table/tbody/tr[2]/td[1]/i/a")
#         # rows_in_big_table = response.xpath("/table/tbody")
#         rows_in_big_table = response.xpath('//*[@id="mw-content-text"]/table[4]/tr')
#         print "=" * 50
#         for i, onerow in enumerate(rows_in_big_table):
#             WXB360ExclusiveItem = WikipediaXB360ExclusiveItem()
#
#             gameName = onerow.xpath('td/i/a/text()').extract()
#             exclusiveType = onerow.xpath('td[4]/text()').extract()
#             print(gameName)
#             print(exclusiveType)
#
#             WXB360ExclusiveItem['gameName'] = gameName
#             WXB360ExclusiveItem['exclusiveType'] = exclusiveType
#             print "=" * 50
#             yield WXB360ExclusiveItem
