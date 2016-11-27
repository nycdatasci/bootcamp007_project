from scrapy.selector import HtmlXPathSelector
from scrapy.spider import BaseSpider
from w3lib.html import remove_tags
from XboxBC.items import WikipediaXB360ExclusiveItem

class WikipediaXB360Exclusive(BaseSpider):
    name = "WikipediaXB360Exclusive"
    allowed_domains = ['en.wikipedia.org']
    start_urls = (
        "https://en.wikipedia.org/wiki/List_of_video_game_exclusives_(seventh_generation)",
    )

    def parse(self, response):
        base_link = 'https://en.wikipedia.org'
        rows_in_big_table = response.xpath('//*[@id="mw-content-text"]/table[4]/tr')
        for i, onerow in enumerate(rows_in_big_table):
            WXB360ExclusiveItem = WikipediaXB360ExclusiveItem()
            gameName = onerow.xpath('td/i/a/text()')
            if len(gameName) != 0:
                gameName = gameName[0].extract()
            publisher = onerow.xpath('td[3]/a[1]/text()')
            if len(publisher) != 0:
                publisher = publisher[0].extract()
            releaseDate = onerow.xpath('td[5]/span[1]/text()')
            if len(releaseDate) != 0:
                releaseDate = releaseDate[0].extract()[8:18]
            exclusiveType = onerow.xpath('td[4]/text()')
            if len(exclusiveType) != 0:
                exclusiveType = exclusiveType[0].extract()
            WXB360ExclusiveItem['gameName'] = gameName
            WXB360ExclusiveItem['publisher'] = publisher
            WXB360ExclusiveItem['releaseDate'] = releaseDate
            WXB360ExclusiveItem['exclusiveType'] = exclusiveType
            yield WXB360ExclusiveItem
