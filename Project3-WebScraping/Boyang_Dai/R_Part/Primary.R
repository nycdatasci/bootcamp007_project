# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #
#                                                                       #
#    Author:  Boyang 'David' Dai                                        #
#    Time:    Nov. 11th, 2016                                           #
#    Project: Web Scrapying                                             #
#    Topic:   Amazon Product Analysis - Condom                          #
#                                                                       #
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #
#
#
#     # - - - - - - - - # - - - - - - - - #
#     #              Question             #
#     # - - - - - - - - # - - - - - - - - #
#
#   When buying the products online, there are many things that needed
# to be put into concerned: rating of the product, rank of the product in 
# the corresponding categories, reviews from other customers, and so forth.
# Therefore, the question that how are the products ranked on a e-commerce
# website interested me for a long time since there is no universal way to 
# claim whether an item is really good or not, for the judgement of one product
# varied from different customers; thus the ratings/evaluations of a product 
# based on the feedback of customers may have high variance. Many people may 
# take others' reviews as references to evaluate a product, while others 
# purchase a product based on other preferences. 
#
# Given that thousands of the condnom were produced each year, 
# For the condom retailers: 
#         Is there a way to get to the top of the corresponding category for 
#         the condom retailer?
# For the customers:
#         Is there a stable way to evalute th quality of a product without 
#         relying on reviews or their own preferences? 
#
#
#
#     # - - - - - - - - - - - - - - # - - - - - - - - - - - - - - #
#     #       Scraping [Top 100] condom products from Amazon      #
#     # - - - - - - - - - - - - - - # - - - - - - - - - - - - - - #
#
#   In order to get all the data, I used a Python library: 'scrapy'. Below are
# some brief steps.
#     a. Use scrapy in Python to obtain a list of 100 products' unique asin numbers.
#     b. Save the asin numbers into JSON file.
#     c. Input those asin numbers to Amazon to get to the products' pages
#     d. Scrapy the individual product's page and get all data.
#     e. Parse the aggregated data, clean it.
#
#   Many important product's information were considered and scraped from Amazon
# website, such as products' names, brand, sale price, number of preview images, 
# and so forth. 
# 
#   The scrapying process for the top 100 condom products took several hours to 
# finish. I was able to obtain all needed variables.
#
#
#
#
#
#
#
#
#     # - - - - - - - - # - - - - - - - - #
#     #      Introduction to dataset      #
#     # - - - - - - - - # - - - - - - - - #
#
# Source: Data was collected
#
#
#
#
#     # - - - - - - - - # - - - - - - - - #
#     #        Product Rating Score       #
#     # - - - - - - - - # - - - - - - - - #
#
#   Out of those variable, I am especially interested in to know how does the product
# rating score corelatie with other variables. 
# 
# 
#
#
#
#
#
#
# 
#
#
#
#
#
#
# 
#
#
#
#
#
#
# 
#
#     # - - - - - - - - # - - - - - - - - #
#     #                                   #
#     #            Data Analysis          #
#     #                                   #
#     # - - - - - - - - # - - - - - - - - #
#
#
#
setwd("~/Desktop/NYCDSA/Project/scrapy_draft/Amazon_Main_Page/R_Part")
# required pakacges
library(tm)
library(SnowballC)
library(RColorBrewer)
library(ggplot2)
library(wordcloud)
library(biclust)
library(cluster)
library(biclust)
library(igraph)
library(fpc)
library(Rcampdf)
library(dplyr)

# - - - - - - - - # - - - - - - - - #
#      
main <- read.csv('top_100.csv', sep = ',', header = TRUE, stringsAsFactors = FALSE)
reviews <- read.csv('top_100_reviews.csv', sep = ',', header = TRUE, stringsAsFactors = FALSE)
main$X <- NULL
reviews$X <- NULL
main$TOP_CUSTOMER_REVIEW <- NULL
main$TOP_CUSTOMER_REVIEW_STAR <- NULL
main$WEIGHT <- NULL
#
# The asin code for different products
main$URL <- gsub('http://www.amazon.com/dp/', '', main$URL)
#
#
main <- main %>% arrange(RANK_IN_CONDOM)
main$RANK_IN_CONDOM <- c(1:100)
#
# - - - - - - - - - - - - - - #
# --- --- REVIEW DATASET
# General Dataset
STAR_ALL <- reviews %>% select(REVIEW)
# --- 1 - 2.5 STAR
STAR_LOW <- reviews %>% filter(STAR >= 0 & STAR < 2.5) %>% select(REVIEW)
# --- 2.5 - 3.5 STAR
STAR_MID <- reviews %>% filter(STAR >= 2.5 & STAR < 4) %>% select(REVIEW)
# --- 3.5+ STAR
STAR_HIGH <- reviews %>% filter(STAR >= 4 & STAR <= 5) %>% select(REVIEW)
# Output to txt file for text processing
write.table(STAR_ALL, file = '100ReviewStarALL.txt')
write.table(STAR_LOW, file = '100ReviewStarLow.txt')
write.table(STAR_MID, file = '100ReviewStarMid.txt')
write.table(STAR_HIGH, file = '100ReviewStarHigh.txt')
#
#     # - - - - - - - - # - - - - - - - - #
#     #        Product Rating Score       #
#     # - - - - - - - - # - - - - - - - - #
#
#
#
cname <- file.path("~", "Desktop", "NYCDSA/Project/scrapy_draft/Amazon_Main_Page/R_Part")   
cname
dir(cname) #condom_reviews.csv
docs <- Corpus(DirSource(cname))
summary(docs)
ReviewStarHigh100 <- docs['100ReviewStarHigh.txt']
ReviewStarMid100 <- docs['100ReviewStarMid.txt']
ReviewStarLow100 <- docs['100ReviewStarLow.txt']
# - - - - - - - - - START PREPROCESSING

# ---Removing punctuation:
ReviewStarHigh100 <- tm_map(ReviewStarHigh100, removePunctuation)
ReviewStarMid100 <- tm_map(ReviewStarMid100, removePunctuation)
ReviewStarLow100 <- tm_map(ReviewStarLow100, removePunctuation)

# inspect(docs[1]) # Check to see if it worked. 

# ---Removing numbers:
ReviewStarHigh100 <- tm_map(ReviewStarHigh100, removeNumbers)
ReviewStarMid100 <- tm_map(ReviewStarMid100, removeNumbers)
ReviewStarLow100 <- tm_map(ReviewStarLow100, removeNumbers)
# inspect(docs[1]) # You can check a document (in this case the first) to see if it worked.   

# ---Converting to lowercase:
ReviewStarHigh100 <- tm_map(ReviewStarHigh100, tolower)
ReviewStarMid100 <- tm_map(ReviewStarMid100, tolower)
ReviewStarLow100 <- tm_map(ReviewStarLow100, tolower)
# inspect(docs[1])

# ---Removing “stopwords” (common words) that usually have no analytic value.
# For a list of the stopwords, see:   
# length(stopwords("english"))   
# stopwords("english")   
ReviewStarHigh100 <- tm_map(ReviewStarHigh100, removeWords, stopwords("english"))
ReviewStarMid100 <- tm_map(ReviewStarMid100, removeWords, stopwords("english"))
ReviewStarLow100 <- tm_map(ReviewStarLow100, removeWords, stopwords("english"))
# inspect(docs[1]) # Check to see if it worked.   

# ---Removing particular words:
ReviewStarHigh100 <- tm_map(ReviewStarHigh100, removeWords, c("also", "may"))
ReviewStarMid100 <- tm_map(ReviewStarMid100, removeWords, c("also", "may"))
ReviewStarLow100 <- tm_map(ReviewStarLow100, removeWords, c("also", "may"))


# ---Removing common word endings (e.g., “ing”, “es”, “s”):
library(SnowballC)   
ReviewStarHigh100 <- tm_map(ReviewStarHigh100, stemDocument)
ReviewStarMid100 <- tm_map(ReviewStarMid100, stemDocument)
ReviewStarLow100 <- tm_map(ReviewStarLow100, stemDocument)
# ---Stripping unnecesary whitespace from your documents: 
ReviewStarHigh100 <- tm_map(ReviewStarHigh100, stripWhitespace)
ReviewStarMid100 <- tm_map(ReviewStarMid100, stripWhitespace)
ReviewStarLow100 <- tm_map(ReviewStarLow100, stripWhitespace)
# FINISH
ReviewStarHigh100 <- tm_map(ReviewStarHigh100, PlainTextDocument)
ReviewStarMid100 <- tm_map(ReviewStarMid100, PlainTextDocument)
ReviewStarLow100 <- tm_map(ReviewStarLow100, PlainTextDocument)


# - - - - - - - - - - - Stage the Data
# To proceed, create a document term matrix.
dtm_ReviewStarHigh100 <- DocumentTermMatrix(ReviewStarHigh100)
dtm_ReviewStarMid100 <- DocumentTermMatrix(ReviewStarMid100)
dtm_ReviewStarLow100 <- DocumentTermMatrix(ReviewStarLow100)
inspect(dtm_ReviewStarHigh100[1, 1:2]) # view first 1 docs & first 2 terms 
inspect(dtm_ReviewStarMid100[1, 1:2])
inspect(dtm_ReviewStarLow100[1, 1:2])




# - - - - - - - - - - - Explore your data
# Organize terms by their frequency:
freq_ReviewStarHigh100 <- colSums(as.matrix(dtm_ReviewStarHigh100))   
freq_ReviewStarMid100 <- colSums(as.matrix(dtm_ReviewStarMid100))   
freq_ReviewStarLow100 <- colSums(as.matrix(dtm_ReviewStarLow100))   
# length(freq_ReviewStarHigh100)
ord_ReviewStarHigh100 <- order(freq_ReviewStarHigh100)
ord_ReviewStarMid100 <- order(freq_ReviewStarMid100)
ord_ReviewStarLow100 <- order(freq_ReviewStarLow100)

####export the matrix to Excel:   
#m <- as.matrix(dtm_ReviewStarHigh100)     
#write.csv(m, file="dtm_ReviewStarHigh100.csv") 


# - - - - - - - - - - - BONUS
#  Start by removing sparse terms:   
dtms_ReviewStarHigh100 <- removeSparseTerms(dtm_ReviewStarHigh100, 0.20)
dtms_ReviewStarMid100 <- removeSparseTerms(dtm_ReviewStarMid100, 0.20) 
dtms_ReviewStarLow100 <- removeSparseTerms(dtm_ReviewStarLow100, 0.20) 
### This makes a matrix that is 20% empty space, maximum.   
# inspect(dtms_ReviewStarHigh100) 
# --- --- Word Frequency
#freq_ReviewStarHigh100[head(ord_ReviewStarHigh100)]
#freq_ReviewStarHigh100[tail(ord_ReviewStarHigh100)]
#
#
freq_ReviewStarHigh100 <- colSums(as.matrix(dtms_ReviewStarHigh100))
freq_ReviewStarMid100 <- colSums(as.matrix(dtms_ReviewStarMid100))  
freq_ReviewStarLow100 <- colSums(as.matrix(dtms_ReviewStarLow100))  
# 
wf_ReviewStarHigh100 <- data.frame(word = names(freq_ReviewStarHigh100), freq = freq_ReviewStarHigh100)
wf_ReviewStarMid100 <- data.frame(word = names(freq_ReviewStarMid100), freq = freq_ReviewStarMid100)
wf_ReviewStarLow100 <- data.frame(word = names(freq_ReviewStarLow100), freq = freq_ReviewStarLow100)


# - - - - - - - - - - - Plot Word Frequencies
##Plot words that appear at least 30 times.
p_ReviewStarHigh100 <- ggplot(subset(wf_ReviewStarHigh100, freq > 100), aes(word, freq)) + 
  geom_bar(stat="identity") + 
  theme(axis.text.x=element_text(angle=45, hjust=1)) 
p_ReviewStarMid100 <- ggplot(subset(wf_ReviewStarMid100, freq > 10), aes(word, freq)) + 
  geom_bar(stat="identity") + 
  theme(axis.text.x=element_text(angle=45, hjust=1)) 
p_ReviewStarLow100 <- ggplot(subset(wf_ReviewStarLow100, freq > 10), aes(word, freq)) + 
  geom_bar(stat="identity") + 
  theme(axis.text.x=element_text(angle=45, hjust=1))   
p_ReviewStarHigh100 
p_ReviewStarMid100
p_ReviewStarLow100   

# - - - - - - - - - - - Relationships Between Terms
##Term Correlations
#findAssocs(dtm, c("condoms"), corlimit = 0.01) 
# specifying a correlation limit of 0.98  

# - - - - - - - - - - - Word Clouds
set.seed(1128)
wordcloud(names(freq_ReviewStarHigh100), 
          freq, min.freq=40, 
          scale=c(5, .1), 
          colors=brewer.pal(6, "Dark2"))
wordcloud(names(freq_ReviewStarMid100), 
          freq, min.freq=10, 
          scale=c(5, .1), 
          colors=brewer.pal(6, "Dark2"))
wordcloud(names(freq_ReviewStarLow100), 
          freq, min.freq=10, 
          scale=c(5, .1), 
          colors=brewer.pal(6, "Dark2"))
##Plot the 100 most frequently occurring words.
set.seed(1128)   
dark2 <- brewer.pal(6, "Dark2")   
wordcloud(names(freq_ReviewStarHigh100), freq, max.words=100, rot.per=0.2, colors=dark2)   



# - - - - - - - - - - - Clustering by Term Similarity
# To do this well, you should always first remove a lot of the uninteresting
# or infrequent words. If you have not done so already, you can remove these
# with the following code.
dtmss_ReviewStarHigh100 <- removeSparseTerms(dtm_ReviewStarHigh100, 0.15) 
# This makes a matrix that is only 15% empty space, maximum. 


inspect(dtmss)
#First calculate distance between words & then cluster them according to similarity.
# - - - - - - - - - - - Hierarchal Clustering
d_ReviewStarHigh100 <- dist(t(dtmss_ReviewStarHigh100), method="euclidian")   
fit <- hclust(d = d_ReviewStarHigh100, method = "ward.D")   
fit
plot(fit, hang = -1)
# --- Helping to Read a Dendrogram
#If you find dendrograms difficult to read, then there is still hope.
# To get a better idea of where the groups are in the dendrogram, 
# you can also ask R to help identify the clusters. 
# Here, I have arbitrarily chosen to look at five clusters, 
# as indicated by the red boxes. If you would like to highlight a different 
# number of groups, then feel free to change the code accordingly.
plot.new()
plot(fit, hang=-1)
groups <- cutree(fit, k=8)   # "k=" defines the number of clusters you are using   
rect.hclust(fit, k=8, border="red") # draw dendogram with red borders around the 8 clusters  



# - - - - - - - - - - - - K-means clustering 
# The k-means clustering method will attempt to cluster words into a specified
# number of groups (in this case 2), such that the sum of squared distances 
# between individual words and one of the group centers.
d <- dist(t(dtmss), method="euclidian")   
kfit <- kmeans(d, 2)   
clusplot(as.matrix(d), kfit$cluster, color=T, shade=T, labels=2, lines=0)  





