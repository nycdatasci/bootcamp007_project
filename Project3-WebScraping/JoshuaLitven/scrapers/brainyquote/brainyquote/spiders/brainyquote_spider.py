# -*- coding: utf-8 -*-
import csv
import logging
from scrapy import Spider, Request
from scrapy.selector import Selector
from brainyquote.items import BrainyQuoteItem, SearchResultItem

pantheon_file = '../data/pantheon.tsv'
missing_authors_file = '../data/missing_authors.txt'
open(missing_authors_file, 'w')  # empty the file

parse_quotes = True

class BrainyQuoteSpider(Spider):
    """A spider to scrape an author's quotes on brainyquote.com"""

    name = 'brainyquote_spider'
    allowed_urls = ['https://www.brainyquote.com/']

    def start_requests(self):
        """Override start requests to pull from the pantheon csv file"""

        # Iterate over names in pantheon
        with open(pantheon_file, 'r') as f:
            reader = csv.reader(f, delimiter='\t')
            next(reader, None)  # skip the headers
            for row in reader:
                author = row[1]
                url_prefix = 'https://www.brainyquote.com/search_results.html?q='
                url = url_prefix + author.replace(' ', '+')
                yield Request(url, self.parse, meta={'author': author})

    def get_last_page_number(self, response):
        """Return the last page number on an author's page"""

        try:
            # Path to the number of the last page in the navigation menu
            xpath = '//ul[@class="pagination bqNPgn pagination-sm "]/li[last()-1]/a/text()'
            last_page_number = int(response
                                   .xpath(xpath)
                                   .extract_first())
        except TypeError:
            # Only one page
            last_page_number = 1
        return last_page_number

    def parse(self, response):
        """Parse the search result of an author"""

        author_name = response.meta['author']
        print "Parsing author {}".format(author_name)
        try:
            # Extract the panel on the right containing author results
            panel = response.xpath('//*[@class="six columns omega"]').extract_first()

            # Check that the Matching Pages includes 'Authors'
            matching_pages = Selector(text=panel).xpath('//*[@class="bq_s"]').extract_first()
            matching_pages_text = Selector(text=matching_pages).xpath('//text()').extract()

            if "Authors" not in matching_pages_text:
                raise ValueError("No author page found!")

            # Get the list of authors by extracting the first row
            matches_row = Selector(text=matching_pages).xpath('//*[@class="row"]').extract_first()
            matches = Selector(text=matches_row).xpath('//*[@class="bqLn"]').extract()

            # Find matching author and extract their url
            author_href = None
            for match in matches:
                match_name = Selector(text=match).xpath('//a//text()').extract_first()
                if match_name.lower() == author_name.lower():
                    author_href = Selector(text=match).xpath('//a/@href').extract_first()
                    author_href = response.urljoin(author_href)
                    break
            if not author_href:
                raise ValueError("No matching author found!")

        except Exception, e:
            print "Error parsing author: {}".format(author_name)
            print str(e)
            with open(missing_authors_file, 'a') as f:
                f.write(author_name + '\n')
            return

        if parse_quotes:
            # Parse the author page
            request = Request(author_href, callback=self.parse_author_page, dont_filter=True,
                              meta=response.meta)
            yield request

    def parse_author_page(self, response):
        """Iterate through each quotes page of the author"""

        # Iterate through all pages
        last_page_number = self.get_last_page_number(response)

        url_prefix = response.url[:-5]
        page_urls = [url_prefix + '_' + str(n) + '.html' for n in range(1, last_page_number + 1)]

        # Yield the author's page
        for url in page_urls:
            yield Request(url, callback=self.parse_quotes_page, meta=response.meta)

    def parse_quotes_page(self, response):
        """Parse a page of an author's quotes"""

        # Get the list of quotes
        quotes = response.css('.masonryitem').extract()
        for quote in quotes:
            brainy_quote = BrainyQuoteItem()

            # Get author of quote
            brainy_quote['author'] = response.meta['author']

            # Get body of quote
            body = Selector(text=quote).xpath('//span//text()').extract_first()
            brainy_quote['body'] = body

            # Get tags of quote
            tags = []
            try:
                bottom_box = Selector(text=quote).css('.boxyBottom').extract_first()
                tags = Selector(text=bottom_box).xpath('//a//text()').extract()
            except:
                print "No tags found!"
            brainy_quote['tags'] = tags

            yield brainy_quote
