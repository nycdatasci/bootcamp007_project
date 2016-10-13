#This is my DataViz project

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

#Create copy of MergedNews to clean
MergedNewsClean <- MergedNews

#Adjusted Timestamp to readable format
# http://stackoverflow.com/questions/13456241/convert-unix-epoch-to-date-object-in-r
MergedNewsClean$timestamp <- as.POSIXct(MergedNewsClean$timestamp/1000, origin="1970-01-01")

#Plot graph category, number of publications
newsplot <- ggplot(data = MergedNewsClean,aes(x=category))
newsplot + geom_bar(aes(fill=category)) #is it possible to change the category labels directly in ggplot2?

#Set each category equal to a variable
BusinessCluster <- MergedNewsClean %>% filter(., category == "business")
EntertainmentCluster <- MergedNewsClean %>% filter(., category == "entertainment")
HealthCluster <- MergedNewsClean %>% filter(., category == "health")
TechnologyCluster <- MergedNewsClean %>% filter(., category == "technology")

#Find top stories in each category
BusinessDf <- as.data.frame(table(BusinessCluster$clusterid))
TopFrqBusiness <- BusinessDf[which.max(BusinessDf$Freq),]

EntertainmentDf <- as.data.frame(table(EntertainmentCluster$clusterid))
TopFrqEntertainment <- EntertainmentDf[which.max(EntertainmentDf$Freq),]

HealthDf <- as.data.frame(table(HealthCluster$clusterid))
TopFrqHealth <- HealthDf[which.max(HealthDf$Freq),]

TechnologyDf <- as.data.frame(table(TechnologyCluster$clusterid))
TopFrqTechnology <- TechnologyDf[which.max(TechnologyDf$Freq),]

#filter Cluster variables based on Top clusterid
TopStoryBusinessCluster <- MergedNewsClean %>% filter(., clusterid == "d2OyTeAXDFQpb3M9Cr_Ftde6Ig0aM")
TopStoryEntertainmentCluster <- MergedNewsClean %>% filter(., clusterid == "d--MozT4MsoFfIMgKu5_N58OF_f9M")
TopStoryHealthCluster <- MergedNewsClean %>% filter(., clusterid == "dRL3APAAYdKPwuMnih--zAQtflluM")
TopStoryTechnologyCluster <- MergedNewsClean %>% filter(., clusterid == "dubwcJArLL_qAKML5LGPLiunKzNLM")

# return min and max on time stamps for
FirstTopStoryBusinessCluster <- TopStoryBusinessCluster %>% max(., timestamp, na.rm = FALSE)
LastTopStoryBusinessCluster <- TopStoryBusinessCluster %>% min(., timestamp, na.rm = FALSE)
FirstTopStoryEntertainmentCluster <- TopStoryEntertainmentCluster %>% max(., timestamp, na.rm = FALSE)
LastTopStoryEntertainmentCluster <- TopStoryEntertainmentCluster %>% max(., timestamp, na.rm = FALSE)
FirstTopStoryHealthCluster <- TopStoryHealthCluster %>% max(., timestamp, na.rm = FALSE)
LastTopStoryHealthCluster <- TopStoryHealthCluster %>% max(., timestamp, na.rm = FALSE)
FirstTopStoryTechnologyCluster <- TopStoryTechnologyCluster %>% max(., timestamp, na.rm = FALSE)
LastTopStoryTechnologyCluster <- TopStoryTechnologyCluster %>% max(., timestamp, na.rm = FALSE)

#Sum categories
#CategoryCount <- data.frame(table(MergedNews$category))

#Top clusterid
#TopStories <- head(unique(MergedNews$clusterid))

#Top hdline via clusterid

#Top 10 publishers
# Top10Publishers <- head(MergedNews$publisher, n=10)                                