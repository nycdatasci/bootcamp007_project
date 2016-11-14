#rm(list = ls())
#################### tripadvisor data ###############

## preprocess price_range
test = unlist(strsplit(
  tripadvisor$price_range,
  split = c("[$-(]"),
  perl = T
))

## get the odd rows
test_low = test[seq(2, length(test), 4)]
test_high = test[seq(3, length(test), 4)]
## remove "-" in the test_low
price_low = as.numeric(gsub("-", "", test_low))
price_high = as.numeric(test_high) ## there is a NA in price_high need to delete in future

##process hotel star data
star_test <- unlist(strsplit(
  tripadvisor$hotel_star,
  split = c("star")
))

hotel_star <- star_test[seq(1,length(star_test),2)] # save hotel_star

##process hotel name
hotel_name <- gsub(",","", tripadvisor$hotel_name)
hotel_name <- gsub("\\n","",hotel_name)

##process review tags
review_tag <- gsub("All reviews,","", tripadvisor$review_tag)

##remove dirty columns
drop_t <- c("review_tag",
            "hotel_star",
            "services",
            "price_range",
            "hotel_name")
## drop dirty columns
tripadvisor_d <- tripadvisor[,!(names(tripadvisor) %in% drop_t)]
## create clean and beautiful final trip advisor
tripadvisor1 <- cbind(hotel_name, tripadvisor_d$address, coords$lon, coords$lat, 
                      tripadvisor_d$review_score,
                      hotel_star, price_low, price_high, review_tag)

## rename columns in tripadvisor1
tripadvisor_names <- c("hotel_name",
                       "address",
                       "lon",
                       "lat",
                       "review_score",
                       "hotel_star",
                       "price_low",
                       "price_high",
                       "review_tag")

colnames(tripadvisor1) <- tripadvisor_names
tripadvisor2 <- cbind(tripadvisor1, a_trip)
## remove NA in tripadvisor1 price_high
tripadvisor3 = tripadvisor2 %>% na.omit()

tripadvisor_final <- data.frame(tripadvisor3, stringsAsFactors = F)

###save final file as csv
write.csv(tripadvisor_final,"~/Downloads/tripadvisor_final.csv")

as.numeric(tripadvisor_final$price_low)
as.numeric(tripadvisor_final$price_high)

lapply(tripadvisor_final, class)
##process serveice content (amenities in tripadvisor)
## refer worldcloud_service


test1 <- read.csv("~/Downloads/airbnb_final.csv")      ##works:)
test2 <- read.csv("~/Downloads/tripadvisor_final.csv") ##works:)

##map tripadvisor hotel get tripadvisor map
##get lon and lat
library(ggmap)
library(leaflet)
library(plotly)

coords <- geocode(tripadvisor_d$address)
names(coords)   #coords$lon,coords$lat
##add lon and lat into tripadvisor

