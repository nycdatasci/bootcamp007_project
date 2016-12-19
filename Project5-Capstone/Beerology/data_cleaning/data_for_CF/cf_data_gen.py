import numpy as np
import pandas as pd
import pickle

def get_dict(x):
    '''create dictionary of users and beers'''
    if x == 'user':
        dict = {}
        key_lst = df_tf['user'].tolist()
        value_lst = df['user'].tolist()
        for i in range(len(key_lst)):
            dict[key_lst[i]] = value_lst[i]
        return dict
    if x == 'beer':
        dict = {}
        key_lst = df_tf['item'].tolist()
        value_lst = df['item'].tolist()
        for i in range(len(key_lst)):
            dict[key_lst[i]] = value_lst[i]
        return dict


if __name__ == '__main__':

    # load the dataframe with three needed columns
    df = pd.read_csv('github/data_cleaning/data_for_CF/beer_ratings_only.csv')

    # factorize user_name and beer_name columns and create a new dataframe
    df_tf = pd.DataFrame()
    df_tf['user'] = pd.factorize(df['user'])[0]
    df_tf['item'] = pd.factorize(df['item'])[0]
    df_tf['rating'] = df['rating']

    # generate two dictionaries for user and beer
    user_dict = get_dict('user')
    beer_dict = get_dict('beer')
    print 'two dictionaries are generated'

    # export three objects
    pickle.dump(user_dict, open('user_dict.pickle', 'wb'))
    pickle.dump(beer_dict, open('beer_dict.pickle', 'wb'))
    df_tf.to_csv('user_item_rating_fac.csv', index=False)
    print 'objects are exported'