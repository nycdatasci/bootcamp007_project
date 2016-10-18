library(ggplot2)
library(maps)
library(scales)
library(ggmap)
library(RColorBrewer)
library(reshape2)
library(geosphere)
# 緯度と経度の範囲は手作業で
long.lim <- expand_range(range(typhoon.all$Longitude), 0.05)
lat.lim <- expand_range(range(typhoon.all$Latitude), 0.05)
jpn <- data.frame(map(plot=FALSE, fill=TRUE, col="blue", xlim = long.lim, ylim = lat.lim)[c("x","y")]) 
# 地図座標系用
library(maptools)

p <- ggplot(typhoon.all, aes(Longitude, Latitude, colour = Name)) + 
  geom_point(aes(size = Pressure), shape = 21, alpha = 0.8) + # drawing the pressure size
  geom_path(arrow = arrow()) + # drawing the line
  geom_path(aes(x, y, colour = NULL), jpn) + # draws the map? how?
  coord_map(xlim = long.lim, ylim = lat.lim) +  # set coordinates to mercator
  scale_size_continuous(range = c(1, 10), trans = "reverse") + #scale point, lower pressure the greater the circle
  ggtitle("Typhoons in the Pacific 2016")

p


# 2016 Typhoon Visualization ----------------------------------------------

# use one year only for these! 

#add gradient

jpn.map <- qmap("Japan", zoom = 3, maptype = "hybrid", extent = "panel")
typhoon.2016.g1 <- jpn.map +
  geom_point(data = typhoon.all, aes(Longitude, Latitude, col = Name, size = Pressure), 
             shape = 21, alpha = 0.8) +
  geom_path(data = typhoon.all, aes(x = Longitude, y = Latitude, col = Name), arrow = arrow()) +
  scale_size_continuous(range = c(1,10), trans = "reverse") + 
  ggtitle("Typhoons in the Pacific 2016")


typhoon.2016.g1

# wind speed has too many missing values
jpn.map <- qmap("Japan", zoom = 3, maptype = "hybrid", extent = "panel")
typhoon.2016.g2 <- jpn.map +
  geom_point(data = typhoon.all, aes(Longitude, Latitude, size = MaxWindSpd, col = Name), 
             shape = 21, alpha = 0.8) + 
  geom_path(data = typhoon.all, aes(x = Longitude, y = Latitude, col = Name)) 

?scale_color_gradient

typhoon.2016.g2





# Plot Grade Level No good 6 is extra tropical cyclone, its not intensity
grade.g <- ggplot(typhoon.all, aes(x=NRow, y=Grade)) +
  geom_bar(stat="identity") + facet_wrap(~Name)

grade.g

# plot Pressure over Time
# need to adjust scales
pressure.g <- ggplot(typhoon.all, aes(x=Time, y=Pressure, col = Name)) +
  geom_line(stat="identity") + ylim(c(900,1100)) + facet_wrap(~Name, scales = "free_x") 


pressure.g

# plot windspeed over Time
wind.g <- ggplot(typhoon.all, aes(x=Time, y=MaxWindSpd, col = Name)) +
  geom_line() + facet_wrap(~Name, scales = "free_x")

wind.g

# plot pressure vs windspeed
# doesnt work well
pressure.wind.g <- ggplot(typhoon.all, aes(x=Pressure, y=MaxWindSpd, col = Name)) +
  geom_line() + facet_wrap(~Name)

pressure.wind.g



# 1951 -2016 Typhoon Visualization


# Seasonality Code --------------------------------------------------------


start.marker <- which(typhoon.all$TimeElapsed == 0)
typhoon.start <- typhoon.all[start.marker,]

end.marker <- start.marker - 1
# boundary cases
end.marker <- c(end.marker[-1],nrow(typhoon.all))
typhoon.end <- typhoon.all[end.marker,]

typhoon.start.end <- rbind(typhoon.start, typhoon.end)
typhoon.start.end$Point <- ifelse(typhoon.start.end$TimeElapsed == 0, "Start",
                                  "End")
typhoon.start.end$Point <- as.factor(typhoon.start.end$Point)

# seasonality by start date of Typhoon
# need to calculate start and end separately to avoid grabbing end points
# with a start point in a different season
# basic split by month
# can reshape too with reshape2
# deal with NA variables?
spring.start <- typhoon.start[month(typhoon.start$Time) %in% c(3:5),]
summer.start <- typhoon.start[month(typhoon.start$Time) %in% c(6:8),]
autumn.start <- typhoon.start[month(typhoon.start$Time) %in% c(9:11),]
winter.start <- typhoon.start[month(typhoon.start$Time) %in% c(12,1,2),]


spring.end <- filter(typhoon.end, IID %in% spring.start$IID)
summer.end <- filter(typhoon.end, IID %in% summer.start$IID)
autumn.end <- filter(typhoon.end, IID %in% autumn.start$IID)
winter.end <- filter(typhoon.end, IID %in% winter.start$IID)

spring.start.end <- rbind(spring.start, spring.end)
summer.start.end <- rbind(summer.start, summer.end)
autumn.start.end <- rbind(autumn.start, autumn.end)
winter.start.end <- rbind(winter.start, winter.end)

spring.start.end$Point <- ifelse(spring.start.end$TimeElapsed == 0, "Start", "End")
spring.start.end$Point <- as.factor(spring.start.end$Point)
summer.start.end$Point <- ifelse(summer.start.end$TimeElapsed == 0, "Start", "End")
summer.start.end$Point <- as.factor(summer.start.end$Point)
autumn.start.end$Point <- ifelse(autumn.start.end$TimeElapsed == 0, "Start", "End")
autumn.start.end$Point <- as.factor(autumn.start.end$Point)
winter.start.end$Point <- ifelse(winter.start.end$TimeElapsed == 0, "Start", "End")
winter.start.end$Point <- as.factor(winter.start.end$Point)

'''
typhoon.spring <- typhoon.all[spring.start$IID,]
typhoon.summer <- typhoon.all[summer.start$IID,]
typhoon.autumn <- typhoon.all[autumn.start$IID,]
typhoon.winter <- typhoon.all[winter.start$IID,]
'''

# Start and End By Season -------------------------------------------------

test.g <- jpn.map +
  geom_line(data =autumn.start.end, aes(Longitude,Latitude,group=IID), 
            col ="beige", alpha=0.5) + 
  geom_point(data = autumn.start.end, 
             aes(Longitude,Latitude, fill=Point), shape =21) +
  ggtitle("1951 - 2016 Autumn Typhoon Start and End Locations")

test.g

test2.g <- jpn.map +
  geom_line(data =autumn.start.end[year(autumn.start.end$Time) > 2000,], aes(Longitude,Latitude,group=IID), 
            col ="beige", alpha=0.5) + 
  geom_point(data = autumn.start.end[year(autumn.start.end$Time) > 2000,], 
             aes(Longitude,Latitude, fill=Point), shape =21) +
  ggtitle("2000 - 2016 Autumn Typhoon Start and End Locations")

test2.g


test3.g <- jpn.map +
  geom_line(data =spring.start.end[year(spring.start.end$Time) > 2000,], aes(Longitude,Latitude,group=IID), 
            col ="beige", alpha=0.5) + 
  geom_point(data = spring.start.end[year(spring.start.end$Time) > 2000,], 
             aes(Longitude,Latitude, fill=Point), shape =21) +
  ggtitle("2000 - 2016 Spring Typhoon Start and End Locations")

test3.g


test4.g <- jpn.map +
  geom_line(data =summer.start.end[year(summer.start.end$Time) > 2000,], aes(Longitude,Latitude,group=IID), 
            col ="beige", alpha=0.5) + 
  geom_point(data = summer.start.end[year(summer.start.end$Time) > 2000,], 
             aes(Longitude,Latitude, fill=Point), shape =21) +
  ggtitle("2000 - 2016 Summer Typhoon Start and End Locations")

test4.g

test5.g <- jpn.map +
  geom_line(data =winter.start.end[year(winter.start.end$Time) > 2000,], aes(Longitude,Latitude,group=IID), 
            col ="beige", alpha=0.5) + 
  geom_point(data = winter.start.end[year(winter.start.end$Time) > 2000,], 
             aes(Longitude,Latitude, fill=Point), shape =21) +
  ggtitle("2000 - 2016 Winter Typhoon Start and End Locations")

test5.g


# Counts --------------------------------------------------------
typhoon.month <- data.frame("Month"= month(typhoon.start$Time))

years.of.data <- max(year(typhoon.all$Time)) - min(year(typhoon.all$Time))
avg.per.month <- summarise(group_by(typhoon.month, Month), Avg = round(n()/years.of.data,3))
avg.per.month$Month <- month.abb[avg.per.month$Month]

avg.month.g <- ggplot(avg.per.month, aes(x= reorder(Month, c(1:12)), y= Avg, fill = Month)) +
  geom_bar(stat="identity") + geom_text(aes(label = Avg), vjust = -.5) + guides(fill=FALSE) +
  labs(title="1951-2016 Average Typhoons per Month", x = "Month") 

avg.month.g

season.count <- data.frame("Season" = c("Spring", "Summer", "Autumn","Winter"),
                   "Count" = c(nrow(spring.start), nrow(summer.start),
                               nrow(autumn.start), nrow(winter.start)))
season.count

season.g <- ggplot(season.count, aes(x=reorder(Season, c(1:4)), y=Count)) +
  geom_bar(stat="identity", aes(fill=Season), col="black") +
  geom_text(aes(label=Count), vjust = -.5) + 
  theme_bw() +
  labs(title = "1951-2016 Typhoons by Season", x="Season") + guides(fill=FALSE) +
  scale_fill_manual(values = c("darkorange","limegreen", "gold", "deepskyblue"))

season.g

typhoon.distinct <-distinct(typhoon.all, IID, .keep_all =  TRUE)
typhoon.distinct[,"Time"]
typhoon.years <- data.frame("Year" =year(typhoon.distinct[,"Time"]))
summary(typhoon.years)

year.g <- ggplot(typhoon.years, aes(x=Year)) + geom_bar(col = "Black", fill = "royalblue") +
  labs(title="Typhoons Per Year")

year.g
# Clusters ----------------------------------------------------------------

# (0, 30) , (80, 130)
tester <- 
  autumn.end[between(autumn.end$Longitude, 80,130) & between(autumn.end$Latitude, 0,30),"IID"]

cluster1.g <- jpn.map +
  geom_line(data =autumn.start.end[autumn.start.end$IID %in% tester,], 
            aes(Longitude,Latitude,group=IID), 
            col ="beige", alpha=0.5) + 
  geom_point(data = autumn.start.end[autumn.start.end$IID %in% tester,], 
             aes(Longitude,Latitude, fill=Point), shape =21) +
  ggtitle("Autumn Typhoon Start and End Locations 2")

cluster1.g

# (25,65), (170,190)
tester <- 
  autumn.end[between(autumn.end$Longitude, 170,190) & between(autumn.end$Latitude, 25,65),"IID"]

cluster2.g <- jpn.map +
  geom_line(data =autumn.start.end[autumn.start.end$IID %in% tester,], 
            aes(Longitude,Latitude,group=IID), 
            col ="beige", alpha=0.5) + 
  geom_point(data = autumn.start.end[autumn.start.end$IID %in% tester,], 
             aes(Longitude,Latitude, fill=Point), shape =21) +
  ggtitle("Autumn Typhoon Start and End Locations 3")

cluster2.g

# Distances Traveled ------------------------------------------------------
# note assumes spherical earth
# could query google for more precise distances
# positions <- select(typhoon.all, IID, Longitude, Latitude)
# 
# is for loop avoidable? we are using values that are in data frame
# distance.traveled <- rep(0,nrow(typhoon.header2))
# z <- 1
# while( z < nrow(typhoon.header2) + 1) {
#   r <- 1
#   counts <- typhoon.header2[z,"NRow"]
#   while( r < counts){
#     distance.traveled[z] <- distance.traveled[z] +
#       distHaversine(c(positions[r,"Longitude"], positions[r,"Latitude"]),
#                     c(positions[r+1, "Longitude"],positions[r+1, "Latitude"]))
# 
#     r <- r + 1
# 
# 
#   }
#   z <- z + 1
# }
# distance.traveled
# ?distHaversine
# 
# typhoon.distances <- data.frame("IID"= typhoon.header2$IID,
#                                 "DistanceTraveled" = distance.traveled / 1000)
# saveRDS(typhoon.distances, "typhoon.distances.rds")

typhoon.distances <- readRDS("typhoon.distances.rds")



# Average Max Sustained Wind Speed vs. Distance Traveled ------------------
typhoon.compare1 <- summarise(group_by(filter(typhoon.all,!is.na(MaxWindSpd)), 
                                       IID), AvgMaxWindSpd = mean(MaxWindSpd))
typhoon.compare1 <- inner_join(typhoon.compare1, typhoon.distances, by="IID")

typhoon.compare1.g <- ggplot(typhoon.compare1, 
                             aes(x = DistanceTraveled / 10, y = AvgMaxWindSpd)) +
  geom_point() + xlim(c(0,2000)) + theme_bw() +
  labs(title = "Average Max Sustained Wind Speed vs. Distance Traveled",
       x = "Distance Traveled (10km)", y = "AvgMaxSusWindSpd (kt)")

typhoon.compare1.g



# Average Pressure vs. Distance Traveled ----------------------------------

typhoon.compare2 <- summarise(group_by(filter(typhoon.all,!is.na(Pressure)), 
                                       IID), AvgPressure = mean(Pressure))
typhoon.compare2 <- inner_join(typhoon.compare2, typhoon.distances, by="IID")

typhoon.compare2.g <- ggplot(typhoon.compare2, 
                             aes(x = DistanceTraveled / 10, y = AvgPressure)) +
  geom_point() + xlim(c(0,2000)) + theme_bw() +
  labs(title = "Average Pressure vs. Distance Traveled",
       x = "Distance Traveled (10km)", y = "AvgPressure (hPa)")

typhoon.compare2.g

# Average Pressure vs Time Elapsed ----------------------------------------

typhoon.compare3 <- summarise(group_by(filter(typhoon.all,!is.na(Pressure)), 
                                       IID), AvgPressure = mean(Pressure))

typhoon.compare3 <- inner_join(typhoon.compare3, typhoon.end, by="IID")

typhoon.compare3.g <- ggplot(typhoon.compare3, 
                             aes(x = TimeElapsed, y = AvgPressure)) +
  geom_point() + theme_bw() +
  labs(title = "Average Pressure vs. Time Elapsed",
       x = "Time Elapsed (hours)", y = "AvgPressure (hPa)")

typhoon.compare3.g


# MaxWindSpd vs Time Elapsed ----------------------------------------------

typhoon.compare4 <- summarise(group_by(filter(typhoon.all,!is.na(MaxWindSpd)), 
                                       IID), AvgMaxWindSpd = mean(MaxWindSpd))

typhoon.compare4 <- inner_join(typhoon.compare4, typhoon.end, by="IID")

typhoon.compare4.g <- ggplot(typhoon.compare4, 
                             aes(x = TimeElapsed, y = AvgMaxWindSpd)) +
  geom_point() + theme_bw() +
  labs(title = "Average Max Sustained Wind Speed vs. Time Elapsed",
       x = "Time Elapsed (hours)", y = "AvgPressure (hPa)")

typhoon.compare4.g

# Avg Pressure vs Avg MaxWdSpd

typhoon.compare5 <- summarise(group_by(filter(typhoon.all,!is.na(MaxWindSpd),
                                                !is.na(Pressure)), 
                                       IID), AvgMaxWindSpd = mean(MaxWindSpd),
                                AvgPressure = mean(Pressure))

typhoon.compare5.g <- ggplot(typhoon.compare5, aes(x = AvgMaxWindSpd, y = AvgPressure)) +
  geom_point() + theme_bw() +
  labs(title = "Average Pressure vs. Average Max Sustained Wind Speed",
       x = "AvgMaxSusWindSpd (kt)", y = "AvgPressure (hPa)")


typhoon.compare5.g

  

# distance traveled vs time elapsed ---------------------------------------
typhoon.compare6 <- inner_join(typhoon.distances, typhoon.end, by="IID")

typhoon.compare6.g <- ggplot(typhoon.compare6, aes(x = TimeElapsed, y = DistanceTraveled / 10)) +
  geom_point() + theme_bw() +
  labs(title = "Distance Traveled vs Time Elapsed",
       x = "Time Elapsed (hours)", y = "Distance Traveled (10km)")

typhoon.compare6.g
  

# Distance Histogram ------------------------------------------------------

distance.g <- ggplot(typhoon.distances, aes(x=DistanceTraveled)) +
  geom_histogram(binwidth = 1000, col="black", fill = "limegreen") + 
  xlab("DistanceTraveled (km)") + ggtitle(" 1951 - 2016 Typhoon Distance Traveled")

distance.g

#brewer_pal()
#display.brewer.all()
