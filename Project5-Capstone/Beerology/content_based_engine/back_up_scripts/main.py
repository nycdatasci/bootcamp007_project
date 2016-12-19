from TFIDF_LSI_SIM_plus_beer_recomend import *
import pickle
import pandas as pd

beer_list = pickle.load(open("../../review_proc_result/name_lst.p", "rb"))
print "second pickle inc"
rev_list = pickle.load(open("../../review_proc_result/words_lst.p", "rb"))

print "pickle imported.."

textDict, index, corpus_tfidf = TFIDF_LSI_SIM(rev_list)
# print index

print get_beer_keywords('18th Street Barrel Aged Hunter - Wheat Whiskey', corpus_tfidf, beer_list, textDict, ntop=50)
# print get_similar_beers('18th Street Barrel Aged Hunter - Wheat Whiskey', beer_list, index, ntop = 10)


