library(shiny)
library(dplyr)
library(leaflet)

# Load in the data
LOAD_DATA = TRUE
if(LOAD_DATA){
  pantheon = read.csv('data/cleaned_data/pantheon.csv', stringsAsFactors=FALSE)
  quotes = read.csv('data/cleaned_data/quotes.csv', stringsAsFactors=FALSE)
  load('data/cleaned_data/similarity_matrix.RData') # loads similarity_matrix
}


# Get the top n most similar authors
# author_name - string
# n - number of similar authors
# returns - names of authors
get_similar_authors = function(author_name, n=10){
  most_similar = sort(similarity_matrix[author_name, ], decreasing=TRUE)
  most_similar = most_similar[-1] # exclude top element
  return(names(most_similar[1:n]))
}

# Only load complete data for now
points = pantheon %>% filter(name %in% quotes$author)
points = points[complete.cases(points$LAT), ]

# Jitter the lon and lat as many points are the same
points$LON = jitter(points$LON, 5)
points$LAT = jitter(points$LAT, 5)

# Set the domain to a factor for coloring
points$domain = as.factor(points$domain)
domain_palette = colorFactor("RdYlBu", points$domain)

# Get the birth year
years = points$birthyear