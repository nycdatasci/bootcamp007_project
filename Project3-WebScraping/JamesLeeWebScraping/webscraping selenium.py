from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.common.exceptions import NoSuchElementException
from bs4 import BeautifulSoup
from selenium.webdriver.support.ui import Select
from geopy.geocoders import Nominatim
import unicodedata
import re
import pandas as pd

geolocator = Nominatim()


driver = webdriver.Chrome('/Users/James/Desktop/chromedriver.exe')
looptime = ['18']
loopdate = ['2016-11-26']
loopparty = ['4']
restaurant = []
cuisinel = []
diningl = []
addressl = []
pricel = []
restaurant2 = []

for p in loopparty:
    for d in loopdate:
        for i in looptime:
            driver.get("http://www.opentable.com/s/?covers="+p+"&currentview=list&datetime="+d+"+"+i+"%3A00&metroid=8&regionids=16&size=100&sort=Popularity&from=0")
            html = BeautifulSoup(driver.page_source)
            pagen = int(html.find_all('span', {'class':'js-pagination-page pagination-link '})[-1].text)*100
            for j in range(0, pagen, 100):
                pagel = str(j)
                driver.get("http://www.opentable.com/s/?covers="+p+"&currentview=list&datetime="+d+"+"+i+"%3A00&metroid=8&regionids=16&size=100&sort=Popularity&from="+pagel)
                rhtml = BeautifulSoup(driver.page_source)
                restaurantlist = rhtml.find_all('span', {'class':"rest-row-name-text"})[3:]
                for r in range(0,len(restaurantlist)):
                    restaurant.append(unicodedata.normalize("NFKD", restaurantlist[r].text).encode('ascii','ignore'))

restaurantl = [re.sub('&', 'and',s) for s in restaurant]
restaurantl = [re.sub(' - ', '-', s) for s in restaurantl]
restaurantl = [re.sub(r'[^a-zA-Z0-9\s-]+', '', s) for s in restaurantl]
restaurantl = [re.sub(r'\s+', '-', s) for s in restaurantl]



for l in restaurantl:
    try:
        driver.get("http://www.opentable.com/"+l)
        hide = driver.find_element(By.XPATH, '//*[@id="info"]/div[6]/a')
        hide.click()
        driver.implicitly_wait(3)
        xcuisine = driver.find_element(By.XPATH, '//*[@id="profile-details"]/div/div/div[1]/p[2]/span[2]').text
        xcuisine = str(unicodedata.normalize("NFKD", xcuisine).encode('ascii','ignore'))
        cuisine = xcuisine.split(',')[0]
        cuisinel.append(cuisine)
        dining = str(driver.find_element(By.XPATH, '//*[@id="profile-details"]/div/div/div[1]/p[1]/span[2]').text)
        diningl.append(dining)
        baddress = driver.find_element(By.XPATH, '//*[@id="info"]/div[2]/div/div[2]/div/div').text
        baddress = str(unicodedata.normalize("NFKD", baddress).encode('ascii','ignore'))
        baddress = re.sub('\\n', ' ', baddress)
        addressl.append(baddress)
        nhtml = BeautifulSoup(driver.page_source)
        title = nhtml.find_all('h1', {'itemprop':'name'})[0].text
        restaurant2.append(str(unicodedata.normalize("NFKD", title).encode('ascii','ignore')))
    except NoSuchElementException as e:
        try:
            driver.get("http://www.opentable.com/r/"+l+"-new-york")
            hide = driver.find_element(By.XPATH, '//*[@id="info"]/div[6]/a')
            hide.click()
            driver.implicitly_wait(3)
            xcuisine = driver.find_element(By.XPATH, '//*[@id="profile-details"]/div/div/div[1]/p[2]/span[2]').text
            xcuisine = str(unicodedata.normalize("NFKD", xcuisine).encode('ascii','ignore'))
            cuisine = xcuisine.split(',')[0]
            cuisinel.append(cuisine)
            dining = str(driver.find_element(By.XPATH, '//*[@id="profile-details"]/div/div/div[1]/p[1]/span[2]').text)
            diningl.append(dining)
            baddress = driver.find_element(By.XPATH, '//*[@id="info"]/div[2]/div/div[2]/div/div').text
            baddress = str(unicodedata.normalize("NFKD", baddress).encode('ascii','ignore'))
            baddress = re.sub('\\n', ' ', baddress)
            addressl.append(baddress)
            nhtml = BeautifulSoup(driver.page_source)
            title = nhtml.find_all('h1', {'itemprop':'name'})[0].text
            restaurant2.append(str(unicodedata.normalize("NFKD", title).encode('ascii','ignore')))        
        except NoSuchElementException as e:
            try:
                driver.get("http://www.opentable.com/r/"+l)
                hide = driver.find_element(By.XPATH, '//*[@id="info"]/div[6]/a')
                hide.click()
                driver.implicitly_wait(3)
                xcuisine = driver.find_element(By.XPATH, '//*[@id="profile-details"]/div/div/div[1]/p[2]/span[2]').text
                xcuisine = str(unicodedata.normalize("NFKD", xcuisine).encode('ascii','ignore'))
                cuisine = xcuisine.split(',')[0]
                cuisinel.append(cuisine)
                dining = str(driver.find_element(By.XPATH, '//*[@id="profile-details"]/div/div/div[1]/p[1]/span[2]').text)
                diningl.append(dining)
                baddress = driver.find_element(By.XPATH, '//*[@id="info"]/div[2]/div/div[2]/div/div').text
                baddress = str(unicodedata.normalize("NFKD", baddress).encode('ascii','ignore'))
                baddress = re.sub('\\n', ' ', baddress)
                addressl.append(baddress)
                nhtml = BeautifulSoup(driver.page_source)
                title = nhtml.find_all('h1', {'itemprop':'name'})[0].text
                restaurant2.append(str(unicodedata.normalize("NFKD", title).encode('ascii','ignore')))
            except NoSuchElementException as e:
                print(l)

        

tabledata = pd.DataFrame({'Restaurant': restaurant2, 'Address': addressl, 'Cuisine': cuisinel, 'DiningStyle': diningl})
tabledata.to_csv('OpenTableData3.csv')

