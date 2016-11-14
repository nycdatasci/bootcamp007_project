# left to do

#  scrape airports

# apply and clean airports and get pathway of longitudes and latitudes
# calculate cents per mile




# get pathway 

# create leaflet
# plot points
# filter by airline, hold x fixe
# filter by locaiton, hold y fixed
# filter by time, hold j fixed



# calculate lowest?


# color markers ? maybe. png file. # johnassta'ss file? green yellow radii?



flightdeal.data <- read.csv('FlightDealPrettified.txt', sep = '|', stringsAsFactors = FALSE)


# Routing -----------------------------------------------------------------


library(ggmap)
flightdeal.data <- separate_rows(flightdeal.data, Routing, sep = "/")

# note we manually removed abbr for Canada Provinces
# trivial to do manually

# read in airport codes as list
# no idea why it doesnt capture all the slashes. hidden text?
airport.codes.raw <- scan('AirportCodes.txt', what= 'character', sep ='|')

# remember split uses regular expressions 
split.codes <- unlist(lapply(airport.codes.raw, strsplit, split = '|', fixed = TRUE))

# inconsistency was found in that we lost a city when we tried to split by parantheses below
# find the culprit
# another typo in seemingly innocuous data set...
# added this manually.
which(!grepl("\\(\\w\\w\\w\\)", split.codes))

# more inconsistency. this time it's a missing space before parentheses...
for (i in which(grepl("\\w\\(", split.codes))) {
  split.codes[i] <- sub('(', ' (', split.codes[i], fixed = TRUE)
}
which(grepl("\\w\\(", split.codes))

# checks out. 3623 airorts from python
length(split.codes) 

# this is written incorrectly. doesn't actual check double parentheses.
# manually found which ones were the culprits.
# (Keeling) and (FYROM)
# which(length(gregexpr(" (?=\\()", split.codes, perl = TRUE)[[1]]) == 2)

split.codes2 <- unlist(lapply(split.codes, strsplit, split = " (?=\\()", perl = TRUE))
?gsub
# keep validating proper split
length(split.codes2) == length(split.codes) * 2

airport.codes <- data.frame('Location' = split.codes2[seq(1,length(split.codes2), 2)],
                            'Code' = split.codes2[seq(2,length(split.codes2), 2)])

airport.codes$Code <- sapply(airport.codes$Code, sub, pattern = '(', replacement ='',
                             fixed = TRUE)
airport.codes$Code <- sapply(airport.codes$Code, sub, pattern = ')', replacement ='',
                             fixed = TRUE)

airport.codes$Location <- as.character(airport.codes$Location)
airport.codes$Code <- as.character((airport.codes$Code))
# geocode takes the format cleanly!

# TravelDates -------------------------------------------------------------


flightdeal.data$TravelDates <- sapply(flightdeal.data$TravelDates, function(x){sub('^/', '', x)})
a$Routing

flightdeal.data$TravelDates

# need to decide whether to split into multiple columns for each separate travel date or
# somehow capture all of them in one.




# complicated function to add missing years
# can be made easier if we later choose to split dates into multiple
addYears <- function(travel.dates, posting.date){
  years.added = travel.dates
  # May - June 2016, year should precede dashes
  years.idx <- gregexpr('\\d{4} - ', travel.dates)[[1]]
  # May - June/July - August 2016, year should precede slashes
  years.idx2 <- gregexpr('\\d{4}/', travel.dates)[[1]]
  # year should precede end of string
  years.idx3 <- gregexpr('\\d{4}$', travel.dates)[[1]]
  
  years.idx.all <- c(years.idx , years.idx2, years.idx3)
  
  
  possible.years.idx <- gregexpr(' - ', travel.dates)[[1]]
  possible.years.idx2 <- gregexpr('/', travel.dates)[[1]]
  
  # because not every date has mutiples, indicated by /
  if(possible.years.idx2[1] == -1){
    possible.years.idx2 = integer()
  }
  
  # plus one because when we shift later we need to move 1 less
  possible.years.idx3 <- nchar(travel.dates) + 1
  possible.years.idx.all <- sort(c(possible.years.idx, possible.years.idx2, possible.years.idx3))
  
  
  years.idx.shift <- possible.years.idx.all - 4
  missing.years <- years.idx.shift %in% years.idx.all
  k <- which(missing.years == FALSE)
  
  
  # bad practice to update in loop. it's accounted for
  # how to add them all at once instead? easy in python...
  j <- 0
  # posting.date is formatted "DD Mon YYYY"
  year <- substr(posting.date, 7, nchar(posting.date))
  
  # k == integer(0) if all years are already present
  if(length(k) > 0){
    for(i in k){
      
      # adding the ' year' which is at index 7 to end of string
      years.added <- paste0(substr(years.added,1, possible.years.idx.all[i] - 1 + j),
                            year,
                            substr(years.added, possible.years.idx.all[i] + j, nchar(years.added)))
      # catch the shift due to each add
      j <- j + 5
      
      
    }
  }
  return(years.added)
}  

flightdeal.data$TravelDates <- mapply(addYears, flightdeal.data$TravelDates, flightdeal.data$PostingDate)



