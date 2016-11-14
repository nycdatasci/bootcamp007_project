# Script to test getting genre playlists
library(httr)
library(jsonlite)

clientID = 'e74c52988f6d4bcebb36970a423d348d'
secret = '0edc87deae1a4611a97b6cebef262136'
#info = GET('https://accounts.spotify.com/authorize')

response = POST(
  'https://accounts.spotify.com/api/token',
  accept_json(),
  authenticate(clientID, secret),
  body = list(grant_type = 'client_credentials'),
  encode = 'form',
  verbose()
)

mytoken = content(response)$access_token

HeaderValue = paste0('Bearer ', mytoken)

# Get genre
max_ids = 50
category_id = 'party'
URI = paste0('https://api.spotify.com/v1/browse/categories/', category_id, '/playlists')
request = GET(url = URI, add_headers(Authorization = HeaderValue))
playlist_object = fromJSON(content(request, "text")) 
#playlists = playlist_object[[1]]['items'][[1]]
playlists = playlist_object$playlists$items

# Get playlist tracks
playlist_id = playlists$id[1]
user_id = playlists$owner$id[[1]]

# Test getting related artists of artists from a playlist
URI = paste0('https://api.spotify.com/v1/users/', user_id,'/playlists/', playlist_id,'/tracks')
response2 = GET(url = URI, add_headers(Authorization = HeaderValue))
playlist = content(response2)
playlist_df = fromJSON(content(response2, "text"))

# Get tracks of the playlist and find each artist's related artists
tracks = playlist[[2]]
