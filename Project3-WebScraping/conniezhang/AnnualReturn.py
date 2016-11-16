

## Annual Return

from selenium import webdriver
driver = webdriver.Chrome('C:\Users\shiyan\Documents\chromedriver_win32\chromedriver.exe')

#FName = 'VMRGX' # done in R
##FName = 'VDEQX'  #done 
#FName = 'VDIGX'
#FName = 'VGENX'  #try again
#FName = 'VGHCX'
#FName = 'VGSLX'   #
#FName = 'VDEQX'
#FName = 'VDIGX'
#FName = 'VEIPX'
#FName = 'VFINX'   # in R
#FName = 'VEVFX'
#FName = 'VEXAX'
#FName = 'VBLTX'
#FName = 'VSEQX'
#FName = 'VBIIX' #       intermediate-term Bond Index
FName = 'VBISX'   #     short-term Bond Index

PageURL ='https://finance.yahoo.com/quote/' + FName +'/performance?p=' + FName

driver.get(PageURL)
stringsForReturn = list("")
stringsForReturn = driver.find_element_by_xpath('//*[@id="main-0-Quote-Proxy"]/section/div[2]/section/section/div[3]').text
# covert unicode to ascii
stringsForReturn = stringsForReturn.encode('ascii','ignore')
stringsForReturn = stringsForReturn.split('\n')

Directory = "C:/Users/shiyan/Downloads/cloudera-quickstart-vm-5.5.0-0-virtualbox/Data Science/Projects/project3/"
outfileName = Directory + FName + '_Annual_Data.txt'
textfile = open(outfileName,"a")
for i in range(1, len(stringsForReturn), 3):
	textfile.write(' {} {} {} \n'.format(stringsForReturn[i], stringsForReturn[i+1], stringsForReturn[i+2]))

textfile.close()
driver.close()