import scrapy
from scrapy import Spider
from scrapy.selector import Selector
from happyhour.items import YelpItem


class yelpSpider(scrapy.Spider):
    name = "happyhour_spider"
    allowed_domains = ['https://www.yelp.com']
    start_urls = ["https://www.yelp.com/search?find_desc=Happy+Hour+Specials&find_loc=Boston,+MA&start=0"]
    

    # def last_pagenumer_in_search(self, response):
    #     try:  # to get the last page number 
    #         last_page_number = int(response
    #                                .xpath('//ul[@class="list-unstyled"]/li[last()-1]/a/@href')
    #                                .extract()[0]
    #                                .split('page=')[1]
    #                                )
    #         return last_page_number

    #     except IndexError:  # if there is no page number
    #         # get the reason from the page
    #         reason = response.xpath('//p[@class="text-lead"]/text()').extract()
    #         # and if it contains the key words set last page equal to 0
    #         if reason and ('find any results that matched your criteria' in reason[0]):
    #             logging.log(logging.DEBUG, 'No results on page' + response.url)
    #             return 0
    #         else:
    #         # otherwise we can conclude that the page 
    #         # has results but that there is only one page.
    #             return 1


    # def parse(self, response):
    #     last_page_number = self.last_pagenumer_in_search(response)
    #     if last_page_number < 1:
    #         return
    #     else:
    #         page_urls = [response.url + "?page=" + str(pageNumber)
    #                  for pageNumber in range(1, last_page_number + 1)]
    #         for page_url in page_urls:
    #             yield scrapy.Request(page_url, 
    #                                 callback=self.parse_listing_results_page)


    def parse(self, response):

        #what are these for?
        #sel = Selector(response)
        #sites = sel.xpath('//a[@class="biz-name js-analytics-click"]/@href').extract()
        names = response.xpath('//a[@class="biz-name js-analytics-click"]//span/text()').extract()

        for name in names:
            item = YelpItem()
            item['name'] = name
            yield item

        # for site in sites:
        #     item = YelpItem()
        #     name=site.xpath('div/div[1]/div[2]/h3/span/a/text()').extract()
        #     if len(name)>0:
        #         item['name'] = name[0]
        #     else:
        #         item['name'] = ''

            # url=site.xpath('div/div[1]/div[2]/h3/span/a/@href').extract()
            # if len(url)>0:
            #     item['url'] = u'http://www.yelp.com'+url[0]
            # else:
            #     item['url'] = ''

            # address_l1=site.xpath('div/div[2]/address/text()[1]').extract()
            # if len(address_l1)>0:
            #     item['address_l1'] = address_l1[0].replace('\n','').strip()
            # else:
            #     item['address_l1'] = ''

            # address_l2=site.xpath('div/div[2]/address/text()[2]').extract()
            # if len(address_l2)>0:
            #             item['address_l2'] = address_l2[0].replace('\n','').strip() 
            # else:
            #     item['address_l2'] = ''

            # phone=site.xpath('div/div[2]/span[2]/text()').extract()
            # if len(phone)>0:
            #     item['phone']=phone[0].replace('\n','').strip()
            # else:
            #     phone = ''

            # item['category'] = site.xpath('div/div[1]/div[2]/div[2]/span[2]/a/text()').extract()

            # rating=site.xpath('div/div[1]/div[2]/div[1]/div/i/@title').extract()
            # if len(rating)>0:
            #     item['rating'] = rating[0].split(' ')[0]
            # else:
            #     item['rating'] = ''

            # price_rating=site.xpath('div/div[1]/div[2]/div[2]/span[1]/span/text()').extract()
            # if len(price_rating)>0:
            #     item['price_rating'] = unicode(str(len(price_rating[0]))) 
            # else:
            #     item['price_rating'] = ''

            #items.append(item)
        
            #yield items