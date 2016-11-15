from scrapy import Spider
#from scrapy.selector import Selector
from greatschools.items import GreatschoolsItem
import numpy as np

import pandas as pd


class GSSpider(Spider):
    name = 'greatschoolsRating_spider'
    allowed_urls = ['www.greatschools.org']

    filename = '~/datascience/webscraping/greatschools/greatschools/schoolLinks.txt'
    urlList = pd.read_table(filename)
    urlList.columns = ['ID', 'Name', 'Link']


    base_urls = urlList.loc[:, "Link"].tolist()

    start_urls = [base_urls[i] + 'quality/' for i in range(0, len(base_urls))]


    def parse(self, response):

        respUrl = response.url

        with open("ratings.txt", 'a') as f:
            testScoreRating = response.xpath('/html/body/div[7]/div[2]/div[2]/div[1]/div[2]/div[2]/div/table/tbody/tr[1]/td[2]/text()').extract_first()
            collegeReadinessRating = response.xpath('/html/body/div[7]/div[2]/div[2]/div[1]/div[2]/div[2]/div/table/tbody/tr[3]/td[2]/text()').extract_first()
            overallRating = response.xpath('/html/body/div[7]/div[2]/div[2]/div[1]/div[2]/div[1]/div/div/div[1]/text()').extract_first()

            line = str(respUrl) + '\t' + str(overallRating) + '\t' + str(collegeReadinessRating) + '\t' + str(testScoreRating) + '\n'

            f.write(line)
            f.close()




