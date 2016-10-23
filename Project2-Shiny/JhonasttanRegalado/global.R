# This is needed because the shinyapps dependency detection doesn't realize
# that jsonlite::fromJSON needs httr when using URLs.
library(httr)

#cb_df  <- read.csv("/Users/jhonasttanregalado/Documents/DataScience/bootcamp7/githubcrush/bootcamp007_project/Project2-Shiny/JhonasttanRegalado/201606-citibike-tripdata.csv",stringsAsFactors = FALSE)

cb_df  <- read.csv("./data/201606-citibike-tridatasubset.csv",stringsAsFactors = FALSE) #sampled 1k rows dataset

#which(rowSums(is.na(cb_df)) !=0 )
#length(which(rowSums(is.na(cb_df)) !=0 ))

cb_df_avg_trip_duration <- cb_df %>% group_by(start.station.id, start.station.name, 
                                              start.station.latitude, start.station.longitude,
                                              end.station.id,end.station.name, end.station.latitude,
                                              end.station.longitude) %>% 
  summarise(avg_duration_sec = mean(tripduration), 
            avg_duration_min = mean(tripduration)/60 ) %>% 
  filter(start.station.id != end.station.id) %>%  #select destinations where start station is not equal to end station.
  arrange(start.station.name) 

oneRow <- cb_df_avg_trip_duration[1,c("start.station.name","start.station.latitude","start.station.longitude","end.station.name","end.station.latitude","end.station.longitude")]
tempMatrix <- oneRow %>% matrix(2,3,2)
exmapLeaflet <- as.data.frame(tempMatrix)
names(exmapLeaflet)  <- c("station.name","lat","lng")
exmapLeaflet$lat <- as.numeric(exmapLeaflet$lat)
exmapLeaflet$lng <- as.numeric(exmapLeaflet$lng)

tile_layer <- "https://api.mapbox.com/styles/v1/mapbox/streets-v10/tiles/256/{z}/{x}/{y}?access_token=pk.eyJ1IjoiamhvbmFzdHRhbiIsImEiOiJFLTAzeVVZIn0.mwAAfKtGwv3rs3L61jz87A"

choice <- colnames(cb_df_avg_trip_duration)