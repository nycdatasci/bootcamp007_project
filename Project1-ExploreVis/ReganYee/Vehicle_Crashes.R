library(RgoogleMaps)
library(dplyr)
library(ggplot2)
library(ggmap)
library(choroplethrZip)

setwd("~/Documents/Project")
vehc = read.csv("NYPD_Motor_Vehicle_Collisions.csv")

## Look at some column data from vehc to understand the data structure.
colnames(vehc)
distinct(vehc, CONTRIBUTING.FACTOR.VEHICLE.1)
distinct(vehc, CONTRIBUTING.FACTOR.VEHICLE.2)
distinct(vehc, NUMBER.OF.PERSONS.KILLED)

# Create a monthDate column
v = strsplit(as.character(vehc$DATE),"/")
v1 = matrix(unlist(v), ncol=3, byrow=TRUE)
v2 = paste(v1[,1],v1[,2],sep="/")
vehc$monthDate = v2

# Create a month column
v = strsplit(as.character(vehc$DATE),"/")
v1 = matrix(unlist(v), ncol=3, byrow=TRUE)
vehc$month = v1[,1]

# Create a year column
v = strsplit(as.character(vehc$DATE),"/")
v1 = matrix(unlist(v), ncol=3, byrow=TRUE)
vehc$year = v1[,3]

############### By Time
# We want to organize the crashes by hours
date_hour = strptime(vehc$TIME,"%H")
hour = as.numeric(format(date_hour, "%H")) +
  as.numeric(format(date_hour, "%M"))/60
vehc$hour = hour

common_times = vehc %>% group_by(hour) %>%
                        summarize(count=n()) %>% 
                        arrange(desc(count))

common_months = vehc %>% group_by(month) %>%
  filter(year %in% c(2013,2014,2015)) %>% 
  summarize(count=n()) %>% 
  arrange(desc(count))

##Barchart of the common times of car crashes in the entire dataset.
g_hour=ggplot(data=common_times)
g_hour+geom_bar(aes(x=hour, y=count),stat="identity")

##Barchart of the common months of car crashes in the entire dataset.
g_month=ggplot(data=common_months)
g_month+geom_bar(aes(x=month, y=count),stat="identity")

############### By Year

### Contributing Factors Summaries
contributing_factors = vehc %>% select(CONTRIBUTING.FACTOR.VEHICLE.1,CONTRIBUTING.FACTOR.VEHICLE.2,CONTRIBUTING.FACTOR.VEHICLE.3,CONTRIBUTING.FACTOR.VEHICLE.4,CONTRIBUTING.FACTOR.VEHICLE.5)
distinct(contributing_factors, CONTRIBUTING.FACTOR.VEHICLE.1)
sum1 = contributing_factors %>% group_by(CONTRIBUTING.FACTOR.VEHICLE.1) %>% summarize(count=n())
sum2 = contributing_factors %>% group_by(CONTRIBUTING.FACTOR.VEHICLE.2) %>% summarize(count=n())
reasons = sum1 %>% arrange(desc(count))
sum1 %>% arrange(desc(count))
sum2 %>% arrange(desc(count))
reasons[[1]]

### Number of people killed by year sum(Pedestrians, Cyclists, Motorists)
vehc %>% group_by(year) %>% summarize(total=sum(NUMBER.OF.PERSONS.KILLED))
vehc %>% group_by(year) %>% summarize(total=sum(NUMBER.OF.PEDESTRIANS.KILLED))

## Summarize to get the count per year
vehc %>% group_by(year) %>%
                   summarize(count=n())

##Find all records with 2016 in its DATE
year_filter = grepl("2016", vehc$DATE)
crashesIn2016 = vehc %>% filter(year_filter)

#######################ggplot2()
##Plot the crashes for the year 2016
g = ggplot(data = crashesIn2016, aes(x = LONGITUDE, y = LATITUDE, color = BOROUGH))

###Scatterplot of 2016 crashes without any base map
g + geom_point(data = crashesIn2016, aes(x=LONGITUDE, y=LATITUDE, color = BOROUGH), size=0.01)
###Binmap of 2016 crashes without any base map
g + geom_bin2d(data = crashesIn2016, aes(x=LONGITUDE, y=LATITUDE))
##Density map of 2016 crashes without any base map
g + geom_density2d(data = crashesIn2016, aes(x=LONGITUDE, y=LATITUDE)) + facet_wrap (~ BOROUGH)

#####################RGoogleMaps()
#Calculate the center for the Google Maps
avglat = mean(vehc$LONGITUDE, na.rm=TRUE)
avglon = mean(vehc$LATITUDE, na.rm=TRUE)
center=c(avglon,avglat)

#Plot on Google Maps with center as Bensonhurst
BrooklynMap = GetMap(center = "Bensonhurst", size = c(640,640), zoom=14)
bklyn = PlotOnStaticMap(BrooklynMap,crashesIn2016$LATITUDE,crashesIn2016$LONGITUDE)

####################ggmap()
## Create a ggmap for Bensonhurst
map<-get_map(location='Bensonhurst', zoom=13, maptype = "terrain",
             source='google',color='color')
map2<-get_map(location='Bensonhurst', zoom=10, maptype = "terrain",
             source='google',color='color')

###Scatterplot of crashes with location='Bensonhurst'
ggmap(map) + geom_point(data = crashesIn2016, aes(x=LONGITUDE, y=LATITUDE, color = "red"), size=0.1)
###Binmap of crashes with location='Bensonhurst'
ggmap(map) + geom_bin2d(data = crashesIn2016, aes(x=LONGITUDE, y=LATITUDE), bins=40)
###Density map of crashes with location='Bensonhurst'
ggmap(map2) + geom_density_2d(data = crashesIn2016, aes(x=LONGITUDE, y=LATITUDE, color=BOROUGH))


###################choroplethrZip
data(zip.regions)
head(zip.regions)
distinct(zip.regions,cbsa)

nyz = zip.regions %>% filter(state.name=='new york')
data(df_pop_zip)

# New York City is comprised of 5 counties: Bronx, Kings (Brooklyn), New York (Manhattan), 
# Queens, Richmond (Staten Island). Their numeric FIPS codes are:
nyc_fips = c(36005, 36047, 36061, 36081, 36085)

zip_counts = vehc %>% 
  group_by(year,ZIP.CODE) %>%
  summarize(count = n()) %>%
  select(year, ZIP.CODE, value = count) %>%
  mutate(region = as.character(ZIP.CODE))


crashes_in_2016 = zip_counts %>% filter(year==2016)
crashes_in_2015 = zip_counts %>% filter(year==2015)
crashes_in_2014 = zip_counts %>% filter(year==2014)
crashes_in_2013 = zip_counts %>% filter(year==2013)
crashes_in_2012 = zip_counts %>% filter(year==2012)

## 2015 vs 2014
y2015.vs.y2014 = left_join(crashes_in_2015,crashes_in_2014,by = 'region')
df20152014 = as.data.frame(y2015.vs.y2014) %>% select(year.x,region,value.x,value.y)
df20152014 = df20152014 %>% mutate(value=value.x-value.y)

# Choropleth map of changes from 2015-2014
diff2015 = zip_choropleth(df20152014,
                       county_zoom=nyc_fips,
                       num_colors = 1,
                       legend="Difference in Accidents")

diff2015 + scale_fill_gradient2(
  low = "#67a9cf",
  mid= "#f7f7f7",
  high = "#ef8a62",
  midpoint = 0,
  space = "Lab",
  na.value = "white",
  name = "Diff"
)
?ggtitle
?scale_fill_gradient2

## 2014 vs 2013
y2014.vs.y2013 = left_join(crashes_in_2014,crashes_in_2013,by = 'region')
df20142013 = as.data.frame(y2014.vs.y2013) %>% select(year.x,region,value.x,value.y)
df20142013 = df20142013 %>% mutate(value=value.x-value.y)
head(df20142013 %>% arrange(desc(value)))

# Choropleth map of changes from 2015-2014
diff2014 = zip_choropleth(df20142013,
                          county_zoom=nyc_fips,
                          num_colors = 1,
                          legend="Difference in Accidents")

diff2014 + scale_fill_gradient2(
  low = "#67a9cf",
  mid= "#f7f7f7",
  high = "#ef8a62",
  midpoint = 0,
  space = "Lab",
  na.value = "white",
  name = "Diff",
  limits = c(-275,200)
)


crashes_in_2013 %>% filter(region==11435)
crashes_in_2014 %>% filter(region==11435)
crashes_in_2015 %>% filter(region==11435)
crashes_in_2014 %>% summarize(count=n())
crashes_in_2015 %>% arrange(desc(value))

crashes_in_2013 %>% summarize(count=sum(value))
crashes_in_2014 %>% summarize(count=sum(value))
crashes_in_2015 %>% summarize(count=sum(value))
### Crashes broken down by day of year
crashperday = vehc %>% filter(year==2014) %>% 
                                 select(year,DATE,monthDate) %>%
                                 group_by(monthDate) %>% 
                                 summarize(count=n())

tail(crashperday,20)
crashperday %>% arrange(count)
crashperday %>% arrange(desc(count))

crashperdayg = ggplot(data=crashperday)
crashperdayg + geom_point(aes(x=monthDate,y=count))

# Choropleth map of 2016 crashes by zip and count accidents
g2016 = zip_choropleth(crashes_in_2016,
               county_zoom=nyc_fips,
               num_colors = 1,
               title="2016 Vehicular Crashes",
               legend="Number of Accidents")

g2015 = zip_choropleth(crashes_in_2015,
               county_zoom=nyc_fips,
               num_colors = 1,
               title="2015 Vehicular Crashes",
               legend="Number of Accidents")

g2014 = zip_choropleth(crashes_in_2014,
                       county_zoom=nyc_fips,
                       num_colors = 1,
                       title="2014 Vehicular Crashes",
                       legend="Number of Accidents")

g2013 = zip_choropleth(crashes_in_2013,
                       county_zoom=nyc_fips,
                       num_colors = 1,
                       title="2013 Vehicular Crashes",
                       legend="Number of Accidents")

g2012 = zip_choropleth(crashes_in_2012,
                       county_zoom=nyc_fips,
                       num_colors = 1,
                       title="2012 Vehicular Crashes",
                       legend="Number of Accidents")


g2012 + scale_fill_continuous(low = "#FFFFFF", high = "red", space = "Lab", na.value = "grey50",
                              guide = "colourbar", limits=c(0,3000))

g2013 + scale_fill_continuous(low = "#FFFFFF", high = "red", space = "Lab", na.value = "grey50",
                              guide = "colourbar", limits=c(0,3000))

g2014 + scale_fill_continuous(low = "#FFFFFF", high = "red", space = "Lab", na.value = "grey50",
                              guide = "colourbar", limits=c(0,3000))

g2015 + scale_fill_continuous(low = "#FFFFFF", high = "red", space = "Lab", na.value = "grey50",
                              guide = "colourbar", limits=c(0,3000))

g2016 + scale_fill_continuous(low = "#FFFFFF", high = "red", space = "Lab", na.value = "grey50",
                              guide = "colourbar", limits=c(0,3000))