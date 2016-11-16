from scrapy import Spider
#from scrapy.selector import Selector
from greatschools.items import GreatschoolsItem
import numpy as np

import pandas as pd


class GSSpider(Spider):
    name = 'greatschoolsDet_spider'
    allowed_urls = ['www.greatschools.org']

    filename = '~/datascience/webscraping/greatschools/greatschools/schoolLinks.txt'
    urlList = pd.read_table(filename)
    urlList.columns = ['ID', 'Name', 'Link']


    base_urls = urlList.loc[:, "Link"].tolist()

    start_urls = [base_urls[i] + 'reviews/' for i in range(0, len(base_urls))]

    def parse(self, response):

        numStarsTxt = response.xpath('//*[@id="new_review"]/div[3]/div[1]/div[1]/span[1]/@class').extract_first()

        reviews = response.xpath('//div[@itemprop="review"]')
        respUrl = response.url

        with open("comments.txt", 'a') as f:

            for review in reviews:
                reviewText = review.xpath('.//span[@itemprop="reviewBody"]/text()').extract_first()
                reviewPostedBy = review.xpath('.//span[@class="cuc_posted-by"]/text()').extract_first()
                reviewDate = review.xpath('.//span[@itemprop="datePublished"]/@content').extract_first()
                reviewRating = review.xpath('.//meta[@itemprop="ratingValue"]/@content').extract_first()
                #schoolName = response.xpath('//span[@itemprop="title"]/text()').extract()[3].strip()
                revText = str(reviewText).encode("utf8",'ignore')
                revText = revText.replace('\n',' ')
                line = str(respUrl) + '\t' + revText + '\t' + str(reviewPostedBy) + '\t' + str(reviewDate) + '\t' + str(reviewRating) + '\n'

                f.write(line)




