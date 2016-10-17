# Script to create the world playlist markdown file

# Load the necessary packages
require(curl)
require(jsonlite)

# Your API key obtained via https://console.developers.google.com/ 
API_key='AIzaSyAt0_WRWxpckm72zxCG_sCGHjA7vi9sZNA'

# Base URL for Google API's services and YouTube specific API's
Base_URL='https://www.googleapis.com/youtube/v3'

# YouTube Web Services
# Note that we have replaced the %2C with "," so sprintf works correctly with it
# as an alternative we can add an extra % in front of %2C to make it %%2C
YT_Service <- c( 'search?part=snippet&q=%s&maxResults=1&orderby=viewCounttype=%s&key=%s',                         # search API
                 'subscriptions?part=snippet,contentDetails&channelId=%s&key=%s'    # subscriptions API
)

# Create a youtube url from an artist name
# returns (video_name, video_url) as a list
create_video_url = function(artist_name) {
  # Form request URL
  url <- paste0(Base_URL, "/", 
                sprintf('search?part=snippet&q=%s&maxResults=1&orderby=viewCount&type=%s&key=%s', # search 1 result
                        gsub(" ", "+", paste(artist_name, "band", sep = " ")),
                        'video',
                        API_key))
  
  # Perform query
  result <- fromJSON(txt=url)
  
  # Get the video id
  video_id = result[['items']][['id']][['videoId']]
  video_url = paste0('https://www.youtube.com/watch?v=', video_id)
  
  # Get the video name
  video_name = result[['items']][['snippet']][['title']]
  return(list(video_name, video_url))
}

# Create the R markdown file with a playlist for each artist
create_playlist = function(artist_by_country){
  
  # Top of R markdown file
  header = 
    "---
  title: \"Popular Artists Around the World\"
  author: \"Joshua Litven\"
  date: \"10/15/2016\"
  output: html_document
---
  
Country | Artist | Country Pop. | World Pop. | Net Pop.
---|---|---|---|---|\n"
  
  output_file = "playlist.Rmd"
  cat(header, file=output_file)
  
  write_row = function(x, output){
    
    country = x[1]
    artist = x[2]
    country_pop = x[3]
    world_pop = x[4]
    net_pop = x[5]
    
    video = create_video_url(artist)
    video_name = video[[1]]
    video_url = video[[2]]
    
    cat(paste0(country, " | ", "[", artist, "]", "(", video_url, ") |", country_pop, "|", world_pop, "|", net_pop, "\n"), 
        file=output, append=T)
  }
  
  apply(artist_by_country, 1, write_row, output=output_file)
}
