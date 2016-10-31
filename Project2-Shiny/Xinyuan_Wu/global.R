setwd("C:/Users/Xinyuan Wu/Dropbox/NYC DS Academy/Project 2/Xinyuan_Wu")
library(dplyr); library(DT); library(googleVis) 
library(ggplot2); library(dplyr); library(ggthemes)
library(shiny); library(shinydashboard); library(shinythemes)


# load the data
data <- read.csv("tidy.csv")
levels(data$condition) <- c('New', 'Like new', 'Used')
select_type <- c('Cars' = 'Cars', 'SUV' = 'SUV', 'Trucks' = 'Trucks', 'Van' = 'Van')
select_mpg <- c('City MPG' = 'mpg_city', 'Highway MPG' = 'mpg_hwy',
                'Overall MPG' = 'mpg_mix')
select_manuf <- sort(unique(as.character(data$make)))
select_condition <- levels(data$condition)
select_lux <- levels(data$lux)
select_trans <- levels(data$trans_broad)