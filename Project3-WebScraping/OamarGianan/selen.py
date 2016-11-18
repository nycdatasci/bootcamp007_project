from selenium import webdriver
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException
from selenium.webdriver.common.by import By
from selenium.webdriver.common.action_chains import ActionChains
import time
import numpy as np
import pickle
"""
Selenium looping script to load all chord progression combinations
These chord progressions were selected based on the following assumptions:
    -chords will be described by Roman numerals instead of keys;
    -cover only four note chord progressions in western music
    -chord progressions are in standard diatonic harmony
The following chord preogressions will be scraped:
#Major sounds
I-IV-vi-V *h
I-V-vi-IV *%h
I-V-vi-iii h
I-V-iv-I
I-V-IV-V *h
I-V-IV-IV *
I-vi-II-V %
I-vi-IV-V *%h
I-vi-V-IV *
#meh sounds
IV-ii-vi-iii *
IV-V-iii-vi *
IV-V-vi-iii *
IV-V-vi-ii *
#minor sounds
vi-I-IV-V *
vi-I-V-vi *
vi-IV-I-V *
vi-IV-ii-iii *
vi-IV-II-V *
vi-V-IV-V *h
"""

c_prog = ("1.4.6.5",
"1.5.6.3",
"1.5.6.4",
"1.5.4.1", #missing
#"1.5.4.4", #missing, but checking website, no results shown.
"1.5.4.5", #missing
"1.6.2.5",
"1.6.4.5",
"1.6.5.4",
"4.2.6.3",
"4.5.3.6",
"4.5.6.3",
"4.5.6.2",
"6.1.4.5",
"6.1.5.6",
"6.4.1.5",
"6.4.2.3",
"6.4.2.5",
"6.5.4.5")
start_url = "https://www.hooktheory.com/trends#node="
append_url =  "&key=rel"
path_to_chromedriver = '/home/oamar/Documents/NYCDataScience/Projects/Web Scraping/chromedriver' # change path as needed

#loop for creating urls
html = dict()
for chord in c_prog:
    urls = start_url + chord + append_url
    print urls
    driver = webdriver.Chrome(executable_path = path_to_chromedriver)
    driver.get(urls)
    driver.maximize_window()
    while True:
        try:
            time.sleep(5)
            load_more = driver.find_element_by_xpath("//*[@id='cp-results_showmore']")
            ActionChains(driver).move_to_element(load_more).click().perform()
            print "clicking load more"
        except:
            print "no more to load"
            break
#do this until end of list
####end loop for clicking load-more

# And grab the page HTML source
    print "saving source to dictionary with key as", chord
    html[chord] = driver.page_source
    driver.quit()
####end loop for opening chord progressions

#save dictionary object to file
pickle.dump(html, open( "sources.p", "wb" ) )
