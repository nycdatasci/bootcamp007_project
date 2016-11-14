
##read data
library(dplyr)

airbnb <- read.csv(
  "~/Downloads/listing.csv",
  header = T,
  stringsAsFactors = F,
  na.strings = c("", "NA")
)
tripadvisor <- read.csv(
  "~/Downloads/tripadvisor.csv",
  header = T,
  stringsAsFactors = F,
  na.strings = c("", "NA")
)

##remove NA in dataset
airbnb = airbnb %>% na.omit()
tripadvisor = tripadvisor %>% na.omit()

#################### airbnb data ###############

## preprocess amenitites in airbnb
vec = gsub(',', ' ', gsub('\\]', '', gsub('\\[', '', airbnb$amenities)))
v <- strsplit(vec, '  ')

temp = as.character(seq(1, 51, 1))
# test wether it works or not, temp%in%v[[5]]
# prepare amentities columns (service)
s = NULL
for (i in 1:length(v)) {
  s <- rbind(s, temp %in% v[[i]])
}
s <- data.frame(s)
# find non exist colums
colSums(s)

# create service data frame with rating with price
# rename colnames of s
amenities_name = c(
  "TV",
  "Cable.TV",
  "Internet",
  "Wireless.Internet",
  "Air.conditioning",
  "Wheelchair accessible",
  "Pool",
  "Kitchen",
  "Free.parking.on.premises",
  "10",
  "Smoking.allowed",
  "Pets.allowed",
  "13",
  "Doorman",
  "Gym",
  "Breakfast",
  "17",
  "18",
  "19",
  "20",
  "Elevator.in.building",
  "22",
  "23",
  "24",
  "Hot.tub",
  "26",
  "Indoor.fireplace",
  "Buzzer/wireless.intercom",
  "29",
  "Heating",
  "Family/kid.friendly",
  "Suitable.for.events",
  "Washer",
  "Dryer",
  "35",
  "36",
  "37",
  "38",
  "39",
  "Essentials",
  "Shampoo",
  "42",
  "43",
  "Hangers",
  "Hair.dryer",
  "Iron",
  "Laptop.friendly.workspace",
  "48",
  "49",
  "50",
  "Self.Check-In"
)

colnames(s) <- amenities_name

##remove unselected columns
drops <- c(
  "10",
  "13",
  "17",
  "18",
  "19",
  "20",
  "22",
  "23",
  "24",
  "26",
  "29",
  "35",
  "36",
  "37",
  "38",
  "39",
  "42",
  "43",
  "48",
  "49",
  "50"
)
s <- s[,!(names(s) %in% drops)]

## pre process cancel_policy
# 4 moderate
# 3 flexible
# 5 strict

## reorgainze data frame airbnb
names(airbnb)
drops_bnb <- c("response_time", "amenities", "service_fee")
airbnb <- airbnb[,!(names(airbnb) %in% drops_bnb)]

##combine service with airbnb
test <- cbind(airbnb, s)

airbnb_final <- test

##save final file
write.csv(airbnb_final,"~/Downloads/airbnb_final.csv")

