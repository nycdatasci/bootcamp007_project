#This is my DataViz project

#This is where I obtained my dataset http://archive.ics.uci.edu/ml/datasets/News+Aggregator#

#If you put the data files in the working directory the code should work


#set working directory and load packages
setwd("Projects_NYCDSA7/DataViz")
library(dplyr)
library(ggplot2)

##read data
data1 <- read.csv("newsCorpora.csv", header = FALSE, sep = "\t") 
data2 <- read.csv("2pageSessions.csv", header = FALSE, sep = "\t") 

#rename header
colnames(data1) <- c("id", "hdline", "url", "publisher", "category", "clusterid", "hostname", "timestamp")
colnames(data2) <- c("clusterid", "hostname", "category", "url")

#Inner Join based on clusterid
MergedNews <- full_join(data2, data1, by=c("clusterid", "category"))

#MergedNews change category name
MergedNews$category[MergedNews$category == "b" ] <- "business"
MergedNews$category[MergedNews$category == "e" ] <- "entertainment"
MergedNews$category[MergedNews$category == "m" ] <- "health"
MergedNews$category[MergedNews$category == "t" ] <- "technology"

#Create copy of MergedNews to clean
MergedNewsClean <- MergedNews

#Adjusted Timestamp to readable format
# http://stackoverflow.com/questions/13456241/convert-unix-epoch-to-date-object-in-r
MergedNewsClean$timestamp <- as.POSIXct(MergedNewsClean$timestamp/1000, origin="1970-01-01")

#Plot graph category, number of publications
newsplot <- ggplot(data = MergedNewsClean,aes(x=category))
newsplot + geom_bar(aes(fill=category)) #is it possible to change the category labels directly in ggplot2?

#Set each category equal to a variable
#arrange, then return top cluster id 

#Find difftime for max and min of the top story for each category

#Sum categories
#CategoryCount <- data.frame(table(MergedNews$category))

#Top clusterid
TopStories <- head(unique(MergedNews$clusterid))

#Top hdline via clusterid

#Top 10 publishers
Top10Publishers <- head(MergedNews$publisher, n=10)                                