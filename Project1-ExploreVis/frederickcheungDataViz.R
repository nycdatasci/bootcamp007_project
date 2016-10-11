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

#Sum categories
#CategoryCount <- data.frame(table(MergedNews$category))

#Top stories
TopStories <- head(unique(MergedNews$clusterid))

#Top 10 publishers
Top10Publishers <- head(MergedNews$publisher, n=10)

#Plot graph category, number of publications
newsplot <- ggplot(data = MergedNews,aes(x=category))
newsplot + geom_bar(aes(fill=category)) #will need to adjust y axis label

#will need to find a way to adjust Timestamp
                                                       