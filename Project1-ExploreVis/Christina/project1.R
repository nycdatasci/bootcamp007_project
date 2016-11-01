setwd("~/Downloads")
d <- read.csv("Seattle_Police_Department_911_Incident_Response.csv")
dim(d)
head(d)

library(dplyr)
library(ggplot2)
library(sp)
install.packages("maptools")
library(maptools)
install.packages("ggmap")
library(ggmap)

setwd("~/Downloads/Neighborhoods/WGS84")
neighb <- readShapeSpatial("Neighborhoods.shp", CRS("+proj=longlat +datum=WGS84"))
neighb1 <- spTransform(neighb, CRS("+proj=longlat +datum=WGS84"))
neighb_mod <- fortify(neighb1)
head(neighb_mod)

# Initial Insights - Distribution of calls
# What are the most frequent types of call made?
Freqs <- as.data.frame(table(d$Event.Clearance.Group)) %>% arrange(desc(Freq))
ggplot(data = Freqs, aes(x = reorder(Var1, Freq), y=Freq)) + 
  geom_bar(stat ="identity", col="white", fill="blue" )+
  coord_flip(ylim=c(0, 230000)) +
  theme(axis.text.y= element_text(size=7.5))+
  labs(title="Call Frequency by Type of Call", x="Reason for Call", y="")

# What time do people make the most calls?
d$datetime <- strptime(as.character(d$Event.Clearance.Date), 
                       tz = "PST7PDT",
                       format = "%m/%d/%Y %I:%M:%S %p")
callsbyhour <- as.data.frame(table(d$datetime$hour))  %>% arrange(desc(Freq))
ggplot(data = callsbyhour, aes(x = reorder(Var1, Freq), y=Freq)) + 
  geom_bar(stat ="identity", col="white", fill="red" )+
  coord_flip(ylim=c(0, 80000)) +
  theme(axis.text.y= element_text(size=11))+
  labs(title="Call Frequency by Hour", x="Time", y="")

# Where do people make the most calls from ?
st_polygon <- readShapePoly("~/Downloads/Neighborhoods/WGS84/Neighborhoods.shp")
d_L_HOOD <- over(SpatialPoints(cbind(d$Longitude, d$Latitude)[complete.cases(cbind(d$Longitude, d$Latitude)),]), st_polygon)
d1 <- na.omit(d)
d1$S_HOOD <- d_L_HOOD$S_HOOD
callsbyhood <- as.data.frame(table(d1$S_HOOD))  %>% arrange(desc(Freq))
ggplot(data = callsbyhood, aes(x = reorder(Var1, Freq), y=Freq)) + 
  geom_bar(stat ="identity", col="white", fill="dark green" )+
  coord_flip(ylim=c(0, 92000)) +
  theme(axis.text.y= element_text(size=5.5))+
  labs(title="Call Frequency by Neighborhood", x="Neighborhood", y="")

#When does the most frequent type of call occur?
most.f <- d[d$Event.Clearance.Group=="TRAFFIC RELATED CALLS",]
ggplot(data = most.f, aes(x = most.f$datetime$hour)) + 
  geom_histogram(binwidth = 1, col="black", fill="dark green" ) +
  theme_minimal()+ 
  labs(title="Volume of Traffic Related Calls by Hour", x="Time", y="")

most.f2 <- d[d$Event.Clearance.Group=="SUSPICIOUS CIRCUMSTANCES",]
ggplot(data = most.f2, aes(x = most.f2$datetime$hour)) + 
  geom_histogram(binwidth = 1, col="black", fill="red" ) +
  theme_minimal() + 
  labs(title="Volume of Suspicious Circumstances Calls by Hour", x="Time", y="")

most.f3 <- d[d$Event.Clearance.Group=="DISTURBANCES",]
ggplot(data = most.f3, aes(x = most.f3$datetime$hour)) + 
  geom_histogram(binwidth = 1, col="black", fill="orange" ) +
  theme_minimal() +
  labs(title="Volume of Disturbances Calls by Hour", x="Time", y="")

most.f4 <- d[d$Event.Clearance.Group=="LIQUOR VIOLATIONS",]
ggplot(data = most.f4, aes(x = most.f4$datetime$hour)) + 
  geom_histogram(binwidth = 1, col="black", fill="blue" ) +
  theme_minimal() + 
  labs(title="Volume of Liquor Violations Calls by Hour", x="Time", y="")

burg <- d[d$Event.Clearance.Group=="BURGLARY",]
ggplot(data = burg, aes(x = burg$datetime$hour)) + 
  geom_histogram(binwidth = 1, col="black", fill="magenta" ) +
  theme_minimal() + 
  labs(title="Volume of Burglary Calls by Hour", x="Time", y="")

assault <- d[d$Event.Clearance.Group=="ASSAULTS",]
ggplot(data = assault, aes(x = assault$datetime$hour)) + 
  geom_histogram(binwidth = 1, col="black", fill="brown" ) +
  theme_minimal() + 
  labs(title="Volume of Assault Calls by Hour", x="Time", y="")

#Where do the most frequent types of call occur during peak ours?
map.seattle_city<- qmap("seattle", zoom = 11, source="stamen", maptype="toner",darken = c(.1,"#BBBBBB"))

# TRAFFIC RELATED CALLS
peak.t.mf2 <- most.f[most.f$datetime$hour >= 8 & most.f$datetime$hour<12,]
map.seattle_city +
  geom_polygon(aes(x = long, y = lat, group = group), data = neighb_mod,
               colour = 'black', fill = 'white', alpha = .2, size=0.4) +
  geom_point(data=peak.t.mf2, aes(x=Longitude, y=Latitude), color="dark green", alpha=.05, size=0.08)+
  labs(title="Location of Traffic Related Calls 8AM to NOON ", x="", y="")

peak.t.mf <- most.f[most.f$datetime$hour >= 20 & most.f$datetime$hour<24,]
map.seattle_city +
  geom_polygon(aes(x = long, y = lat, group = group), data = neighb_mod,
             colour = 'black', fill = 'white', alpha = .2, size=0.4) +
  geom_point(data=peak.t.mf, aes(x=Longitude, y=Latitude), color="dark green", alpha=.05, size=0.08)+
  labs(title="Location of Traffic Related Calls 8PM to MIDNIGHT ", x="", y="")

# SUSPICIOUS CIRCUMSTANCES
peak.t.sc <- most.f2[most.f2$datetime$hour >= 20 & most.f2$datetime$hour<24,]
map.seattle_city +  
  geom_polygon(aes(x = long, y = lat, group = group), data = neighb_mod,
               colour = 'black', fill = 'white', alpha = .2, size=0.4) +
  geom_point(data=peak.t.sc, aes(x=Longitude, y=Latitude), color="red", alpha=.05, size=0.08)+
  labs(title="Location of Suspicious Circumstances Calls 8PM to MIDNIGHT ", x="", y="")

# DISTURBANCES
peak.t.dist2 <- most.f3[most.f3$datetime$hour >= 20 & most.f3$datetime$hour< 24,]
map.seattle_city +
  geom_polygon(aes(x = long, y = lat, group = group), data = neighb_mod,
               colour = 'black', fill = 'white', alpha = .2, size=0.4) +
  geom_point(data=peak.t.dist2, aes(x=Longitude, y=Latitude), color="orange", alpha=.04, size=0.06)+
  labs(title="Location of Disturbances Calls 8PM to MIDNIGHT", x="", y="")

peak.t.dist <- most.f3[most.f3$datetime$hour >= 0 & most.f3$datetime$hour< 4,]
map.seattle_city +
  geom_polygon(aes(x = long, y = lat, group = group), data = neighb_mod,
               colour = 'black', fill = 'white', alpha = .2, size=0.4) +
  geom_point(data=peak.t.dist, aes(x=Longitude, y=Latitude), color="orange", alpha=.04, size=0.06)+
  labs(title="Location of Disturbances Calls MIDNIGHT to 4AM", x="", y="")

# LIQUOR VIOLATIONS
peak.t.lv <- most.f4[most.f4$datetime$hour >= 20 & most.f4$datetime$hour< 24,]
map.seattle_city +
  geom_polygon(aes(x = long, y = lat, group = group), data = neighb_mod,
               colour = 'black', fill = 'white', alpha = .2, size=0.4) +
  geom_point(data=peak.t.lv, aes(x=Longitude, y=Latitude), color="blue", alpha=.04, size=0.06)+
  labs(title="Location of Liquor Violation Calls 8PM to MIDNIGHT", x="", y="")

# BURGLARIES
peak.t.b <- burg[burg$datetime$hour >= 15 & burg$datetime$hour< 20,]
map.seattle_city +
  geom_polygon(aes(x = long, y = lat, group = group), data = neighb_mod,
               colour = 'black', fill = 'white', alpha = .2, size=0.4) +
  geom_point(data=burg, aes(x=Longitude, y=Latitude), color="magenta", alpha=.04, size=0.06) +
  labs(title="Location of Burglary Calls 3PM to 8PM", x="", y="")

# ASSAULTS
peak.t.a <- assault[assault$datetime$hour >= 17 & assault$datetime$hour< 21,]
map.seattle_city +
  geom_polygon(aes(x = long, y = lat, group = group), data = neighb_mod,
               colour = 'black', fill = 'white', alpha = .2, size=0.4) +
  geom_point(data=peak.t.a, aes(x=Longitude, y=Latitude), color="brown", alpha=.04, size=0.06)+
  labs(title="Location of Assault Calls 5PM to 9PM", x="", y="")

peak.t.a2 <- assault[assault$datetime$hour >= 0 & assault$datetime$hour< 4,]
map.seattle_city +
  geom_polygon(aes(x = long, y = lat, group = group), data = neighb_mod,
               colour = 'black', fill = 'white', alpha = .2, size=0.4) +
  geom_point(data=peak.t.a2, aes(x=Longitude, y=Latitude), color="brown", alpha=.04, size=0.06)+
  labs(title="Location of Assault Calls MIDNIGHT to 4AM", x="", y="")













