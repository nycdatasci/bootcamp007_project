# Script to create the artist network
library(dplyr)
library(visNetwork)

# Get artists
# Maximum allowed ids: 50
max_ids = 50
artist_ids = sapply(tracks, function(track) track$track$artists[[1]]$id)
URI = paste0('https://api.spotify.com/v1/artists?ids=', paste(artist_ids[1:max_ids], collapse=","))
artists = fromJSON(txt=URI)$artists
artist_cols = c('id', 'name', 'images', 'genres')
artists = artists[, artist_cols]
artists$group = 'initial'

# Create network
edges = data.frame(from=character(), to=character(), stringsAsFactors=FALSE)
for(artist_id in artists$id){ 
  
  # Find related artists
  URI = paste0('https://api.spotify.com/v1/artists/', artist_id, '/related-artists')
  related_artists = fromJSON(txt=URI)$artists
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

# Get unique artists and edges
artists = unique(artists)
edges = unique(edges)

# Remove all vertices with 1 edge
temp = data.frame(id=c(edges$from, edges$to), stringsAsFactors=FALSE)
connected_artists = temp %>% group_by(id) %>% filter(n() > 1) %>% summarise(n_edges=n())

filtered_edges = 
  edges %>% 
  filter(from %in% connected_artists$id, to %in% connected_artists$id)

filtered_nodes = 
  artists %>% 
  filter(id %in% connected_artists$id)
filtered_nodes = inner_join(filtered_nodes, connected_artists, by=c("id"))

# Process for the network
#filtered_nodes$shape = "circularImage"
#filtered_nodes$image = as.character(sapply(filtered_nodes$images, function(image) image$url[[3]]))
filtered_nodes$label = filtered_nodes$name
filtered_nodes$value = pmin(filtered_nodes$n_edges, 5)

# Plot the network
network = visNetwork(filtered_nodes, filtered_edges) %>% 
  visOptions(nodesIdSelection = TRUE, highlightNearest = TRUE) %>% 
  visNodes(shadow = list(enabled = TRUE, size = 10)) %>% 
  visEdges(shadow = TRUE,
           arrows =list(to = list(enabled = TRUE, scaleFactor = .5)),
           color = list(color = "lightblue", highlight = "darkblue"))

# Experiment
# Get counts of genres
genres = data.frame(genre=unlist(artists$genres))  %>% count(genre)  %>% arrange(desc(n))
