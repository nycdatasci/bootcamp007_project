# Dan Jurafsky 
# Code to create csv file input to R for NYPL dataset
# Uploaded Mon Oct 3, 2016
# Assumes NYPL datasets MenuPage.csv Dish.csv MenuItem.csv Menu.csv are in .

#!/usr/bin/python
import numpy as np
from collections import defaultdict
from collections import Counter
import math
import sys
import codecs
import cProfile
import csv
import re

PREFIX='/Users/jurafsky/p/menu/work/'
sys.stdout = codecs.getwriter('utf8')(sys.stdout)


_originwords = set(['ecofriendly','sustainable','farmhouse','artisinal','artisanal','artisan','wild','raised','locally', 'market', 'local','diver','dayboat','elysian','foraged','cultivated']
        + ['farmed','farm','farms','heirloom','seasonal', 'seasonally', 'heritage', 'diver', 'dayboat', 'elysian'])
_originphrases = set(['wild caught','grass fed', 'bassett dairy', 'grass dairy', 'creek dairy', 'clawson dairy']
        + ['niman ranch', 'free range', 'hand picked', 'hand selected', 'hand dug'])
#ca camera ready:
_tradwords = set(['fashioned','traditional','old-fashioned', 'traditionally', 'timeless', 'home', 'homemade', 'homestyle', 'homebaked', 'homeade', 'homemdae', 'homespun', 'homelike', 'homemeade', 'ourhomemade','hometown','homefries','homegrown','homesetyle','homefried','homelike','homes','homeamde'])
# CA cameraready
_tradphrases = set(['american favorite','america s favorite','all american', 'our founder','time favorite','old fashion','old school', 'old favorite','family recipe','home style','home made','home baked','home roasted','home cured','home cooked','from scratch', 'home make', 'down home', 'at home', 'home scrunched', 'home spun','years ago','for years','family meatball recipe'])

_uselesswords = set(['amazing', 'awesome', 'best', 'delightful', 'dynamite', 'excellent', 'exciting', 'fabulous', 'fantastic', 'gorgeous', 'great', 'greatest', 'incredible', 'incredibly', 'magnificent', 'marvelous', 'outstanding', 'perfect', 'splendid', 'superb',  'terrific', 'wonderful']
        + ['magical','famous','fancy','fine','finest', 'greater','greatest','heavenly','incredible', 'lavish','divine','better','best','dazzling','appealing', 'beautiful', 'delightfully', 'exceptional', 'extraordinary', 'favorite', 'irresistable', 'irresistible', 'legendary', 'lovely', 'outrageous', 'popular', 'spectacular', 'striking', 'stunning', 'sublime','sensational','unforgettable','unique'])
#removed "gourmet" from historical dataset, since meaning shifted
_deliciouswords = ['licious','delicious','appetizing','luscious','savory','savoury', 'flavorful','flavorfull','appetizing','mouth-watering','mouthwatering','delectable','delious', 'scrumptious', 'tasty','toothsome', 'yummy','tastiest']
#_deliciouswords = ['gourmet','gourmets']
_choicewords = set(['choice', 'choose', 'any', 'add', 'or','specify', 'substitutions','specifications', 'options','pick'])
_choicephrases = set(['your way', 'your own', 'your liking', 'your style', 'your favorite', 'you like', 'you want', 'you request', 'way you', 'you may','select your', 'select from', 'you select', 'select one', 'select any', 'select or', 'select a', 'select up', 'select two' ])
_notadj = set([ 'phyllo crisp', 'apple crisp', 'blackberry crisp', 'parmesan crisp', 'plum crisp', 'rye crisp', 'cranberry crisp', 'berry crisp', 'blueberry crips', 'huckleberry crisp', 'dessert crisp', ])
_personwords = set([ "mother", "mom", "dad", "uncle", "aunt", "grandma", "granny", "gramma", "grandpa", "mama", "daddy", "momma", "grandmother", "grandfather", "grandmom", "aunty", "auntie", "ma's", "pop's", "mother's", "mom's", "dad's", "uncle's", "aunt's", "grandma's", "granny's", "gramma's", "grandpa's", "mama's", "daddy's", "momma's", "grandmother's", "grandfather's", "grandmom's", "aunty's", "auntie's", "mommy", "mommy's", "moms"])
_personphrases = set([ "mom s ", "mama s", "mother s",  "grandmother s", "grandma s",  "my aunt's", "ma brown","ma mmgillins", "ma mcgillins", "ma clavin", "pop pop"])
_notperson = set(['granny smith', 'daddy warbucks', 'daddy ipa', "auntie anne's", "chef ma's", "village ma's", "mother's day", "granny apple","puff daddy's","mac daddy","charlie mom", "grandmother cake", "torta della"])
_generouswords = set(['colossal','hearty', 'enormous', 'plenty', 'loads', 'lots', 'hefty', 'gigantic', 'generous', 'generously']
              + ['over size', 'over sized', 'thick cut', 'oversized','oversize','piled', 'loaded', 'heaping', 'heaped','refills', 'bottomless', 'unlimited', 'huge', 'big', 'bigger', 'biggest', 'colossal', 'ginormous','mega', 'largest','massive']
              + ['largest', 'heaping', 'refills', 'bottomless', 'unlimited', 'huge', 'big', 'bigger', 'biggest', 'ginormous','mega', 'largest','bountiful','endless','plentiful','mammoth','overstuffed'])
_generousphrases = set(['and more','with more','tons of', 'king size', 'king sized', 'texas size', 'texas sized'])
_notgenerousphrases = set(['big eye'])
_uselessphrases = ['garden salad']
_nouseless = set(['great hill','fine herbs','tarte fine'])

_edwords = set([line.strip() for line in open('adjs_ed')])
_sensoryadj = set([line.strip() for line in open('casensoryadjs')])
_adj = set([line.strip() for line in open('adjs_handcurated')])
i=0
menus = defaultdict(lambda: defaultdict(lambda:""))
menus2 = defaultdict(lambda: defaultdict(lambda:""))
dishes = defaultdict(lambda: defaultdict(lambda:""))
menuitems = defaultdict(lambda: defaultdict(lambda:""))
menupage = defaultdict(lambda: defaultdict(lambda:""))
years = defaultdict(lambda: defaultdict(lambda:""))
stored = defaultdict(int)
_mask = [ 'adj','choice','person', 'traditional', 'origin', 'generous', 'useless', 'delicious','sensoryadj']

def extractfeatures(dish):
    allwords=  dish
    allwordsset= set(allwords)
    allcounts = Counter(allwords)
    alltext=' '.join(allwords)
    allpairs = [allwords[i]+' ' +allwords[i+1] for i in range(len(allwords)-1)]
    allpairset = set(allpairs)
    allpaircounts = Counter(allpairs)
    adjlen = len(allwordsset.intersection(_adj))
    adjlen -= len(allpairset.intersection(_notadj))
    if adjlen>0:
        yield('adj',str(adjlen))
    choicelen = sum([allcounts[word] for word in _choicewords])
    choicelen += sum([allpaircounts[phrase] for phrase in _choicephrases])
    if choicelen:
        yield('choice',str(choicelen))
    personlen =  len(allwordsset.intersection(_personwords))
    personlen += len(allpairset.intersection(_personphrases))
    personlen -= len(allpairset.intersection(_notperson))
    if personlen>0:
        yield('person',str(personlen))
    tradlen = sum([allcounts[word] for word in _tradwords])
    tradlen += sum([allpaircounts[phrase] for phrase in _tradphrases])
    if personlen > 0:
        tradlen += personlen
    if tradlen>0:
        yield('traditional',str(tradlen))
    yield ('itemnumwords', str(len(allwords)))
    yield ('numletters', str(len(alltext)))
    originlen = len(allwordsset.intersection(_originwords))
    originlen += len(allpairset.intersection(_originphrases))
    if originlen:
        yield('origin',str(originlen))
    generouslen = len(allwordsset.intersection(_generouswords))
    #print "generous: ",allwordsset.intersection(_generouswords)
    generouslen += sum([allpaircounts[phrase]for phrase in _generousphrases])
    #print ([allpaircounts[phrase]for phrase in _generousphrases])
    generouslen -= sum([allpaircounts[phrase]for phrase in _notgenerousphrases])
    if generouslen > 0:
        yield('generous',str(generouslen))
    uselesslen = len(allwordsset.intersection(_uselesswords))
    uselesslen += sum([allpaircounts[phrase] for phrase in _uselessphrases])
    uselesslen -= sum([alltext.count(phrase) for phrase in _nouseless])
    if uselesslen:
        yield('useless',str(uselesslen))
    deliciouslen = len(allwordsset.intersection(_deliciouswords))
    if deliciouslen:
        yield('delicious',str(deliciouslen))
    sensoryadjlen = len(allwordsset.intersection(_sensoryadj))
    sensoryadjlen -= len(allpairset.intersection(_notadj))
    if sensoryadjlen>0:
        yield('sensoryadj',str(sensoryadjlen))

wRE = re.compile('[^a-zA-Z]')
wRE2 = re.compile('[^a-zA-Z\',;-]')
spRE = re.compile('\s+')
def tokenize(name):
    #name = wRE2.sub(' ', name)
    name = wRE.sub(' ', name)
    name = spRE.sub(' ', name).strip()
    name = name.lower()
    return name.split()

def readfiles():
    with open('Menu.csv', 'rb') as f:
        for row in csv.DictReader(f):
            #print row["id"],row["name"],row["sponsor"],row["date"]
            id = row["id"]
            menus[id] = row
            menus[id]["year"] = row["date"][0:4]
            #print id, menus[id]["year"]
            menus[id]["numitems"] = 0
            menus[id]["name"] = row["name"]
            menus[id]["location"] = row["location"]
            menus[id]["range"] = "x"
            menus[id]["abovemedian"] = "x"
            menus[id]["totalprice"] = 0
            menus[id]["pricelist"] = []
            menus[id]["featurelist"] = []
            menus[id]["featuredict"] = defaultdict(list)
            if menus[id]["currency_symbol"] == "" or menus[id]["currency_symbol"] == '$':
                menus[id]["good"] = True
            else:
                menus[id]["good"] = False
            years[menus[id]["year"]]["totalprice"] = 0
            years[menus[id]["year"]]["pricelist"] = []
            years[menus[id]["year"]]["menulist"] = []
            years[menus[id]["year"]]["numitems"] = 0
    with open('MenuPage.csv', 'rb') as f:
        for row in csv.DictReader(f):
            id = row["id"]
            menupage[id] = row
    with open('Dish.csv', 'rb') as f:
        for row in csv.DictReader(f):
            id = row["id"]
            dishes[id] = row
            dishes[id]["tokname"] = tokenize(row["name"])
    with open('MenuItem.csv', 'rb') as f:
        for row in csv.DictReader(f):
            id = row["id"]
            menu_page_id = row["menu_page_id"]
            if menus[menupage[menu_page_id]["menu_id"]]["good"] == True and row["price"] != "":
                menuitems[id] = row
                menuitems[id]["menu_id"] = menupage[menu_page_id]["menu_id"]
                menu_id = menuitems[id]["menu_id"] 
                if dishes[menuitems[id]["dish_id"]]["tokname"]:
                    hashstring = menus[menupage[menu_page_id]["menu_id"]]["year"] + ' '.join(dishes[menuitems[id]["dish_id"]]["tokname"])
                    if menus[menu_id]["name"] == "":
                        hashstring +=  menus[menu_id]["location"]
                    else:
                        hashstring += menus[menu_id]["name"]
                        #only count dishes that haven't appeared before, since there are huge numbers of duplicate menus
                    if hashstring in stored:
#                        hashstring =  "ignoring previously seen dish " + hashstring + "\n"
                        u_hash = hashstring.decode('utf-8')
                        sys.stdout.write(u_hash)
                        #dishes[menuitems[id]["dish_id"]]["tokname"] = [];
                        menuitems[id]["dish_id"] = -1
                    else:
                        stored[hashstring]=1;
                        menus[menu_id]["numitems"] += 1
                        #for feature in extractfeatures(dishes[menuitems[id]["dish_id"]]["tokname"]):
                            #menus[menu_id]["featurelist"].append(feature)
                        for (feat,val) in extractfeatures(dishes[menuitems[id]["dish_id"]]["tokname"]):
                            menus[menu_id]["featuredict"][feat].append(int(val))
                #menus[menu_id]["featurelist"].append(feature)
                        menus[menu_id]["pricelist"].append(float(menuitems[id]["price"]))
                        menuitems[id]["year"] = menus[menupage[menu_page_id]["menu_id"]]["year"]
                        menus[menu_id]["totalprice"] += float(menuitems[id]["price"])
                        #print "newly appended", menus[menu_id]["pricelist"]
                        years[menuitems[id]["year"]]["totalprice"]  = float(years[menuitems[id]["year"]]["totalprice"]) + float(menuitems[id]["price"])
                        years[menuitems[id]["year"]]["pricelist"].append(float(menuitems[id]["price"]))
                        years[menuitems[id]["year"]]["numitems"] += 1

def toppercent(pricelist,percentage):
    if pricelist:
                pricelist.sort(reverse=True)
    topquarter = int(len(pricelist)*percentage+.5)
    if topquarter:
        #print "here it is", pricelist[0:topquarter]
        return np.min(pricelist[0:topquarter])
    return 0

def bottompercent(pricelist,percentage):
    if pricelist:
                pricelist.sort(reverse=True)
    bottomquarter = int(len(pricelist)*(1-percentage)+.5)
    if bottomquarter and pricelist[bottomquarter:] != []:
        #print "computing percentage",percentage,"of pricelist",pricelist,"is", np.max(pricelist[bottomquarter:])
        return np.max(pricelist[bottomquarter:])
    #else:
        #print "not returning bottompercent", percentage,"of pricelist",pricelist
    return 0

def printrow(menu,row,menu_id):
    print >>f, '"%d" ' %  row,
    print >>f, ' "%s" ' %  menu_id,
    print >>f, ' "%s" ' %  menu["year"],
    print >>f, ' "%s" ' %  menu["abovemedian"],
    print >>f, ' "%f" ' %  menu["avgwordlen"],
    print >>f, ' "%d" ' %  menu["numwords"],
    print >>f, ' "%f" ' %  menu["numitems"],
    for feature in _mask:
        print >>f, ' "%f" ' %  menu[feature],
    print >>f

def printheaderrow():
    print >>f, ' "menuid"  ',
    print >>f, ' "year"  ',
    print >>f, ' "price"  ',
    print >>f, ' "avgwordlen"  ',
    print >>f, ' "numwords"  ',
    print >>f, ' "numitems"  ',
    for feature in _mask:
        print >>f, ' "%s" ' %  feature,
    print >>f




##### main program starts here


f  = open(PREFIX+'nypl.out', 'w')


readfiles()


for menu in menus:
    if menus[menu]["good"] == True:
        if menus[menu]["pricelist"] != []:
            #print "year", menus[menu]["year"], ":", menus[menu]["pricelist"]
            mean_price =  np.mean(menus[menu]["pricelist"])
            median_price =  np.median(menus[menu]["pricelist"])
            menus[menu]["mean_price"] = mean_price
            menus[menu]["median_price"] = median_price
            #years[menus[menu]["year"]]["menulist"].append(mean_price)
            years[menus[menu]["year"]]["menulist"].append(median_price)
            #print "features are :",  (menus[menu]["featuredict"])
            #print "about to sum ",  (menus[menu]["featuredict"]["numletters"])
            #print "about to divide by ",  (menus[menu]["featuredict"]["itemnumwords"])
            menus[menu]["avgwordlen"] = np.sum(menus[menu]["featuredict"]["numletters"])/float(np.sum(menus[menu]["featuredict"]["itemnumwords"]))
            menus[menu]["numwords"] = int(np.sum(menus[menu]["featuredict"]["itemnumwords"]))
            for feature in _mask:
                menus[menu][feature] = np.sum(menus[menu]["featuredict"][feature])/float(menus[menu]["numitems"])
            #print "generous:",  menus[menu]["generous"] 
            #menus[menu]["choice"] = np.sum(menus[menu]["featuredict"]["generous"])/float(menus[menu]["numitems"])

for year in years:
    if years[year]["menulist"] != []:
        years[year]["topquartile"] = toppercent(years[year]["menulist"],.25)
        years[year]["tophalf"] = toppercent(years[year]["menulist"],.50)
        years[year]["bottomhalf"] = bottompercent(years[year]["menulist"],.50)
        years[year]["bottomquartile"] = bottompercent(years[year]["menulist"],.25)
        years[year]["median"] = np.median(years[year]["menulist"])
        #print "year is ", year,  " median: ", years[year]["median"], " length: ", len(years[year]["menulist"])

printheaderrow()
row=0
for menu in menus:
    if menus[menu]["good"] == True:
        if years[menus[menu]["year"]]["menulist"] != [] and menus[menu]["pricelist"] != [] and len(years[menus[menu]["year"]]["menulist"]) > 3 and menus[menu]["year"] != "" and int(menus[menu]["year"]) >= 1892 and int(menus[menu]["year"]) <= 1921:
            if menus[menu]["median_price"] > years[menus[menu]["year"]]["median"]:
                menus[menu]["abovemedian"]  = "$$"
            elif menus[menu]["median_price"] < years[menus[menu]["year"]]["median"]:
                menus[menu]["abovemedian"]  = "$"
            if menus[menu]["mean_price"] >= years[menus[menu]["year"]]["topquartile"]:
                menus[menu]["range"] = "$$$$"
            elif menus[menu]["mean_price"] <= years[menus[menu]["year"]]["bottomquartile"]:
                menus[menu]["range"] = "$"
            elif menus[menu]["mean_price"] <= years[menus[menu]["year"]]["tophalf"]:
                menus[menu]["range"] = "$$"
            else:
                menus[menu]["range"] = "$$$"
            if menus[menu]["abovemedian"] == "$" or menus[menu]["abovemedian"] == "$$":
                row = row + 1
                printrow(menus[menu],row,menu)


for item in menuitems:
    if menus[menuitems[item]["menu_id"]]["good"]== True:
        #if menus[menuitems[item]["menu_id"]]["year"] and int(menus[menuitems[item]["menu_id"]]["year"]) > 1840 and int(menus[menuitems[item]["menu_id"]]["year"]) < 2015:
        if menus[menuitems[item]["menu_id"]]["year"] and int(menus[menuitems[item]["menu_id"]]["year"]) >= 1892 and int(menus[menuitems[item]["menu_id"]]["year"]) <= 1921 and (menus[menuitems[item]["menu_id"]]["abovemedian"]  == "$" or menus[menuitems[item]["menu_id"]]["abovemedian"]  == "$$"):


            if dishes[menuitems[item]["dish_id"]]["tokname"]:
                print menuitems[item]["menu_id"],"+",
                print menus[menuitems[item]["menu_id"]]["abovemedian"],"+",
                #print menus[menuitems[item]["menu_id"]]["range"],
                print menus[menuitems[item]["menu_id"]]["year"],"+",
                if menus[menuitems[item]["menu_id"]]["name"] == "":
                    namestring =  menus[menuitems[item]["menu_id"]]["location"]
                else:
                    namestring = menus[menuitems[item]["menu_id"]]["name"]
                u_str = namestring.decode('utf-8')
                sys.stdout.write(u_str)
                print "+",
                print ' '.join(dishes[menuitems[item]["dish_id"]]["tokname"])
        #else:
                #print 'skipping menu id ', menuitems[item]["menu_id"]
