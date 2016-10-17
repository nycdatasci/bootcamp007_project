getwd()
setwd("/Users/chris")
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
library(openxlsx)


# Load Datasets
location = read.csv("All_Starbucks_Locations_in_the_World.csv")
locationCol = data.frame(names(location))
top20brands = read.xlsx("ForbesTop20Brands2016.xlsx")
top20brandsCol = data.frame(names(top20brands))
top10brands = read.xlsx("ForbesTop10Brands2016.xlsx")
coffeeConsumption = read.xlsx("coffeeConsumptionGDP.xlsx")
coffeeConsumptionCol = data.frame(names(coffeeConsumption))

# IDEA #1: Top 20 Brands Globally & Starbucks

bubbleBrand = ggplot(top10brands, aes(x= Brand.Value, y = Age, size = Brand.Value, fill = Brand)) +
  geom_point(shape = 21, size = 20)

bubbleBrand + scale_y_continuous(breaks = seq(1, 200, 5)) +
  coord_flip() + theme_bw() +
  theme(legend.position="bottom", legend.direction="horizontal",
                       legend.box = "horizontal",
                       legend.key.size = unit(1, "cm")) +
  labs(x = "Brand Value in $ billion", y = "Age")
  

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
storebyCity2 = storebyCity


# test
storebyCity2 = mutate(storebyCity, City == "上海市", "Shanghai", City)
storebyCity2 = mutate(storebyCity, City == "北京市", "Beijing", City)

  
  

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
  ggplot(Top20SbuxCitiesTrans, aes(x= reorder(City, n), y=n, fill = City )) + 
  geom_bar(stat = "identity") + theme_bw() + 
  theme(axis.title.x = element_text(colour = "darkgreen"),
        axis.title.y = element_text(color = "darkgreen")) +
  xlab("cities") + ylab("number of stores") +
  coord_flip()

#test

write.csv(Top20SbuxCities, file = "Top20SbuxCitiesCSV.csv")
write.csv(storebyCity, file = "storebyCityCSV.csv")


# create new col = LocationCategory [US, non-US]
location$LocationCategory = c()
location$LocationCategory = ifelse(location$Country == "US", "US", "non-US")
str(location$LocationCategory)
head(location$LocationCategory)

Top20SbuxCitiesTrans = read.xlsx("Top20SbuxCitiesTrans.xlsx")

# IDEA #4: create bar graph showing LocationCategory & OwnershipType

LocationCatOwnTyp = 
  ggplot(location, aes(x=reorder(LocationCategory, Ownership.Type))) + 
  geom_bar(aes(fill = Ownership.Type)) + xlab("location") +
  ylab("number of stores")

# IDEA #5: coffee consumption per capita 
# source: https://fusiontables.google.com/DataSource?docid=1C-fn6nSe21acP0xJIO1T1x0wohqfMYCQyJjbqdk#rows:id=1

globalConsumpChart = 
  ggplot(coffeeConsumption, aes(x= CoffeeinKG)) + 
  geom_density(color = "#6f4e37", fill = "#6f4e37") +
  theme_bw() + xlab("Coffee Consumption per Capita (in kg)")

# top 10 coffee consumers
globalConsump2 = coffeeConsumption%>%
select(Country,CoffeeinKG)

coffeeLover10 = globalConsump2%>%
  arrange(CoffeeinKG)%>%
  top_n(10)

# coffeeLover10 bar graph
coffeeLover10Bar = ggplot(coffeeLover10, aes(reorder(Country, CoffeeinKG ), y = CoffeeinKG)) + 
  geom_bar(stat = "identity", aes(fill = Country )) + theme_bw() + 
  theme(axis.title.x = element_text(colour = "darkgreen"),
        axis.title.y = element_text(color = "darkgreen")) +
  xlab("country") + ylab("Coffee Consumption per Capita (in kg)") +
  coord_flip()


# are there starbucks stores in coffeeLover10?
location%>%
  select(storebyCity= 
           location%>%
           count(City))

storebyCountry = 
  location%>%
  count(Country)




