# This package will contain the spiders of your Scrapy project
#
# Please refer to the documentation for information on how to create and manage
# your spiders.
#class Major_Nelson_Blog_BC_List_Spider(scrapy.Spider):
import scrapy
from scrapy.selector import Selector
from XboxBC.items import UserVoiceItem

class UserVoice(scrapy.Spider):
    name = "UserVoice"
    allowed_domains = ["xbox.uservoice.com"]

    start_urls = (
        'https://xbox.uservoice.com/forums/298503-backwards-compatibility',
    )

    def parse(self, response):
        base_link = 'http://www.xbox.uservoice.com'

        print "=" * 50
        rows_in_big_table = response.xpath("/html/body/div[2]/div/div/div[1]/article/section[3]/ol/li[1]/div[1]/h2/a")

        # now we only consider rows with odd index number, namely, skip useless rows
        for i, onerow in enumerate(rows_in_big_table):
            if i % 2 == 0:
                continue

            movie_budget_item = UserVoiceItem()

            name  = "a"
            votes = "b"
            # release_date = onerow.xpath('td/a/text()').extract()[0]
            # _partial_url = onerow.xpath('td/b/a/@href').extract()[0]
            # movie_link = base_link + _partial_url
            # movie_name = onerow.xpath('td/b/a/text()').extract()[0]
            #
            # budgets = onerow.xpath('td[@class="data"]/text()').extract()[1:]
            # production_budget = budgets[0]
            # domestic_gross = budgets[1]
            # worldwide_gross = budgets[2]
            #
            # movie_budget_item['release_date'] = release_date
            # movie_budget_item['movie_link'] = movie_link
            # movie_budget_item['movie_name'] = movie_name
            # movie_budget_item['production_budget'] = production_budget
            # movie_budget_item['domestic_gross'] = domestic_gross
            # movie_budget_item['worldwide_gross'] = worldwide_gross

            print "=" * 50
            yield movie_budget_item
