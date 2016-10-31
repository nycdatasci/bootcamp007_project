library(shiny)
library(shinydashboard)
library(leaflet)
library(dplyr)
library(caret)
library(RSQLite)
library(sp)


load("./data/North America.RData")
load("./data/South America.RData")
load("./data/Africa.RData")
load("./data/Australia.RData")
load("./data/Asia.RData")
load("./data/Europe.RData")


pokeID = read.csv("./data/pokemonID.csv") %>% select(., pokemonId=Id, Pokemon)
cities = c("Amsterdam","Bangkok","Central_US","Denver","Dublin","East_Coast_US","Edmonton","England","Kuching",
           "Ljubljana","Madrid","Melbourne","Mexico_City","Oslo","Paris","Phoenix","Prague",
           "Rome","Stockholm","Tokyo","Toronto","Vancouver","Vienna","Warsaw","West_Coast_US","Zurich")

# The single argument to this function, points, is a data.frame in which:
#   - column 1 contains the longitude in degrees
#   - column 2 contains the latitude in degrees
coords2region = function(points, region="continent"){  
  require("rworldmap")
  countriesSP <- getMap(resolution='low')
  #setting CRS directly to that from rworldmap
  pointsSP = SpatialPoints(points, proj4string=CRS(proj4string(countriesSP)))  
  # use 'over' to get indices of the Polygons object containing each point 
  indices = over(pointsSP, countriesSP)
  # return the ADMIN names of each country
  if (region=="continent"){
    indices$REGION
  }else if (region=="country"){
    indices$ADMIN
  }
}

modelSel = function(modelName){
  switch(modelName, "North America.RData"=NorthAmericaFit,
         "South America.RData"=SouthAmericaFit,
         "Africa.RData"=AfricaFit,
         "Australia.RData"=AustraliaFit,
         "Asia.RData"=AsiaFit,
         "Europe.RData"=EuropeFit)
}

dbSel = function(regionName){
  switch(regionName, "North America"="NorthAmerica",
         "South America"="SouthAmerica",
         "Africa"="Africa",
         "Australia"="Australia",
         "Asia"="Asia",
         "Europe"="Europe")
}

dbCity = function(cityName){
  switch(cityName, "Amsterdam"="Amsterdam", "Bangkok"="Bangkok", "Central_US"="Chicago",
         "Denver"="Denver", "Dublin"="Dublin", "Edmonton"="Edmonton", "Kuching"="Kuching",
         "Ljubljana"="Ljubljana", "England"="London", "West_Coast_US"="Los_Angeles", "Madrid"="Madrid",
         "Melbourne"="Melbourne", "Mexico_City"="Mexico_City", "East_Coast_US"="New_York", "Oslo"="Oslo",
         "Paris"="Paris", "Phoenix"="Phoenix", "Prague"="Prague", "Rome"="Rome",
         "Stockholm"="Stockholm", "Tokyo"="Tokyo", "Toronto"="Toronto", "Vancouver"="Vancouver",
         "Vienna"="Vienna", "Warsaw"="Warsaw", "Zurich"="Zurich"
         )
}

