library(dplyr)
library(tidyr)
library(lubridate)


typhoon.data <- read.csv("bst_all.csv", stringsAsFactors = FALSE,
                         colClasses = c(Time="character", IID="factor",
                                        Grade="factor"))

typhoon.data$Landfall <- ifelse(typhoon.data$Landfall =="#", "Here", " ")
summary(typhoon.data)

# because of the way data is coded, first number in the
# DIRLong50R and DIRLong30R indicates direction, followed by radial length
typhoon.data2 <- separate(typhoon.data, DirLong50R, c("Dir50R", "Long50R"),
                         sep= 1, extra = "merge")

typhoon.data2 <- separate(typhoon.data2, DirLong30R, c("Dir30R", "Long30R"),
                         sep= 1, extra = "merge")

typhoon.data2$Long50R[typhoon.data2$Long50R == ""] <- "0"

# separate is via character columns
typhoon.data2[,c("Long50R", "Long30R")] <- as.numeric(c(typhoon.data2$Long50R, typhoon.data2$Long30R))
summary(typhoon.data2)



# do a quick conversion b/c latitude and longitude are in 0.1 deg units
# alternatively, use transform or mutate
typhoon.data2[,c("Latitude", "Longitude")] <- 
  0.1 * typhoon.data2[,c("Latitude", "Longitude")]



# remove Ind column (used as an indicator where data starts
# and ends or format check in ASCII file)
typhoon.data2$Ind <- NULL

# change 0 wind speed to NA
typhoon.data2$MaxWindSpd[typhoon.data2$MaxWindSpd == 0] <- NA


typhoon.header <- read.csv("bst_all_header.csv",
                           colClasses = c(IID = "factor"))
summary(typhoon.header)
# only keep relevant data
typhoon.header2 <- select(typhoon.header, IID, NRow, Name)

typhoon.all <- inner_join(typhoon.header2, typhoon.data2, by = "IID")

# replace number of rows of data with row number
index <- numeric()
nrows <- 0
n <- 1
while(n < nrow(typhoon.all)) {
  nrows <- typhoon.all[n,"NRow"]
  index <- c(index,1:nrows)
  n <- n + nrows
} 
typhoon.all$NRow <- index



# get time intervals

start.time <- summarise(group_by(typhoon.all, IID, Name), min = min(Time))
# extra step because dplyr functions dont like POSClxt values
offset.time <- ymd_h(start.time$min)
names(offset.time) <- start.time$IID
typhoon.all$Time <- ymd_h(typhoon.all$Time)
# neat way to do it if we only had one year
# offset.times <- start.time$min[typhoon.all$IID%%1600]

typhoon.all <- mutate(typhoon.all, TimeElapsed = typhoon.all$Time - offset.time[typhoon.all$IID])
typhoon.all$TimeElapsed <- typhoon.all$TimeElapsed / 3600

# rearrange TimeElapsed column
i <- which(colnames(typhoon.all) == "Time")
typhoon.all <- select(typhoon.all, c(1:i,ncol(typhoon.all),(i+2):(ncol(typhoon.all)-1)))

summary(typhoon.all)


'''
typhoon.all <- transform(typhoon.all, 
                         Time = strptime(typhoon.all$Time,
                                         "%y%m%d%H"))

lines <- readLines("bst2016.txt")
hln <- grep("66666", lines)

header <- read.table(textConnection(lines[hln]))
tester <- read.table("bst2016.txt", fill = TRUE)
entry <- read.table(textConnection(lines[-hln]), fill = TRUE)
names(header) <- c("HIND", "IID", "NROW", "CID", "IID2", "FLD", "DTM", "Name", "REV")
names(entry) <- c("TIME", "IND", "GRADE", "LAT", "LON", "hPa", "WDSPD", "50R", "50RSPD", "30R", "30RSPD") 
entry$CID <- rep(header$CID, header$NROW)
'''