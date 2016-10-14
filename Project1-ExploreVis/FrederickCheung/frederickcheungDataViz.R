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

#Set each category equal to a variable
BusinessCluster <- MergedNews %>% filter(., category == "business")
EntertainmentCluster <- MergedNews %>% filter(., category == "entertainment")
HealthCluster <- MergedNews %>% filter(., category == "health")
TechnologyCluster <- MergedNews %>% filter(., category == "technology")

#Sort cluster
#Select distinct, n=5
#what are the top 5 stories about?

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
TopStoryBusinessCluster <- MergedNews %>% filter(., clusterid == "d2OyTeAXDFQpb3M9Cr_Ftde6Ig0aM")
TopStoryEntertainmentCluster <- MergedNews %>% filter(., clusterid == "d--MozT4MsoFfIMgKu5_N58OF_f9M")
TopStoryHealthCluster <- MergedNews %>% filter(., clusterid == "dRL3APAAYdKPwuMnih--zAQtflluM")
TopStoryTechnologyCluster <- MergedNews %>% filter(., clusterid == "dubwcJArLL_qAKML5LGPLiunKzNLM")

# return min and max on time stamps for
FirstTopStoryBusinessCluster <- TopStoryBusinessCluster$timestamp %>% max(., na.rm = FALSE)
LastTopStoryBusinessCluster <- TopStoryBusinessCluster$timestamp %>% min(., na.rm = FALSE)
FirstTopStoryEntertainmentCluster <- TopStoryEntertainmentCluster$timestamp %>% max(., na.rm = FALSE)
LastTopStoryEntertainmentCluster <- TopStoryEntertainmentCluster$timestamp %>% max(., na.rm = FALSE)
FirstTopStoryHealthCluster <- TopStoryHealthCluster$timestamp %>% max(., na.rm = FALSE)
LastTopStoryHealthCluster <- TopStoryHealthCluster$timestamp %>% max(., na.rm = FALSE)
FirstTopStoryTechnologyCluster <- TopStoryTechnologyCluster$timestamp %>% max(., na.rm = FALSE)
LastTopStoryTechnologyCluster <- TopStoryTechnologyCluster$timestamp %>% max(., na.rm = FALSE)

#Adjusted Timestamp to readable format
# http://stackoverflow.com/questions/13456241/convert-unix-epoch-to-date-object-in-r
MergedNewsClean$timestamp <- as.POSIXct(MergedNewsClean$timestamp/1000, origin="1970-01-01")



#Plot graph category, number of publications
newsplot <- ggplot(data = MergedNews,aes(x=category))
newsplot + geom_bar(aes(fill=category)) #is it possible to change the category labels directly in ggplot2?

#Sum categories
#CategoryCount <- data.frame(table(MergedNews$category))

#Top clusterid
#TopStories <- head(unique(MergedNews$clusterid))

#Top hdline via clusterid

#Top 10 publishers
# Top10Publishers <- head(MergedNews$publisher, n=10)                                