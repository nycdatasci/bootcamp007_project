import scrapy
from scrapy.selector import Selector
from XboxBC.items import RemastersItem
import re

class Remasters(scrapy.Spider):
    name = "Remasters"
    allowed_domains = ["gameinformer.com"]
    start_urls = (
        'http://www.gameinformer.com/themes/blogs/generic/post.aspx?WeblogApp=features&y=2016&m=05&d=16&WeblogPostName=definitive-evolving-list-new-gen-remaster-hd-remake-&PostPageIndex=1',
    )
    
    def parse(self, response):
        base_link = 'http://www.gameinformer.com'
        numberOfPages = int(response.xpath('//*[@id="divRenderBody"]/div/@rel').extract()[0])
        for j in range(1,numberOfPages+1):
            next_page = 'http://www.gameinformer.com/themes/blogs/generic/post.aspx?WeblogApp=features&y=2016&m=05&d=16&WeblogPostName=definitive-evolving-list-new-gen-remaster-hd-remake-&PostPageIndex=' + str(j)
            yield scrapy.Request(next_page, callback=self.remasterFind)

    def remasterFind(self, response):
            gameNames = response.xpath('//*[@id="divRenderBody"]/div[1]/div/p/strong/text()').extract()
            for i in range(0,len(gameNames)):
                remasterItem = RemastersItem()
                gameName = gameNames[i]
                remasterItem['gameName'] = gameName
                yield remasterItem
