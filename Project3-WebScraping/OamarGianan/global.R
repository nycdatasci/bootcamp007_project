library(dplyr); library(DT); library(googleVis) 
library(ggplot2); library(dplyr); library(ggthemes)
library(shiny); library(shinydashboard); library(shinythemes)


# load the data
df <- read.csv("forShiny.csv")
df$genres <- as.character(df$genres)
df$C_1 <- as.character(df$C_1)
df$C_2 <- paste(df$C_2," ",sep="")
df$C_3 <- paste(df$C_3,"  ",sep="")
df$C_4 <- paste(df$C_4,"   ",sep="")
artists <- as.data.frame(sort(unique(df$artist)))
names(artists) <- "Artist Name"
