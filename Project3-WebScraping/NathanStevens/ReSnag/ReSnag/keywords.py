# -*- coding: utf-8 -*-
"""
Created on Wed Nov 09 11:49:45 2016
This class has a function which uses web scraping
to return a list of keywords to seach on
@author: nathan
"""
from bs4 import BeautifulSoup
import urllib

# define the webpage where the keywords we need
site_url = "https://application.wiley-vch.de/vch/journals/keyword.php"
page = urllib.urlopen(site_url).read()
soup = BeautifulSoup(page)

# function to parse the website which contains the keywords
def load_keywords():
    keywords = []
    
    all_tables = soup.find_all('table') 
    
    for table in all_tables:
        rows = table.findAll('tr')
        for row in rows:
            cells = row.findAll('td')
             
            # get the keyword if we are in the right row 
            if len(cells) == 2 and 'mm_kwd' in cells[0].text:
                keyword = cells[0].text.split('"')[1::2][0]
                if len(keyword) > 4:                
                    keywords.append(keyword.lower())
    
    # return the keywords
    return keywords

keywords = load_keywords()
print '# keywords #: ', len(keywords)
# now defines are function which takes a test and looks for
# the keywords within that text
def get_keywords(text):
    global keywords
    text = text.lower()
    return [kw for kw in keywords if(kw in text)]

# some text code    
#print 'Keywords: ' + str(get_keywords('nano thin film Strontium'))
    
                    