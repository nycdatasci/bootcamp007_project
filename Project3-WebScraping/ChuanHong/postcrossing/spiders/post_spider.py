# -*- coding: utf-8 -*-
import scrapy
import yaml
import time
from selenium import webdriver
from scrapy.selector import Selector
from postcrossing.items import CountryItem
from postcrossing.items import PostcardItem
from selenium.webdriver.common.keys import Keys
from scrapy.exceptions import NotConfigured
from selenium.common.exceptions import NoSuchElementException

class PostSpiderSpider(scrapy.Spider):

    name = "post_spider"
    allowed_domains = ["postcrossing.com"]
    login_page = 'https://www.postcrossing.com/login'
    start_urls = (
        # 'https://www.postcrossing.com/explore/countries',
        'http://www.postcrossing.com/gallery',
    )
    test = False

    def start_requests(self):
        ## open Firefox browser
        self.driver = webdriver.Firefox()
        ## add implicit waiting time
        self.driver.implicitly_wait(5)
        ## send request to parse gallery
        yield scrapy.Request(url=self.start_urls[0], callback=self.parse_gallery)

    def parse_gallery(self, response):
        ## open gallery url
        self.driver.get(response.url)
        ## check login
        self.login_check()

        ## locate gallery tab
        # gallery_tab = self.driver.current_window_handle

        while True:
            ## find postcard list in gallery
            image_list = self.driver.find_element_by_css_selector('ul.postcardImageList')
            ## iterate postcards in list
            for postcard in image_list.find_elements_by_css_selector('li.postcard'):
                ## create postcard item
                postcard_item = PostcardItem()
                ## add image url
                postcard_item['img_url'] = postcard.\
                    find_element_by_xpath('.//figure/a').\
                    get_attribute('href')
                ## add postcard url
                postcard_item['card_url'] = postcard.\
                    find_element_by_xpath('.//figure/figcaption/a[last()]').\
                    get_attribute('href')
                ## create request
                request = scrapy.Request(url=postcard_item['card_url'],
                                         callback=self.parse_postcard)
                ## create request metadata
                request.meta['item'] = postcard_item

                yield request
                time.sleep(5)

            if self.test and self.driver.current_url.rsplit('/', 1)[-1] == '3':
                self.driver.close()
                return
            ## switch back to the gallery tab
            # self.driver.switch_to.window(gallery_tab)
            ## click next page
            try:
                elem = self.driver.find_element_by_link_text('next')
                elem.click()
            except NoSuchElementException as e:
                print e.msg
                self.driver.close()
                return

    def parse_postcard(self, response):

        postcard_item = response.meta['item']

        postcard_item['from_user'], postcard_item['to_user'] = response.\
            xpath('//h3[text() = "From:"]/following-sibling::span/a/text()').extract()

        postcard_item['from_country'], postcard_item['to_country'] = response. \
            xpath('//h3[text() = "From:"]/following-sibling::span/span/a/text()').extract()

        postcard_item['from_date'], postcard_item['to_date'] = response.\
            xpath('//h3[text() = "From:"]/following-sibling::time/text()').extract()

        postcard_item['from_lat'], postcard_item['to_lat'] = response.\
            xpath('//span[@itemprop="geo"]/meta[@itemprop="latitude"]/@content').extract()

        postcard_item['from_lng'], postcard_item['to_lng'] = response.\
            xpath('//span[@itemprop="geo"]/meta[@itemprop="longitude"]/@content').extract()

        postcard_item['distance'] = response.\
            xpath('//div[@id="postcardInfo"]/div[@class="iconDistance"]/text()[last()]').\
            extract()[0].strip()

        postcard_item['travel_time'] = response.\
            xpath('//div[@id="postcardInfo"]/div[@class="iconTime"]/text()[last()]').\
            extract()[0].strip()

        return postcard_item

    def parse_country(self, response):
        for row in response.xpath('//*[@id="countryList"]/tr').extract():
            item = CountryItem()
            item['code'] = Selector(text=row).xpath('//td[1]/*/text()').extract()[0].strip()
            item['country'] = Selector(text=row).xpath('//td[2]/*/text()').extract()[0].strip()
            item['members'] = Selector(text=row).xpath('//td[3]/text()').extract()[0].strip()
            item['postcards'] = Selector(text=row).xpath('//td[4]/text()').extract()[0].strip()
            item['population'] = Selector(text=row).xpath('//td[5]/text()').extract()[0].strip()
            yield item

    def login_check(self):
        if u'Sign in required!' in self.driver.page_source:
            with open('.conf.yml', 'rb') as ymlfile:
                cfg = yaml.load(ymlfile)
            username = self.driver.find_element_by_id('username')
            password = self.driver.find_element_by_id('password')
            username.send_keys(cfg['username'])
            password.send_keys(cfg['password'])
            self.driver.find_element_by_xpath('//form/button').click()
