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

#gauge query
cb_station_bike_gauge <- cb_station_df[,c("stationName","availableBikes")] %>% arrange(desc(availableBikes))
cb_station_dock_gauge <- cb_station_df[,c("stationName","availableDocks")] %>% arrange(desc(availableDocks))

# set select box options
choice <- cb_station_df$stationName

maxBikes <- max(cb_station_df$availableBikes)
maxDocks <- max(cb_station_df$availableDocks)

#return red fonts in HTML syntax

html_font_color <- function(var_x,var_color = "green") {
  paste0("<font color=",var_color,">",var_x,"</font>")
}


get_coordinates <- function(vars) { #process two addresses and return coordinates for leaflet
  oneRow <- filter(cb_station_df, stationName == vars[1]) %>% 
    select(stationName,latitude,longitude, availableBikes, availableDocks, totalDocks)
  oneRow <- rbind(oneRow, filter(cb_station_df, stationName == vars[2]) %>% 
                    select(stationName,latitude,longitude, availableBikes, availableDocks, totalDocks))
  
  exmapLeaflet <- oneRow
  names(exmapLeaflet)[1:3]  <- c("station.name","lat","lng")
  exmapLeaflet$lat <- as.numeric(exmapLeaflet$lat)
  exmapLeaflet$lng <- as.numeric(exmapLeaflet$lng)
  
  #capture waypoints
  conUrl_start <- "https://api.mapbox.com/directions/v5/mapbox/cycling/"
  conUrl_mid <- paste0(exmapLeaflet$lng[1],",",exmapLeaflet$lat[1],";",exmapLeaflet$lng[2],",",exmapLeaflet$lat[2]) # ex: -73.98,40.73;-73.97,40.75
  conUrl_end <- "?geometries=geojson&continue_straight=true&access_token=pk.eyJ1IjoiamhvbmFzdHRhbiIsImEiOiJFLTAzeVVZIn0.mwAAfKtGwv3rs3L61jz87A"
  conUrl <- paste0(conUrl_start,conUrl_mid,conUrl_end)
  
  con <- url(conUrl)  
  data.json <- fromJSON(paste(readLines(con), collapse=""))
  close(con)
  
  poly_points <- data.frame(matrix((unlist(data.json$routes[[1]]$geometry$coordinates)),
                                   length(unlist(data.json$routes[[1]]$geometry$coordinates)),2,2))
  names(poly_points) <- c("lng","lat")
  travel_duration <- data.json$routes[[1]]$duration
  
  
  #complete coordinates
  #poly_points <- rbind(poly_points, exmapLeaflet[2,c('lng','lat')])
  #poly_points <- rbind(poly_points,poly_points[rev(rownames(poly_points)),])
  #rownames(poly_points) <- 1:nrow(poly_points)
  #observe(poly_points)
  list(ExmapLeaflet = exmapLeaflet,Poly_points = poly_points, Data.json = data.json)
}

get_markers <- function(vars) {
  cb_station_df_markers <- filter(cb_station_df, cb_station_df$stationName %in% vars[[1]] ) %>% 
    select(stationName,lat = latitude,lng = longitude, availableBikes, availableDocks, totalDocks)
  cb_station_df_markers_2 <- filter(cb_station_df, availableBikes >= vars[[2]] | availableDocks >= vars[[3]] ) %>% 
    select(stationName,lat = latitude,lng = longitude, availableBikes, availableDocks, totalDocks)
  cb_station_df_markers <- rbind(cb_station_df_markers,cb_station_df_markers_2)
  
}


get_all_markers <- function(inputBikesAvailable = 0,inputDocksAvailable = 0) {
  print(names(inputBikesAvailable))
  cb_station_df_all_markers <- cb_station_df %>% 
    filter( cb_station_df, (availableBikes >= as.integer(inputBikesAvailable) | availableDocks >= as.integer(inputDocksAvailable)) ) %>%
    select(stationName,lat = latitude,lng = longitude, availableBikes, availableDocks, totalDocks)
}