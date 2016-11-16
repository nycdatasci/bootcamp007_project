from scrapy import Spider
#from scrapy.selector import Selector
from greatschools.items import GreatschoolsItem
import numpy as np

import pandas as pd


class GSSpider(Spider):
    name = 'greatschools_spider'
    allowed_urls = ['www.greatschools.org']

    baseURL ='''http://www.greatschools.org/search/search.page?gradeLevels%5B%5D=h&distance=60&st%5B%5D=public&state=NJ&city=Butler&lat=40.9886496&lon=-74.3822058&locationSearchString=07405&locationType=postal_code&normalizedAddress=Butler%2C%20NJ%2007405'''
    start_urls = [baseURL + "&page=" + str(i) for i in range(1,17)]

    def parse(self, response):
        rows = response.xpath('//div[@class="pvm gs-bootstrap js-schoolSearchResult js-schoolSearchResultCompareErrorMessage"]/div') # all the rows

        filename = 'test.txt'
        with open(filename, 'a') as f:

            for row in rows:
                schoolName = row.xpath(".//a[@class='open-sans_sb mbs font-size-medium rs-schoolName']/text()").extract_first()
                schoolLnk = row.xpath(".//a[contains(@href,'reviews')]/@href").extract_first()
                schoolID = row.xpath('.//div/@data-schoolid').extract_first()


                line = str(schoolID) + '\t' + str(schoolName) + '\t' + str(schoolLnk) + '\n'
                f.write(line)



