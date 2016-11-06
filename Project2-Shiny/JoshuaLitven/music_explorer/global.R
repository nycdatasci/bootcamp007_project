library(dplyr)
library(V8)
require(visNetwork)
library(googleVis)
library(shinyjs)
library(shinydashboard)
library(shiny)
suppressPackageStartupMessages(library(googleVis))

DATA_PATH = '../scraping/data'

js_set_audio_src = "shinyjs.setAudioSrc = function(source){document.getElementById('audio_player').src=source};"
js_pause_audio = "shinyjs.pauseAudio = function(){document.getElementById('audio_player').pause()};"
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