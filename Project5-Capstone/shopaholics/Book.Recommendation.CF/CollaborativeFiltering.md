
# Book Recommendation using

# Collaborative Filtering


### by Chris Valle, Jhonasttan Regalado, Conred Wang


*Marcel Caraciolo suggested a [collaborative filtering (CF) algorithm](http://aimotion.blogspot.com/2009/11/collaborative-filtering-implementation.html) based on distance-base similarity score.  We adopted his approach and built a simple book recommendation engine, and we tested it using the [Book-Crossing Dataset](http://www2.informatik.uni-freiburg.de/~cziegler/BX/).  Since this dataset has many zero implicit ratings, we replaced these ratings with average ratings when possible. Then we re-tested our engine with the enhanced dataset.  And we observed that the number of ratings available to CF do impact the recommendations made by the engine.


```python
# CollaborativeFiltering.ipynb

import numpy as np
import pandas as pd
from math import sqrt
```

## Data Structures

We use two types of 2D matrices, implemented using Python dictionary, to capture the user-item-rating information.

1. _prefs_
  * In order to provide recommendation for a user, 2D prefs matrix will have users as rows and items as columns; i.e., rating stores as __prefs[user][item]__ 
  * We provide two __prefs__ matrices:
    * **prefsLess** which is based on non-zero ratings from original dataset.
    * **prefsMore** which includes prefsLess plus additional non-zero ratings by imputing average ratings. 

2. _critics_
  * In order to provide recommendation for an item, 2D critics matrix will have items as rows and users as columns; i.e., rating stores as __critics[item][user]__ 
  * We provide two __critics__ matrices:
    * **criticsLess** which is just a re-arrangement of **prefsLess**.  
    * **criticsMore** which is just a re-arrangement of **prefsMore**.  


```python
"""
* Build prefsLess using BX-Books.csv and BX-Book-Ratings.csv.
* Both files are from original Book-Crossing Dataset.  
* They use ";" as field separator.
"""
def buildPrefsLess():
	#Load books information
	books = {}
	for line in open("data/BX-Books.csv"):
		line = line.replace('"', "")
		(id,title) = line.split(";")[0:2]
		books[id] = title
	
	#Load ratings information
	prefs = {}
	countValueError = 0
	countKeyError = 0
	for line in open("data/BX-Book-Ratings.csv"):
		line = line.replace('"', "")
		line = line.replace("\\","")
		(user,bookid,rating) = line.split(";")[0:3]
		try:
			if float(rating) > 0.0:
				prefs.setdefault(user,{})
				prefs[user][books[bookid]] = float(rating)
		except ValueError:
			countValueError += 1
		except KeyError:
			countKeyError += 1
	print "# .Value Error : " + str(countValueError)
	print "# ...Key Error : " + str(countKeyError)
	return prefs
```


```python
prefsLess = buildPrefsLess()
```

    # .Value Error : 1
    # ...Key Error : 49818



```python
"""
* Build prefsMore using MC.Books.csv and Good.Ratings.csv.
* They are based on BX-Books.csv and BX-Book-Ratings.csv, 
  with some data cleaning and zero-ratings replacement (with average ratings) when available.  
* They use "," as field separator.
"""
def buildPrefsMore():
	#Load books information
	books = {}
	for line in open("data/MC.Books.csv"):
		line = line.replace('"', "")
		line = line.replace("\\","")
		line = line.replace("\n","")                
		(id,title) = line.split(",")[0:2]
		books[id] = title
	
	#Load ratings information
	prefs = {}
	countValueError = 0
	countKeyError = 0
	for line in open("data/Good.Ratings.csv"):
		line = line.replace('"', "")
		line = line.replace("\\","")
		line = line.replace("\n","")        
		(user,bookid,rating) = line.split(",")[0:3]
		try:
			if float(rating) > 0.0:
				prefs.setdefault(user,{})
				prefs[user][books[bookid]] = float(rating)
		except ValueError:
			countValueError += 1
		except KeyError:
			countKeyError += 1
	print "# .Value Error : " + str(countValueError)
	print "# ...Key Error : " + str(countKeyError)
	return prefs
```


```python
prefsMore = buildPrefsMore()
```

    # .Value Error : 2
    # ...Key Error : 76127



```python
print "# prefsLess values : " + str(sum(len(v) for v in prefsLess.itervalues()))
print "# prefsLess values : " + str(sum(len(v) for v in prefsMore.itervalues()))
```

    # prefsLess values : 382807
    # prefsLess values : 846584



```python
"""
Spot check. Same.
"""
print "prefsLess['98556'] : ", prefsLess['98556']
print "prefsMore['98556'] : ", prefsMore['98556']
```

    prefsLess['98556'] :  {'Foundation (Foundation Novels (Paperback))': 7.0}
    prefsMore['98556'] :  {'Foundation (Foundation Novels (Paperback))': 7.0}



```python
"""
Spot check. Same.
"""
print "prefsLess['180727'] : ", prefsLess['180727']
print "\nprefsMore['180727'] : ", prefsMore['180727']
```

    prefsLess['180727'] :  {'Foundation (Foundation Novels (Paperback))': 3.0, 'Brave New World': 6.0, 'Jeeves in the morning (Perennial library)': 7.0, 'Foundation and Empire (Foundation Novels (Paperback))': 4.0, "Foundation's Edge : The Foundation Novels (Foundation Novels (Paperback))": 3.0, 'Second Foundation (Foundation Novels (Paperback))': 4.0}
    
    prefsMore['180727'] :  {'Foundation (Foundation Novels (Paperback))': 3.0, 'Brave New World': 6.0, 'Jeeves in the morning (Perennial library)': 7.0, 'Foundation and Empire (Foundation Novels (Paperback))': 4.0, "Foundation's Edge : The Foundation Novels (Foundation Novels (Paperback))": 3.0, 'Second Foundation (Foundation Novels (Paperback))': 4.0}



```python
"""
Spot check. prefsMore has user 276725, but not found in prefsLess.

In "BX-Book-Ratings.csv", user "276725" has only 1 entry and with zero rating:
> bc7_cwang@nodeD:~/Book.Recommendation.CF$ grep '"276725"' data/BX-Book-Ratings.csv 
> "276725";"034545104X";"0" # According to Amazon, <ISBN-10: 034545104X> is for hardcover <Flesh Tones>.
Since "Good.Ratings.csv" has average rating 6 for <Flesh Tones>, prefsMore capture the rating.
"""
print prefsLess.has_key('276725')
print prefsMore.has_key('276725')
print "prefsMore['276725'] : ", prefsMore['276725']
```

    False
    True
    prefsMore['276725'] :  {'Flesh Tones: A Novel': 6.0}



```python
"""
Function transform from prefs[user][item] to critics[item][user].
"""
def transformPrefs(prefs):
	results = {}
	for user in prefs:
		for item in prefs[user]:
			results.setdefault(item,{})
			#Flip item and user
			results[item][user] = prefs[user][item]
	return results
```


```python
criticsLess = transformPrefs(prefsLess)
criticsMore = transformPrefs(prefsMore)
```


```python
print "# criticsLess values : " + str(sum(len(v) for v in criticsLess.itervalues()))
print "# criticsLess values : " + str(sum(len(v) for v in criticsMore.itervalues()))
```

    # criticsLess values : 382807
    # criticsLess values : 846584



```python
"""
Functions calculate distance-base similarity score:
1. sim_euclidean : calculate the Euclidean distance between user1 and user2.
2. sim_pearson   : calculate the Pearson correlation coefficient for user1 and user2.
"""

# --- sim_euclidean --------------------

def sim_euclidean(prefs, user1, user2):
	#Get the list of shared_items
	si = {}
	for item in prefs[user1]:
		if item in prefs[user2]:
			si[item] = 1

	#if they have no rating in common, return 0
	if len(si) == 0: 
		return 0

	#Add up the squares of all differences
	sum_of_squares = sum([pow(prefs[user1][item]-prefs[user2][item],2) for item in prefs[user1] if item in prefs[user2]])

	return 1 / (1 + sum_of_squares)

# --- sim_pearson --------------------

def sim_pearson(prefs, user1, user2):
	#Get the list of mutually rated items
	si = {}
	for item in prefs[user1]:
		if item in prefs[user2]: 
			si[item] = 1

	#if they are no rating in common, return 0
	if len(si) == 0:
		return 0

	#sum calculations
	n = len(si)

	#sum of all preferences
	sum1 = sum([prefs[user1][it] for it in si])
	sum2 = sum([prefs[user2][it] for it in si])

	#Sum of the squares
	sum1Sq = sum([pow(prefs[user1][it],2) for it in si])
	sum2Sq = sum([pow(prefs[user2][it],2) for it in si])

	#Sum of the products
	pSum = sum([prefs[user1][it] * prefs[user2][it] for it in si])

	#Calculate r (Pearson score)
	num = pSum - (sum1 * sum2/n)
	den = sqrt((sum1Sq - pow(sum1,2)/n) * (sum2Sq - pow(sum2,2)/n))
	if den == 0:
		return 0

	r = num/den

	return r
```


```python
"""
Returns the best matches for user from the prefs dictionary
Number of the results and similiraty function are optional params.
"""

def topMatches(prefs, user, n=5, similarity=sim_pearson):
	scores = [(similarity(prefs,user,other),other)
				for other in prefs if other != user]
	scores.sort()
	scores.reverse()
	return scores[0:n]
```


```python
"""
Gets recommendations for a user by using a weighted average
of every other user's rankings
"""

def getRecommendations(prefs, user, similarity=sim_pearson):
	totals = {}
	simSums = {}

	for other in prefs:
		#don't compare me to myself
		if other == user:
			continue
		sim = similarity(prefs,user,other)

		#ignore scores of zero or lower
		if sim <= 0: 
			continue
		for item in prefs[other]:
			#only score books i haven't seen yet
			if item not in prefs[user] or prefs[user][item] == 0:
				#Similarity * score
				totals.setdefault(item,0)
				totals[item] += prefs[other][item] * sim
				#Sum of similarities
				simSums.setdefault(item,0)
				simSums[item] += sim

	#Create the normalized list
	rankings = [(total/simSums[item],item) for item,total in totals.items()]

	#Return the sorted list
	rankings.sort()
	rankings.reverse()
	return rankings
```

* Now we can try our book recommendation functions.
* We will try each function with:
  * Euclidean distance and Pearson correlation.
  * Original dataset (less ratings) and our enhanced dataset (more ratings).

Let's first try to find top 10 users like user 177432 and 180727.


```python
"""
* Case-1 : user 177432
** Top 10 selected by euclidean are different than pearson.
** Top 10 selected by euclidean are different when available number of ratings are different,
   although all selected scores are the same (1.0).
** Top 10 selected by pearson are different when available number of ratings are different.
   When more ratings areavailable, pearson select more higher scores candidates.    
"""
print "<<topMatches(prefsLess, '177432', 10, sim_euclidean)>>"
print topMatches(prefsLess, '177432', 10, sim_euclidean)
print "\n<<topMatches(prefsMore, '177432', 10, sim_euclidean)>>"
print topMatches(prefsMore, '177432', 10, sim_euclidean)
print "\n<<topMatches(prefsLess, '177432', 10, sim_pearson)>>"
print topMatches(prefsLess, '177432', 10, sim_pearson)
print "\n<<topMatches(prefsMore, '177432', 10, sim_pearson)>>"
print topMatches(prefsMore, '177432', 10, sim_pearson)
```

    <<topMatches(prefsLess, '177432', 10, sim_euclidean)>>
    [(1.0, '98575'), (1.0, '98484'), (1.0, '98230'), (1.0, '97968'), (1.0, '97721'), (1.0, '96463'), (1.0, '96440'), (1.0, '95567'), (1.0, '95173'), (1.0, '9502')]
    
    <<topMatches(prefsMore, '177432', 10, sim_euclidean)>>
    [(1.0, '99630'), (1.0, '99051'), (1.0, '98686'), (1.0, '98618'), (1.0, '98575'), (1.0, '98484'), (1.0, '98422'), (1.0, '98230'), (1.0, '98159'), (1.0, '97968')]
    
    <<topMatches(prefsLess, '177432', 10, sim_pearson)>>
    [(1.0000000000000107, '199515'), (1.0000000000000107, '110112'), (1.000000000000007, '94923'), (1.000000000000007, '51883'), (1.000000000000007, '259320'), (1.0000000000000033, '89602'), (1.0000000000000018, '94307'), (1.0, '99766'), (1.0, '98026'), (1.0, '97324')]
    
    <<topMatches(prefsMore, '177432', 10, sim_pearson)>>
    [(1.000000000000016, '69554'), (1.000000000000016, '62755'), (1.000000000000016, '45557'), (1.000000000000016, '38464'), (1.000000000000016, '237154'), (1.000000000000016, '222716'), (1.000000000000016, '217106'), (1.000000000000016, '207499'), (1.000000000000016, '201674'), (1.000000000000016, '145641')]



```python
"""
* Case-2 : user 180727
** Top 10 selected by euclidean are different than pearson.
** Top 10 selected by euclidean are the same  number.
** Top 10 selected by pearson are different when available number of ratings are different.
   When less ratings areavailable, pearson select only 3 candidates with non-zero scores.
   When more ratings areavailable, pearson select all 10 candidates with non-zero scores. 
"""
print "<<topMatches(prefsLess, '180727', 10, sim_euclidean)>>"
print topMatches(prefsLess, '180727', 10, sim_euclidean)
print "\n<<topMatches(prefsMore, '180727', 10, sim_euclidean)>>"
print topMatches(prefsMore, '180727', 10, sim_euclidean)
print "\n<<topMatches(prefsLess, '180727', 10, sim_pearson)>>"
print topMatches(prefsLess, '180727', 10, sim_pearson)
print "\n<<topMatches(prefsMore, '180727', 10, sim_pearson)>>"
print topMatches(prefsMore, '180727', 10, sim_pearson)
```

    <<topMatches(prefsLess, '180727', 10, sim_euclidean)>>
    [(1.0, '48999'), (1.0, '4483'), (1.0, '39159'), (1.0, '246759'), (1.0, '243917'), (1.0, '209707'), (1.0, '179327'), (0.5, '96913'), (0.5, '95287'), (0.5, '87911')]
    
    <<topMatches(prefsMore, '180727', 10, sim_euclidean)>>
    [(1.0, '48999'), (1.0, '4483'), (1.0, '39159'), (1.0, '246759'), (1.0, '243917'), (1.0, '209707'), (1.0, '179327'), (0.5, '96913'), (0.5, '95287'), (0.5, '87911')]
    
    <<topMatches(prefsLess, '180727', 10, sim_pearson)>>
    [(1.0, '189139'), (1.0, '11676'), (0.6622661785325219, '177432'), (0, '99998'), (0, '99997'), (0, '99996'), (0, '99993'), (0, '99987'), (0, '99980'), (0, '99973')]
    
    <<topMatches(prefsMore, '180727', 10, sim_pearson)>>
    [(1.000000000000016, '171818'), (1.0, '86202'), (1.0, '32773'), (1.0, '224646'), (1.0, '189139'), (1.0, '184299'), (1.0, '154070'), (1.0, '11676'), (0.9449111825230734, '155463'), (0.8660254037844402, '3165')]


Unlike social media engines, book engines recommend books (i.e., not similar readers).  So let's try to recommend 5 books to user 177432 and 180727.


```python
"""
* Case-3 : user 177432
* Recommendations are all different.
"""
print "<<getRecommendations(prefsLess, '177432', sim_euclidean)[0:5]>>"
print getRecommendations(prefsLess, '177432', sim_euclidean)[0:5]
print "\n<<getRecommendations(prefsMore, '177432', sim_euclidean)[0:5]>>"
print getRecommendations(prefsMore, '177432', sim_euclidean)[0:5]
print "\n<<getRecommendations(prefsLess, '177432', sim_pearson)[0:5]>>"
print getRecommendations(prefsLess, '177432', sim_pearson)[0:5]
print "\n<<getRecommendations(prefsMore, '177432', sim_pearson)[0:5]>>"
print getRecommendations(prefsMore, '177432', sim_pearson)[0:5]
```

    <<getRecommendations(prefsLess, '177432', sim_euclidean)[0:5]>>
    [(10.000000000000002, 'Zaftig: The Case for Curves'), (10.000000000000002, "You're My Baby (9 Months Later) (Harlequin Superromance, No. 1059)"), (10.000000000000002, "Yachtsman's Eight Language Dictionary: English, French, German, Dutch, Danish, Italian, Spanish, Portuguese"), (10.000000000000002, 'World of Robert Bateman'), (10.000000000000002, 'Witchdame')]
    
    <<getRecommendations(prefsMore, '177432', sim_euclidean)[0:5]>>
    [(10.000000000000004, 'The Magic School Bus and the Electric Field Trip'), (10.000000000000004, 'The Drowned and the Saved'), (10.000000000000004, 'Southern Belle (Mira)'), (10.000000000000004, 'Sorrow Floats'), (10.000000000000004, 'Red Branch')]
    
    <<getRecommendations(prefsLess, '177432', sim_pearson)[0:5]>>
    [(10.000000000000002, "Uncle John's Unstoppable Bathroom Reader (Bathroom Reader Series)"), (10.000000000000002, 'Twelve Steps and Twelve Traditions'), (10.000000000000002, 'Traveling Light: Releasing the Burdens You Were Never Intended to Bear'), (10.000000000000002, "The Woman Who Wouldn't Talk"), (10.000000000000002, 'The Very Best Baby Name Book in the Whole Wide World')]
    
    <<getRecommendations(prefsMore, '177432', sim_pearson)[0:5]>>
    [(10.000000000000004, "The Heart of a Woman (Oprah's Book Club (Hardcover))"), (10.000000000000004, 'The Experiment (Animorphs'), (10.000000000000004, 'Notes to Myself: A Guided Journal (Guided Journals)'), (10.000000000000004, 'North and South (North and South Trilogy'), (10.000000000000004, 'Natural California: A Postcard Book')]



```python
"""
* Case-4 : user 180727
* Recommendations are all different.
"""
print "<<getRecommendations(prefsLess, '180727', sim_euclidean)[0:5]>>"
print getRecommendations(prefsLess, '180727', sim_euclidean)[0:5]
print "\n<<getRecommendations(prefsMore, '180727', sim_euclidean)[0:5]>>"
print getRecommendations(prefsMore, '180727', sim_euclidean)[0:5]
print "\n<<getRecommendations(prefsLess, '180727', sim_pearson)[0:5]>>"
print getRecommendations(prefsLess, '180727', sim_pearson)[0:5]
print "\n<<getRecommendations(prefsMore, '180727', sim_pearson)[0:5]>>"
print getRecommendations(prefsMore, '180727', sim_pearson)[0:5]
```

    <<getRecommendations(prefsLess, '180727', sim_euclidean)[0:5]>>
    [(10.000000000000002, 'Dune'), (10.000000000000002, 'Best Friends'), (10.000000000000002, 'All Creatures Great and Small'), (10.000000000000002, 'A Christmas Carol (Dover Thrift Editions)'), (10.000000000000002, '100 Selected Poems by E. E. Cummings')]
    
    <<getRecommendations(prefsMore, '180727', sim_euclidean)[0:5]>>
    [(10.000000000000002, "Year's Best Fantasy and Horror"), (10.000000000000002, 'When The Loving Stopped (Harlequin Romance'), (10.000000000000002, 'Watership Down (Scribner Classics)'), (10.000000000000002, 'Three Weeks with My Brother'), (10.000000000000002, "The Year's Best Fantasy and Horror: Twelfth Annual Collection (Yeara's Best Fantasy &amp")]
    
    <<getRecommendations(prefsLess, '180727', sim_pearson)[0:5]>>
    [(10.000000000000002, 'The Two Towers (The Lord of the Rings, Part 2)'), (10.000000000000002, 'The Return of the King (The Lord of the Rings, Part 3)'), (10.000000000000002, 'Hawaii'), (10.000000000000002, '1984'), (10.0, '\xc2\xa1Corre, perro, corre!')]
    
    <<getRecommendations(prefsMore, '180727', sim_pearson)[0:5]>>
    [(10.000000000000002, 'The War of the Worlds (Bantam Classics)'), (10.0, '\xc2\xa1Corre'), (10.0, 'Zen Gardening'), (10.0, 'Yvgenie'), (10.0, 'Youth in Revolt')]


We just saw what functions topMatches and getRecommendations can do for an user based on the data structure prefs.  Now we will see what these two functions can do for a book based on the data structure critics.
* If you give function topMatches a prefs matrix and an user as input, it returns top matched users.
* If you give function topMatches a critics matrix and a book title as input, it returns similar books.


```python
"""
Case-5 : Let's try to find 5 similar books as 'Drums of Autumn'.
* Only "Zukunftsmarkt Business on Demand." appears twice using euclidean distance.
"""
print "<<topMatches(criticsLess, 'Drums of Autumn', 5, sim_euclidean)>>"
print topMatches(criticsLess, 'Drums of Autumn', 5, sim_euclidean)
print "\n<<topMatches(criticsMore, 'Drums of Autumn', 5, sim_euclidean)>>"
print topMatches(criticsMore, 'Drums of Autumn', 5, sim_euclidean)
print "\n<<topMatches(criticsLess, 'Drums of Autumn', 5, sim_pearson)>>"
print topMatches(criticsLess, 'Drums of Autumn', 5, sim_pearson)
print "\n<<topMatches(criticsMore, 'Drums of Autumn', 5, sim_pearson)>>"
print topMatches(criticsMore, 'Drums of Autumn', 5, sim_pearson)
```

    <<topMatches(criticsLess, 'Drums of Autumn', 5, sim_euclidean)>>
    [(1.0, '\\Good Housekeeping\\ Soups and Starters'), (1.0, "\\A Room of One's Own\\, and \\Three Guineas\\ (Oxford World's Classics)"), (1.0, 'Zukunftsmarkt Business on Demand. Unternehmenserfolg durch st\xc3?\xc2\xa4ndige Verf\xc3?\xc2\xbcgbarkeit.'), (1.0, 'Zoya'), (1.0, "Zest: Cosmopolitan's Health and Beauty Handbook")]
    
    <<topMatches(criticsMore, 'Drums of Autumn', 5, sim_euclidean)>>
    [(1.0, 'christmas on snowbird mountain'), (1.0, 'bridegroom on her doorstep  (white weddings)'), (1.0, 'Zuleika Dobson (Modern Library (Paperback))'), (1.0, 'Zukunftsmarkt Business on Demand. Unternehmenserfolg durch st\xc3?\xc2\xa4ndige Verf\xc3?\xc2\xbcgbarkeit.'), (1.0, 'ZigZag: A Novel')]
    
    <<topMatches(criticsLess, 'Drums of Autumn', 5, sim_pearson)>>
    [(1.0, 'Year of Wonders'), (1.0, 'Velvet Angel'), (1.0, 'Twice Loved'), (1.0, 'Trying to Save Piggy Sneed'), (1.0, 'The Zebra Wall')]
    
    <<topMatches(criticsMore, 'Drums of Autumn', 5, sim_pearson)>>
    [(1.0000000000000255, 'Heart of a Warrior'), (1.000000000000016, 'The Unlikely Spy'), (1.000000000000016, "Everything's Eventual : 14 Dark Tales"), (1.0000000000000155, 'The Simple Truth'), (1.0000000000000133, 'Lady of Hay')]


* If you give function getRecommendations a prefs matrix and an user as input, it returns few book recommendations.
* If you give function getRecommendations a critics matrix and a book title as input, it returns few users who may want to read the book.


```python
"""
Case-6 : Let's try to find 5 users who may want to read 'The Weight of Water'.
* Recommendations are all different.
"""
print "<<getRecommendations(criticsLess, 'The Weight of Water', sim_euclidean)[0:5]>>"
print getRecommendations(criticsLess, 'The Weight of Water', sim_euclidean)[0:5]
print "\n<<getRecommendations(criticsMore, 'The Weight of Water', sim_euclidean)[0:5]>>"
print getRecommendations(criticsMore, 'The Weight of Water', sim_euclidean)[0:5]
print "\n<<getRecommendations(criticsLess, 'The Weight of Water', sim_pearson)[0:5]>>"
print getRecommendations(criticsLess, 'The Weight of Water', sim_pearson)[0:5]
print "\n<<getRecommendations(criticsMore, 'The Weight of Water', sim_pearson)[0:5]>>"
print getRecommendations(criticsMore, 'The Weight of Water', sim_pearson)[0:5]
```

    <<getRecommendations(criticsLess, 'The Weight of Water', sim_euclidean)[0:5]>>
    [(10.000000000000002, '99085'), (10.000000000000002, '96635'), (10.000000000000002, '95375'), (10.000000000000002, '94025'), (10.000000000000002, '9219')]
    
    <<getRecommendations(criticsMore, 'The Weight of Water', sim_euclidean)[0:5]>>
    [(10.000000000000002, '98735'), (10.000000000000002, '97921'), (10.000000000000002, '97421'), (10.000000000000002, '97139'), (10.000000000000002, '94125')]
    
    <<getRecommendations(criticsLess, 'The Weight of Water', sim_pearson)[0:5]>>
    [(10.000000000000002, '92048'), (10.000000000000002, '211152'), (10.000000000000002, '198996'), (10.000000000000002, '156467'), (10.0, '99298')]
    
    <<getRecommendations(criticsMore, 'The Weight of Water', sim_pearson)[0:5]>>
    [(10.000000000000002, '99298'), (10.000000000000002, '98344'), (10.000000000000002, '78631'), (10.000000000000002, '43937'), (10.000000000000002, '41343')]


We have tested the function topMatches and getRecommendations with:
* Euclidean distance and Pearson correlation.
* Original dataset (less ratings) and our enhanced dataset (more ratings).

We cannot confirm if any recommendations made are valid since: 
* The dataset is not ideally clean. 
* The dataset does not have enough information about users or books. 
* Marcel Caraciolo’s approach does not make use of users’ profile.

But we do observe that the number of ratings available to CF do impact the recommendations made by the engine.

(end)
