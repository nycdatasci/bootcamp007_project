import Spider from scrapy
from scrapy.selector import Selector
import FedItem from fed.items

class fedSpider(Spider):
    name = "fedspider"
    allowed_domains=['https://fred.stlouisfed.org']
    start_urls=('https://fred.stlouisfed.org/tags/series')

    def parse(self, response):

        last_page_number = 50
        page_urls = [response.url + "?pageID=" + str(pageNumber)
                     for pageNumber in range(1, last_page_number + 1)]
        for page_url in page_urls:
            yield scrapy.Request(page_url,
                                 callback=self.parse_listing_results_page)
    def parse_listing_results_page(self, response):

        for href in response.xpath('//*[@class="col-xs-12 col-sm-10"]/a/@href').extract():
            url = response.urljoin(href)
            yield scrapy.Request(url, callback=self.parse_listing_contents)

    def parse_listing_contents(self, response):
        item = FedItem()
   ###     url_download= allowed_domains + response.xpath('//*[@id="download-button-container"]/span/div/ul/li/a/@href').extract()[2]
        tbname =response.xpath('//*[@id="series-title-text-container"]/text()').extract()
        name_short = response.xpath('//*[@id="series-title-text-container"]/span/text()').extract()


