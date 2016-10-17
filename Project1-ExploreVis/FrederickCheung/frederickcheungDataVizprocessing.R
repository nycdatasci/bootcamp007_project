#set working directory and load packages
setwd("~/Dropbox/Projects_NYCDSA7/DataViz")
library(dplyr)
library(ggplot2)
library(NLP)
library(tm)
library(SnowballC)
library(RColorBrewer)
library(wordcloud)

MergedNews <- readRDS("MergedNews")

#Set each category equal to a variable
BusinessCluster <- MergedNews %>% filter(., category == "business")
EntertainmentCluster <- MergedNews %>% filter(., category == "entertainment")
HealthCluster <- MergedNews %>% filter(., category == "health")
TechnologyCluster <- MergedNews %>% filter(., category == "technology")

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

#Plot graph category, number of publications
newsplot <- ggplot(data = MergedNews,aes(x=category))
newsplot + geom_bar(aes(fill=category)) #is it possible to change the category labels directly in ggplot2?

#find Top 5 stories in each cluster
Top5Business <- (count(BusinessCluster, clusterid)) %>% top_n(., 5, n)
Top5Entertainment <- (count(EntertainmentCluster, clusterid)) %>% top_n(., 5, n)
Top5Health <- (count(HealthCluster, clusterid)) %>% top_n(., 5, n)
Top5Technology <- (count(TechnologyCluster, clusterid)) %>% top_n(., 5, n)

#Assign Top 5 cluster id headlines
Top5BusinessHeadlines <- filter(BusinessCluster, clusterid %in% Top5Business$clusterid) %>% select(hdline)
Top5EntertainmentHeadlines <- filter(EntertainmentCluster, clusterid %in% Top5Entertainment$clusterid) %>% select(hdline)
Top5HealthHeadlines <- filter(HealthCluster, clusterid %in% Top5Health$clusterid) %>% select(hdline)
Top5TechnologyHeadlines <- filter(TechnologyCluster, clusterid %in% Top5Technology$clusterid) %>% select(hdline)

#Write headlines to text files
write.table(Top5BusinessHeadlines, paste("Top5BusinessHeadlinesText"), row.names=F, append=F, sep=" ")
write.table(Top5EntertainmentHeadlines, paste("Top5EntertainmentHeadlinesText"), row.names=F, append=F, sep=" ")
write.table(Top5HealthHeadlines, paste("Top5HealthHeadlinesText"), row.names=F, append=F, sep=" ")
write.table(Top5TechnologyHeadlines, paste("Top5TechnologyHeadlinesText"), row.names=F, append=F, sep=" ")

#Word Cloud Business
BusinessText = readLines("Top5BusinessHeadlinesText")
BusinessCorpus <- Corpus(VectorSource(BusinessText))
BusinessCorpus <- tm_map(BusinessCorpus, removePunctuation)
BusinessCorpus <- tm_map(BusinessCorpus, content_transformer(tolower))
BusinessCorpus <- tm_map(BusinessCorpus, removeWords, stopwords("english"))
BusinessCorpus <- tm_map(BusinessCorpus, removeWords, c("breaking","news"))
BusinessCorpus <- tm_map(BusinessCorpus, stripWhitespace)
pal2 <- brewer.pal(8,"Greens")
wordcloud(BusinessCorpus, max.words = 100, random.order = FALSE, colors=pal2)

#Word Cloud for Entertainment
EntertainmentText = readLines("Top5EntertainmentHeadlinesText")
EntertainmentCorpus <- Corpus(VectorSource(EntertainmentText))
EntertainmentCorpus <- tm_map(EntertainmentCorpus, removePunctuation)
EntertainmentCorpus <- tm_map(EntertainmentCorpus, content_transformer(tolower))
EntertainmentCorpus <- tm_map(EntertainmentCorpus, removeWords, stopwords("english"))
EntertainmentCorpus <- tm_map(EntertainmentCorpus, removeWords, c("breaking","news"))
EntertainmentCorpus <- tm_map(EntertainmentCorpus, stripWhitespace)
pal2 <- brewer.pal(8,"Reds")
png("Entertainmentwordcloud.png", width=2560,height=1600)
wordcloud(EntertainmentCorpus, max.words = 100, random.order = FALSE, colors=pal2)

#Word Cloud for Health
HealthText = readLines("Top5HealthHeadlinesText")
HealthCorpus <- Corpus(VectorSource(HealthText))
HealthCorpus <- tm_map(HealthCorpus, removePunctuation)
HealthCorpus <- tm_map(HealthCorpus, content_transformer(tolower))
HealthCorpus <- tm_map(HealthCorpus, removeWords, stopwords("english"))
HealthCorpus <- tm_map(HealthCorpus, removeWords, c("breaking","news"))
HealthCorpus <- tm_map(HealthCorpus, stripWhitespace)
pal2 <- brewer.pal(8,"Blues")
png("Healthwordcloud.png", width=2560,height=1600)
wordcloud(HealthCorpus, max.words = 100, random.order = FALSE, colors=pal2)

#Word Cloud for Technology
TechnologyText = readLines("Top5TechnologyHeadlinesText")
TechnologyCorpus <- Corpus(VectorSource(TechnologyText))
TechnologyCorpus <- tm_map(TechnologyCorpus, removePunctuation)
TechnologyCorpus <- tm_map(TechnologyCorpus, content_transformer(tolower))
TechnologyCorpus <- tm_map(TechnologyCorpus, removeWords, stopwords("english"))
TechnologyCorpus <- tm_map(TechnologyCorpus, removeWords, c("breaking","news"))
TechnologyCorpus <- tm_map(TechnologyCorpus, stripWhitespace)
pal2 <- brewer.pal(8,"Purples")
png("Technologywordcloud.png", width=2560,height=1600)
wordcloud(TechnologyCorpus, max.words = 100, random.order = FALSE, colors=pal2)

#Adjusted Timestamp to readable format
# http://stackoverflow.com/questions/13456241/convert-unix-epoch-to-date-object-in-r
MergedNewsClean <- MergedNews
MergedNewsClean$timestamp <- as.POSIXct(MergedNewsClean$timestamp/1000, origin="1970-01-01")

#Sum categories
#CategoryCount <- data.frame(table(MergedNews$category))

#Top 10 publishers
# Top10Publishers <- head(MergedNews$publisher, n=10)  