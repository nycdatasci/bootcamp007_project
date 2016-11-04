# This package will contain the spiders of your Scrapy project
#
# Please refer to the documentation for information on how to create and manage
# your spiders.
#class Major_Nelson_Blog_BC_List_Spider(scrapy.Spider):
import scrapy
from scrapy.selector import Selector
from XboxBC.items import MajorNelsonItem

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
        print(rows_in_big_table)
        for i, onerow in enumerate(rows_in_big_table):
            xb360_Ex_item = MajorNelsonItem()

# //*[@id="DataTables_Table_0"]/tbody/tr[51]/td[1]/a
            gameName = onerow.xpath('td[1]/a/text()').extract()[0]
            print(gameName)

            xb360_Ex_item['gameName'] = gameName
            yield xb360_Ex_item
            print "=" * 50
