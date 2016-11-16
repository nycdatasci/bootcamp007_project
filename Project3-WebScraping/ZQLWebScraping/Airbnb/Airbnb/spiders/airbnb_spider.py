# -*- coding: utf-8 -*-
import scrapy
import json
from Airbnb.items import AirbnbItem

QUERY = 'Orlando--FL--United-States'

# class BnbspiderSpider(scrapy.Spider):
class BnbSpider(scrapy.Spider):
    name = "airbnbspider"
    allowed_domains = ["airbnb.com"]
    start_urls = (
        'https://www.airbnb.com/s/'+QUERY,
    )

    def last_pagenumer_in_search(self, response):
        try:  # to get the last page number 
            last_page_number = int(response
                                   .xpath('//ul[@class="list-unstyled"]/li[last()-1]/a/@href')
                                   .extract()[0]
                                   .split('page=')[1]
                                   )
            return last_page_number

        except IndexError:  # if there is no page number
            # get the reason from the page
            reason = response.xpath('//p[@class="text-lead"]/text()').extract()
            # and if it contains the key words set last page equal to 0
            if reason and ('find any results that matched your criteria' in reason[0]):
                logging.log(logging.DEBUG, 'No results on page' + response.url)
                return 0
            else:
            # otherwise we can conclude that the page 
            # has results but that there is only one page.
                return 1

    def parse(self, response):
        last_page_number = self.last_pagenumer_in_search(response)
        if last_page_number < 1:
            return
        else:
            page_urls = [response.url + "?page=" + str(pageNumber)
                     for pageNumber in range(1, last_page_number + 1)]
            for page_url in page_urls:
                yield scrapy.Request(page_url, 
                                    callback=self.parse_listing_results_page)



    def parse_listing_results_page(self, response):
        for href in response.xpath('//a[@class="media-photo media-cover"]/@href').extract():
            url = response.urljoin(href)
            yield scrapy.Request(url, callback=self.parse_listing_contents)


    def parse_listing_contents(self, response):
        item = AirbnbItem()
        item['review_score_a'] = response.xpath('//div[@class="star-rating"]/@content').extract()[1]

        json_array = response.xpath('//meta[@id="_bootstrap-room_options"]/@content').extract()
        if json_array:
            airbnb_json_all = json.loads(json_array[0])
            airbnb_json = airbnb_json_all['airEventData']
            item['rev_count'] = airbnb_json['visible_review_count']
            item['amenities'] = airbnb_json['amenities']
            item['host_id'] = airbnb_json_all['hostId']
            item['hosting_id'] = airbnb_json['hosting_id']
            item['room_type'] = airbnb_json['room_type']
            item['price'] = airbnb_json['price']
            item['bed_type'] = airbnb_json['bed_type']
            item['person_capacity'] = airbnb_json['person_capacity']
            item['cancel_policy'] = airbnb_json['cancel_policy']
            item['rating_communication'] = airbnb_json['communication_rating']
            item['rating_cleanliness'] = airbnb_json['cleanliness_rating']
            item['rating_checkin'] = airbnb_json['checkin_rating']
            item['satisfaction_guest'] = airbnb_json['guest_satisfaction_overall']
            item['instant_book'] = airbnb_json['instant_book_possible']
            item['accuracy_rating'] = airbnb_json['accuracy_rating']
            item['response_time'] = airbnb_json['response_time_shown'] 
            item['nightly_price'] = airbnb_json_all['nightly_price']
            item['lon'] = airbnb_json['listing_lng']            
            item['lat'] = airbnb_json['listing_lat']
        item['url'] = response.url

        json_array1 = response.xpath('//*[@id="_bootstrap-trip_details"]/@content').extract()
        if json_array1:
            airbnb_json_all1 = json.loads(json_array1[0])
            airbnb_json1 = airbnb_json_all1['pricing_quote']
            item['cleaning_fee'] = airbnb_json1['cleaning_fee_usd']
            item['service_fee'] = airbnb_json1['service_fee_usd']
            item['tax'] = airbnb_json1['tax_amount_usd']
        yield item

