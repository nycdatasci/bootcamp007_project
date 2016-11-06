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

# Test getting related artists of artists from a playlist
URI = paste0('https://api.spotify.com/v1/users/', '1212629687','/playlists/', '4gEnJZkhP2mDDbFpz2GK4P','/tracks')
response2 = GET(url = URI, add_headers(Authorization = HeaderValue))
playlist = content(response2)

# Get tracks of the playlist and find each artist's related artists
tracks = playlist[[2]]

artist_list = c()
initial_artists = c()
from = c()
to = c()
for(track in tracks){ 
  # Get the artist name and id
  artist_name = track$track$artists[[1]]$name
  
  if(artist_name %in% initial_artists){
    next
  }
  initial_artists = c(initial_artists, artist_name)
  
  artist_list = c(artist_name, artist_list)
  artist_id = track$track$artists[[1]]$id
  
  # Find their related artists
  URI = paste0('https://api.spotify.com/v1/artists/', artist_id, '/related-artists')
  related_artists = fromJSON(txt=URI)$artists
  related_artist_names = related_artists$name
  artist_list = c(related_artist_names, artist_list)
  
  # Create the edges
  from = c(from, rep(artist_name, length(related_artist_names)))
  to = c(to, related_artist_names)
}

edges = data.frame(from, to, stringsAsFactors=FALSE)
nodes = data.frame(id=unique(as.character(artist_list)),
                   shape = "circularImage",
                   image=artist_image_url)

# Remove all vertices with 1 edge
temp = data.frame(artist=c(edges$from, edges$to))
connected_artists = temp %>% group_by(artist) %>% filter(n() > 1) %>% tally()

filtered_edges = 
  edges %>% 
  filter(from %in% connected_artists$artist, to %in% connected_artists$artist)

artist_counts =
  connected_artists %>%
  mutate(size = ifelse(artist %in% initial_artists, 1, n))

filtered_nodes = data.frame(id=artist_counts$artist, 
                            value=artist_counts$size,
                            title=artist_counts$artist,
                            label=artist_counts$artist,
                            shape = "circularImage",
                            image=artist_image_url)

filtered_nodes$group = ifelse(filtered_nodes$id %in% initial_artists, "Initial", "Related")

# Plot the network
visNetwork(filtered_nodes, filtered_edges[1]) %>% 
  visOptions(highlightNearest = TRUE) %>% 
  visGroups(groupname = "Initial", color = "red") %>%
   visGroups(groupname = "Related", color = "lightblue")
  