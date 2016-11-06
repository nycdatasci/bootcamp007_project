# -*- coding: utf-8 -*-

# author : Conred Wang
# title : Wed scraping using Scrapy.  Code 1 of 3.  items.py

from scrapy import Item, Field

# SkyscraperItem has information about one skyscraper/building:
# Type-1. Some fields are from primary page "https://skyscrapercenter.com/buildings".
# Type-2. Some fields are from secondary pages by navigating the skyscraper's/building's specific url.
# Type-3. Some fields are derived by fields mentioned above.
#.........Example-1 forOffice (Type-3) value Y/N is set by checking if "office" is in blgPurpose (Type-1).
# ........Example-2 tmStartComplete (Type-3) = yrComplete (Type-1) - yrStart (Type-2.)

class SkyscraperItem(Item):
	blgName = Field() # skyscraper/building name
	blgCity = Field() # skyscraper/building city
	blgCountry = Field() # skyscraper/building country code
	blgFloor = Field() # skyscraper/building number of floors
	blgPurpose = Field() # skyscraper/building usage/purpose
	blgUrl = Field() # skyscraper/building url - page of individual/specific information 
	hgtRank = Field() # skyscraper/building height ranking   
	hgtFeet = Field() # skyscraper/building height in feet
	isMultiPurpose = Field() # Y/N. Is the skyscraper/building usage mutli-purposed? 
	forOffice = Field() # Y/N. Is the skyscraper/building for office?
	forResidential = Field() # Y/N. Is the skyscraper/building for reisdential?
	forHotel = Field() # Y/N. Is the skyscraper/building for hotel?
	forRetail = Field() # Y/N. Is the skyscraper/building forrental?   
	yrPropose = Field() # Year the skyscraper/building was proposed.
	yrStart = Field() # Year the skyscraper/building construction started.    
	yrComplete = Field() # Year the skyscraper/building construcion completed.
	tmProposeStart = Field() # Time taken (in year) from prosposal to construction started.
	tmProposeComplete = Field() # Time taken (in year) from prosposal to construcion completed.
	tmStartComplete = Field() # Time taken (in year) from construction started to construcion completed.

