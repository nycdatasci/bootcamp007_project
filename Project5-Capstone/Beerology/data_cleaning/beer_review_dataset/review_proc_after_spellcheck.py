import pandas as pd
import numpy as np
import pickle
from nltk.corpus import stopwords
from nltk.stem import WordNetLemmatizer
import re

def clean_str(s):
    '''input: str
       output: cleaned str'''
    #print s
    s = ''.join(e for e in s if e.isalnum())
    s = s.decode('utf-8', 'ignore').encode('ascii', 'ignore').lower()
    lmtizer = WordNetLemmatizer()
    s = lmtizer.lemmatize(s).encode('ascii', 'ignore')
    return s

def clean_lst(l):
    '''input: word list
       output: cleaned list'''
    lst = map(lambda x: clean_str(x), l)
    print 'list cleaned'
    return [word for word in lst if word != '']

if __name__ == '__main__':

    # load names words list and words list after spell check
    names = pickle.load(open("back_up/review_proc_result/name_lst.p", "rb"))
    #words_proc = pickle.load(open("back_up/review_proc_result/words_lst.p", "rb"))   # this is lemmatized without sc
    words_sc = pickle.load(open("back_up/reviews_spellchecked.p/reviews_spellchecked.p", "rb"))
    #words_bf = pickle.load(open("back_up/reviews_spellchecked.p/reviews_before.p", "rb"))   # version before sc
    print 'done loading!'

    words_sc_proc = map(lambda l: clean_lst(l), words_sc)
    print 'done processing'
    pickle.dump(words_sc_proc, open('words_sc_proc.pickle', 'wb'))
    print 'pickle dumped'
