# This package will contain the spiders of your Scrapy project
#
# Please refer to the documentation for information on how to create and manage
# your spiders.
#class Major_Nelson_Blog_BC_List_Spider(scrapy.Spider):
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

# //*[@id="DataTables_Table_0"]
# //*[@id="DataTables_Table_0"]/tbody/tr[1]
    # now we only consider rows with odd index number, namely, skip useless rows
    def parse(self, response):
        rows_in_big_table = response.xpath('//*[@id="post-20954"]/div/div/table/tbody/tr')
        print "=" * 50
        for i, onerow in enumerate(rows_in_big_table):
            xb360_Ex_item = MajorNelsonItem()
            gameName = onerow.xpath('td[1]/a/text()').extract()
            if len(gameName) > 0:
                gameName = gameName[0].strip()
            else:
                print 'FAILED'
                continue
            xb360_Ex_item['gameName'] = gameName
            xb360_Ex_item['BCCompatible'] = 'TRUE'
            yield xb360_Ex_item
            print "=" * 50
