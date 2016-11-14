# Test lastfm package
library(RLastFM)
key = "2f6ddc241fa04a98e753fe4fee576afe"

# Find artist bio and tags
artist_name ="boards of canada"
res = artist.search(artist_name)
artist = res$artist[1]
info = artist.getInfo(artist, parse=FALSE)
summary = xpathSApply(info, "//summary", xmlValue)
tags = artist.getTopTags(artist)


# Look up artist on last.fm and scrape their bio
get_artist_bio = function(artist_name){
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