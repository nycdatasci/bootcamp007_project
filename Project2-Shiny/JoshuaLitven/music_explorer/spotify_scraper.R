# Script to scrape Spotify categories
#
# Each category has a list of playlists. These playlists
# are exported in a directory as 3 csv files:
#   tracks.csv - contains track features, see https://developer.spotify.com/web-api/get-several-audio-features/
#   artists.csv - contains artists and their related artists
#   edges.csv - contains the edges between artists and their related artists
#


# Libraries ---------------------------------------------------------------


library(dplyr)
library(httr)
library(jsonlite)
library(RLastFM)


# Settings ----------------------------------------------------------------


BASE_PATH = '/Users/alexanderlitven/Courses/nyc_data_science_academy/projects/Shiny/scraping/data'
MAX_NUM_AUDIO_FEATURES = 100
MAX_NUM_TRACKS = 50
MAX_NUM_ARTISTS = 50
NUM_PLAYLISTS = 1
PLAYLIST_FILE = 'playlists.csv'


# Functions ---------------------------------------------------------------


# Look up artist on last.fm and scrape their bio
# Arguments:
#   artist_name - string
# Returns:
#   The artist's bio
get_artist_bio = function(artist_name){
  
  print(artist_name)
  out = tryCatch({
    info = artist.getInfo(artist_name, parse=FALSE)
    summary = xpathSApply(info, "//summary", xmlValue)
    summary
  },
  error = function(cond){
    return('No bio available!')
  }
  )
  return(out)
}

# Scrape a Spotify category and dumping its playlists
# Arguments:
#   category_id - string
#   num_playlists - integer
# Returns:
#   None
scrape_category = function(category_id='pop', num_playlists=NUM_PLAYLISTS){
  
  # Get playlists from category
  playlists = get_playlists(category_id)
  playlists = playlists[1:num_playlists, ]
  image_url = sapply(playlists$images, function(image) return(image['url'][[1]]))
  playlists = data.frame(playlist_id=playlists$id, owner_id=playlists$owner$id, 
                         name=playlists$name, image_url, category_id)
  
  # TODO: Dump category information e.g. name and image
  write.table(playlists, file=file.path(BASE_PATH, PLAYLIST_FILE), 
              append=TRUE, row.names=FALSE, sep=",", col.names=FALSE)
  
  # Dump playlists to csv files
  apply(playlists, 1, dump_playlist, export_path=BASE_PATH)
}

# Dump playlist to csv files
# Arguments:
#   playlist_id - string
#   user_id - string
# Returns:
#   None
dump_playlist = function(playlist_row, export_path){
  
  # Get playlist data
  playlist_id = playlist_row['playlist_id']
  owner_id = playlist_row['owner_id']
  
  # Create playlist directory
  playlist_path = file.path(export_path, playlist_id)
  dir.create(playlist_path)
  
  # Get playlist tracks
  tracks = get_tracks(playlist_id, user_id=owner_id)
  artist_ids = unlist(lapply(tracks$artists, function(artist) artist$id))
  
  # Dump scraped data to csv files
  dump_track_features(tracks$id, playlist_path)
  dump_artist_network(artist_ids, playlist_path)
}

# Get playlist info from a playlist url
# Arguments:
#   playlist_id - the Spotify playlist link or url
# Returns:
#   tracks - a dataframe of track features
#   artists - a dataframe of artists
#   edges - a dataframe of connections between artists
get_playlist_info = function(playlist_url){
  
  # Parse the playlist and user ids
  split_playlist_url = unlist(strsplit(playlist_url, '/|:'))
  user_id = split_playlist_url[which(split_playlist_url=='user') + 1]
  playlist_id = split_playlist_url[which(split_playlist_url=='playlist') + 1]
  
  # Get playlist info
  playlist_info = get_playlist(user_id, playlist_id)
  
  # Get playlist track features
  tracks = get_tracks(playlist_id, user_id)
  track_features = get_track_features(tracks$id)
  
  artist_ids = unlist(lapply(tracks$artists, function(artist) artist$id))
  artist_network = get_artist_network(artist_ids)
  artists = artist_network[[1]]
  edges = artist_network[[2]]
  
  return(list(track_features, artists, edges, playlist_info))
}

# Get playlists of a category
# Arguments:
#   category_id - string
# Returns:
#   Data frame of playlists
get_playlists = function(category_id){
  
  # Request playlists
  URI = paste0('https://api.spotify.com/v1/browse/categories/', category_id, '/playlists')
  request = GET(url = URI, add_headers(Authorization = HeaderValue))
  playlist_object = fromJSON(content(request, "text")) 
  playlists = playlist_object$playlists$items
  return(playlists)
}

# Get a playlist list
# Arguments:
#   user_id - string
#   playlist_id - string
# Returns:
#   list of playlist info
get_playlist = function(user_id, playlist_id){
  
  # Request playlist
  URI = paste0('https://api.spotify.com/v1/users/', user_id,'/playlists/', playlist_id)
  request = GET(url = URI, add_headers(Authorization = HeaderValue))
  playlist_info = fromJSON(content(request, "text"))
  return(playlist_info)
}

# Get tracks of a playlist
# Arguments:
#   playlist_id - string
#   user_id - string
# Returns:
#   Data frame of tracks
get_tracks = function(playlist_id, user_id){
  
  # Request tracks
  URI = paste0('https://api.spotify.com/v1/users/', user_id,'/playlists/', playlist_id,'/tracks')
  response2 = GET(url = URI, add_headers(Authorization = HeaderValue))
  tracks = fromJSON(content(response2, "text"))$items$track
  return(tracks)
}

# Get top tracks of an artist
# Arguments:
#   artist_id - string
# Returns:
#   vector containing (id, name, preview_url)
get_top_track = function(artist_id){
  
  # Request tracks
  URI = paste0('https://api.spotify.com/v1/artists/', artist_id,'/top-tracks?country=US')
  response2 = GET(url = URI, add_headers(Authorization = HeaderValue))
  tracks = fromJSON(content(response2, "text"))$tracks
  if(length(tracks)==0){
    return(NA)
  }
  top_track = c(tracks$id[1], tracks$name[1], tracks$preview_url[1])
  return(top_track)
}

# Get track features
# Arguments:
#   track_ids - list
# Returns:
#   dataframe of track features
get_track_features = function(track_ids){
  
  # Get audio features for tracks 
  max_ids = min(MAX_NUM_AUDIO_FEATURES, length(track_ids))
  URI = paste0('https://api.spotify.com/v1/audio-features/?ids=', paste(track_ids[1:max_ids], collapse=","))
  request = GET(url = URI, add_headers(Authorization = HeaderValue))
  features_obj = fromJSON(content(request, "text"))
  features = features_obj[[1]]
  
  # Request tracks
  max_tracks = min(MAX_NUM_TRACKS, max_ids)
  features = features[1:max_tracks, ]
  URI = paste0('https://api.spotify.com/v1/tracks/?ids=', paste(features$id, collapse=","))
  response2 = GET(url = URI, add_headers(Authorization = HeaderValue))
  track_info = fromJSON(content(response2, "text"))
  tracks = track_info$tracks
  tracks$artist = as.character(lapply(tracks$artists, function(x) x['name'][1, 'name']))
  tracks = tracks[, c('uri', 'name', 'popularity', 'preview_url', 'artist')]
  tracks = inner_join(tracks, features, by="uri")
  return(tracks)
}

# Dump track features to a csv file
# Arguments:
#   track_ids - list
#   export_path - path to export csv file
# Returns:
#   None
dump_track_features = function(track_ids, export_path){
  
  # get track features
  tracks = get_track_features(track_ids)
  
  # export to csv
  write.csv(tracks, file.path(export_path, 'tracks.csv'))
}

# Dump artist network to a csv file
# Arguments:
#   artists_ids - list of artist ids
#   export_path - directory path
# Returns:
#   None
dump_artist_network = function(artist_ids, export_path){
  
  network_info = get_artist_network(artist_ids)
  artists = network_info[[1]]
  edges = network[[2]]
  
  # Export to csv
  write.csv(artists, file.path(export_path,'artists.csv'))
  write.csv(edges, file.path(export_path, 'edges.csv'))
}

# Get artist network
# Arguments:
#   artists_ids - list of artist ids
# Returns:
#   list containing artists and edge dataframes
get_artist_network = function(artist_ids){

  # Get artists details
  max_ids = min(MAX_NUM_ARTISTS, length(artist_ids))
  URI = paste0('https://api.spotify.com/v1/artists?ids=', paste(artist_ids[1:max_ids], collapse=","))
  artists = fromJSON(txt=URI)$artists
  artist_cols = c('id', 'name', 'images', 'genres')
  artists = artists[, artist_cols]
  artists$group = 'initial'
  
  # Create network
  edges = data.frame(from=character(), to=character(), stringsAsFactors=FALSE)
  
  n_artists = nrow(artists)
  withProgress(message = 'Building Artist Network', value = 0, {
    for(artist_id in artists$id){ 
      
      # Increment the progress bar, and update the detail text.
      incProgress(1/n_artists)
      
      # Find related artists
      URI = paste0('https://api.spotify.com/v1/artists/', artist_id, '/related-artists')
      related_artists = fromJSON(txt=URI)$artists
      if(length(related_artists) == 0){
        next
      }
      related_artists = related_artists[, artist_cols]
      related_artists$group = 'related'
      related_artist_ids = related_artists$id
      
      # Create the edges
      from = rep(artist_id, length(related_artist_ids))
      to = related_artist_ids
      edges = rbind(edges, data.frame(from, to, stringsAsFactors = FALSE))
      
      # Append to artists data frame
      # Filter out artists already stored
      related_artists =
        related_artists %>% 
        filter(!id %in% artists$id)
      artists = rbind(artists, related_artists)
    }
  })
  
  print("Getting Unique artists..")
  # Get unique artists and edges
  artists = unique(artists)
  edges = unique(edges)
  
  # Remove all artists with only one connection in the network
  temp = data.frame(id=c(edges$from, edges$to), stringsAsFactors=FALSE)
  connected_artists = temp %>% group_by(id) %>% filter(n() > 1) %>% summarise(n_edges=n())
  
  filtered_edges = 
    edges %>% 
    filter(from %in% connected_artists$id, to %in% connected_artists$id)
  
  filtered_artists = 
    artists %>% 
    filter(id %in% connected_artists$id)
  filtered_artists = inner_join(filtered_artists, connected_artists, by=c("id"))
  
  # Convert images to one url
  print("Converting images to one url..")
  filtered_artists$image = as.character(sapply(filtered_artists$images, function(image) tail(image$url, n=1)))
  filtered_artists$images = NULL
  # Convert genres to string
  filtered_artists$genres = sapply(filtered_artists$genres, function(genre) paste(genre, collapse=', '))
  
  return(list(filtered_artists, filtered_edges))
}

# Get the Spotify token header for API calls
# Returns:
#   Header for GET requests
get_token_header = function(){
  clientID = 'e74c52988f6d4bcebb36970a423d348d'
  secret = '0edc87deae1a4611a97b6cebef262136'
  
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
  return(HeaderValue)
}

# Get authorization token so we can scrape Spotify
HeaderValue = get_token_header()

# Scraping ----------------------------------------------------------------

scrape = function(){
  # Clear playlists file
  write('id, owner_id, name, image_url, category_id', file=file.path(BASE_PATH, PLAYLIST_FILE))
  
  # Scrape categories
  # Categories: pop, rock, jazz etc.
  categories = c('pop', 'rock', 'jazz', 'indie_alt', 'edm_dance', 'chill', 'sleep', 'hiphop', 'country', 'soul', 'blues')
  for(category in categories){
    scrape_category(category)
  }
}
