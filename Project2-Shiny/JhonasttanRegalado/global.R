# This is needed because the shinyapps dependency detection doesn't realize
# that jsonlite::fromJSON needs httr when using URLs.
library(httr)
library(rjson)
library(RJSONIO)
library(shiny)
library(shinydashboard)
library(dplyr)
library(leaflet)
library(googleVis)
library(data.table)
library(DT)

#load 1k row sample data for June
cb_df  <- read.csv("./data/201606-citibike-tridatasubset.csv",stringsAsFactors = FALSE) #sampled 1k rows dataset

#calculate avg ride times between locations: from / to
cb_df_avg_trip_duration <- cb_df %>% group_by(start.station.id, start.station.name, 
                                              start.station.latitude, start.station.longitude,
                                              end.station.id,end.station.name, end.station.latitude,
                                              end.station.longitude) %>% 
  summarise(avg_duration_sec = mean(tripduration), 
            avg_duration_min = mean(tripduration)/60 ) %>% 
  filter(start.station.id != end.station.id) %>%  #select destinations where start station is not equal to end station.
  arrange(start.station.name) 

#set leaflet map tile
tile_layer <- "https://api.mapbox.com/styles/v1/mapbox/streets-v10/tiles/256/{z}/{x}/{y}?access_token=pk.eyJ1IjoiamhvbmFzdHRhbiIsImEiOiJFLTAzeVVZIn0.mwAAfKtGwv3rs3L61jz87A"

#set column selection
cb_url <- "https://feeds.citibikenyc.com/stations/stations.json"
cb_json <- fromJSON(paste(readLines(cb_url), collapse=""))
cb_stations <- cb_json$stationBeanList
cb_station_df <- data.frame(t(sapply(cb_stations,unlist)),stringsAsFactors = FALSE)

choice <- cb_station_df$stationName