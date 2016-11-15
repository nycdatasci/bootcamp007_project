
## Quartely Return

from selenium import webdriver
driver = webdriver.Chrome('C:\Users\shiyan\Documents\chromedriver_win32\chromedriver.exe')

#FName = 'VMRGX' # done  seeks long-term growth of capital: stocks of mid- and large-capitalization US companies
#FName = 'VDEQX'  #done  seeks long-term capital appreciation and dividend income fund of funds of VG family
#FName = 'VDIGX'  #done  seeks to provide primarily a growing stream of income over time, invest in stocks that tend to offer current dividends

#FName = 'VGENX' #done  seeks to provide long-term capital appreciation 80% invested in energy industry
#FName = 'VGHCX'  #done  long-term capital appreciation, 80% of its assets in stocks of health care related industry
#FName = 'VGSLX' #done  REIT Index (composed of stocks of publicly traded equity real estate investment trusts)

#FName =  'VFINX'  #done 500 index fund  baseline fund

#FName = 'VSEQX'  # done    seeks to provide long-term capital appreication mainly in the stocks of small and mid-side of US companies.

# Bond Funds    
#FName = 'VBLTX'  #done     Long-term Bond Index: seeks to track the peroformance of a market-weighted bond index
#FName = 'VBIIX' #       intermediate-term Bond Index
FName = 'VBISX'   #     short-term Bond Index

PageURL ='https://finance.yahoo.com/quote/' + FName +'/performance?p=' + FName

driver.get(PageURL)
stringsForReturn = list("")
stringsForReturn = driver.find_element_by_xpath('//*[@id="main-0-Quote-Proxy"]/section/div[2]/section/section/div[4]').text
# covert unicode to ascii
stringsForReturn = stringsForReturn.encode('ascii','ignore')
stringsForReturn = stringsForReturn.split('\n')

Directory = "C:/Users/shiyan/Downloads/cloudera-quickstart-vm-5.5.0-0-virtualbox/Data Science/Projects/project3/"
outfileName = Directory + FName + '_QY_Data.txt'
textfile = open(outfileName,"w")
for i in range(1, len(stringsForReturn), 5):
	textfile.write(' {} {} {} {} {} \n'.format(stringsForReturn[i], stringsForReturn[i+1], stringsForReturn[i+2],
	stringsForReturn[i+3],stringsForReturn[i+4]))

textfile.close()
driver.close()