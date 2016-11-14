import scrapy
import urllib2
from TvShows.items import UrlItem
import pandas as pd

# scrapy crawl url_spider -o imdburl_reduced.json

class TvUrlGenerator():
    def __init__(self):
        pass

    def extract_search_menu(self):
        with open("showname_reduced.csv", "r") as f:
            shownames = pd.read_csv(f)

        urls = []
        for row in shownames.iterrows():
            title = row[1][0].strip().replace(" ", "_").replace("'", "")
            title_utf = urllib2.quote(title.encode('utf-8'))
            imdb_search_menu = "http://www.imdb.com/find?ref_=nv_sr_fn&q={}&s=tt".format(title_utf)
            urls.append(imdb_search_menu)
        # print "=" * 50
        # print urls
        return urls

class UrlImdbSpider(scrapy.Spider):
    name = "url_spider"
    allowed_domains = ["imdb.com"]
    start_urls = TvUrlGenerator().extract_search_menu()

    def parse(self, response):
        item = UrlItem()

        first_href = response.xpath("//table[@class='findList']/tr/td[@class='result_text']/a/@href").extract()[0]
        full_url = "http://www.imdb.com" + first_href

        item["show_url"] = full_url

        yield item
