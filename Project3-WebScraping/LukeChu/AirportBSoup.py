from bs4 import BeautifulSoup
import urllib2

url = "https://www.orbitzforbusiness.net/shared/pagedef/content/air/airportCodes.jsp"

content = urllib2.urlopen(url).read()

soup = BeautifulSoup(content)

f = open('AirportCodes.txt', 'w')


airport_codes = soup.find_all('li')

# last checked: 3636
# minus 13 canadian codes for province + territories (do manually, it's trivial)
# search for Ontario, etc.

# but R gives 3709??? wut
print len(airport_codes)
for i in range(0, len(airport_codes)):
	
	f.write((airport_codes[i].get_text()).rstrip() + '|')


f.close()
