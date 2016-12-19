from content_based_recommendation import *
import pickle
import json

if 'beer_list' not in locals():
    beer_list = pickle.load(open("beer_list.p", "rb"))
    print 'beer_list loaded'
if 'textDict' not in locals():
    textDict = pickle.load(open("textDict.p", "rb"))
    print 'textDict loaded'
if 'index' not in locals():
    index = pickle.load(open("index.p", "rb"))
    print 'index loaded'
if 'corpus_tfidf' not in locals():
    corpus_tfidf = pickle.load(open("corpus_tfidf.p", "rb"))
    print 'corpus_tfidf loaded'

beer_keywords = {}
for beer in beer_list:
    beer_keywords[beer] = get_beer_keywords(beer, corpus_tfidf, beer_list, textDict, ntop=20)

with open('beer_keywords.json','w') as fp:
    json.dump(beer_keywords,fp)