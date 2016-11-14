import scrapy
import json
from TvShows.items import ImdbItem

# scrapy crawl imdb_spider -o imdb_final.json

class ImdbUrlGenerator():
    def __init__(self):
        pass

    def extract_search_menu(self):
        with open("imdburl_reduced.json", "r") as js:
            urls = json.load(js)

        links = [url["show_url"] for url in urls]

        return links


class ImdbSpider(scrapy.Spider):
    name = "imdb_spider"
    allowed_domains = ["imdb.com"]
    start_urls = ImdbUrlGenerator().extract_search_menu()

    def parse(self, response):
        item = ImdbItem()

        try:
            show_name = response.xpath('//*[@id="title-overview-widget"]/div[2]/div[2]/div/div[2]/div[2]/h1/'
                           'text()').extract()[0].strip().rstrip('\\xa0')
        except:
            show_name = None
        item["show_name"] = show_name

        try:
            imdb_rating = response.xpath('//*[@id="title-overview-widget"]/div[2]/div[2]/div/div[1]/div[1]/div[1]/'
                           'strong/span/text()').extract()[0]
        except:
            imdb_rating = None
        item["imdb_rating"] = imdb_rating

        yield item



