# -*- coding: utf-8 -*-
import scrapy
from test.items import TestItem


# class TedtalkSpider(scrapy.Spider):
class TestSpider(scrapy.Spider):
    name = 'testspider'
    allowed_domains = ["ted.com"]
    start_urls = [
        "https://www.ted.com/talks"
    ]

    def last_pagenumber_in_search(self, response):
        last_page_number = int(response
                               .xpath('//*[@id="browse-results"]/div[2]/div/a[5]/text()')
                               .extract()[0]
                               )
        return last_page_number


    def parse(self, response):
        last_page_number = self.last_pagenumber_in_search(response)
        if last_page_number < 1:
            return
        else:
            page_urls = [response.url + "?page=" + str(pageNumber)
                for pageNumber in range(1, last_page_number + 1)]
            for page_url in page_urls:
                yield scrapy.Request(page_url,
                                     callback = self.parse_listing_results_page)


    def parse_listing_results_page(self, response):
        url_lst = response.xpath('//a[contains(@href, "/talks/")]/@href').extract()
        url_lst = set(url_lst)
        url_lst = list(url_lst)
        for href in url_lst:
            url = response.urljoin(href)
            yield scrapy.Request(url, callback = self.parse_listing_contents)


    def parse_listing_contents(self, response):
        item = TestItem()
        item['title'] = response.xpath('//*[@id="player-hero"]/div[1]/div[2]/h1/div[2]/span/text()').extract()
        item['speaker'] = response.xpath('//*[@id="player-hero"]/div[1]/div[2]/h1/div[1]/span/text()').extract()
        item['ted_info'] = response.xpath('//*[@id="player-hero"]/div[1]/div[2]/div/strong/text()').extract()
        item['duration'] = response.xpath('//*[@id="player-hero"]/div[1]/div[2]/div/span[1]/text()').extract()
        item['filmed_date'] = response.xpath('//*[@id="player-hero"]/div[1]/div[2]/div/span[2]/text()').extract()[1]
        item['upload_date'] = response.xpath('//*[@id="talk"]/meta[4]/@content').extract()
        item['subtitle'] = response.xpath('//*[@id="hero-subtitle-link"]/text()').extract()[1]
        item['total_views'] = response.xpath('//*[@id="sharing-count"]/span/text()').extract()
        item['speaker_desc'] = response.xpath('//*[@class="talk-speaker__description"]/text()').extract()
        item['similar_topics'] = response.xpath('/html/head/meta[4]/@content').extract()
        item['url_og'] = response.xpath('/html/head/meta[8]/@content').extract()
        item['related_talk1'] = response.xpath('//*[@id="talk"]/div[2]/div/div/div/div[1]/div/div/h4/a/div[2]/text()').extract()
        item['related_talk2'] = response.xpath('//*[@id="talk"]/div[2]/div/div/div/div[2]/div/div/h4/a/div[2]/text()').extract()
        item['related_talk3'] = response.xpath('//*[@id="talk"]/div[2]/div/div/div/div[3]/div/div/h4/a/div[2]/text()').extract()
        item['related_talk4'] = response.xpath('//*[@id="talk"]/div[2]/div/div/div/div[4]/div/div/h4/a/div[2]/text()').extract()
        item['related_talk5'] = response.xpath('//*[@id="talk"]/div[2]/div/div/div/div[5]/div/div/h4/a/div[2]/text()').extract()
        item['related_talk6'] = response.xpath('//*[@id="talk"]/div[2]/div/div/div/div[6]/div/div/h4/a/div[2]/text()').extract()
        item['comment_num'] = response.xpath('//*[@class="h11"]/text()').extract()
        item['imgs_url'] = response.xpath('//*[@id="player-hero-poster"]/img/@src').extract()
        item['speaker_img_url'] = response.xpath('//*[@id="talk-pusher"]/div[1]/div[2]/div[1]/div[2]/div/a/span/span/span/img/@src').extract()
        yield item
