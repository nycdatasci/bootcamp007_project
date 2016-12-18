import scrapy
from scrapy.selector import Selector
from XboxBC.items import MajorNelsonItem
import re
class Major_Nelson_Blog_BC_List_Spider(scrapy.Spider):
    name = "Major_Nelson_Blog_BC_List"
    allowed_domains = ["majornelson.com"]
    start_urls = (
        'https://majornelson.com/blog/xbox-one-backward-compatibility/',
    )
    def parse(self, response):
        rows_in_big_table = response.xpath('//*[@id="post-20954"]/div/div/table/tbody/tr')
        for i, onerow in enumerate(rows_in_big_table):
            xb360_Ex_item = MajorNelsonItem()
            gameName = onerow.xpath('td[1]/a/text()').extract()
            if len(gameName) > 0:
                gameName = gameName[0].strip()
            else:
                continue
            xb360_Ex_item['gameName'] = gameName
            xb360_Ex_item['BCCompatible'] = 'TRUE'
            yield xb360_Ex_item
