import time
import os
import sys
import json
import numpy as np

import pandas as pd

from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException
from selenium.webdriver.common.action_chains import ActionChains 
 
def init_driver():
    chromedriver = "/Users/sippiejason/Downloads/chromedriver"
    os.environ["webdriver.chrome.driver"] = chromedriver
    driver = webdriver.Chrome(chromedriver)

    driver.wait = WebDriverWait(driver, 5)
    return driver
 
 
def getZillowData(rowID, driver, query):
    driver.get("http://www.zillow.com")

    oneProp = {}
# high level try/catch to get catch any error that is not accounted in nested code
# Will just return a dictionary with just the rowID
    try: 
        print "Trying to get data for " + query
    # home page
        box = driver.wait.until(EC.presence_of_element_located((By.ID, "citystatezip")))
        box.send_keys(query)

        button = driver.find_element_by_xpath('//button')     
        button.click()

    # addr landing page
    # get link to house's home page
        nextItem = driver.wait.until(EC.visibility_of_element_located((By.XPATH, '//li[@id="hdp-popout-menu"]/a[contains(@href,"homedetails")]')))
        

        x = driver.find_element_by_xpath('//li[@id="hdp-popout-menu"]/a[contains(@href,"homedetails")]').get_attribute('href')

        oneProp = scrapeProp(driver, x)
    except:
        print sys.exc_info()[0]
        print sys.exc_info()[1]
        print "There was some issue retrieving " + query


    return oneProp


def scrapeProp(driver, houseLink):
    driver.get(houseLink)
    wait = WebDriverWait(driver, 5)

    lowItem = driver.find_element_by_xpath('//span[text()=" Nearby Schools  in "]')

# move to bottom to trigger ajax calls
    ActionChains(driver).move_to_element(lowItem).perform()

    houseFact1 = driver.find_element_by_xpath('//h3[@class="edit-facts-light"]').text # basic house facts

    houseFact2 = [] 
# click on more/less for house facts
    try:
        moreLess = wait.until(EC.element_to_be_clickable((By.XPATH, '//a[text()="More "]')))
        ActionChains(driver).move_to_element(moreLess).perform()
        driver.execute_script("window.scrollBy(0,-100);")

        moreLess.click()

    # house facts list

        items =  driver.find_elements_by_xpath('//section[@class="zsg-content-section "][1]//li') # all details available
        houseFact2 = [l.text for l in items]
    except Exception as err:
        print "Couln't get house facts 2 for " + houseLink
        print err


# price history
# all tr's with price events

 # click on more/less for price history
    priceHist = []
    try:
        moreLess = wait.until(EC.element_to_be_clickable((By.XPATH, '//a/span[text()="More "]/parent::*')))
        ActionChains(driver).move_to_element(moreLess).perform()
        moreLess.click()
    except Exception as err:
        pass

    try: # Just because the button isn't there doesn't mean the price isn't there    
        items = driver.find_elements_by_xpath('//div[@id="hdp-price-history"]//tr')
        priceHist = [l.text for l in items]
    except:
        print "Couln't get price history for " + houseLink
        print sys.exc_info()[0]
        print sys.exc_info()[1]
        


# tax history
#click the tax tab
    taxHist = []
    try:
        item = wait.until(EC.element_to_be_clickable((By.XPATH,'//a[@href="#hdp-tax-history"]')))
        item.click()

        items = driver.find_elements_by_xpath('//div[@id="hdp-tax-history"]//tr')

        taxHist = [l.text for l in items]
    except Exception as err:
        print "Couln't get tax history for " + houseLink


    houseRec = {}
    houseRec["houseFact1"] = houseFact1 # string
    houseRec["houseFact2"] = houseFact2 # list
    houseRec["priceHist"] = priceHist # list
    houseRec["taxHist"] = taxHist # list

    return houseRec


def fetchProperties(zipScraped, batch):
    driver = init_driver()

    filename = '/users/sippiejason/datascience/webscraping/realestate/data/uniqueAddrs' + zipScraped + '.csv'
    ignoreListFile = '/users/sippiejason/datascience/webscraping/realestate/data/AddrAlreadyLoaded.csv'


    
    addrList = pd.read_csv(filename)
    ignoreList = pd.read_csv(ignoreListFile, index_col=0)
    ignoreList = set(ignoreList['AddrQuery'])

    # loop over list of batches
    for subBatch in batch:
        # filter out addresses in the batch
        batchAddr = addrList[addrList.batch == subBatch]

        # only for reporting
        maxID = max(batchAddr.index)

        dictList = []
        try:
            for i in batchAddr.index:
                if batchAddr.loc[i,"AddrQuery"] in ignoreList:
                    print 'Skipping ' + batchAddr.loc[i,"AddrQuery"]
                    continue

                print "starting item " + str(i) + " of " + str(maxID)
                oneItem = getZillowData(batchAddr.loc[i,"HouseID"], driver, batchAddr.loc[i,"AddrQuery"])

                oneItem['HouseID'] = batchAddr.loc[i,"HouseID"]
                oneItem['AddrQuery'] = batchAddr.loc[i,"AddrQuery"]
                oneItem['ZipCode'] = batchAddr.loc[i,"ZipCode"]

                dictList.append(oneItem)
        except:
            print sys.exc_info()[0]
            print sys.exc_info()[1]
            print "Some unknown error occurred. Will save down what's available."


        suf = str(subBatch)
        outFileName = '/users/sippiejason/datascience/webscraping/realestate/data/zillowOutput' + zipScraped + '-' + suf + '.json'

        with open(outFileName, 'w') as fout:
            json.dump(dictList, fout,  indent=4, sort_keys=True)

    driver.quit()

 
if __name__ == "__main__":

    zipScraped = "28803" #"28786"
    batch = [1, 2, 3, 4] # batch number(s) to run 

    #NOTE: did 23 and 24 for 28803


    fetchProperties(zipScraped, batch)


