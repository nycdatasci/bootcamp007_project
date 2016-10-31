#############################################
# Nelson Chen
# nchen9191@gmail.com
# NYC Data Science Academy
# Shiny project
# Global variables
#############################################

# Read in files
delay_flights = readRDS('delays_only.RDS')
total_byroutes = readRDS('total_byroutes.RDS')
weekly_total_flights = readRDS('weekly_total_flights.RDS')
monthly_total_flights = readRDS('monthly_total_flights.RDS')
airports = read.csv('airports.csv')

# Convert some variables to factors
delay_flights$DayOfWeek = as.factor(delay_flights$DayOfWeek)
delay_flights$Origin = as.factor(delay_flights$Origin)

# Names of airport codes
airport_codes = levels(delay_flights$Origin)

# Reference map to be used
USmap = leaflet(width=900, height=650) %>% 
  setView(lng = -95.72, lat = 37.13, zoom = 4) %>%
  addProviderTiles("NASAGIBS.ViirsEarthAtNight2012",
                   options = providerTileOptions(opacity = 1))

# Key, value pairs of Airline carriers and two letter codes
Airlines = c('Endeavor Air' = '9E', 'American Airlines' = 'AA','9 Air Co' = 'AQ', 'Alaska Airlines' = 'AS',
             'Jetblue Airways' = 'B6', 'Cobaltair' = 'CO', 'Delta Airlines' = 'DL', 'ExpressJet Airlines' = 'EV',
             'Frontier Airlines' = 'F9', 'AirTran Airways' = 'FL', 'Hawaiian Airlines' = 'HA', 'Envoy Air' = 'MQ',
             'Northwest Airline' = 'NW', 'Comair' = 'OH', 'United Airlines' = 'UA', 'US Airways' = 'US', 
             'Southwest Airlines' = 'WN', 'Mesa Air Group' = 'YV')

