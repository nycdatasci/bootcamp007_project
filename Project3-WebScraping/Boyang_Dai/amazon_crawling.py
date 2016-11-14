from lxml import html  
import csv,os,json
import requests
from exceptions import ValueError
from time import sleep
import ast
 
def AmzonParser(url, file):
    headers = {'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.71 Safari/537.36'}
    page = requests.get(url, headers=headers)

    while True:
        sleep(3)
        try:
            doc = html.fromstring(page.content)
            XPATH_NAME = '//h1[@id="title"]//text()'
            XPATH_SALE_PRICE = '//span[contains(@id,"ourprice") or contains(@id,"saleprice")]/text()'
            XPATH_ORIGINAL_PRICE = '//td[contains(text(),"List Price") or contains(text(),"M.R.P") or contains(text(),"Price")]/following-sibling::td/text()'
            XPATH_CATEGORY = '//a[@class="a-link-normal a-color-tertiary"]//text()'
            XPATH_NumCUSTOMER_REVIEW = '//span[@id="acrCustomerReviewText"]//text()'
            XPATH_NumANSWERED_QUESTION = '//a[@id="askATFLink"]/span//text()'
            XPATH_STAR = '//span[@id="acrPopover"]/span/a/i[contains(@class, "a-icon-star")]//text()'
            XPATH_FIVESTAR = '//td[@class="a-nowrap"][2]/a[contains(@class, "a-link-normal") and contains(@title, "5 stars")]/text()'
            XPATH_FOURSTAR = '//td[@class="a-nowrap"][2]/a[contains(@class, "a-link-normal") and contains(@title, "4 stars")]/text()'
            XPATH_THREESTAR = '//td[@class="a-nowrap"][2]/a[contains(@class, "a-link-normal") and contains(@title, "3 stars")]/text()'
            XPATH_TWOSTAR = '//td[@class="a-nowrap"][2]/a[contains(@class, "a-link-normal") and contains(@title, "2 stars")]/text()'
            XPATH_ONESTAR = '//td[@class="a-nowrap"][2]/a[contains(@class, "a-link-normal") and contains(@title, "1 stars")]/text()'
            XPATH_RANK_IN_CONDOM = '//span[@class="zg_hrsr_rank"]//text()'
            XPATH_WEIGHT = '//div[@class="content"]/ul/li[1]/text()[1]'
            XPATH_PACKAGE = '//div[@id="detail-bullets_feature_div"]/div/table/tr/td/div[@class="disclaim"]/strong//text()'
            XPATH_WEIGHT = '//td[@class="bucket"]/div/ul/li[1]/text()'
            XPATH_TOP_CUSTOMER_REVIEW = '//div[@id="revMHRL"]/div/div[contains(@id, "dpReviewsMostHelpful")]/div[@class="a-section"]//text()'
            XPATH_PREVIEW_IMAGE_COUNT = '//ul[@class="a-nostyle a-button-list a-vertical a-spacing-top-micro"]/li'
            XPATH_ITEM_ALSO_BOUGHT = '//div[@class="a-section a-spacing-none p13n-asin"]/@data-p13n-asin-metadata'
            XPATH_TOP_CUSTOMER_REVIEW_STAR = '//div[@id="revMHRL"]//div[@class="a-icon-row a-spacing-none"]/a[1]/i/span/text()'
            XPATH_BRAND = '//a[@id="brand"]//text()'

# 				cd /Users/David/Desktop/NYCDSA/Project/Project_3/scrapy/spiders
			
            RAW_NAME = doc.xpath(XPATH_NAME)
            RAW_SALE_PRICE = doc.xpath(XPATH_SALE_PRICE)
            RAW_CATEGORY = doc.xpath(XPATH_CATEGORY)
            RAW_ORIGINAL_PRICE = doc.xpath(XPATH_ORIGINAL_PRICE)
            RAW_NumCUSTOMER_REVIEW = doc.xpath(XPATH_NumCUSTOMER_REVIEW)
            RAW_NumANSWERED_QUESTION = doc.xpath(XPATH_NumANSWERED_QUESTION)
            RAW_STAR = doc.xpath(XPATH_STAR)
            RAW_FIVESTAR = doc.xpath(XPATH_FIVESTAR)
            RAW_FOURSTAR = doc.xpath(XPATH_FOURSTAR)
            RAW_THREESTAR = doc.xpath(XPATH_THREESTAR)
            RAW_TWOSTAR = doc.xpath(XPATH_TWOSTAR)
            RAW_ONESTAR = doc.xpath(XPATH_ONESTAR)
            RAW_RANK_IN_CONDOM = doc.xpath(XPATH_RANK_IN_CONDOM)
            RAW_WEIGHT = doc.xpath(XPATH_WEIGHT)
            RAW_PACKAGE = doc.xpath(XPATH_PACKAGE)
            RAW_WEIGHT = doc.xpath(XPATH_WEIGHT)
            RAW_PREVIEW_IMAGE_COUNT = len(doc.xpath(XPATH_PREVIEW_IMAGE_COUNT))-2
            RAW_TOP_CUSTOMER_REVIEW = doc.xpath(XPATH_TOP_CUSTOMER_REVIEW)
            RAW_TOP_CUSTOMER_REVIEW_STAR = doc.xpath(XPATH_TOP_CUSTOMER_REVIEW_STAR)
            RAW_BRAND = doc.xpath(XPATH_BRAND)
            

            
            try:
                GENERAL_ITEM_ALSO_BOUGHT = doc.xpath(XPATH_ITEM_ALSO_BOUGHT)
                # Items also bought
                RAW_ITEM_ALSO_BOUGHT_1 = ast.literal_eval(' '.join(GENERAL_ITEM_ALSO_BOUGHT).strip().split()[0])['asin'] 
                RAW_ITEM_ALSO_BOUGHT_2 = ast.literal_eval(' '.join(GENERAL_ITEM_ALSO_BOUGHT).strip().split()[1])['asin']
                RAW_ITEM_ALSO_BOUGHT_3 = ast.literal_eval(' '.join(GENERAL_ITEM_ALSO_BOUGHT).strip().split()[2])['asin']
                RAW_ITEM_ALSO_BOUGHT_4 = ast.literal_eval(' '.join(GENERAL_ITEM_ALSO_BOUGHT).strip().split()[3])['asin']
                RAW_ITEM_ALSO_BOUGHT_5 = ast.literal_eval(' '.join(GENERAL_ITEM_ALSO_BOUGHT).strip().split()[4])['asin']
                RAW_ITEM_ALSO_BOUGHT_6 = ast.literal_eval(' '.join(GENERAL_ITEM_ALSO_BOUGHT).strip().split()[5])['asin']
                # Items also viewed
                RAW_ITEM_ALSO_VIEWED_1 = ast.literal_eval(' '.join(GENERAL_ITEM_ALSO_BOUGHT).strip().split()[6])['asin']
                RAW_ITEM_ALSO_VIEWED_2 = ast.literal_eval(' '.join(GENERAL_ITEM_ALSO_BOUGHT).strip().split()[7])['asin']
                RAW_ITEM_ALSO_VIEWED_3 = ast.literal_eval(' '.join(GENERAL_ITEM_ALSO_BOUGHT).strip().split()[8])['asin']
                RAW_ITEM_ALSO_VIEWED_4 = ast.literal_eval(' '.join(GENERAL_ITEM_ALSO_BOUGHT).strip().split()[9])['asin']
                RAW_ITEM_ALSO_VIEWED_5 = ast.literal_eval(' '.join(GENERAL_ITEM_ALSO_BOUGHT).strip().split()[10])['asin']
                RAW_ITEM_ALSO_VIEWED_6 = ast.literal_eval(' '.join(GENERAL_ITEM_ALSO_BOUGHT).strip().split()[11])['asin']
            except IndexError:
            	RAW_ITEM_ALSO_BOUGHT_1 = 'null'
            	RAW_ITEM_ALSO_BOUGHT_2 = 'null'
            	RAW_ITEM_ALSO_BOUGHT_3 = 'null'
            	RAW_ITEM_ALSO_BOUGHT_4 = 'null'
            	RAW_ITEM_ALSO_BOUGHT_5 = 'null'
            	RAW_ITEM_ALSO_BOUGHT_6 = 'null'
            	RAW_ITEM_ALSO_VIEWED_1 = 'null'
            	RAW_ITEM_ALSO_VIEWED_2 = 'null'
            	RAW_ITEM_ALSO_VIEWED_3 = 'null'
            	RAW_ITEM_ALSO_VIEWED_4 = 'null'
            	RAW_ITEM_ALSO_VIEWED_5 = 'null'
            	RAW_ITEM_ALSO_VIEWED_6 = 'null'

 
            NAME = ' '.join(''.join(RAW_NAME).split()) if RAW_NAME else None
            SALE_PRICE = ' '.join(''.join(RAW_SALE_PRICE).split()).strip() if RAW_SALE_PRICE else None
            CATEGORY = ' > '.join([i.strip() for i in RAW_CATEGORY]) if RAW_CATEGORY else None
            ORIGINAL_PRICE = ''.join(RAW_ORIGINAL_PRICE).strip() if RAW_ORIGINAL_PRICE else None
            NumCUSTOMER_REVIEW = ' '.join(RAW_NumCUSTOMER_REVIEW) if RAW_NumCUSTOMER_REVIEW else None
            NumANSWERED_QUESTION = ' '.join(RAW_NumANSWERED_QUESTION).strip() if RAW_NumANSWERED_QUESTION else None
            STAR = ' '.join(RAW_STAR) if RAW_STAR else None
            FIVESTAR = ' '.join(RAW_FIVESTAR) if RAW_FIVESTAR else None
            FOURSTAR = ' '.join(RAW_FOURSTAR) if RAW_FOURSTAR else None
            THREESTAR = ' '.join(RAW_THREESTAR) if RAW_THREESTAR else None
            TWOSTAR = ' '.join(RAW_TWOSTAR) if RAW_TWOSTAR else None
            ONESTAR = ' '.join(RAW_ONESTAR) if RAW_ONESTAR else None
            RANK_IN_CONDOM = ' '.join(RAW_RANK_IN_CONDOM) if RAW_RANK_IN_CONDOM else None
            WEIGHT = ' '.join(RAW_WEIGHT).strip() if RAW_WEIGHT else None
            PACKAGE = ' '.join(RAW_PACKAGE).strip() if RAW_PACKAGE else None
            WEIGHT = ' '.join(RAW_WEIGHT).strip() if RAW_WEIGHT else None
            PREVIEW_IMAGE_COUNT = RAW_PREVIEW_IMAGE_COUNT
            BRAND = ' '.join(RAW_BRAND).strip() if RAW_BRAND else None

            TOP_CUSTOMER_REVIEW = RAW_TOP_CUSTOMER_REVIEW
            TOP_CUSTOMER_REVIEW_STAR = RAW_TOP_CUSTOMER_REVIEW_STAR

            # Item also bought
            ITEM_ALSO_BOUGHT_1 = RAW_ITEM_ALSO_BOUGHT_1
            ITEM_ALSO_BOUGHT_2 = RAW_ITEM_ALSO_BOUGHT_2
            ITEM_ALSO_BOUGHT_3 = RAW_ITEM_ALSO_BOUGHT_3
            ITEM_ALSO_BOUGHT_4 = RAW_ITEM_ALSO_BOUGHT_4
            ITEM_ALSO_BOUGHT_5 = RAW_ITEM_ALSO_BOUGHT_5
            ITEM_ALSO_BOUGHT_6 = RAW_ITEM_ALSO_BOUGHT_6
            # Item also viewed
            ITEM_ALSO_VIEWED_1 = RAW_ITEM_ALSO_VIEWED_1
            ITEM_ALSO_VIEWED_2 = RAW_ITEM_ALSO_VIEWED_2
            ITEM_ALSO_VIEWED_3 = RAW_ITEM_ALSO_VIEWED_3
            ITEM_ALSO_VIEWED_4 = RAW_ITEM_ALSO_VIEWED_4
            ITEM_ALSO_VIEWED_5 = RAW_ITEM_ALSO_VIEWED_5
            ITEM_ALSO_VIEWED_6 = RAW_ITEM_ALSO_VIEWED_6


            if not ORIGINAL_PRICE:
                ORIGINAL_PRICE = SALE_PRICE
 
            if page.status_code!=200:
                raise ValueError('captha')

            data = {
                    'NAME':NAME,
                    'SALE_PRICE':SALE_PRICE,
                    'CATEGORY':CATEGORY,
                    'ORIGINAL_PRICE':ORIGINAL_PRICE,
                    'URL':url,
                    'NumCUSTOMER_REVIEW':NumCUSTOMER_REVIEW, 
                    'NumANSWERED_QUESTION':NumANSWERED_QUESTION,
                    'STAR':STAR,
                    '5_STAR':FIVESTAR,
                    '4_STAR':FOURSTAR,
                    '3_STAR':THREESTAR,
                    '2_STAR':TWOSTAR,
                    '1_STAR':ONESTAR,
                    'RANK_IN_CONDOM':RANK_IN_CONDOM,
                    'WEIGHT':WEIGHT,
                    'PREVIEW_IMAGE_COUNT':PREVIEW_IMAGE_COUNT,
                    'PACKAGE':PACKAGE,
                    'WEIGHT':WEIGHT,
                    'TOP_CUSTOMER_REVIEW':TOP_CUSTOMER_REVIEW,
                    'ITEM_ALSO_BOUGHT_1':ITEM_ALSO_BOUGHT_1,
                    'ITEM_ALSO_BOUGHT_2':ITEM_ALSO_BOUGHT_2,
                    'ITEM_ALSO_BOUGHT_3':ITEM_ALSO_BOUGHT_3,
                    'ITEM_ALSO_BOUGHT_4':ITEM_ALSO_BOUGHT_4,
                    'ITEM_ALSO_BOUGHT_5':ITEM_ALSO_BOUGHT_5,
                    'ITEM_ALSO_BOUGHT_6':ITEM_ALSO_BOUGHT_6,
                    'ITEM_ALSO_VIEWED_1':ITEM_ALSO_VIEWED_1,
                    'ITEM_ALSO_VIEWED_2':ITEM_ALSO_VIEWED_2,
                    'ITEM_ALSO_VIEWED_3':ITEM_ALSO_VIEWED_3,
                    'ITEM_ALSO_VIEWED_4':ITEM_ALSO_VIEWED_4,
                    'ITEM_ALSO_VIEWED_5':ITEM_ALSO_VIEWED_5,
                    'ITEM_ALSO_VIEWED_6':ITEM_ALSO_VIEWED_6,
                    'TOP_CUSTOMER_REVIEW_STAR':TOP_CUSTOMER_REVIEW_STAR,
                    'BRAND':BRAND,
                    }
 
            #json.dump(data, file, indent = 4)
            #break
            json.dump(data,file,indent=4,separators=(',', ':'))
            break
        except Exception as e:
            print e
 

#os.chdir('/Users/nycdsa/Desktop/Project_3/scrapy/spiders')
#with open('AmazonCondoms_300pg.csv', 'rU') as f:
#    reader = csv.reader(f)
#    your_list = list(reader)


def ReadAsin():
    #AsinList = csv.DictReader(open(os.path.join(os.path.dirname(__file__),"ss.csv")))
    AsinList = ['B000FQRYAI',
    			'B00BPELFBS',
    			'B0040VPKC8',
    			'B0073RAL3O',
    			# 'B008UYN4QA',
    			# 'B0083HLPLA',
    			# 'B01J939GVC',
    			# 'B00O0E0NR2',
    			# 'B004TTXA8C',
    			# 'B00BISGKJI',
    			# 'B003QL263E',
    			# 'B00NNR9SAU',
    			# 'B00BCUF8AO',
    			# 'B00U2VYOSG',
    			# 'B00C33CVSQ',
    			# 'B004WDRCTI',
       #          'B01GHPCA4U',
       #          'B00LO3QX44',
       #          'B0064FHAR6',
       #          'B005CDDUP2',
       #          'B004HTVNEC',
       #          'B00BISMMZE',
       #          'B00C33OCAG',
       #          'B000EY1I3K',
       #          'B0045ENSJ2',
       #          'B01HO2VW0S',
       #          'B00328R398',
       #          'B00714Z648',
       #          'B0073RLP3Y',
       #          'B00C343PZS',
       #          'B000HJIG5U',
       #          'B00VIJMF7I',
       #          'B01M98T85D',
       #          'B00HI35HLY',
       #          'B007O3CPVS',
       #          'B00BI0BGL8',
       #          'B0073RKL2U',
       #          'B005GM1KWY',
       #          'B0183LNHF2',
       #          'B0078OZBKA',
       #          'B00OG8GT0W',
       #          'B0001Q6DEU',
       #          'B0073R9IQA',
       #          'B000FQSLE6',
       #          'B000I0Y1K2',
       #          'B00BPELFBS',
       #          'B00R3UKU6O',
       #          'B00VIJLSQ2',
       #          'B0029XFWPE',
       #          'B00ITWY1II',
       #          'B004KU2J6O',
       #          'B0040VPKAU',
       #          'B00JRG8Q04',
       #          'B009729698',
       #          'B001GKO4X2',
       #          'B004N731ZM',
       #          'B00R6NU9ZU',
    			]
    #AsinList = [item for sublist in your_list for item in sublist]
    extracted_data = []
    with open('data.json','w') as f:
        for i in AsinList:
            url = "http://www.amazon.com/dp/"+i
            print "Processing: "+url
            AmzonParser(url, f)
            sleep(5)
    # extracted_data = []
    # for i in AsinList:
    #     url = "http://www.amazon.com/dp/"+i
    #     print "Processing: "+url
    #     extracted_data.append(AmzonParser(url))
    #     sleep(5)
    # f = open('data.json','r+')
    # json.dump(extracted_data,f,indent=4)

    

if __name__ == "__main__":
    ReadAsin()