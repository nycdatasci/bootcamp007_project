from bs4 import BeautifulSoup

f1 = open('FlightDeals.txt', 'r')
content = f1.readlines()

f2 = open('FlightDealsCleaned.txt', 'w')

for i in range(0, len(content)):
	f2.write(BeautifulSoup(content[i]).get_text())

f1.close()
f2.close()