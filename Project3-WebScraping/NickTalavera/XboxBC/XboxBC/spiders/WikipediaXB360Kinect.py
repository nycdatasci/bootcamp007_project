from scrapy.selector import HtmlXPathSelector
from scrapy.spider import BaseSpider

from w3lib.html import remove_tags
from XboxBC.items import WikipediaXB360KinectItem

class WikipediaXB360Kinect(BaseSpider):
    name = "WikipediaXB360Kinect"
    allowed_domains = ['en.wikipedia.org']

    start_urls = (
        "https://en.wikipedia.org/wiki/List_of_Kinect_games_for_Xbox_360",
    )

    def parse(self, response):
        base_link = 'https://en.wikipedia.org'
        rows_in_big_table = response.xpath('//*[@id="mw-content-text"]/table/tr')
        print "=" * 50
        for i, onerow in enumerate(rows_in_big_table):
            # if len(onerow.xpath('td/i/text()').extract()) == 0:
            #     continue
                # //*[@id="mw-content-text"]/table/tbody/tr[6]/td[1]/i/a
            WXB360KinectItem = WikipediaXB360KinectItem()

            gameName = onerow.xpath('td[1]/i/a/text()').extract()
            if len(gameName) == 0:
                gameName = onerow.xpath('td/i/text()').extract()
            kinectRequired = onerow.xpath('td[9]/text()').extract()
            # if kinectRequired == 'Yes':
            #     kinectRequired = 'TRUE'
            # else:
                # kinectRequired = 'FALSE'
            # td[9]
            kinectSupport = 'TRUE'
            print(gameName)
            print(kinectRequired)
            print(kinectSupport)

            WXB360KinectItem['gameName'] = gameName
            WXB360KinectItem['kinectRequired'] = kinectRequired
            WXB360KinectItem['kinectSupport'] = kinectSupport
            print "=" * 50
            yield WXB360KinectItem
