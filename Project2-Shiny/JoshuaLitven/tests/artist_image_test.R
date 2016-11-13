library(httr)
library(visNetwork)
library(RLastFM)
library(spotifyr)
library(dplyr)

clientID = 'e74c52988f6d4bcebb36970a423d348d'
secret = '0edc87deae1a4611a97b6cebef262136'

# Get credentials for Spotify
client_tokens <- get_tokens()

info = GET('https://accounts.spotify.com/authorize')

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

# Test getting artist pictures
URI = paste0('https://api.spotify.com/v1/artists/', '0EP5EpsiMP8oLYy7sPHwf9')
response2 = GET(url = URI, add_headers(Authorization = HeaderValue))
artist_info = content(response2)
artist_image_url = artist_info$images[[4]]$url
