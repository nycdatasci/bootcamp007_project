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
cb_station_df$id <- as.numeric(cb_station_df$id)
cb_station_df$totalDocks <- as.numeric(cb_station_df$totalDocks)
cb_station_df$availableDocks <- as.numeric(cb_station_df$availableDocks)
cb_station_df$availableBikes <- as.numeric(cb_station_df$availableBikes)
cb_station_df <- filter(cb_station_df, statusValue == "In Service")

# set select box options
choice <- cb_station_df$stationName

#return red fonts in HTML syntax

html_font_color <- function(var_x,var_color = "green") {
  paste0("<font color=",var_color,">",var_x,"</font>")
}
