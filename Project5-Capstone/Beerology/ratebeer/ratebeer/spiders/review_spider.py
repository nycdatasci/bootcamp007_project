import scrapy
import re
from ratebeer.items import ReviewItem
from scrapy.http import Request
from scrapy import Selector



class BeerReviewSpider(scrapy.Spider):
    name = "beerreview_spider"
    allowed_domains = ["www.ratebeer.com"]

    def start_requests(self):
        start_url = "https://www.ratebeer.com/BestInMyArea.asp?CountryID=213&StateID="
        urls = [start_url + str(i) for i in range(14, 27)] #State ID
        for url in urls:
            request = scrapy.Request(url=url, callback=self.parse)
            yield request

    def parse(self, response):

        beer_table = response.xpath('//*[@id="rbbody"]/div[3]/div[2]/table[2]').extract()

        # number of beers on state page
        for i in range(2, 27):

            root_url = "https://www.ratebeer.com"
            beer_url = \
                Selector(text=beer_table[0]).xpath('//tr['+str(i)+']/td[2]/a/@href').extract()[0].encode("utf-8")

            print "-" * 50
            print root_url + beer_url
            prod_url = root_url + beer_url
            rev_count = Selector(text=beer_table[0]).xpath('//*/tr['+str(i)+']/td[4]/text()').extract()[0]
            print type(rev_count)
            print rev_count

            if int(rev_count) <= 10:
                print "One Page"
                request = Request(prod_url, callback=self.parse_reviews)
            else:
                print "Multiple Pages"
                request = Request(prod_url, callback=self.parse_revpg_urls)
            yield request

    def parse_revpg_urls(self, response):
        root_url = "https://www.ratebeer.com"
        # i = 1
        revpg_url = response.xpath('//*[@id="container"]/div[2]/div[2]/div[9]/a[1]/@href').extract()

        if revpg_url:
            last_pgnum = response.xpath('//*[@id="container"]/div[2]/div[2]/div[9]/a/text()').extract()[-1]
            print "page num exists"
            # firstpg_url = revpg_url[0][:-2]+"1/"
            # pgs_urls = [root_url+firstpg_url]
            pgs_urls = [root_url + re.sub('[0-9]+\/$', '', response.xpath('//*[@id="container"]/div[2]/div[2]/div[9]/a[1]/@href')
                                                                          .extract()[0]) + str(i) + "/" for i in range(1, int(last_pgnum)+1)]

            # while revpg_url:
            #     last_page = revpg_url[0]
            #     # pgs_urls.append(root_url+revpg_url[0])
            #
            #     # print last_page
            #     # i += 1
            #     revpg_url = \
            #         response.xpath('//*[@id="container"]/div[2]/div[2]/div[9]/a['+str(i)+']/@href').extract()
            # # last_pgnum = re.search(r'[0-9]+\/$', revpg_url[0]).group(0).strip("/")
            # print last_pgnum

            for url in pgs_urls:
                print "#" * 50
                print url
                request = Request(url, callback=self.parse_reviews)
                yield request

    def parse_reviews(self, response):
        item = ReviewItem()
        try:
            # beer_name = response.xpath('//*[@id="container"]/div[1]/div[2]/div/span/div/h1/span/text()').extract()[0]
            beer_name = response.xpath('//*[@itemprop="name"]/text()').extract()[0].encode('utf-8')
        except:
            beer_name = None
        print beer_name
        item["beer_name"] = beer_name
        state = response.xpath('//*[@id="container"]/div[2]/div[2]/div[1]/div/div[2]/div[1]/a[3]/text()').extract()[0].strip()
        item["state"] = state

        review_container = response.xpath('//*[@id="container"]/div[2]/div[2]/div[7]').extract()

        num_reviews = len(Selector(text=review_container[0]).xpath('//div/div/div/strong').extract())

        for rev in range(1, num_reviews+1):
            try:
                user_rating = \
                    Selector(text=review_container[0]).xpath('//div/div/div['+str(2*rev-1)+']/div[2]/text()').extract()[0]
            except:
                user_rating = None
            item["user_rating"] = user_rating

            try:
                aroma = \
                    Selector(text=review_container[0]).xpath('//div/div/div['+str(2*rev-1)+']/strong/big[1]/text()').extract()[0].split('/')[0]
            except:
                aroma = None
            item["aroma"] = aroma

            try:
                appearance = \
                    Selector(text=review_container[0]).xpath('//div/div/div['+str(2*rev-1)+']/strong/big[2]/text()').extract()[0].split('/')[0]
            except:
                appearance = None
            item["appearance"] = appearance

            try:
                taste = \
                    Selector(text=review_container[0]).xpath('//div/div/div['+str(2*rev-1)+']/strong/big[3]/text()').extract()[0].split('/')[0]
            except:
                taste = None
            item["taste"] = taste

            try:
                palate = \
                    Selector(text=review_container[0]).xpath('//div/div/div['+str(2*rev-1)+']/strong/big[4]/text()').extract()[0].split('/')[0]
            except:
                palate = None
            item["palate"] = palate

            try:
                overall = \
                    Selector(text=review_container[0]).xpath('//div/div/div['+str(2*rev-1)+']/strong/big[5]/text()').extract()[0].split('/')[0]
            except:
                overall = None
            item["overall"] = overall

            try:
                user_name = Selector(text=review_container[0]).xpath('//div/div/small['+str(rev)+']/a/text()').extract()[0]
            except:
                user_name = None
            item["user_name"] = user_name

            try:
                user_info = Selector(text=review_container[0]).xpath('//div/div/small['+str(rev)+']/text()').extract()[0].encode('utf-8')
            except:
                user_info = None
            item["user_info"] = user_info

            try:
                rev_ls = Selector(text=review_container[0]).xpath('//div/div/div['+str(2*rev)+']/text()').extract()
                review = "|".join(rev_ls).encode('utf-8', 'ignore')
            except:
                review = None
            item["review"] = review

            print "*" * 50
            print "beer name: ", beer_name
            print "state: ", state
            print "user rating: ", user_rating
            print "user name: ", user_name
            print "aroma: ", aroma
            print "appearance: ", appearance
            print "taste: ", taste
            print "palate: ", palate
            print "overall: ", overall
            print "user info: ", user_info
            print "review: ", review
            print "-" * 50

            yield item














