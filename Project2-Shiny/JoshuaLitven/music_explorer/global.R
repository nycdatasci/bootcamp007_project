library(dplyr)
require(visNetwork)
library(googleVis)
library(shinyjs)
library(shinydashboard)
library(shiny)
suppressPackageStartupMessages(library(googleVis))

DATA_PATH = '/Users/alexanderlitven/Courses/nyc_data_science_academy/bootcamp007_project/Project2-Shiny/JoshuaLitven/scraping/data/'

jsCode = "shinyjs.pageCol = function(source){document.getElementById('audio_player').src=source};"
jsCode2 = "shinyjs.pauseAudio = function(){document.getElementById('audio_player').pause()};"
js_play_audio = "shinyjs.playAudio = function(){document.getElementById('audio_player').play()};"

# Load playlists
playlists = read.csv(file.path(DATA_PATH, 'playlists.csv'))

# Define numerical and categorical columns
num_cols = c("Acousticness" = "acousticness",
             "Danceability" = "danceability",
             "Duration (ms)" = "duration_ms",
             "Energy" = "energy",
             "Instrumentalness" = "instrumentalness",
             "Liveness" = "liveness",
             "Loudness" = "loudness",
             "Speechiness" = "speechiness",
             "Tempo" = "tempo",
             "Positiveness" = "valence",
             "Popularity" = "popularity")

cat_cols = c("Key" = "key",
             "Modality" = "mode",
             "Time Signature" = "time_signature")

# X labels
plot_labels = names(num_cols)
names(plot_labels) = num_cols

# Get descriptive terms for selected metrics in the summary page
compute_metrics = function(){
  # Runtime
  total_runtime = paste0(round(sum(tracks$duration_ms) / (60 * 1000)), " Minutes")
  
  # Energy
  median_energy = median(tracks$energy)
  energy_level = cut(median_energy, breaks=c(0, 0.33, 0.66, 1), labels=c("Low", "Medium", "High"))
  
  # Tempo
  median_tempo = median(tracks$tempo)
  tempo_level = cut(median_tempo, breaks=c(60, 80, 100, 120, 140), labels=c("Very Slow", "Slow", "Fast", "Very Fast"))
  
  # Volume
  median_volume = median(tracks$loudness)
  volume_level = cut(median_volume, breaks=c(-20, -15, -10, -5, 0), labels=c("Very Quiet", "Quiet", "Loud", "Very Loud"))
  
  # Valence
  median_valence = median(tracks$valence)
  valence_level = cut(median_valence, breaks=c(0, 0.33, 0.66, 1), labels=c("Negative", "Neutral", "Positive"))
  
  # Popularity
  median_popularity = median(tracks$popularity)
  popularity_level = cut(median_popularity, breaks=c(0, 50, 75, 100), 
                         labels=c("Mustic Snob", "Popular", "Very Popular"))
  
  # Top tags
  genres = artists$genres
  genre_lists = sapply(genres, function(x) strsplit(x, ", "))
  genre_counts = data.frame(genre=unlist(genre_lists), stringsAsFactors = FALSE)  %>% count(genre)  %>% arrange(desc(n))
  genre_counts
  top_genres = genre_counts[1:10,]
  top_genres$genre.annotation = top_genres$genre
}
