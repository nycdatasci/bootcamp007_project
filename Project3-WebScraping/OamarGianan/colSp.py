"""
This script connects to the spotify API to get track details
getting the track popularity:
  result['tracks']['items'][0]['popularity']
getting the album id
  album_id = res_track['tracks']['items'][0]['album']['id']
getting the album details
  album_det = sp.album(album_id)
getting release date from album_det
  album_det['release_date']
getting album genres
  album_det['genres']
apparently, album genres are always empty in spotify
getting artist ID
  res_track['tracks']['items'][0]['artists'][0]['uri']
getting artist details
  artist_det = sp.artist(res_track['tracks']['items'][0]['artists'][0]['uri'])
getting genres
  artist_det['genres']

Client ID: 6fd8426e0d5842c8a71f5fb2fe500755
Client Secret: c8dd889c094b47f99e89ae221a29df9b

"""
import pandas as pd
import spotipy
from spotipy.oauth2 import SpotifyClientCredentials


client_credentials_manager = SpotifyClientCredentials("6fd8426e0d5842c8a71f5fb2fe500755", "c8dd889c094b47f99e89ae221a29df9b")
sp = spotipy.Spotify(client_credentials_manager=client_credentials_manager)

df = pd.read_csv("hooktheory.csv")
print df.tail()
# Create new dataframe for info to be retireved from Spotify
spdf = {
    'popularity' : [],
    'release_date' : [],
    'genres' : [],
    'valence' : [],
    'key' : [],
    'energy' : [],
    'tempo' : []
}

for i in range(len(df.index)):
#for troublechecking
#for i in range(1505,2150):
# creating the search term string
    s_term = df.song[i], df.artist[i]
    print "searching", s_term
    print "index", i
# searching spotify
    res_track = sp.search(s_term, limit=1, type='track')
    print res_track
    try:
# getting album id
        album_id = res_track['tracks']['items'][0]['album']['id']
        print album_id
# getting track id
        track_id = res_track['tracks']['items'][0]['id']
        print track_id
# getting audio features
        features = sp.audio_features([track_id])
        print features[0]['valence'], features[0]['key'], features[0]['energy'], features[0]['tempo']
# getting album details
        album_det = sp.album(album_id)
# getting artist details from artist id
        artist_det = sp.artist(res_track['tracks']['items'][0]['artists'][0]['uri'])
        spdf['popularity'].append(res_track['tracks']['items'][0]['popularity'])
        spdf['release_date'].append(album_det['release_date'])
        spdf['genres'].append(artist_det['genres'])
        spdf['valence'].append(features[0]['valence'])
        spdf['key'].append(features[0]['key'])
        spdf['energy'].append(features[0]['energy'])
        spdf['tempo'].append(features[0]['tempo'])
    except IndexError:
        spdf['popularity'].append("NA")
        spdf['release_date'].append("NA")
        spdf['genres'].append("NA")
        spdf['valence'].append("NA")
        spdf['key'].append("NA")
        spdf['energy'].append("NA")
        spdf['tempo'].append("NA")
# convert dict to dataframe
spdf = pd.DataFrame(spdf)

### cbind spdf to df here
finaldf = pd.concat([df, spdf], axis = 1)
#saving dataframe to csv file
finaldf.to_csv("forEDA_moredeets.csv")
