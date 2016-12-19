import scrapy
import re
from ratebeer.items import BeerItem
from scrapy.http import Request
from scrapy import Selector

class RateBeerSpider(scrapy.Spider):
    name = "ratebeer_spider"
    allowed_domains = ["www.ratebeer.com"]

    def start_requests(self):
        start_url = "https://www.ratebeer.com/BestInMyArea.asp?CountryID=213&StateID="
        urls = [start_url + str(i) for i in range(1, 52)]
        for url in urls:
            request = scrapy.Request(url=url, callback=self.parse)
            yield request

    def parse(self, response):
        beer_table = response.xpath('//*[@id="rbbody"]/div[3]/div[2]/table[2]').extract()

        for i in range(2, 27):
            item = BeerItem()
            # beer_row = Selector(text=beer_table[0]).xpath('//tr[i]').extract()
            # for j in range(1, 6):
            state = response.xpath('//*[@id="rbbody"]/div[3]/div[2]/h4[2]/text()').extract()[0]
            item["state"] = re.search(r'(?<=FROM )(\w+)( )?(\w+)?(?=,)', state).group(0)

            try:
                beer_rank = Selector(text=beer_table[0]).xpath('//*/tr['+str(i)+']/td[1]/text()').extract()[0]
            except:
                beer_rank = None
            item['beer_rank'] = beer_rank

            try:
                beer_name = \
                    Selector(text=beer_table[0]).xpath('//*/tr['+str(i)+']/td[2]//*/text()').extract()[0].encode('utf-8')
            except:
                beer_name = None
            item['beer_name'] = beer_name

            try:
                brewer = Selector(text=beer_table[0]).xpath('//*/tr['+str(i)+']/td[3]//*/text()').extract()[0]
            except:
                brewer = None
            item['brewer'] = brewer

            try:
                review_count = Selector(text=beer_table[0]).xpath('//*/tr['+str(i)+']/td[4]/text()').extract()[0]
            except:
                review_count = None
            item['review_count'] = review_count

            try:
                overall_score = Selector(text=beer_table[0]).xpath('//*/tr['+str(i)+']/td[5]//*/text()').extract()[0]
            except:
                overall_score = None
            item['overall_score'] = overall_score

            # print "*" * 50
            # print beer_rank, beer_name, brewer, review_count, overall_score
            # print "*" * 50

            # try:
            root_url = "https://www.ratebeer.com"
            beer_url = \
                Selector(text=beer_table[0]).xpath('//tr['+str(i)+']/td[2]/a/@href').extract()[0].encode("utf-8")
            # except:
            #     beer_url = None
            # item['beer_url'] = beer_url
            print "-" * 50
            print root_url + beer_url
            url = root_url + beer_url
            request = Request(url, callback=self.parse_beer_info)
            request.meta['item'] = item
            print request
            print "-" * 50
            yield request

    def parse_beer_info(self, response):
        print "-" * 50
        print "IMADEIT"
        item = response.meta["item"]
        try:
            beer_img = response.xpath('//*[@id="container"]/div[2]/div[1]/a/@href').extract()[0]
        except:
            beer_img = None
        item['beer_img'] = beer_img

        try:
            style_score = response.xpath('//*[@id="_aggregateRating6"]/div[2]/div/text()').extract()[0]
        except:
            style_score = None
        item['style_score'] = style_score

        try:
            mean = \
                response.xpath('//*[@id="container"]/div[2]/div[2]/div[2]/small/a[1]/big/strong/text()').extract()[0]
        except:
            mean = None
        item['mean'] = mean

        try:
            beer_style = \
                response.xpath('//*[@id="container"]/div[2]/div[2]/div[1]/div/div[2]/div[1]/a[1]/text()').extract()[0]
        except:
            beer_style = None
        item['beer_style'] = beer_style

        try:
            wgt_avg = \
                response.xpath('//*[@id="container"]/div[2]/div[2]/div[2]/small/a[2]/big/strong/span[1]/text()').extract()[0]
        except:
            wgt_avg = None
        item['wgt_avg'] = wgt_avg

        try:
            ibu = response.xpath('//*[@id="container"]/div[2]/div[2]/div[2]/small/big[2]/text()').extract()[0]
        except:
            ibu = None
        item['ibu'] = ibu

        try:
            est_cal = response.xpath('//*[@id="container"]/div[2]/div[2]/div[2]/small/big[3]/text()').extract()[0]
        except:
            est_cal = None
        item['est_cal'] = est_cal

        try:
            abv = response.xpath('//*[@id="container"]/div[2]/div[2]/div[2]/small/big[4]/strong/text()').extract()[0]
        except:
            abv = None
        item['abv'] = abv

        try:
            beer_desc = \
                response.xpath('//*[@id="_description3"]/text()').extract()[0].lstrip('\r\n').strip().rstrip('\r\n')
        except:
            beer_desc = None
        item['beer_desc'] = beer_desc

        print beer_img, est_cal

        yield item






