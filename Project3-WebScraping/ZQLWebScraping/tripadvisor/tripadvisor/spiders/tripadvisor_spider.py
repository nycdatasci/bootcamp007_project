### tripadvisor spider

import scrapy
from scrapy.selector import Selector
from tripadvisor.items import TripadvisorItem

QUERY = ['-Orlando_Florida-Hotels.html']

#https://www.tripadvisor.com/Hotels-g34515-Orlando_Florida-Hotels.html
# class BnbspiderSpider(scrapy.Spider):
class TripadvisorSpider(scrapy.Spider):
    name = "tripadvisorspider"
    # allowed_domains = ["https://www.tripadvisor.com"]
    start_urls = ['https://www.tripadvisor.com/Hotels-g34515' + x for x in QUERY]

    def last_pagenumer_in_search(self, response):
        '''
        Function defined to get the largest page number of search result
        '''
        try:  # to get the last page number 
            last_page_number = int(response.xpath('//div[@class="pageNumbers"]/a[@class="pageNum last taLnk"]/@data-page-number').
                                    extract()[0]
                                   )
            return last_page_number

        except:
            return -1


    def parse(self, response):
        last_page_number = self.last_pagenumer_in_search(response)
        if last_page_number == -1:
            return
        else:
            page_urls = ['https://www.tripadvisor.com/Hotels-g34515-oa' + str(pageNumber*30) + "-Orlando_Florida-Hotels.html"
                     for pageNumber in range(1, last_page_number+1)]
                     #  u'/Hotels-g34515-oa330-Orlando_Florida-Hotels.html#ACCOM_OVERVIEW'
            for page_url in page_urls:
                yield scrapy.Request(page_url, 
                                    callback=self.parse_listing_results_page)



    def parse_listing_results_page(self, response):
        #print "=" * 50
        for href in response.xpath('//div[@class="listing_title"]/a/@href').extract():
            yield scrapy.Request('https://www.tripadvisor.com' + href, callback=self.parse_listing_contents)


    def parse_listing_contents(self, response):
        print response.url
        item = TripadvisorItem()
        item['review_score'] = response.xpath('//div[@class="heading_rating separator"]/div[1]/div[1]/span/@content').extract()
        item["price_range"] = response.xpath('//*[@property="priceRange"]/text()').extract()
        #item["location"] =  response.xpath('//*[@class="mapWxH"]/img/@src').extract() 
        # item["address"] = response.xpath('//*[@class="format_address"]//text()').extract()[8] + \
        #                 response.xpath('//*[@class="format_address"]//text()').extract()[9] +\
        #                 response.xpath('//*[@class="format_address"]//text()').extract()[10]
        address = response.xpath('//*[@class="format_address"]/span[@property="streetAddress"]/text()').extract()
        city = response.xpath('//*[@class="format_address"]/span[@class="locality"]/span[@property="addressLocality"]/text()').extract()
        state = response.xpath('//*[@class="format_address"]/span[@class="locality"]/span[@property="addressRegion"]/text()').extract()  
        zipcode = response.xpath('//*[@class="format_address"]/span[@class="locality"]/span[@property="postalCode"]/text()').extract()       
        item["address"] = address + city + state + zipcode
        item["services"] = filter(lambda x: str(x).strip() != "", response.xpath('//*[@class="amenity_lst"]//li/text()').extract())
        item["hotel_name"]= response.xpath('//h1[@id="HEADING"]/text()').extract()
        item["review_tag"]=filter(lambda x: str(x).strip() != "", response.xpath('//*[@class="ui_tagcloud_group easyClear"]//text()').extract())
        item["hotel_star"]= response.xpath('//div[@class="additional_info stars"]//text()').extract()[2]

    # response.xpath('//div[class="rs rating"]').extract()
    # //*[@id="taplc_hr_meta_block_offerclick_0"]/div[4]/div[1]/div/div[1]/div[1]/div/div
    
        yield item
    #         