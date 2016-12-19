library(dplyr)
library(ggplot2)

# Expedia data ======================================================================

setwd("~/R Workspace/Expedia/data/")
expedia = read.csv("train.csv")      # warning: takes a while to load (~30 min)

by_all_trips=
  expedia %>%
  group_by(srch_id) %>%
  summarize(count = n())

names(expedia)
# [1] "srch_id"                     "date_time"                   "site_id"                    
# [4] "visitor_location_country_id" "visitor_hist_starrating"     "visitor_hist_adr_usd"       
# [7] "prop_country_id"             "prop_id"                     "prop_starrating"            
# [10] "prop_review_score"           "prop_brand_bool"             "prop_location_score1"       
# [13] "prop_location_score2"        "prop_log_historical_price"   "position"                   
# [16] "price_usd"                   "promotion_flag"              "srch_destination_id"        
# [19] "srch_length_of_stay"         "srch_booking_window"         "srch_adults_count"          
# [22] "srch_children_count"         "srch_room_count"             "srch_saturday_night_bool"   
# [25] "srch_query_affinity_score"   "orig_destination_distance"   "random_bool"                
# [28] "comp1_rate"                  "comp1_inv"                   "comp1_rate_percent_diff"    
# [31] "comp2_rate"                  "comp2_inv"                   "comp2_rate_percent_diff"    
# [34] "comp3_rate"                  "comp3_inv"                   "comp3_rate_percent_diff"    
# [37] "comp4_rate"                  "comp4_inv"                   "comp4_rate_percent_diff"    
# [40] "comp5_rate"                  "comp5_inv"                   "comp5_rate_percent_diff"    
# [43] "comp6_rate"                  "comp6_inv"                   "comp6_rate_percent_diff"    
# [46] "comp7_rate"                  "comp7_inv"                   "comp7_rate_percent_diff"    
# [49] "comp8_rate"                  "comp8_inv"                   "comp8_rate_percent_diff"    
# [52] "click_bool"                  "gross_bookings_usd"          "booking_bool"               

# system.time(as.factor(expedia$site_id))
# expedia[c(3:4,7:9,11,15,17,21:24,27,52)] <- lapply(expedia[c(3:4,7:9,11,15,17,21:24,27,52)], factor))

#find which are consecutive
# sapply(expedia, function(x) length(unique(x)))
# is.numeric(expedia[,51])
# length(unique(expedia[,51]))
# max(expedia[,51]) - min(expedia[,51])
# 
# 
# object <- function(dataset){
#   n = ncol(dataset)
#   for(i in 1:n){
#     col_name <- names(dataset[i])
#     factor <- is.factor(dataset[[i]])
#     ordered <- is.ordered(dataset[[i]])
#     numeric <- is.numeric(dataset[[i]])
#     print(list(variable_name, factor, ordered, numeric))
#   }
# }

# i <- sapply(bob, is.factor)
# bob[i] <- lapply(bob[i], as.character)

# $ srch_id                    : int  1 1 1 1 1 1 1 1 1 1 ...
# $ date_time                  : Factor w/ 394534 levels "2012-11-01 00:01:37",..: 233427 233427 233427 233427 233427 233427 233427 233427 233427 233427 ...
# $ site_id                    : int  12 12 12 12 12 12 12 12 12 12 ...
# $ visitor_location_country_id: int  187 187 187 187 187 187 187 187 187 187 ...
# $ visitor_hist_starrating    : Factor w/ 326 levels "1.0","1.41","1.5",..: 326 326 326 326 326 326 326 326 326 326 ...
# $ visitor_hist_adr_usd       : Factor w/ 12836 levels "0.0","100.0",..: 12836 12836 12836 12836 12836 12836 12836 12836 12836 12836 ...
# $ prop_country_id            : int  219 219 219 219 219 219 219 219 219 219 ...
# $ prop_id                    : int  893 10404 21315 27348 29604 30184 44147 50984 53341 56880 ...
# $ prop_starrating            : int  3 4 3 2 4 4 3 2 4 4 ...
# $ prop_review_score          : Factor w/ 11 levels "0.0","1.0","1.5",..: 7 8 9 8 7 9 7 1 8 8 ...
# $ prop_brand_bool            : int  1 1 1 1 1 1 1 0 1 1 ...
# $ prop_location_score1       : num  2.83 2.2 2.2 2.83 2.64 2.77 2.2 1.61 2.56 2.83 ...
# $ prop_location_score2       : Factor w/ 9541 levels "0.0","0.0010",..: 430 141 237 117 1233 1294 348 9541 1230 1020 ...
# $ prop_log_historical_price  : num  4.95 5.03 4.92 4.39 4.93 5.2 4.81 4.14 5.18 5.15 ...
# $ position                   : int  27 26 21 34 4 7 18 35 3 10 ...
# $ price_usd                  : num  105 171 180 603 144 ...
# $ promotion_flag             : int  0 0 0 0 0 0 0 0 0 0 ...
# $ srch_destination_id        : int  23246 23246 23246 23246 23246 23246 23246 23246 23246 23246 ...
# $ srch_length_of_stay        : int  1 1 1 1 1 1 1 1 1 1 ...
# $ srch_booking_window        : int  0 0 0 0 0 0 0 0 0 0 ...
# $ srch_adults_count          : int  4 4 4 4 4 4 4 4 4 4 ...
# $ srch_children_count        : int  0 0 0 0 0 0 0 0 0 0 ...
# $ srch_room_count            : int  1 1 1 1 1 1 1 1 1 1 ...
# $ srch_saturday_night_bool   : int  1 1 1 1 1 1 1 1 1 1 ...
# $ srch_query_affinity_score  : Factor w/ 305668 levels "-10.0","-10.0001",..: 305668 305668 305668 305668 305668 305668 305668 305668 305668 305668 ...
# $ orig_destination_distance  : Factor w/ 685151 levels "0.01","0.02",..: 685151 685151 685151 685151 685151 685151 685151 685151 685151 685151 ...
# $ random_bool                : int  1 1 1 1 1 1 1 1 1 1 ...
# $ comp1_rate                 : Factor w/ 4 levels "-1","0","1","NULL": 4 4 4 4 4 4 4 4 4 4 ...
# $ comp1_inv                  : Factor w/ 4 levels "-1","0","1","NULL": 4 4 4 4 4 4 4 4 4 4 ...
# $ comp1_rate_percent_diff    : Factor w/ 2821 levels "10","100","1004",..: 2821 2821 2821 2821 2821 2821 2821 2821 2821 2821 ...
# $ comp2_rate                 : Factor w/ 4 levels "-1","0","1","NULL": 2 4 2 1 2 4 2 4 2 2 ...
# $ comp2_inv                  : Factor w/ 4 levels "-1","0","1","NULL": 2 4 2 2 2 4 2 4 2 2 ...
# $ comp2_rate_percent_diff    : Factor w/ 727 levels "10","100","10001",..: 727 727 727 449 727 727 727 727 727 727 ...
# $ comp3_rate                 : Factor w/ 4 levels "-1","0","1","NULL": 2 2 2 1 2 2 2 4 2 2 ...
# $ comp3_inv                  : Factor w/ 4 levels "-1","0","1","NULL": 2 2 2 2 2 2 2 4 2 2 ...
# $ comp3_rate_percent_diff    : Factor w/ 663 levels "10","100","100429",..: 663 663 663 485 663 575 663 663 663 663 ...
# $ comp4_rate                 : Factor w/ 4 levels "-1","0","1","NULL": 4 4 4 4 4 4 4 4 4 4 ...
# $ comp4_inv                  : Factor w/ 4 levels "-1","0","1","NULL": 4 4 4 4 4 4 4 4 4 4 ...
# $ comp4_rate_percent_diff    : Factor w/ 603 levels "10","100","1001584",..: 603 603 603 603 603 603 603 603 603 603 ...
# $ comp5_rate                 : Factor w/ 4 levels "-1","0","1","NULL": 2 2 2 2 2 2 4 4 4 2 ...
# $ comp5_inv                  : Factor w/ 4 levels "-1","0","1","NULL": 2 3 2 3 2 2 4 4 4 2 ...
# $ comp5_rate_percent_diff    : Factor w/ 790 levels "10","100","100001",..: 790 790 790 790 790 790 790 790 790 790 ...
# $ comp6_rate                 : Factor w/ 4 levels "-1","0","1","NULL": 4 4 4 4 4 4 4 4 4 4 ...
# $ comp6_inv                  : Factor w/ 4 levels "-1","0","1","NULL": 4 4 4 4 4 4 4 4 4 4 ...
# $ comp6_rate_percent_diff    : Factor w/ 447 levels "10","100","1002",..: 447 447 447 447 447 447 447 447 447 447 ...
# $ comp7_rate                 : Factor w/ 4 levels "-1","0","1","NULL": 4 4 4 4 4 4 4 4 4 4 ...
# $ comp7_inv                  : Factor w/ 4 levels "-1","0","1","NULL": 4 4 4 4 4 4 4 4 4 4 ...
# $ comp7_rate_percent_diff    : Factor w/ 792 levels "10","100","1001",..: 792 792 792 792 792 792 792 792 792 792 ...
# $ comp8_rate                 : Factor w/ 4 levels "-1","0","1","NULL": 2 2 2 1 2 2 2 4 2 2 ...
# $ comp8_inv                  : Factor w/ 4 levels "-1","0","1","NULL": 2 2 2 2 2 2 2 4 2 2 ...
# $ comp8_rate_percent_diff    : Factor w/ 624 levels "10","100","10000",..: 624 624 624 447 624 535 624 624 503 624 ...
# $ click_bool                 : int  0 0 0 0 0 0 0 0 0 0 ...
# $ gross_bookings_usd         : Factor w/ 85421 levels "0.0","0.01","0.3",..: 85421 85421 85421 85421 85421 85421 85421 85421 85421 85421 ...
# $ booking_bool               : int  0 0 0 0 0 0 0 0 0 0 ...

factor.cols = c(3:4,7:11,15,17,21:22,24,27,28:29,31:32,34:35,37:38,40:41,43:44,46:47,49:50)
numeric.cols = c(1,5,6,12:13,14,16,18,19,20,23,25:26,30,33,36,39,42,45,48,51:54)

factor.cols2 = c(3:4,7:8,15,17,27,28:29,31:32,34:35,37:38,40:41,43:44,46:47,49:50)
numeric.cols2 = c(1,5,6,9:13,14,16,18,19:24,23,25:26,30,33,36,39,42,45,48,51:54)

# Double check - 8,18

for(i in factor.cols2){
  expedia[,i] = as.factor(expedia[,i])
  print(paste("Applying as.factor to column", i))
  print(Sys.time())
}
for(i in numeric.cols2){
  expedia[,i] = as.numeric(as.character(expedia[,i]))
  print(paste("Applying as.numeric(as.character()) to column", i))
  print(Sys.time())
}


expedia_US[,2] = strptime(expedia_US[,2], "%Y-%m-%d %H:%M:%S")
head(strptime(expedia_US[,2], "%m/%d"))

head(strptime(expedia[,2], "%Y/%m/%d %H:%M:%S"))

head(as.Date(expedia[,2]),100)


#country codes=================
#range from 1 to 231 with 218 unique values. which 13 are missing?
which(!seq(1:231) %in% (expedia$visitor_location_country_id))
# 43  49  75  96 119 124 141 159 165 175 192 197 225
plot(expedia$visitor_location_country_id)
#do these correlate to known country codes???
#check the freq of each
#barplot(expedia$visitor_location_country_id), takes time to run
# 
# > str(expedia)
# 'data.frame':	9917530 obs. of  54 variables:
#   $ srch_id                    : num  1 1 1 1 1 1 1 1 1 1 ...
# $ date_time                  : Factor w/ 394534 levels "2012-11-01 00:01:37",..: 233427 233427 233427 233427 233427 233427 233427 233427 233427 233427 ...
# $ site_id                    : Factor w/ 34 levels "1","2","3","4",..: 12 12 12 12 12 12 12 12 12 12 ...
# $ visitor_location_country_id: Factor w/ 218 levels "1","2","3","4",..: 177 177 177 177 177 177 177 177 177 177 ...
# $ visitor_hist_starrating    : num  NA NA NA NA NA NA NA NA NA NA ...
# $ visitor_hist_adr_usd       : num  NA NA NA NA NA NA NA NA NA NA ...
# $ prop_country_id            : Factor w/ 172 levels "1","2","4","7",..: 163 163 163 163 163 163 163 163 163 163 ...
# $ prop_id                    : Factor w/ 136886 levels "1","2","3","4",..: 872 10123 20739 26592 28786 29355 42921 49571 51857 55292 ...
# $ prop_starrating            : Factor w/ 6 levels "0","1","2","3",..: 4 5 4 3 5 5 4 3 5 5 ...
# $ prop_review_score          : Factor w/ 11 levels "0.0","1.0","1.5",..: 7 8 9 8 7 9 7 1 8 8 ...
# $ prop_brand_bool            : Factor w/ 2 levels "0","1": 2 2 2 2 2 2 2 1 2 2 ...
# $ prop_location_score1       : num  2.83 2.2 2.2 2.83 2.64 2.77 2.2 1.61 2.56 2.83 ...
# $ prop_location_score2       : num  0.0438 0.0149 0.0245 0.0125 0.1241 ...
# $ prop_log_historical_price  : num  4.95 5.03 4.92 4.39 4.93 5.2 4.81 4.14 5.18 5.15 ...
# $ position                   : Factor w/ 40 levels "1","2","3","4",..: 27 26 21 34 4 7 18 35 3 10 ...
# $ price_usd                  : num  105 171 180 603 144 ...
# $ promotion_flag             : Factor w/ 2 levels "0","1": 1 1 1 1 1 1 1 1 1 1 ...
# $ srch_destination_id        : num  23246 23246 23246 23246 23246 ...
# $ srch_length_of_stay        : num  1 1 1 1 1 1 1 1 1 1 ...
# $ srch_booking_window        : num  0 0 0 0 0 0 0 0 0 0 ...
# $ srch_adults_count          : Factor w/ 9 levels "1","2","3","4",..: 4 4 4 4 4 4 4 4 4 4 ...
# $ srch_children_count        : Factor w/ 10 levels "0","1","2","3",..: 1 1 1 1 1 1 1 1 1 1 ...
# $ srch_room_count            : Factor w/ 8 levels "1","2","3","4",..: 1 1 1 1 1 1 1 1 1 1 ...
# $ srch_saturday_night_bool   : Factor w/ 2 levels "0","1": 2 2 2 2 2 2 2 2 2 2 ...
# $ srch_query_affinity_score  : num  NA NA NA NA NA NA NA NA NA NA ...
# $ orig_destination_distance  : num  NA NA NA NA NA NA NA NA NA NA ...
# $ random_bool                : Factor w/ 2 levels "0","1": 2 2 2 2 2 2 2 2 2 2 ...
# $ comp1_rate                 : Factor w/ 4 levels "-1","0","1","NULL": 4 4 4 4 4 4 4 4 4 4 ...
# $ comp1_inv                  : Factor w/ 4 levels "-1","0","1","NULL": 4 4 4 4 4 4 4 4 4 4 ...
# $ comp1_rate_percent_diff    : num  NA NA NA NA NA NA NA NA NA NA ...
# $ comp2_rate                 : Factor w/ 4 levels "-1","0","1","NULL": 2 4 2 1 2 4 2 4 2 2 ...
# $ comp2_inv                  : Factor w/ 4 levels "-1","0","1","NULL": 2 4 2 2 2 4 2 4 2 2 ...
# $ comp2_rate_percent_diff    : num  NA NA NA 5 NA NA NA NA NA NA ...
# $ comp3_rate                 : Factor w/ 4 levels "-1","0","1","NULL": 2 2 2 1 2 2 2 4 2 2 ...
# $ comp3_inv                  : Factor w/ 4 levels "-1","0","1","NULL": 2 2 2 2 2 2 2 4 2 2 ...
# $ comp3_rate_percent_diff    : num  NA NA NA 5 NA 7 NA NA NA NA ...
# $ comp4_rate                 : Factor w/ 4 levels "-1","0","1","NULL": 4 4 4 4 4 4 4 4 4 4 ...
# $ comp4_inv                  : Factor w/ 4 levels "-1","0","1","NULL": 4 4 4 4 4 4 4 4 4 4 ...
# $ comp4_rate_percent_diff    : num  NA NA NA NA NA NA NA NA NA NA ...
# $ comp5_rate                 : Factor w/ 4 levels "-1","0","1","NULL": 2 2 2 2 2 2 4 4 4 2 ...
# $ comp5_inv                  : Factor w/ 4 levels "-1","0","1","NULL": 2 3 2 3 2 2 4 4 4 2 ...
# $ comp5_rate_percent_diff    : num  NA NA NA NA NA NA NA NA NA NA ...
# $ comp6_rate                 : Factor w/ 4 levels "-1","0","1","NULL": 4 4 4 4 4 4 4 4 4 4 ...
# $ comp6_inv                  : Factor w/ 4 levels "-1","0","1","NULL": 4 4 4 4 4 4 4 4 4 4 ...
# $ comp6_rate_percent_diff    : num  NA NA NA NA NA NA NA NA NA NA ...
# $ comp7_rate                 : Factor w/ 4 levels "-1","0","1","NULL": 4 4 4 4 4 4 4 4 4 4 ...
# $ comp7_inv                  : Factor w/ 4 levels "-1","0","1","NULL": 4 4 4 4 4 4 4 4 4 4 ...
# $ comp7_rate_percent_diff    : num  NA NA NA NA NA NA NA NA NA NA ...
# $ comp8_rate                 : Factor w/ 4 levels "-1","0","1","NULL": 2 2 2 1 2 2 2 4 2 2 ...
# $ comp8_inv                  : Factor w/ 4 levels "-1","0","1","NULL": 2 2 2 2 2 2 2 4 2 2 ...
# $ comp8_rate_percent_diff    : num  NA NA NA 5 NA 7 NA NA 6 NA ...
# $ click_bool                 : Factor w/ 2 levels "0","1": 1 1 1 1 1 1 1 1 1 1 ...
# $ gross_bookings_usd         : num  NA NA NA NA NA NA NA NA NA NA ...
# $ booking_bool               : Factor w/ 2 levels "0","1": 1 1 1 1 1 1 1 1 1 1 ...



booked = expedia %>% select(gross_bookings_usd, booking_bool) %>% filter(booking_bool == 1)

histogram(expedia$price_usd)
barplot(table(expedia$booking_bool))
barplot(table(expedia$srch_room_count))
barplot(table(expedia$srch_children_count))
barplot(table(expedia$srch_adults_count))


barplot(table(expedia$visitor_location_country_id), main = "Country ID of Visitors", ylab = "Count")
barplot(table(expedia$prop_country_id), main = "Country ID of Hotels", ylab = "Count")

table(expedia$visitor_location_country_id)
table(expedia$prop_country_id)

#country 219 has 5778805 rows associated with visitors from it, and 6052976 of the hotels

barplot(table(expedia$srch_destination_id))

barplot(table(expedia$site_id),  main = "Site ID of Website", ylab = "Count")
table(expedia$site_id)
barplot(table(expedia$site_id, expedia$visitor_location_country_id == 219)[,2], main = "Site ID of Website For Visitors in Country 219", ylab = "Count")

#website 5 has the vast majority of the traffic and the vast majority of the traffic from country 219

#subsetting for this group

expedia_US =
  expedia %>%
  filter(visitor_location_country_id == 219, prop_country_id == 219)
# site_id == 5
# table(expedia_US$site_id)

#inspect an example search ID
expedia_US %>%
  filter(srch_id == 4 | srch_id == 8)


n <- length(expedia_US$price_usd)
sort(expedia_US$price_usd,partial=n-1)[n-1]
hist(expedia_US$price_usd, main = "Price", ylab = "Count", xlab = "", xlim = c(0,1000), breaks = 100000)


barplot(table(expedia_US$booking_bool),main = "Booked or Not", ylab = "Count")

barplot(table(expedia_US$srch_room_count), main = "Number of Rooms", ylab = "Count")

#by roooms
by_rooms=
  expedia_US %>%
  select(srch_id, srch_room_count, click_bool, booking_bool) %>%
  group_by(srch_id) %>%
  summarize(rooms = mean(srch_room_count), clicks = sum(click_bool), booking = sum(booking_bool)) %>%
  ungroup() %>%
  group_by(rooms) %>%
  summarize(mean(clicks), mean(booking))

barplot(table(expedia_US$srch_children_count), main = "Number of Children", ylab = "Count")



barplot(table(expedia_US$srch_adults_count), main = "Number of Adults", ylab = "Count")

hist(expedia_US$visitor_hist_starrating,main = "Historical Rating", ylab = "Count", xlab = "")
hist(expedia_US$visitor_hist_adr_usd,main = "Historical ADR", ylab = "Count", xlab = "", xlim = c(0,1000), breaks = 100)

hist(expedia_US$gross_bookings_usd,main = "Gross Bookings", ylab = "Count", xlab = "", xlim = c(0,1000), breaks = 10000)
hist(expedia_US$srch_booking_window,main = "Search in Days Ahead of Stay", ylab = "Count", xlab = "", xlim = c(0,10), breaks = 700)

table(expedia_US$srch_adults_count, expedia_US$srch_children_count)

#by search ID
by_srch_id =
  as.data.frame(
    expedia_US %>%
      select(srch_id, booking_bool) %>%
      group_by(srch_id) %>%
      summarize(count = n(), booking = sum(booking_bool)) %>%
      arrange(desc(count))
  )
barplot(table(by_srch_id$booking), main = "Booked Or Not?", ylab = "Count")

#by number of times searched
by_search_number =
  as.data.frame(
    expedia_US %>%
      select(srch_id, booking_bool, click_bool) %>%
      group_by(srch_id) %>%
      summarize(count = n(), booking = sum(booking_bool), clicks = sum(click_bool)) %>%
      ungroup() %>%
      group_by(count) %>%
      summarize(amount = n(), avg_booking = mean(booking), avg_clicks = mean(clicks)) %>%
      arrange(desc(count))
  )

ggplot(by_search_number, mapping = aes(count)) + 
  geom_line(aes(y = avg_booking, colour = "Avg. Booking")) +
  geom_line(aes(y = avg_clicks, colour = "Avg. Click")) +
  xlim(6,35)

  geom_line(stat = "Identity") +
  labs(title= "Booking Rate by Number of Searches", x="Search Count", y="Booking Rate")
ggplot(by_search_number, mapping = aes(count, amount)) + geom_bar(stat = "Identity") + labs(title= "Number of Searches Results Returned To User", x="Search Results Returned", y="Count")

#by number of clicks
by_clicks =
  as.data.frame(
    expedia_US %>%
      select(srch_id, click_bool, booking_bool) %>%
      group_by(srch_id) %>%
      summarize(clicks = sum(click_bool), booking = sum(booking_bool)) %>%
      ungroup() %>%
      group_by(clicks) %>%
      summarize(amount = n(), avg_booking = mean(booking)) %>%
      arrange(desc(clicks))
  )
ggplot(by_clicks, mapping = aes(clicks, avg_booking)) + geom_bar(stat = "Identity") + scale_x_continuous(breaks = seq(0,10), limits = c(0,10)) + labs(title="Booking Rate by Number of Results Clicked", x="Clicks", y="Average Booking Rate")
ggplot(by_clicks, mapping = aes(clicks, amount)) + geom_bar(stat = "Identity") + scale_x_continuous(breaks = seq(0,10), limits = c(0,10)) + labs(title="Number of Results Clicked by Search ID", x="Clicks on Search Results", y="Search ID")

# clicks per booking
clicks_num =
  as.data.frame(
    expedia_US %>%
      select(srch_id, click_bool, booking_bool) %>%
      group_by(srch_id) %>%
      summarize(clicks = sum(click_bool), booking = sum(booking_bool)) %>%
      ungroup() %>%
      group_by(clicks) %>%
      filter(booking >= 1) %>%
      summarize(amount = n())
  )

#booking rate by search window
booking_rate_by_srch_window =
  expedia_US %>%
  select(srch_id, booking_bool, srch_booking_window) %>%
  group_by(srch_booking_window) %>%
  summarize(count = n(), avg_booking_rate = mean(booking_bool)) %>%
  arrange(desc(count))

ggplot(booking_rate_by_srch_window, mapping = aes(srch_booking_window, avg_booking_rate)) + geom_line()

#amount of children by search window
# booking_rate_by_srch_window =
#   expedia_US %>%
#   select(srch_id, booking_bool, srch_booking_window) %>%
#   group_by(srch_booking_window) %>%
#   summarize(count = n(), avg_booking_rate = mean(booking_bool)) %>%
#   arrange(desc(count))

# by historical ADR visitor_hist_starrating visitor_hist_adr_usd
by_hist =
  as.data.frame(
    expedia_US %>%
      select(srch_id, booking_bool, visitor_hist_starrating, prop_starrating, visitor_hist_adr_usd, price_usd) %>%
      group_by(srch_id) %>%
      filter(booking_bool == 1)
  )
ggplot(by_hist, mapping = aes(visitor_hist_starrating, prop_starrating)) + geom_point() + labs(title="Ratings of Historical and Current Booking", x="Visitor's Historical Booking Star Rating", y="Star Rating of Property Booked")
?boxplot(expedia_US$visitor_hist_starrating, expedia_US$prop_starrating)  

ggplot(by_hist, mapping = aes(visitor_hist_adr_usd, price_usd)) + geom_point(alpha=0.3) + ylim(0,2000) + labs(title="Price (ADR) of Historical and Current Booking", x="Visitor's Historical ADR", y="ADR of Property Booked")
ggplot(by_hist, mapping = aes(visitor_hist_adr_usd, price_usd)) + stat_binhex() + ylim(0,2000) + labs(title="Price (ADR) of Historical and Current Booking", x="Visitor's Historical ADR", y="ADR of Property Booked")

#promotion flag more likely to click
table(expedia_US$promotion_flag, expedia_US$click_bool)
table(expedia_US$promotion_flag, expedia_US$booking_bool)
table(expedia_US$click_bool, expedia_US$booking_bool)

by_promo =
  as.data.frame(
    expedia_US %>%
      select(srch_id, promotion_flag, click_bool, booking_bool) %>%
      group_by(promotion_flag) %>%
      summarize(click_rate = mean(click_bool), clicks = sum(click_bool), booking_rate = mean(booking_bool), bookings = sum(booking_bool))
  )

ggplot(by_promo, mapping = aes(promotion_flag, click_rate)) + geom_bar(stat = "identity") + ylim(0,.065) + labs(title="Click Rate When Promo Flag", x="Promotion Flag Present", y="Click Rate")
ggplot(by_promo, mapping = aes(promotion_flag, booking_rate)) + geom_bar(stat = "identity") + ylim(0,.065) + labs(title="Booking Rate When Promo Flag", x="Promotion Flag Present", y="Booking Rate")

#more likely to book higher up in search results
barplot(table(expedia_US$position, expedia_US$booking_bool)[,2], main = "Bookings By Position in Search Results")
barplot(table(expedia_US$position, expedia_US$click_bool)[,2], main = "Clicks By Position in Search Results")

#by date
expedia_US[,2] = strptime(expedia_US[,2], "%Y-%m-%d %H:%M:%S")
expedia_US[,2] = as.Date(expedia_US[,2])
#look at the booking, clicking rate by month-date (year not necess?)


########################################
########################################
########################################
########################################

# K-Means Cluster Analysis

names(expedia_US)

kmean_data =
expedia_US %>%
  group_by(srch_id) %>%
  summarize(clicks = sum(click_bool),
            bookings = sum(booking_bool),
            hist_starrating = mean(visitor_hist_starrating, na.rm = T),
            hist_adr_usd = mean(visitor_hist_adr_usd, na.rm = T),
            srch_length_of_stay = mean(srch_length_of_stay),
            srch_booking_window = mean(srch_booking_window),
            srch_adults_count = mean(srch_adults_count),
            srch_children_count = mean(srch_children_count),       
            srch_room_count = mean(srch_room_count), 
            srch_saturday_night_bool = mean(srch_saturday_night_bool),
            prop_starrating = prop_starrating[which.max(booking_bool)], #chosen randomly when all booking_bool==0
            hotel_price = price_usd[which.max(booking_bool)],
            gross_bookings_usd = gross_bookings_usd[which.max(booking_bool)]  
            #hotel_price = price_usd[which(booking_bool == 1)])
  )

str(kmean_data)

# feature engineering ===================
#srch_length_of_stay
table(kmean_data$srch_length_of_stay)
plot(log(head(table(kmean_data$srch_length_of_stay),20)))
#changing into 1,2,3-5,6+
kmean_data =
  mutate(ifelse())

#booking_window
table(kmean_data$srch_booking_window)
plot((head(table(kmean_data$srch_booking_window),100)))
#changing into 0-1, 2-6,7-13,14-30,30+ (easier just 0-1, 2-6,7+)

#adults
table(kmean_data$srch_adults_count)
plot(table(kmean_data$srch_adults_count))
#changing into 1,2,3+ (although 4 has more than 3 and 6 has more than 5, pairs)

#children
table(kmean_data$srch_children_count)
plot(table(kmean_data$srch_children_count))
#changing into 0,1-2,3+ (should really do 0,1+ to capture the very diff behavior between those 2 groups)

#roomcount
table(kmean_data$srch_room_count)
plot(table(kmean_data$srch_room_count))
#link to the adults?
table(kmean_data$srch_room_count, kmean_data$srch_adults_count)

#Sat
table(kmean_data$srch_saturday_night_bool)

#stars
table(kmean_data$prop_starrating)
plot(table(kmean_data$prop_starrating))
#need to impute the 0 value!
#1,2,3,4,5

#price
hist(table(kmean_data$hotel_price), xlim = c(0,100), breaks = 1000)
hist(table(expedia_US$price_usd), xlim = c(0,100), breaks = 100000)
#not using since doesn't make sense - log?

#bookings
hist(kmean_data$gross_bookings_usd, xlim = c(0,500), breaks = 10000)
#change to just website 5 to make sure not per night / whole trip

#1 srch_id
#2 clicks
#3 bookings
#4 hist_starrating 
#5 hist_adr_usd
#6 srch_length_of_stay 
#7 srch_booking_window 
#8 srch_adults_count 
#9 srch_children_count     
#10 srch_room_count 
#11 srch_saturday_night_bool 
#12 prop_starrating 
#13 hotel_price
#14 gross_bookings_usd

kmean_data_scaled = kmean_data[,c(2,3, 6:12,14)]

names(kmean_data_scaled)
# [1] "clicks"                   "bookings"                 "srch_length_of_stay"      "srch_booking_window"     
# [5] "srch_adults_count"        "srch_children_count"      "srch_room_count"          "srch_saturday_night_bool"
# [9] "prop_starrating"     

# length_of_stay_scaled
kmean_data_scaled =
  as.data.frame(
    kmean_data_scaled %>%
      mutate(
        length_of_stay_scaled = ifelse(srch_length_of_stay == 1, 1,
                        ifelse(srch_length_of_stay == 2, 2,
                               ifelse((srch_length_of_stay > 2 & srch_length_of_stay < 6), 3, 4)))))


kmean_data_scaled %>%
  group_by(length_of_stay_scaled) %>%
  summarize(mean(bookings))
plot(expedia_US %>%
  group_by(srch_length_of_stay) %>%
  summarize(mean(booking_bool)))
plot(expedia_US %>%
       group_by(srch_length_of_stay) %>%
       summarize(mean(click_bool)))
plot(expedia_US %>%
       group_by(len=srch_length_of_stay) %>%
       summarize(avg=mean(gross_bookings_usd, na.rm =T)) %>%
       mutate(gross_per_night = avg/len) %>%
       select(-avg))

#adults scaled
kmean_data_scaled =
  as.data.frame(
    kmean_data_scaled %>%
      mutate(
        srch_adults_count_scaled = ifelse(srch_adults_count == 1, 1,
                                          ifelse(srch_adults_count == 2, 2, 
                                                 ifelse(srch_adults_count == 3, 3, 4))))) #maybe include 4 with 3
kmean_data_scaled %>%
  group_by(srch_adults_count_scaled) %>%
  summarize(mean(bookings))
kmean_data_scaled %>%
  group_by(srch_adults_count_scaled) %>%
  summarize(mean(clicks))
plot(kmean_data %>%
       group_by(srch_adults_count) %>%
       summarize(mean(bookings)))     #weird! even numbers lower booking rates!
plot(kmean_data %>%
       group_by(srch_adults_count) %>%
       summarize(mean(clicks)))       #weird! even numbers lower clicking rates! pretty consistent
plot(kmean_data %>%
       group_by(ad=srch_adults_count) %>%
       summarize(avg=mean(gross_bookings_usd, na.rm =T), rooms = mean(srch_room_count)) %>%
       mutate(gross_per_night = avg/rooms) %>%
       select(-avg))


# booking_window_scaled
kmean_data_scaled =
  as.data.frame(
    kmean_data_scaled %>%
      mutate(
        booking_window_scaled = ifelse(srch_booking_window == 0, 0,
                                       ifelse(srch_booking_window == 1, 1,
                                              ifelse((srch_booking_window > 1 & srch_booking_window < 14), 2, 3)
                                                    ))))
#number of observations in each original window
table(kmean_data$srch_booking_window)
plot((head(table(kmean_data$srch_booking_window),100)))
#changing into 0-1, 2-6,7-13,14-30,30+ (easier just 0-1, 2-6,7+)

#new window stats for clicks/bookings
plot(kmean_data_scaled %>%
  group_by(booking_window_scaled) %>%
  summarize(mean(bookings)), main="Avg Booking Rate By Booking Window")
plot(kmean_data_scaled %>%
  group_by(booking_window_scaled) %>%
  summarize(mean(clicks)), main="Avg Click Rate By Booking Window")
plot(kmean_data_scaled %>%
       group_by(booking_window_scaled) %>%
       summarize(avg=mean(gross_bookings_usd, na.rm =T)))


# children_scaled
kmean_data_scaled =
  as.data.frame(
    kmean_data_scaled %>%
      mutate(
        srch_children_count_scaled = ifelse(srch_children_count == 0, 0,
                                            ifelse(srch_children_count == 1, 1,
                                            ifelse(srch_children_count == 2, 2,
                                            ifelse(srch_children_count == 3, 3, 4))))))

#number of children in original df
table(kmean_data$srch_children_count)
plot(table(kmean_data$srch_children_count))
#changing into 0,1-2,3+ (should really do 0,1+ to capture the very diff behavior between those 2 groups)

#new window stats for clicks/bookings
plot(kmean_data_scaled %>%
       group_by(srch_children_count_scaled) %>%
       summarize(mean(bookings)), main="Avg Booking Rate By Booking Window")
plot(kmean_data_scaled %>%
       group_by(srch_children_count_scaled) %>%
       summarize(mean(clicks)), main="Avg Click Rate By Booking Window")
plot(kmean_data_scaled %>%
       group_by(srch_children_count_scaled) %>%
       summarize(avg=mean(gross_bookings_usd, na.rm =T)/mean(srch_room_count)))

# room count scaled
kmean_data_scaled =
  as.data.frame(
    kmean_data_scaled %>%
      mutate(
        srch_room_count_scaled = ifelse(srch_room_count == 1, 1,
                                            ifelse(srch_room_count == 2, 2,
                                                   ifelse(srch_room_count == 3, 3, 4)))))
#roomcount count in original df
table(kmean_data$srch_room_count)
plot(table(kmean_data$srch_room_count))
#link to the adults?
table(kmean_data$srch_room_count, kmean_data$srch_adults_count)

#new window stats for clicks/bookings
plot(kmean_data_scaled %>%
       group_by(srch_room_count_scaled) %>%
       summarize(mean(bookings)), main="Avg Booking Rate By Room Count")
plot(kmean_data_scaled %>%
       group_by(srch_room_count_scaled) %>%
       summarize(mean(clicks)), main="Avg Click Rate By Room Count")


# prop_starrating
plot(kmean_data_scaled %>%
       group_by(prop_starrating) %>%
       summarize(mean(bookings)), main="Avg Booking Rate By Star Rating")
plot(kmean_data_scaled %>%
       group_by(prop_starrating) %>%
       summarize(mean(clicks)), main="Avg Click Rate By Star Rating")

#stars in original df
table(kmean_data$prop_starrating)
plot(table(kmean_data$prop_starrating))


# srch_saturday_night_bool scaled
kmean_data_scaled =
  as.data.frame(
    kmean_data_scaled %>%
      mutate(
        srch_saturday_night_bool_scaled = ifelse(srch_saturday_night_bool == 0, 0, 2)))

#stars in original df
table(kmean_data$srch_saturday_night_bool)
plot(table(kmean_data$srch_saturday_night_bool))

#new window stats for clicks/bookings
plot(kmean_data_scaled %>%
       group_by(srch_saturday_night_bool_scaled) %>%
       summarize(mean(bookings)), main="Avg Booking Rate By Room Count")
plot(kmean_data_scaled %>%
       group_by(srch_saturday_night_bool_scaled) %>%
       summarize(mean(clicks)), main="Avg Click Rate By Room Count")
plot(kmean_data_scaled %>%
       group_by(srch_saturday_night_bool_scaled) %>%
       summarize(mean(srch_children_count)), main="Avg Click Rate By Room Count")
plot(kmean_data_scaled %>%
       group_by(srch_saturday_night_bool_scaled) %>%
       summarize(avg=mean(gross_bookings_usd, na.rm =T)/mean(length_of_stay_scaled)))


# change df to only include clustering columns
names(kmean_data_scaled)
kmean_data_scaled[,c(1:10)] <- NULL

# scale the variables
# summary(scale(kmean_data_scaled$length_of_stay_scaled))
# for(i in seq(1,7)){
#   kmean_data_scaled[,i] = scale(kmean_data_scaled[,i])
#   print(paste("Scaling column", i))
#   print(Sys.time())
# }
# str(kmean_data_scaled)
# summary(kmean_data_scaled)
# sapply(kmean_data_scaled, sd)
# plot(
#   kmean_data_scaled$srch_children_count, kmean_data_scaled$srch_length_of_stay
# )


# K-MEANS clustering
set.seed(0)
km.2 = kmeans(kmean_data_scaled, centers = 3)
km.3 = kmeans(kmean_data_scaled, centers = 3)

#business travelers, couples, families
#backpackers
#millenials?/seniors?

wssplot = function(data, nc = 8, seed = 0) {
  wss = (nrow(data) - 1) * sum(apply(data, 2, var))
  for (i in 2:nc) {
    set.seed(seed)
    wss[i] = sum(kmeans(data, centers = i, iter.max = 10, nstart = 10)$withinss)    # iter.max is 
  }
  plot(1:nc, wss, type = "b",
       xlab = "Number of Clusters",
       ylab = "Within-Cluster Variance",
       main = "Scree Plot for the K-Means Procedure\n Expedia Clusters")
}
wssplot(kmean_data_scaled)

#applying the cluster number to original data
kmean_data$three_clustsv1 = km.iris[[1]]
kmean_data$three_clustsv2 = km.2[[1]]
kmean_data$three_clustsv3 = km.3[[1]]

#grouped by cluster
grouped.by.clust3 =  #change for each cluster
  as.data.frame(
    kmean_data %>%
      group_by(three_clustsv3) %>%   #change for each cluster
      summarize(
        book.rate = mean(bookings),
        click.rate = mean(clicks),
        prop_starrating = mean(prop_starrating),
        hotel_price = mean(hotel_price, na.rm = T),
        gross_bookings_usd = mean(gross_bookings_usd, na.rm = T),
        hist_starrating = mean(hist_starrating, na.rm = T),
        hist_adr_usd = mean(hist_adr_usd, na.rm = T),
        srch_adults_count = mean(srch_adults_count),
        srch_children_count = mean(srch_children_count),
        srch_room_count = mean(srch_room_count),
        srch_saturday_night_bool = mean(srch_saturday_night_bool),
        srch_length_of_stay = mean(srch_length_of_stay),
        srch_booking_window = mean(srch_booking_window)
      )
  )
grouped.by.clust3
km.3$size

#exploring a matrix - the further a ratio is from 1, the more important that attribute is for a segment relative to the total population
clust3.ratio.matrix3 =   #change for each cluster
  cbind(
    grouped.by.clust3$book.rate / mean(kmean_data$bookings),
    grouped.by.clust3$click.rate / mean(kmean_data$clicks),
    grouped.by.clust3$prop_starrating / mean(kmean_data$prop_starrating),
    grouped.by.clust3$hotel_price / mean(kmean_data$hotel_price),
    grouped.by.clust3$gross_bookings_usd / mean(kmean_data$gross_bookings_usd, na.rm = T),
    grouped.by.clust3$hist_starrating / mean(kmean_data$hist_starrating, na.rm = T),
    grouped.by.clust3$hist_adr_usd / mean(kmean_data$hist_adr_usd, na.rm = T),
    grouped.by.clust3$srch_adults_count / mean(kmean_data$srch_adults_count),
    grouped.by.clust3$srch_children_count / mean(kmean_data$srch_children_count),
    grouped.by.clust3$srch_room_count / mean(kmean_data$srch_room_count),
    grouped.by.clust3$srch_saturday_night_bool / mean(kmean_data$srch_saturday_night_bool),
    grouped.by.clust3$srch_length_of_stay / mean(kmean_data$srch_length_of_stay),
    grouped.by.clust3$srch_booking_window / mean(kmean_data$srch_booking_window)
  )
colnames(clust3.ratio.matrix3) = colnames(grouped.by.clust3)[-1] #change for each cluster
clust3.ratio.matrix3

# three_clustsv1 book.rate click.rate prop_starrating hotel_price gross_bookings_usd hist_starrating hist_adr_usd
# 1              1 0.7246831   1.093226        2.992638    139.3044           245.4722        3.036728     162.8258
# 2              2 0.7190365   1.088151        3.004447    144.4857           330.1389        2.990668     153.8434
# 3              3 0.7148775   1.094322        3.095530    161.8943           591.5446        2.986112     159.6821
# srch_adults_count srch_children_count srch_room_count srch_saturday_night_bool srch_length_of_stay
# 1          1.904424           0.3665701        1.026004                 1.000000            1.672053
# 2          1.789200           0.3757112        1.040162                 0.000000            2.473204
# 3          4.246980           0.8821194        2.333017                 0.604591            2.065412
# srch_booking_window
# 1            25.76319
# 2            27.55659
# 3            37.29090
# 
# book.rate click.rate prop_starrating hotel_price gross_bookings_usd hist_starrating hist_adr_usd
# [1,] 1.0039748  1.0018316       0.9963971   0.9759832          0.8187545       1.0094126    1.0318994
# [2,] 0.9961520  0.9971812       1.0003291   1.0122837          1.1011540       0.9941023    0.9749744
# [3,] 0.9903901  1.0028358       1.0306549   1.1342505          1.9730533       0.9925879    1.0119768
# srch_adults_count srch_children_count srch_room_count srch_saturday_night_bool srch_length_of_stay
# [1,]         0.9547600           0.9153875       0.9257959                 1.753234           0.8274504
# [2,]         0.8969937           0.9382144       0.9385719                 0.000000           1.2239169
# [3,]         2.1291720           2.2028014       2.1051558                 1.059989           1.0221126
# srch_booking_window
# [1,]            0.948336
# [2,]            1.014350
# [3,]            1.372668

plot(kmean_data %>%
       group_by(round(hist_starrating)) %>%
       summarize(avg=mean(gross_bookings_usd, na.rm =T)/mean(srch_length_of_stay)))
plot(kmean_data %>%
       group_by(round(hist_starrating,0)) %>%
       summarize(avg=mean(bookings)))
plot(kmean_data %>%
       group_by(round(hist_starrating,0)) %>%
       summarize(avg=mean(clicks)))

