setwd("G:/Dropbox/Dropbox/NYC DS Academy/Project 1")
library(ggplot2); library(dplyr); library(png)
library(grid); library(ggthemes); library(RColorBrewer); library(gridExtra)

# function that converts minutes to seconds
toSeconds <- function(x){
    if (!is.character(x)) stop("x must be a character string of the form H:M:S")
    if (length(x)<=0)return(x)
    
    unlist(
        lapply(x,
               function(i){
                   i <- as.numeric(strsplit(i,':',fixed=TRUE)[[1]])
                   if (length(i) == 3) 
                       i[1]*3600 + i[2]*60 + i[3]
                   else if (length(i) == 2) 
                       i[1]*60 + i[2]
                   else if (length(i) == 1) 
                       i[1]
               }  
        )  
    )  
}

# loading data
raw <- read.csv("shot_logs.csv/shot_logs.csv")
# summary(raw)
# str(raw)
colnames(raw) <- tolower(colnames(raw)) # convert to lower case
raw$pts_type <- factor(raw$pts_type) # convert pts type to factor
raw$player_name <- as.character(raw$player_name) # convert player name to character
raw$closest_defender <- as.character(raw$closest_defender) # convert defender to character
raw$game_clock <- toSeconds(as.character(raw$game_clock)) # convert game clock to seconds

# missing value
sum(is.na(raw)) # number of NA
sapply(raw, function(x) any(is.na(x))) # only SHOT-CLOCK column contains NA
sum(is.na(raw))/dim(raw)[1] # % of NA
sum(is.na(raw$shot_clock)) # verify number of NA
summary(raw[is.na(raw$shot_clock), ]) # found no specific pattern
raw2 <- raw[!is.na(raw$shot_clock), ] # remove NA

# negative touch time
sum(raw2$touch_time < 0)
summary(raw2[raw2$touch_time < 0, ]) # found no specific pattern
sum(raw2$touch_time < 0)/dim(raw2)[1] # % of negative touch time
raw3 <- raw2[raw2$touch_time >= 0, ]

# split the MATCHUP column
raw3.1 <- raw3
raw3.1$matchup <- gsub("vs.", "-", raw3.1$matchup)
raw3.1$matchup <- gsub("@", "-", raw3.1$matchup)
date0 <- sapply(strsplit(raw3.1$matchup, split = " - "), function(x) x[1])
team1 <- sapply(strsplit(raw3.1$matchup, split = " - "), function(x) x[2])
team2 <- sapply(strsplit(raw3.1$matchup, split = " - "), function(x) x[3])
date2 <- as.Date(date0, format = "%B %d, %Y") # convert date to date class
date3 <- strptime(date0, format = "%B %d, %Y") # convert date to POSIlt class
home <- ifelse(grepl("@", as.character(raw3$matchup)), team2, team1)
away <- ifelse(grepl("vs.", as.character(raw3$matchup)), team2, team1)
raw4 <- mutate(raw3.1, date = date2, home_team = home, away_team = away)

# subset the players and format the data
raw5 <- filter(raw4, player_name %in% c("james harden",
                                        "stephen curry",
                                        "lebron james",
                                        "russell westbrook"))
raw5$player_name <- factor(raw5$player_name, levels = c("stephen curry", "james harden",
                                                        "lebron james", "russell westbrook"))
levels(raw5$player_name) <- c("Curry", "Harden", "LBJ", "Westbrook")
raw5$closest_defender <- factor(raw5$closest_defender)
levels(raw5$location) <- c("Away", "Home")
levels(raw5$w) <- c("Lost", "Won")
levels(raw5$pts_type) <- c("2-point", "3-point")

# delete unnecessary features and format the variables
data <- raw5 %>% 
    select(-c(game_id, matchup, closest_defender_player_id, fgm, pts, player_id)) %>% 
        rename(match_result = w) %>% 
            select(c(player_name:away_team, location:close_def_dist))


# load head shot image
img1 <- readPNG("curry.png")
img2 <- readPNG("harden.png")
img3 <- readPNG("james.png")
img4 <- readPNG("westbrook.png")
currylogo <- rasterGrob(img1, interpolate=TRUE)
hardenlogo <- rasterGrob(img2, interpolate=TRUE)
jameslogo <- rasterGrob(img3, interpolate=TRUE)
westbrooklogo <- rasterGrob(img4, interpolate=TRUE)

# add two useful columns
data <- data %>% 
    mutate(result = ifelse(as.character(data$shot_result) == "made", 1, 0 )) %>%
    mutate(match_result2 = ifelse(as.character(data$match_result) == "Won", 1, 0 ))

## functions for exploring hothand hypothesis


find_hot_hand_0 <- function() {
    hothand <- data[0, ]
    for (i in 2:dim(data)[1]) {
        if (data[i, ]$shot_number == data[i-1, ]$shot_number + 1 & data[i-1, ]$result == 0) {
            hothand <- rbind(hothand, data[i, ])
        }
    }
    return(hothand)
}



find_hot_hand_1 <- function() {
    hothand <- data[0, ]
    for (i in 2:dim(data)[1]) {
        if (data[i, ]$shot_number == data[i-1, ]$shot_number + 1 & data[i-1, ]$result == 1) {
            hothand <- rbind(hothand, data[i, ])
        }
    }
    return(hothand)
}



find_hot_hand_2 <- function() {
    hothand <- data[0, ]
    for (i in 3:dim(data)[1]) {
        if (data[i, ]$shot_number == data[i-1, ]$shot_number + 1 &
            data[i, ]$shot_number == data[i-2, ]$shot_number + 2 &
            data[i-1, ]$result == 1 &
            data[i-2, ]$result == 1) {
            hothand <- rbind(hothand, data[i, ])
        }
    }
    return(hothand)
}


find_hot_hand_3 <- function() {
    hothand <- data[0, ]
    for (i in 4:dim(data)[1]) {
        if (data[i, ]$shot_number == data[i-1, ]$shot_number + 1 &
            data[i, ]$shot_number == data[i-2, ]$shot_number + 2 &
            data[i, ]$shot_number == data[i-3, ]$shot_number + 3 &
            data[i-1, ]$result == 1 &
            data[i-2, ]$result == 1 &
            data[i-3, ]$result == 1) {
            hothand <- rbind(hothand, data[i, ])
        }
    }
    return(hothand)
}


find_hot_hand_three0 <- function() {
    three <- data[data$pts_type == "3-point", ]
    hothand <- three[0, ]
    for (i in 2:dim(three)[1]) {
        if (three[i-1, ]$result == 0 &
            three[i-1, ]$date == three[i, ]$date &
            three[i-1, ]$home_team == three[i, ]$home_team &
            three[i-1, ]$away_team == three[i, ]$away_team) {
            hothand <- rbind(hothand, three[i, ])
        }
    }
    return(hothand)
}



find_hot_hand_three1 <- function() {
    three <- data[data$pts_type == "3-point", ]
    hothand <- three[0, ]
    for (i in 2:dim(three)[1]) {
        if (three[i-1, ]$result == 1 &
            three[i-1, ]$date == three[i, ]$date &
            three[i-1, ]$home_team == three[i, ]$home_team &
            three[i-1, ]$away_team == three[i, ]$away_team) {
            hothand <- rbind(hothand, three[i, ])
        }
    }
    return(hothand)
}


find_hot_hand_three2 <- function() {
    three <- data[data$pts_type == "3-point", ]
    hothand <- three[0, ]
    for (i in 3:dim(three)[1]) {
        if (three[i-1, ]$result == 1 &
            three[i-2, ]$result == 1 &
            three[i-1, ]$date == three[i, ]$date &
            three[i-1, ]$home_team == three[i, ]$home_team &
            three[i-1, ]$away_team == three[i, ]$away_team &
            three[i-2, ]$date == three[i, ]$date &
            three[i-2, ]$home_team == three[i, ]$home_team &
            three[i-2, ]$away_team == three[i, ]$away_team ) {
            hothand <- rbind(hothand, three[i, ])
        }
    }
    return(hothand)
}
















