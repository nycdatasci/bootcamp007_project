import numpy as np
import pandas as pd
import re
import pickle

df1 = pd.read_csv('github/Scraped_Review_Data/beerreview1_13.csv')
df2 = pd.read_csv('github/Scraped_Review_Data/beerreview14_26.csv')
df3 = pd.read_csv('github/Scraped_Review_Data/beerreview27_39.csv')
df4 = pd.read_csv('github/Scraped_Review_Data/beerreview40_51.csv')

df = pd.concat([df1, df2, df3, df4], axis = 0, ignore_index = True)

df = df[['user_name', 'user_info', 'state', 'beer_name', 'overall', 'user_rating', 'aroma',
        'appearance', 'palate', 'taste']]

df[df['user_name'].isnull()].index.tolist()   # locate the user with missing name
df.loc[50128, :]  # verify this location
df.drop(50128, inplace=True)   # remove this obs
df[df['user_name'].isnull()].index.tolist()  # verify

un = df['user_name']
print len(un)
clean_name = lambda x: ''.join(e for e in re.sub('\([^)]*\)', '', x) if e.isalnum())
un2 = map(lambda x: clean_name(x), un)  # clean user_name col
print len(un2)

df['user_name'] = un2

ui = df['user_info']
ui[:5]
find_date = lambda x: re.search('[A-Z]{3} \d{1,2}, \d{4}$', x)
user_date = map(lambda x: find_date(x).group() if find_date(x) else np.nan, ui)
user_date.count(np.nan)   # count missing values after extracting date
pd.Series(map(lambda x: len(x), [item for item in user_date if item is not np.nan])).unique()
user_date = pd.to_datetime(user_date, errors='ignore', format='%b %d, %Y')
df['user_date'] = user_date
df = df[['user_name', 'user_date', 'state', 'beer_name', 'overall', 'taste', 'aroma',
        'appearance', 'palate', 'user_rating']]

st = df['state']
len(st.unique())   # state variable is very clean

bn = df['beer_name']
bn = map(lambda x: x.decode('utf-8', 'ignore').encode('ascii', 'ignore'), bn)
bn = map(lambda x: re.sub('\s+', ' ', x).strip(), bn)
df['beer_name'] = bn

df2 = df.groupby('beer_name').agg({'overall': 'mean', 'user_rating': 'mean'})

dict = {}
for i in range(1269):
        dict[df2.index[i]] = [round(df2.iloc[i, 0], 1)*4, round(df2.iloc[i, 1], 1)]
pickle.dump(dict, open('dict_for_CB_table.p', 'wb'))


# df.head()
# pd.DataFrame(df.isnull().sum()).T  # no missing value anymore
# df.to_csv('user_info_rating_proc.csv', index=False)   # export df

