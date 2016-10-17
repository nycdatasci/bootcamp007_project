getwd()
setwd("./Documents/Dataset")

install.packages("openxlsx")
install.packages("dplyr")
install.packages("ggplot2")
install.packages("ggthemes")
install.packages("maptools")
install.packages("maps")
install.packages("RColorBrewer")
install.packages("corrplot")

library(dplyr)
library(ggplot2)
library(maptools)
library(maps)
library(ggthemes)
library(RColorBrewer)
library(corrplot)


# Load Datasets
location = read.csv("All_Starbucks_Locations_in_the_World.csv")
locationCol = data.frame(names(location))
top20brands = read.xlsx("ForbesTop20Brands2016.xlsx")
top20brandsCol = data.frame(names(top20brands))
top20brandsCol

# IDEA #1: Top 20 Brands Globally & Starbucks
ggplot(top20brands, aes(x = Brand, y = Age)) + 
  geom_point()

ggplot(top20brands, aes(x = Brand, y = Age)) + 
  geom_point(data = top20brands, aes(fill = Brand.Value, size = 5)) +
  coord_flip()


# IDEA #2:starbucks globally on geographic map
# use world map library
world_map = map_data("world")
names(world_map)

# geographical map of starbucks stores globally
storeLocGlob = 
ggplot(world_map) + 
  geom_polygon(aes(x=long, y=lat, group=group), 
               fill="white", color="grey10") + 
  geom_point(data=location, aes(x=Longitude, y=Latitude), 
             alpha = 0.2, color = "#00592d", size=1) +
  xlab("longitude") + ylab("latitude")


# IDEA #3: starbucks by city

# create DF for stores by city count
storebyCity= 
  location%>%
  count(City)

# convert non-english characters to english
storebyCity2 =
  storebyCity%>%
  filter_(storebyCity$City == "上海市")
  mutate("Shanghai")
  
str(storebyCity$City)

# create density curve showing 
storeCityDensity =
  ggplot(storebyCity, aes(x=n), fill = City) +
  geom_density(color ="#00592d", fill = "#00592d") +
  scale_x_log10() +
  theme_bw() + xlab("number of stores") + ylab("density") + 
  theme(axis.title.x = element_text(colour = "darkgreen"), 
        axis.title.y = element_text(colour = "darkgreen"))

# create new DF with top 20  
Top20SbuxCities = storebyCity%>%
  arrange(-n)%>%
  top_n(20)
Top20SbuxCities

# create horizontal bar chart for Top20 cities with starbucks
Top20SbuxCitiesChart =
  ggplot(Top20SbuxCities, aes(x= reorder(City, n), y=n, fill = City )) + 
  geom_bar(stat = "identity") + theme_bw() + 
  theme(axis.title.x = element_text(colour = "darkgreen"),
          axis.title.y = element_text(color = "darkgreen")) +
  xlab("cities") + ylab("number of stores") +
      coord_flip()

# create new col = LocationCategory [US, non-US]
location$LocationCategory = c()
location$LocationCategory = ifelse(location$Country == "US", "US", "non-US")
str(location$LocationCategory)
head(location$LocationCategory)


# create bar graph showing LocationCategory & OwnershipType

LocationCatOwnTyp = 
  ggplot(location, aes(x=reorder(LocationCategory, Ownership.Type))) + 
  geom_bar(aes(fill = Ownership.Type)) + xlab("location") +
  ylab("number of stores")

# 


