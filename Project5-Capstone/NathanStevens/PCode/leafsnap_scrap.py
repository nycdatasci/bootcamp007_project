# -*- coding: utf-8 -*-
"""
Created on Wed Nov 09 11:49:45 2016
This script is used for scraping data from the leafsnap site
for integration into the java desktop application

@author: nathan
"""
from bs4 import BeautifulSoup
import urllib
import unicodecsv as csv

# the file to save records to
leafsnap_file = '../raw_data/leafsnap'

# define the webpage where the keywords we need
site_url = "http://leafsnap.com/species/"
page = urllib.urlopen(site_url).read()
soup = BeautifulSoup(page)

# save observations to CSV files
def saveRecordsToCSV(filename, records):
    try:    
        fieldnames = ['spc_latin', 'spc_common', 'leaf', 'flower', 'fruit', 'url']
    
        with open(filename + ".csv", 'wb') as out_file:
            csvwriter = csv.DictWriter(out_file, delimiter=',', fieldnames=fieldnames)
            csvwriter.writeheader()   
    
            for row in records:
                csvwriter.writerow(row)
        
            out_file.close()
    except:
        e = sys.exc_info()[0]
        print 'file %s, %s' % (filename, e)

# function to parse the website which contains the keywords
def scrapSpeciesInfo():
    records = []
    
    table = soup.find('table', {"class" : "speciesTable"}) 
    
    for row in table.findAll('tr'):
        print("processing species records ...")
        
        obs = {}

        cols = row.findAll('td')
        if len(cols) == 5:
            img = cols[0].find('img')
            obs['leaf'] = img['src']
            
            img = cols[1].find('img')
            obs['flower'] = img['src']
            
            img = cols[2].find('img')
            obs['fruit'] = img['src']
            
            obs['spc_common'] = cols[3].text.strip().upper()            
            obs['spc_latin'] = cols[4].text.strip().upper()              
            
            obs['url'] = 'http://leafsnap.com/species/' + cols[4].find('a', href = True)['href']
            
            records.append(obs)            
    
    # return the records
    return records

# scrap the species information now
records = scrapSpeciesInfo()
saveRecordsToCSV(leafsnap_file, records)

print 'species count: ', len(records)
