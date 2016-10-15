# This script does the following:
# 1. Read all data
# 2. Do some basic filtering
# 3. Select a sample of the data
# 4. Write sampled data to one file

#This extraction and transformation of my DataViz project

#This is where I obtained my dataset http://archive.ics.uci.edu/ml/datasets/News+Aggregator#
#If you put the data files in the working directory the code should work

#set working directory and load packages
setwd("~/Dropbox/Projects_NYCDSA7/DataViz")
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

saveRDS(MergedNews, file = "MergedNews")                              
