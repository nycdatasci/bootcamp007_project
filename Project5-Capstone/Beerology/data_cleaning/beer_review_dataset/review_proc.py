### this script is for cleaning beer reviews
### run do_this_shit fuction to perform the entire process, two .p files will be generated
### first file is a list of beer names
### second file is a nested list, each inner list is a list of words
### the index of beer name matches the index of words list

import re
from nltk.corpus import stopwords
from nltk.stem import WordNetLemmatizer
import numpy as np
import pandas as pd
import pickle

# function set 1. get nested list of words
def get_review_full():
    '''output: list, with each element being a review str'''
    part1 = pd.read_csv('github/Scraped_Review_Data/beerreview1_13.csv', usecols = ['review'])
    part2 = pd.read_csv('github/Scraped_Review_Data/beerreview14_26.csv', usecols = ['review'])
    part3 = pd.read_csv('github/Scraped_Review_Data/beerreview27_39.csv', usecols = ['review'])
    part4 = pd.read_csv('github/Scraped_Review_Data/beerreview40_51.csv', usecols = ['review'])
    full = pd.concat([part1, part2, part3, part4], axis = 0, ignore_index = True)
    return ['' if type(x) is not str else x for x in list(full['review'])]

def get_random_review(n = 20, seed = 0):
    '''input: n = number of review you want to generate, seed = random seed
       output: list, with each element being a review str'''
    assert n > 0, 'number of reviews must be greater than 0'
    assert n <= 100, 'don\'t do more than 100...'
    assert type(n) is int, 'number of reviews must be an integer'
    lst0 = range(4)
    lst1 = ['1_13.csv', '14_26.csv', '27_39.csv', '40_51.csv']
    lst2 = [111426, 68132, 61043, 36093]
    np.random.seed(seed)
    r0 = int(np.random.choice(lst0, size = 1)[0])
    r1 = lst1[r0]
    r2 = list(np.random.choice(range(lst2[r0]), size = n, replace = False))
    rev = list(pd.read_csv('github/Scraped_Review_Data/beerreview' + r1, usecols = ['review'])['review'])
    rev = ['' if type(x) is not str else x for x in rev]
    return [rev[x] for x in r2]

def get_beername_full():
    '''output: list of beer names. Each element is a beer name'''
    part1 = pd.read_csv('github/Scraped_Review_Data/beerreview1_13.csv', usecols = ['beer_name'])
    part2 = pd.read_csv('github/Scraped_Review_Data/beerreview14_26.csv', usecols = ['beer_name'])
    part3 = pd.read_csv('github/Scraped_Review_Data/beerreview27_39.csv', usecols = ['beer_name'])
    part4 = pd.read_csv('github/Scraped_Review_Data/beerreview40_51.csv', usecols = ['beer_name'])
    full = pd.concat([part1, part2, part3, part4], axis = 0, ignore_index = True)
    print 'beer name loaded'
    print '='*100
    return list(full['beer_name'])


def clean_str(s):
    '''input: review str
       output: list of words after proper cleaning'''
    s = s.lower().replace('\xe2\x80\x99', '\'').replace('|', ' ')\
        .replace('\r', ' ').replace('\n', ' ').replace('/', ' ').replace('@', ' ')
    s = re.sub('[.:\',\-!;"()?]', '', s)
    lst = re.sub('\s+', ' ', s).strip().split(' ')
    stop_words = set(stopwords.words('english') + stopwords.words('german') + ['&', ''])
    lst = [word for word in lst if word not in stop_words]
    lmtizer = WordNetLemmatizer()
    lst = map(lambda x: lmtizer.lemmatize(x.decode('utf-8', 'ignore')).encode('utf-8', 'ignore'), lst)
    lst = [word for word in lst if word != '']
    return lst

def proc_review_test(n = 20, seed = 0):
    '''test the performace of clean_str function'''
    l = get_random_review(n, seed)
    return map(clean_str, l)

def proc_review_full():
    '''output: nested list, each inner list is a list of words, all reviews included'''
    l = get_review_full()
    print 'all reviews are loaded'
    print '='*100
    result = []
    i = 0
    for review in l:
        result.append(clean_str(review))
        print 'number of review finished:', i
        i += 1
    return result





# function set 2. for getting nested list
def org_tuple(name, z):
    '''input: beer name, list of tuple (first element of tuple is beer name, second element is words list)
       output: word list for a single beer, all reviews considered'''
    ls = []
    for i in z:
        if i[0] == name:
            ls.append(i[1])
    return [item for sublist in ls for item in sublist]

def group_words(name_lst, rev_lst):
    '''input: beer name list, words list generated from proc_review_full function
       output: list of tuple (first element of tuple is beer name,
               second element is words list containing all reviews)'''
    assert len(name_lst) == len(rev_lst), 'name_lst must equal to rev_lst'
    z = zip(name_lst, rev_lst)
    s = list(set(name_lst))
    s.sort()
    ls = []
    for name in s:
        ls.append((name, org_tuple(name, z)))
        print 'review of beer:', name, 'has been processed'
    return ls



def do_this_shit():
    '''run this for the entire process, make sure you set the right path for each file'''
    name_lst = get_beername_full()
    print 'name_lst generated'
    print '='*100, '\n\n'
    rev_lst = proc_review_full()
    print 'all reviews processed'
    print '='*100, '\n\n'
    result_all = group_words(name_lst, rev_lst)
    print 'finished!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
    print '='*100, '\n\n'
    nest_lst = map(lambda x: x[1], result_all)
    name_lst = map(lambda x: x[0], result_all)
    print 'word and name list generated\n\n'
    print 'dumping files'
    pickle.dump(nest_lst, open('words_lst.p', 'wb'))
    pickle.dump(name_lst, open('name_lst.p', 'wb'))
    print 'files dumped!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
    print 'job done!'



def test_this_shit(n = 5, seed = 0):
    '''test the performance of group_words function'''
    name_lst = np.random.choice(range(5), size = n, replace = True)
    rev_lst = proc_review_test(n, seed)
    return group_words(name_lst, rev_lst)





# function set 3. other functions

## input a list of words, return the sum of individual word length + space between words
def count_lst_chr(lst):
    l = 0
    for i in lst:
        l += len(i)
    return l + len(lst) - 1

#a = pickle.load( open( "back_up/words_lst.p", "rb" ) )
#print 'finished'


## input a string, remove parenthesis and everything inside, and filter the weird characters
## returns a cleaned version of string
def clean_user_name(s):
    return ''.join(e for e in re.sub('\([^)]*\)', '', s) if e.isalnum())