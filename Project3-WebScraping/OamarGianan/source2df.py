import pickle
import pandas as pd

html = pickle.load( open( "sources.p", "rb" ))

from bs4 import BeautifulSoup
"""
#This script will accept dictionary with key:html source pairing
"""
#create the dataframe
df = {
    'cprog':[],
    'song': [],
    'artist': []
}
#### create loop to go through dictionary
for n in html.keys():
    print n
    soup = BeautifulSoup(html.get(n), "lxml")

#getting all songs
    song_list = soup.find_all('p', {'class': "song"})
#getting all artists
    artist_list = soup.find_all('p', {'class': "artist"})

    for i in range(len(song_list)):
        df['cprog'].append(n)
        df['song'].append(song_list[i].get_text())
        df['artist'].append(artist_list[i].get_text())

#removing "by" in artist column
df['artist'] = pd.DataFrame(df).artist.str.replace('by ?','')

#saving dataframe to csv file
scrapedDF = pd.DataFrame(df)
scrapedDF.to_csv("hooktheory.csv")
