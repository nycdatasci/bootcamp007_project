##C:/Users/shiyan/demo/mothlyReturn.py

from selenium import webdriver
import time

driver = webdriver.Chrome('C:\Users\shiyan\Documents\chromedriver_win32\chromedriver.exe')
URLstringsStart = 'http://performance.morningstar.com/fund/performance-return.action?t='
#FName = 'VMRGX' 
#FName = 'VFINX'  # try
FName = 'VDIGX'
#FName = 'VGENX'  #try again
#FName = 'VGHCX'
#FName = 'VGSLX'   #This has different URL
#FName = 'VDEQX'
#FName = 'VDIGX'
#FName = 'VEIPX'
#FName = 'VSEQX'
#FName = 'VEVFX'
#FName = 'VEXAX'
#FName = 'VBLTX'
#FName = 'VBIIX' #       intermediate-term Bond Index
#FName = 'VBISX'   #     short-term Bond Index

URLstringsEnd = '&region=usa&culture=en_US'

PageURL = URLstringsStart + FName + URLstringsEnd

driver.get(PageURL)
elems = driver.find_elements_by_xpath('//*[@id="total_returns_page"]/ul[2]/li[2]/a')
elems[0].click()

time.sleep(2)

for i in range(4,9):
	strI = str(i)
	cssAddress = '#div_monthly_returns > table > tbody:nth-child(' + strI + ')'
	elem = driver.find_element_by_css_selector(cssAddress)
	elem.click()

stringsForReturn = list("")
## put the return into strings
for selected in driver.find_elements_by_class_name('selected'):
	stringsForReturn.append(selected.text)
	print selected.text  ## just for check

## convert to ascii from unicode and build the matrix for the all the values in char type
for i in range(len(stringsForReturn)):
	stringsForReturn[i] = stringsForReturn[i].encode('ascii','ignore')
	stringsForReturn[i] = stringsForReturn[i].split(' ')

## reformat the data and output into text file (first)
lastIndex = len(stringsForReturn) - 1 

Directory = "C:/Users/shiyan/Downloads/cloudera-quickstart-vm-5.5.0-0-virtualbox/Data Science/Projects/project3/"
outfileName = Directory + FName + '_M_Data.txt'
textfile = open(outfileName,"w")

###textfile.write("Quarterly Return for : %s  \n" % FName )
for i in range(len(stringsForReturn)):
	textfile.write(stringsForReturn[lastIndex-i][0])
	textfile.write(' ')
	textfile.write(stringsForReturn[lastIndex-i][1])
	textfile.write(' ')
	textfile.write(stringsForReturn[lastIndex-i][2])
        textfile.write(' ')
	textfile.write(stringsForReturn[lastIndex-i][3])
	textfile.write('\n')

textfile.close()
driver.close()	
	