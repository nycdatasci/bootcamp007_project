#################################################
# Nelson Chen
# nchen9191@gmail.com
# NYC Data Science Academy
# Shiny Project
# data cleaning/preprocessing
#################################################

# Packages
library(dplyr)

## Load Data
flights = read.csv('2008.csv', na.strings = NULL)
airports = read.csv('airports.csv')

## Join tables
new_flights = inner_join(flights, airports, by = c("Origin" = "iata"))
new_flights = inner_join(new_flights, airports, by = c("Dest" = "iata"))
names(new_flights)[c(34,35,40,41)] = c('Origin_Lat','Origin_Long','Dest_Lat','Dest_Long')

## Select Columns

new_flightsv2 = new_flights %>% select(Year,
                                       Month,
                                       DayofMonth,
                                       DayOfWeek,
                                       UniqueCarrier,
                                       ArrDelay,
                                       DepDelay,
                                       Origin,
                                       Dest,
                                       Cancelled,
                                       Diverted,
                                       CarrierDelay,
                                       WeatherDelay,
                                       NASDelay,
                                       SecurityDelay,
                                       LateAircraftDelay,
                                       Origin_Lat,
                                       Origin_Long,
                                       Dest_Lat,
                                       Dest_Long)

# Delay only set
delays_only = new_flightsv2[new_flightsv2$WeatherDelay != 'NA',]

# Cancelled only set
cancelled_only =  new_flightsv2[new_flightsv2$Cancelled == 1,]

# Total flights by route
total_byroutes = flights  %>% group_by(Origin,Dest)  %>% summarise(total_flights = n())

# Total flights by airline
total_byairline = flights  %>% group_by(UniqueCarrier)  %>% summarise(total_flights = n())

# Total flights
weekly_total_flights = flights %>% group_by(Origin, Dest, UniqueCarrier, DayOfWeek) %>% summarise(total_flights = n())
monthly_total_flights = flights %>% group_by(Origin, Dest, UniqueCarrier, Month) %>% summarise(total_flights = n())

# Save files
saveRDS(delays_only, "delays_only.RDS")
saveRDS(total_byroutes, 'total_byroutes.RDS')
saveRDS(weekly_total_flights, 'weekly_total_flights.RDS')
saveRDS(monthly_total_flights, 'monthly_total_flights.RDS')
