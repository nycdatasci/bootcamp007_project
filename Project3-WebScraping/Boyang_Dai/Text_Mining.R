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
#     # - - - - - - - - # - - - - - - - - #
#     #                                   #
#     #            Data Analysis          #
#     #                                   #
#     # - - - - - - - - # - - - - - - - - #
#
# Dataset: 2800 obs
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
library(dplyr)
library(plotly)
library(reshape2)
#
#     # - - - - - - - - - #
#     #    Read in Data   #
#     # - - - - - - - - - #
#
main <- read.csv('All.csv', sep = ',', header = TRUE, stringsAsFactors = FALSE)
reviews <- read.csv('All_reviews.csv', sep = ',', header = TRUE, stringsAsFactors = FALSE)
# 
#   Delete unnecessary variables
#
main$X <- NULL
reviews$X <- NULL
#
#   Further tailor variables
#
main$BRAND <- as.factor(main$BRAND)
main$CATEGORY <- as.factor(main$CATEGORY)
main$NumANSWERED_QUESTION[which(is.na(main$NumANSWERED_QUESTION))] <- 0
main$NumCUSTOMER_REVIEW[which(is.na(main$NumCUSTOMER_REVIEW))] <- 0
#
# Impute missingness in som numerical variables
#
main$X1_STAR[which(is.na(main$X1_STAR))] <- 0
main$X2_STAR[which(is.na(main$X2_STAR))] <- 0
main$X3_STAR[which(is.na(main$X3_STAR))] <- 0
main$X4_STAR[which(is.na(main$X4_STAR))] <- 0
main$X5_STAR[which(is.na(main$X5_STAR))] <- 0
main$NumANSWERED_QUESTION[which(is.na(main$NumANSWERED_QUESTION))] <- 0
main$NumCUSTOMER_REVIEW[which(is.na(main$NumCUSTOMER_REVIEW))] <- 0
main$PREVIEW_IMAGE_COUNT[which(main$PREVIEW_IMAGE_COUNT == -2)] <- 0
#
# The asin code for different products
main$URL <- gsub('http://www.amazon.com/dp/', '', main$URL)
#
#
#
#        # - - - - - - - - - - - - - - - - - - #
#        #   Analysis of Univariate Variable   #
#        # - - - - - - - - - - - - - - - - - - #
#    
#     # - - - - - - - - - - - #
#     #    Brand Frequency    #
#     # - - - - - - - - - - - #
#
brand_freq <- as.data.frame(table(main$BRAND))
brand_freq <- brand_freq[which(brand_freq$Var1 != ''),]
ggplot(subset(brand_freq, Freq > 50), aes(x = reorder(Var1, -Freq), y = Freq)) +
  geom_bar(stat = 'identity', fill = 'peachpuff3') +
  labs(x = 'Major Condom Brands', y = 'Number Of Products',
       title = 'Major Brands/Retailers In Condom Market') +
  theme(plot.title = element_text(hjust = 0.5))
#
#
#
#        # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #
#        #             Text mining for individual variable             #
#        # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #
#
#     # - - - - - - #
#     #     NAME    #
#     # - - - - - - #
#
# - - - - - - - Extracting Information from products' names ('NAME') - - - - - - - #
#
#
# ------- a. Extracting number of counts to fillin missingness in 'PACKAGE' variable ------- #
#
name <- main %>% select(NAME)
temp <- name[,1]
temp <- tolower(temp)
for (i in 1:length(temp)){
  temp[i] <- gsub('.*(\\b(?:(\\d+)[-\\s]pack|(?:pack))\\s?(?:of\\s)?(\\d+)).*$', '\\3 pk',temp[i])
  temp[i] <- gsub('.*\\b(?:(\\d+)\\s?(?:condoms)).*$', '\\1',temp[i])
  temp[i] <- gsub('.*\\b(?:(\\d+)\\s?(?:ct)).*$', '\\1',temp[i])
  temp[i] <- gsub('.*\\b(?:(\\d+)\\s?(?:count)).*$', '\\1',temp[i])
  temp[i] <- gsub('.*\\b(?:(\\d+)\\s?(?:pcs)).*$', '\\1',temp[i])
  temp[i] <- gsub('.*\\b(?:(\\d+)\\s?(?:pc)).*$', '\\1',temp[i])
  temp[i] <- gsub('.*\\b(?:(\\d+)\\s?(?:pieces)).*$', '\\1',temp[i])
  temp[i] <- gsub('.*\\b(?:(\\d+)\\s?(?:pack)).*$', '\\1 pk',temp[i])
  temp[i] <- gsub('.*\\b(?:(\\d+)-s?(?:pack)).*$', '\\1 pk',temp[i])
  temp[i] <- gsub('.*\\b(?:(\\d+)-s?(?:pk)).*$', '\\1 pk',temp[i])
  temp[i] <- gsub('.*\\b(?:(\\d+)-s?(?:count)).*$', '\\1',temp[i])
}
temp <- ifelse(nchar(temp) > 10, ";", temp)
#
#     # - - - - - - - - - - - - - - - - - - - - - - - - - - - - #
#     #  Update the package information in the original dataset #
#     # - - - - - - - - - - - - - - - - - - - - - - - - - - - - #
#
main$PACKAGE_temp <- temp
main$PACKAGE_temp[main$PACKAGE_temp == ''] <- NA
main$PACKAGE_temp[main$PACKAGE_temp == ';'] <- NA
main$PACKAGE_temp[which(is.na(main$PACKAGE_temp))] <- main$PACKAGE[which(is.na(main$PACKAGE_temp))]
main$PACKAGE_temp <- ifelse(nchar(main$PACKAGE_temp) > 10, ";", main$PACKAGE_temp)
main$PACKAGE_temp[main$PACKAGE_temp == ''] <- NA
main$PACKAGE_temp[main$PACKAGE_temp == ';'] <- NA
main$PACKAGE_temp <- tolower(main$PACKAGE_temp)
main$PACKAGE_temp <- gsub('pk', '', main$PACKAGE_temp)
main$PACKAGE_temp <- gsub('pack of', '', main$PACKAGE_temp)
main$PACKAGE_temp <- ifelse(nchar(main$PACKAGE_temp) > 4, NA, main$PACKAGE_temp)
main$PACKAGE_temp <- as.numeric(main$PACKAGE_temp)
main$PACKAGE <- main$PACKAGE_temp
main$PACKAGE_temp <- NULL
#
#
#
# ------- b. Get the word frequencies from pruduct names ('NAME') ------- #
#
# Removing particular words:
brand_name <- main[, c('NAME', 'BRAND')]
brand_name$BRAND <- tolower(brand_name$BRAND)
brand_name$BRAND <- ifelse(brand_name$BRAND == 'trojan', 'Trojan',
                           ifelse(brand_name$BRAND == 'lifestyles', 'Lifestyles',
                                  ifelse(brand_name$BRAND == 'durex','Durex', 'Others')))
brand_name <- brand_name[brand_name$NAME != '',]
brand_name <- aggregate(NAME ~ BRAND, data = brand_name, c)
rownames(brand_name) <- brand_name$BRAND
brand_name$NAME <- tolower(brand_name$NAME)
brand_name$NAME <- gsub('ea', '', brand_name$NAME)           # 'gsub' order matters
brand_name$NAME <- gsub('mm', '', brand_name$NAME)
brand_name$NAME <- gsub('condoms', '', brand_name$NAME)
brand_name$NAME <- gsub('condom', '', brand_name$NAME)
brand_name$NAME <- gsub('cts', '', brand_name$NAME)
brand_name$NAME <- gsub('ct', '', brand_name$NAME)
brand_name$NAME <- gsub('-count', '', brand_name$NAME)
brand_name$NAME <- gsub('counts', '', brand_name$NAME)
brand_name$NAME <- gsub('count', '', brand_name$NAME)
brand_name$NAME <- gsub('pcs', '', brand_name$NAME)
brand_name$NAME <- gsub('pc', '', brand_name$NAME)
brand_name$NAME <- gsub('pieces', '', brand_name$NAME)
brand_name$NAME <- gsub('-pack of ', '', brand_name$NAME)
brand_name$NAME <- gsub('-pack', '', brand_name$NAME)
brand_name$NAME <- gsub('pack of ', '', brand_name$NAME)
brand_name$NAME <- gsub('packs', '', brand_name$NAME)
brand_name$NAME <- gsub('pack', '', brand_name$NAME)
brand_name$BRAND <- NULL
brand_name1 <- brand_name
#
write.table(brand_name, file = 'brand_name.txt')
#
#     # - - - - - - - - - - - - - - - - - - - - - - - #
#     #        Reading in the desired text file       #
#     # - - - - - - - - - - - - - - - - - - - - - - - #
#
cname <- file.path("~", "Desktop", "NYCDSA/Project/scrapy_draft/Amazon_Main_Page/R_Part")   
dir(cname)
docs <- Corpus(DirSource(cname))
file_num <- which(rownames(summary(docs)) == 'brand_name.txt')
brand_name <- docs[file_num]
#
#     # - - - - - - - - - - - - - - - - #
#     #       Start preprocessing       #
#     # - - - - - - - - - - - - - - - - #
# a. Removing punctuation:
brand_name <- tm_map(brand_name, removePunctuation)
# b. Removing numbers:
brand_name <- tm_map(brand_name, removeNumbers)
# c. Removing 'stopwords' (common words) that usually have no analytic value.
#     NOTE: For a list of the stopwords, see: 
#                               length(stopwords('english')); stopwords('english')
brand_name <- tm_map(brand_name, removeWords, stopwords("english"))
# d. Removing particular words:
brand_name <- tm_map(brand_name, removeWords, 
                     c('trojan', 'lifestyles', 'durex', 'okamoto',
                       'skyn', 'kimono','magnum','enz'))
# e. Stripping unncessary whitespace from the document:
brand_name <- tm_map(brand_name, stripWhitespace)
# f. Done
brand_name <- tm_map(brand_name, PlainTextDocument)
#
# ------- FINISH ------- #
#
#
#     # - - - - - - - - - - - - - #
#     #       Stage the data      #
#     # - - - - - - - - - - - - - #
#
dtm_brand_name <- DocumentTermMatrix(brand_name)
inspect(dtm_brand_name[1, 1:2]) # view first 1 docs & first 2 terms 
#
#
#     # - - - - - - - - - - - - - #
#     #      Explore the data     #
#     # - - - - - - - - - - - - - #
#
# a. Organize terms by their frequency:
freq_brand_name <- sort(colSums(as.matrix(dtm_brand_name)), decreasing = TRUE)  
# b. Removing sparse terms:
dtms_brand_name <- removeSparseTerms(dtm_brand_name, 0.20) 
#     ** This makes a matrix that is 20% empty space, maximum.
#     NOTE: Definition of sparcity:
#             In the sense of the sparse argument to removeSparseTerms(), 
#             sparsity refers to the threshold of relative document frequency 
#             for a term, above which the term will be removed.
#             (e.g., sparse = 0.01, only terms that appear in (nearly) every
#             document will be retained.)
#
# c. Create data frame for plotting
wf_brand_name <- data.frame(word = names(freq_brand_name), freq = freq_brand_name)
# d. Removing common word endings (e.g., 'ing', 'ed')
wf_brand_name$word <- gsub('ving', 've', wf_brand_name$word)
wf_brand_name$word <- gsub('ved', 've', wf_brand_name$word)
wf_brand_name$word <- gsub('ted', 'te', wf_brand_name$word)
wf_brand_name$word <- gsub('zed', 'ze', wf_brand_name$word)
wf_brand_name$word <- gsub('sed', 'se', wf_brand_name$word)
wf_brand_name$word <- gsub('bbed', 'be', wf_brand_name$word)
wf_brand_name$word <- gsub('ies', 'y', wf_brand_name$word)
wf_brand_name$word <- gsub('ved', 've', wf_brand_name$word)
wf_brand_name$word <- gsub('ced', 'ce', wf_brand_name$word)
wf_brand_name$word <- gsub('ping', '', wf_brand_name$word)
wf_brand_name$word <- gsub('ded', 'de', wf_brand_name$word)
#
#
#     # - - - - - - - - - - - - - #
#     #   Plot word Frequencies   #
#     # - - - - - - - - - - - - - #
#
p_brand_name <- ggplot(subset(wf_brand_name, freq > 50), 
                       aes(x = reorder(word, -freq), y = freq)) + 
  geom_bar(stat="identity") + 
  theme(axis.text.x=element_text(angle=45, hjust=1))  
p_brand_name
#
#
#     # - - - - - - - - - - - #
#     #      Word clouds      #
#     # - - - - - - - - - - - #
#
temp <- DataframeSource(brand_name1)
corp <- Corpus(temp)
corp <- tm_map(corp, removePunctuation)
corp <- tm_map(corp, removeNumbers)
corp <- tm_map(corp, removeWords, stopwords("english"))
corp <- tm_map(corp, removeWords, c('trojan', 'lifestyles', 'durex', 'okamoto', 'skyn', 'kimono','magnum','enz'))
corp <- tm_map(corp, stripWhitespace)
brand_matrix <- TermDocumentMatrix(corp)
brand_matrix <- as.matrix(brand_matrix)
colnames(brand_matrix) <- c('Durex', 'Lifestyles', 'Others', 'Trojan')
#
# a. General wordcloud
comparison.cloud(brand_matrix, max.words = 100,
                 random.order = FALSE,
                 scale = c(2, 0.1), 
                 colors = c('red','green','blue','black'), 
                 main = "Differences Between Condom Brands",
                 title.size = 1)
#
# b. Comparison wordcloud
commonality.cloud(brand_matrix, random.order = FALSE, color = "peachpuff3")
#
#
#
#        # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #
#        #   Extract the desired variables from the original dataset   #
#        # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #
#
#     # - - - - - - - - - - - #
#     #   Numerical Analysis  #
#     # - - - - - - - - - - - #
#
num_main <- main %>% select(contains('STAR'), contains('Num'), SALE_PRICE, PREVIEW_IMAGE_COUNT, RANK_IN_CONDOM, URL)
num_main$TOP_CUSTOMER_REVIEW_STAR <- NULL
num_main$SALE_PRICE[which(num_main$SALE_PRICE == 'None')] <- NA
num_main <- num_main[-which(is.na(num_main$RANK_IN_CONDOM)), ]
num_main <- num_main[-which(is.na(num_main$SALE_PRICE)), ]
num_main <- num_main[-which(is.na(num_main$STAR)), ]
num_main <- num_main %>% arrange(RANK_IN_CONDOM)
num_main$RANK_IN_CONDOM <- c(1:dim(num_main)[1])
#
#
#     # - - - - - - - - - - - - - - #
#     #    Distribution of price    #
#     # - - - - - - - - - - - - - - #
#
price_freq <- as.numeric(num_main$SALE_PRICE)
price_freq <- as.data.frame(price_freq)
ggplot(price_freq, aes(x = price_freq)) +
  geom_histogram(bins = 20, fill = 'red3') +
  labs(x = 'Price of Product', y = '', 
       title = 'Distribution Of Prices Of 881 Condom Products on Amazon') +
  theme(plot.title = element_text(hjust = 0.5)) +
  scale_x_continuous(breaks = seq(0, 300, 30), labels = seq(0, 300, 30))
#
# Over 80% of Amazon Electronics are priced between $0 and $30,  which makes sense as condom 
# products are not usually expensive. However, there’s no statistical correlation between the 
# price of a product and the number of reviews it receives.
#
#
#     # - - - - - - - - - - - - - - - - - - - #
#     #    Distribution of product ratings    #
#     # - - - - - - - - - - - - - - - - - - - #
#
# a. General Distribution
ggplot(num_main, aes(x = STAR)) +
  geom_bar(fill = 'red3') + 
  labs(x = 'Rating of the condom products', y = 'Number of products',
       title = 'Distribution Of Ratings For 2,800 Condom Products On Amazon') +
  theme(plot.title = element_text(hjust = 0.5))
#
# b. Distribution of ratings for 4,249 condom reviews on Amazon
temp <- reviews
temp$LENGTH_OF_REVIEW <- nchar(temp$REVIEW)
temp <- temp[-which(is.na(temp$STAR)), ]
temp$STAR <- as.factor(temp$STAR)
ggplot(temp, aes(x = STAR)) +
  geom_bar(fill = 'green4') + 
  labs(x = 'Review Rating (1 star ~ 5 stars)', y = '',
       title = 'Distribution Of Ratings For 4,249 Condom Reviews On Amazon') +
  theme(plot.title = element_text(hjust = 0.5))
#
# For the overall rating of a particular product, which is the average rating of all reviews 
# for that product, the ratings are no longer limited to discrete numbers between 1 and 5, 
# and can take decimal values between those numbers as well. The distribution of product ratings 
# is similar to the distribution of review ratings.
#
# Again, the perfect rating of 5 is most popular for products. This distribution resembles the 
# distribution of scores of all reviews for the discrete rating values, but this view reveals 
# local maxima at the midpoint between each discrete value. 
# (i.e. 3.5 stars and 4.5 stars are surprisingly common ratings)
#
# c. Product Ratings vs. Product Ranks
temp <- num_main %>% select(RANK_IN_CONDOM, STAR, NumCUSTOMER_REVIEW)
ggplot(subset(temp, NumCUSTOMER_REVIEW > 150), aes(x = RANK_IN_CONDOM, y = STAR)) +
  geom_point(aes(color = NumCUSTOMER_REVIEW, size = NumCUSTOMER_REVIEW), alpha = 0.5) +
  labs(x = 'Product Ranks', y = 'Product Ratings',
       title = 'Product Ratings vs. Product Ranks') + 
  ylim(c(3, 5)) + 
  theme(plot.title = element_text(hjust = 0.5)) +
  scale_color_gradient(low = 'green', high = 'red') +
  geom_smooth(method = "lm", se = FALSE)
#ggplotly()
#
# d. Product price vs. overall rating of reviews written for 2,800 condom products
temp <- num_main %>% select(SALE_PRICE, STAR)
temp$SALE_PRICE <- as.numeric(temp$SALE_PRICE)
ggplot(temp, aes(x = STAR, y = SALE_PRICE)) +
  geom_point(alpha = 0.5, color = 'blue') +
  labs(x = 'Overall Rating Of Product (1 star ~ 5 stars)', y = 'Price Of Products',
       title = 'Product Prices vs. Overall Rating Of Reviews Written For 2,800 Amazon Products') + 
  theme(plot.title = element_text(hjust = 0.5)) +
  scale_y_continuous(breaks = seq(0, 300, 30), labels = paste0('$', seq(0, 300, 30)))
#ggplotly()
#main[main$SALE_PRICE == '284.99', ]
# Observed a distinct outlier with price $284.99.
# https://www.amazon.com/dp/B00OM6Q70U
# Rating: 5 stars
# Number of review: 1; Review rating: 5 stars
# Review: They lit up the entire room after I used them all in one night
# Reason: 1,000 count 
#
# Other Outliers: Not a product of condom, but categorized into condom category.
#
# Inference:
#     The most expensive products have 4-star and 5-star overall ratings, but not 1-star 
#     and 2-star ratings. However, the correlation is very weak. (r = 0.06)
#
#
# e. Avg. Review length of reviews vs. product price for 2,800 products
temp1 <- reviews
temp1$LENGTH_OF_REVIEW <- nchar(temp1$REVIEW)
temp1 <- temp1[-which(is.na(temp1$STAR)), ]
temp1 <- temp1 %>% dplyr::group_by(ID) %>% summarize(avg_review_length = mean(LENGTH_OF_REVIEW))
temp2 <- main %>% select(SALE_PRICE, URL)
temp2$SALE_PRICE <- as.numeric(temp2$SALE_PRICE)
temp2 <- temp2[-which(is.na(temp2$SALE_PRICE)), ]
avg_review_length <- merge(temp1, temp2, by.x = 'ID', by.y = 'URL')
ggplot(avg_review_length, aes(x = SALE_PRICE, y = avg_review_length)) +
  geom_point(color = 'red3', alpha = 0.5) +
  geom_smooth(method = 'lm', formula = y ~ log(x), se = FALSE) +
  labs(x = 'Price of Product', 'Avg. Length Of Reviews (# Characters) For Product',
       title = 'Avg. Review Length Of Reviews vs. Product Price For 2,800 Amazon Products') +
  theme(plot.title = element_text(hjust = 0.5))
#
# In contrast, the relationship between product price and the average length of reviews for 
# the product is interesting.
#
cor.test(x = avg_review_length$SALE_PRICE, y = avg_review_length$avg_review_length)
# This relationship is observed to be logarithmic, though with almost no correlation (r = 0.01), 
# The plot suggests that reviewers put more time and effort into reviewing products which are worth more.
#
#
#     # - - - - - - - - - - - - - - - - - - #
#     #     NumCustomer_Review vs. Ranks    #
#     # - - - - - - - - - - - - - - - - - - #
# NOTE: Using original dataset to retain most information.
temp <- main %>% select(RANK_IN_CONDOM, NumCUSTOMER_REVIEW, STAR, BRAND) %>% arrange(RANK_IN_CONDOM)
temp$RANK_IN_CONDOM <- c(1:dim(temp)[1])
temp$BRAND <- tolower(temp$BRAND)
temp$BRAND <- ifelse(temp$BRAND == 'trojan', 'Trojan',
                     ifelse(temp$BRAND == 'lifestyles', 'Lifestyles',
                            ifelse(temp$BRAND == 'durex','Durex', 'Others')))
temp$STAR <- ifelse(temp$STAR >= 0 & temp$STAR < 3, 'Low',
                    ifelse(temp$STAR >= 3 & temp$STAR < 3.5, 'Medium', 'High'))
temp$STAR <- as.factor(temp$STAR)
temp$BRAND <- as.factor(temp$BRAND)
ggplot(temp, aes(x = RANK_IN_CONDOM, y = NumCUSTOMER_REVIEW)) +
  geom_point(aes(shape = BRAND, color = STAR)) +
  scale_color_manual(values = c("green", "red", 'blue', 'black')) +
  xlim(c(0, 1000)) + ylim(c(0, 100)) + 
  geom_smooth(method = "lm", formula = y ~ splines::bs(x, 3), se = FALSE)
#ggplotly()
#
#
#        # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #
#        #             Sentiment Analysis For Review Dataset           #
#        # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #
#
#     # - - - - - - - - - - - - #
#     #     'REVIEW' DATASET    #
#     # - - - - - - - - - - - - #
#
review_sentiment <- reviews
#
#          # - - - - - - - - - - - - - #
#          #     General level EDA     #
#          # - - - - - - - - - - - - - #
#
#     # - - - - - - - - - - - - #
#     #     Length of review    #
#     # - - - - - - - - - - - - #
#
# Length of review (# of characters)
review_sentiment$LENGTH_OF_REVIEW <- nchar(review_sentiment$REVIEW)
review_sentiment <- review_sentiment[-which(is.na(review_sentiment$STAR)), ]
review_sentiment$RATING_LEVEL <- ifelse(review_sentiment$STAR >= 0 & review_sentiment$STAR < 3, 'Low', 
                               ifelse(review_sentiment$STAR >= 3 & review_sentiment$STAR < 4, 'Mid', 'High'))
review_sentiment$RATING_LEVEL <- as.factor(review_sentiment$RATING_LEVEL)
ggplot(review_sentiment, aes(x = LENGTH_OF_REVIEW)) +
  geom_histogram(binwidth = 100, position = 'dodge', fill = 'orange') +
  scale_x_continuous(breaks = seq(0, 2000, 200), labels = seq(0, 2000, 200)) +
  labs(x = 'Length of review (# of characters)', y = '', 
       title = 'Distribution Of Length On 2,800 Condom Reviews On Amazon') +
  theme(plot.title = element_text(hjust = 0.5))
# Insights:
#       Most reviews are 120-360 characters, but the average amount of characters in review
# is about 410. Assuming that the average amount of characters in a paragraph is 352,
# reviewers typically write about half a paragraph. 
#
# Interestingly, reviews are rarely less than a sentence. 
#
# https://www.amazon.com/gp/help/customer/display.html?nodeId=201929730
# The website suggest a minimum of 20 words in a review, so this discrepancy could be 
# attributed to moderator removal of short, one-liner reviews
#
#
#     # - - - - - - - - - - - - #
#     #      Create Datasets    #
#     # - - - - - - - - - - - - #
#
STAR_ALL <- review_sentiment
STAR_LOW <- review_sentiment %>% dplyr::filter(STAR >= 0 & STAR < 3.5) %>% dplyr::select(REVIEW)   # < 3.5 stars --> Low
STAR_HIGH <- review_sentiment %>% dplyr::filter(STAR >= 3.5 & STAR <= 5) %>% dplyr::select(REVIEW) # > 3.5 stars --> High
#
#     # - - - - - - - - # - - - - - - - - - - - #
#     # Prepare the text for sentiment analysis #
#     # - - - - - - - - # - - - - - - - - - - - #
#
STAR_LOW$Observed_Label <- 'negative'
STAR_HIGH$Observed_Label <- 'positive'
#
#  # - - - - - - - - - - #
#  #    Remove numbers   #
#  # - - - - - - - - - - #
#
STAR_ALL$REVIEW <- gsub("[[:digit:]]", "", STAR_ALL$REVIEW)
STAR_LOW$REVIEW <- gsub("[[:digit:]]", "", STAR_LOW$REVIEW)
STAR_HIGH$REVIEW <- gsub("[[:digit:]]", "", STAR_HIGH$REVIEW)
#
#  # - - - - - - - - - - #
#  #  Remove punctuation #
#  # - - - - - - - - - - #
#
STAR_ALL$REVIEW <- gsub("[[:punct:]]", " ", STAR_ALL$REVIEW)
STAR_LOW$REVIEW <- gsub("[[:punct:]]", " ", STAR_LOW$REVIEW)
STAR_HIGH$REVIEW <- gsub("[[:punct:]]", " ", STAR_HIGH$REVIEW)
#
#  # - - - - - - - - - - - - - - - - #
#  #    Remove unnecessary spaces    #
#  # - - - - - - - - - - - - - - - - #
#
STAR_ALL$REVIEW <- gsub("[ \t]{2,}", " ", STAR_ALL$REVIEW)
STAR_ALL$REVIEW <- gsub("^\\s+|\\s+$", "", STAR_ALL$REVIEW)
STAR_LOW$REVIEW <- gsub("[ \t]{2,}", " ", STAR_LOW$REVIEW)
STAR_LOW$REVIEW <- gsub("^\\s+|\\s+$", "", STAR_LOW$REVIEW)
STAR_HIGH$REVIEW <- gsub("[ \t]{2,}", "", STAR_HIGH$REVIEW)
STAR_HIGH$REVIEW <- gsub("^\\s+|\\s+$", "", STAR_HIGH$REVIEW)
#
#  # - - - - - - - - - - - #
#  #  Lower case transform #
#  # - - - - - - - - - - - #
#
STAR_ALL$REVIEW <- tolower(STAR_ALL$REVIEW)
STAR_LOW$REVIEW <- tolower(STAR_LOW$REVIEW)
STAR_HIGH$REVIEW <- tolower(STAR_HIGH$REVIEW)
#
#     # - - - - - - - - # - - - - - - - - #
#     #      Perform Sentiment Analysis   #
#     # - - - - - - - - # - - - - - - - - #
#
#  # - - - - - - - - - - - - - #
#  #  Tidy sentiment analysis  #
#  # - - - - - - - - - - - - - #
#
# To analyze in the tidy text framework, we need to use the unnest_tokens function 
# and turn this into one-row-per-term-per-document:
#
library(tidytext)
library(stringr)
review_words <- STAR_ALL %>% 
  unnest_tokens(word, REVIEW) %>%
  filter(!word %in% stop_words$word, str_detect(word, "^[a-z']+$"))
#
# Perform sentiment analysis on each review. 
# We’ll use the AFINN lexicon, which provides a positivity score for each word, 
# from -5 (most negative) to 5 (most positive). This, along with several other 
# lexicons, are stored in the sentiments table that comes with tidytext.
#
AFINN <- sentiments %>% dplyr::filter(lexicon == "AFINN") %>% dplyr::select(word, afinn_score = score)
#
# Our sentiment analysis is just an inner-join operation followed by a summary
#
reviews_sentiment <- review_words %>% inner_join(AFINN, by = 'word') %>%
  dplyr::group_by(ID, STAR) %>%
  summarize(sentiment = mean(afinn_score)) 
#
# We now have an average sentiment alongside the star ratings. If we’re right and
# sentiment analysis can predict a review’s opinion towards a restaurant, we should 
# expect the sentiment score to correlate with the star rating.
#
ggplot(reviews_sentiment, aes(STAR, sentiment, group = STAR)) +
  geom_boxplot() + 
  labs(x = 'Product Rating', y = 'Average sentiment score',
       title = 'Avg. Sentiment vs. Product Ratings') +
  theme(plot.title = element_text(hjust = 0.5))
#
# From the boxplot, it seems that our sentiment scores are certainly correlated with positive ratings.
# But there are prediction errorsome 5-star ratings have a highly negative sentiment score. 
# What happened there?
#
#
#     # - - - - - - - - # - - - - - - - - - - - - - - #
#     #      Which words are positive or negative?    #
#     # - - - - - - - - # - - - - - - - - - - - - - - #
#
#   It seems that this algorithm works at the word level, so if we want to improve our approach we
# should start there. Which words are suggestive of positive reviews, and which are negative?
#
# To examine this, let's create a per-word summary, and see which words tend to appear in positive 
# or negative reviews. This takes more grouping and summarizing:
#
review_words_counted <- review_words %>% 
  count(ID, STAR, word) %>%
  ungroup()
#
word_summaries <- review_words_counted %>%
  group_by(word) %>%
  summarize(condom_id = n_distinct(ID), 
            reviews = n(), uses = sum(n),
            average_stars = mean(STAR)) %>%
            ungroup()  
# We can start by looking only at words that appear in at least 10 reviews.
# This makes sense both because rare words will have a noisier measurement 
# (a few good or bad reviews could shift the balance), and because they are
# less likely to be useful in classifying future reviews or text. 
word_summaries_filtered <- word_summaries %>%
  filter(reviews >= 10)
#
# What were the most positive and negative words?
# Positive:
word_summaries_filtered %>%
  arrange(desc(average_stars))
#
#   A tibble: 943 × 5
#   word condom_id reviews  uses average_stars
#   <chr>     <int>   <int> <int>         <dbl>
#   1        boys        11      11    13      5.000000
#   2  naturalamb        12      12    30      5.000000
#   3      prices        15      15    19      5.000000
#   4    securely        10      10    13      5.000000
#   5     slipped        16      16    21      5.000000
#   6     website        10      10    12      5.000000
#   7     improve        17      17    26      4.941176
#   8        adds        14      14    16      4.928571
#   9    irritate        14      14    20      4.928571
#   10   bareback        13      13    17      4.923077
#
# Negative:
word_summaries_filtered %>%
  arrange(average_stars)
#
#   A tibble: 943 × 5
#   word condom_id reviews  uses average_stars
#   <chr>     <int>   <int> <int>         <dbl>
#   1          worst        21      21    22      1.904762
#   2          waste        27      28    32      2.214286
#   3          trash        17      17    18      2.235294
#   4          threw        11      11    13      2.272727
#   5           paid        14      14    19      2.500000
#   6          batch        16      17    44      2.588235
#   7  disappointing        13      13    14      2.615385
#   8   manufactured         9      10    18      2.700000
#   9          awful        24      25    34      2.800000
#   10       novelty         9      10    14      2.800000
#
# Plot positivity by frequency:
ggplot(word_summaries_filtered, aes(reviews, average_stars)) +
  geom_point() +
  geom_text(aes(label = word), check_overlap = TRUE, vjust = 1, hjust = 0.3) +
  scale_x_log10() +
  geom_hline(yintercept = mean(reviews$STAR, na.rm = TRUE), color = "red", lty = 2) +
  labs("Number Of Reviews", y = "Average stars of reviews with this word",
       title = 'Positive/Negative Word Map') +
  theme(plot.title = element_text(hjust = 0.5))
# Note that some fo the most common ords (e.g."condom") are pretty neutral. There are some connon 
# words that are pretty positive (e.g. "love", "amazing") and others that are pretty negative 
# (e.g."worst", "trash")
#
#     # - - - - - - - - # - - - - - - - - - - - #
#     #      Comparing to Sentiment Analysis    #
#     # - - - - - - - - # - - - - - - - - - - - #
#
# When we perform sentiment anlaysos, we're typically comparing to a pre-existing lexicon, one that
# may have been developed for a particular purpose. That means that on our new dataset (Amazon reviews),
# some words may have different implications.
#
# We can combine and compare the two datasets with inner_join.
words_afinn <- word_summaries_filtered %>%
  inner_join(AFINN)
ggplot(words_afinn, aes(afinn_score, average_stars, group = afinn_score)) +
  geom_boxplot() +
  labs(x = "AFINN score of word", y = "Average stars of reviews with this word",
       title = 'Avg. Sentiment vs. Product Ratings') +
  theme(plot.title = element_text(hjust = 0.5))
#
# Unlike our per-review predictions, the trend seems to be lowered. However, the group having AFINN score
# of -5 caught our attention. Further analysis is needed.
#
# Anyway, we may want to see some fo those details. Which positive/negative words were most successful in
# predicting a positive/negative review, and which broke the trend?
#
ggplot(words_afinn, aes(afinn_score, average_stars, group = afinn_score, size = uses, color = reviews)) +
  geom_point() + geom_jitter() +
  geom_text(aes(label = word), check_overlap = TRUE, vjust = -1, hjust = 0.3) +
  labs("AFINN score of word", y = "Average stars of reviews with this word",
       title = 'Positive/Negative Word Map') +
  theme(plot.title = element_text(hjust = 0.5)) + 
  geom_abline(intercept = 4.08090 , slope = 0.09768, col = 'blue')
#
#
# From this plot, we can see that most profanity has an AFINN score of -5,and that while some words, 
# like "worst", successfully predict a negative review, others, like "hate", are often positive 
# (e.g. Customers usually firstly describe things they hate, and then gave positive review on the 
# product about how better it works in compare to their past experience).
#
# Some of the words that AFINN most underestimated included 'cock':
cock <- STAR_ALL[grep("cock", STAR_ALL$REVIEW), ]$REVIEW
#
# Some of the words that AFINN most overestimated was "excited":
excited <- STAR_ALL[grep("excited", STAR_ALL$REVIEW), ]$REVIEW
grep('too excited', excited)
grep('baby', excited)
# Too excited --> Less duration --> Low product rating
#
# Guess:
# If both negative and positive words were found in same review, classify the whole review as negative.
#
# One other way we could look at misclassification is to add AFINN sentiments
# to our frequency vs average stars plot:
#
tmp1 <- word_summaries_filtered
tmp2 <- AFINN
tmp12 <- merge(x = word_summaries_filtered, y = AFINN)
ggplot(tmp12, aes(reviews, average_stars, color = afinn_score)) +
  geom_point() + geom_jitter() +
  geom_text(aes(label = word), check_overlap = TRUE, vjust = 0.5, hjust = 0.5) +
  scale_x_log10() +
  geom_hline(yintercept = mean(reviews$STAR, na.rm = TRUE), color = "red", lty = 2) +
  xlab("# of reviews") +
  scale_colour_gradient(low = "red", high = 'blue') + 
  ylab("Average Stars")
ggplotly()
#
#
#
#
#
#        # - - - - - - - - - - - - - - - - - - - - - - - #
#        #              Sentiment & Numerical            #
#        # - - - - - - - - - - - - - - - - - - - - - - - #
#
#     # - - - - - - - - - - - - #
#     #      Create dataset     #
#     # - - - - - - - - - - - - #
#
#
sentiment_scores <- reviews_sentiment %>% group_by(ID) %>% 
  summarize(avg_rating = mean(STAR, na.rm = TRUE),
            avg_sentiment = mean(sentiment, na.rm = TRUE))
num_main_sentiment <- merge(num_main, sentiment_scores, by.x = 'URL', by.y = 'ID')
#
#     # - - - - - - - - - - - - - - #
#     #     Correlation Analysis    #
#     # - - - - - - - - - - - - - - #
#
# Heat Map for stars and rank of the product
#
get_upper_tri <- function(cormat){ # Get upper triangle of the correlation matrix
  cormat[lower.tri(cormat)]<- NA
  return(cormat)
}
#
#
heatmap_temp <- num_main_sentiment
heatmap_temp$SALE_PRICE <- NULL
heatmap_temp <- merge(avg_review_length, heatmap_temp, by.x = 'ID', by.y = 'URL')
heatmap_temp$ID <- NULL
heatmap_temp <- heatmap_temp[complete.cases(heatmap_temp), ]
cormat <- round(cor(heatmap_temp),2)
upper_tri <- get_upper_tri(cormat)
melted_cormat <- melt(upper_tri, na.rm = TRUE)
ggplot(data = melted_cormat, aes(Var2, Var1, fill = value))+
  geom_tile(color = "white") +
  scale_fill_gradient2(low = "blue", high = "red", mid = "white", 
                       midpoint = 0, limit = c(-1,1), space = "Lab", 
                       name="Pearson\nCorrelation") +
  theme_minimal() + coord_fixed() + 
  theme(axis.text.x = element_text(angle = 45, vjust = 1, size = 12, hjust = 1)) +
  geom_text(aes(Var2, Var1, label = value), color = "black", size = 4) +
  theme(
    axis.title.x = element_blank(),
    axis.title.y = element_blank())
#
#
#     # - - - - - - - - - - - - - - - - - #
#     #     Multiple Linear Regression    #
#     # - - - - - - - - - - - - - - - - - #
#
library(car)
mlr_data <- heatmap_temp 
# Assume that we are fitting a multiple linear regression on the 'mlr_data' data:
mlr_fit <- lm(STAR ~. - (X1_STAR + X2_STAR + X3_STAR + X4_STAR), data = mlr_data)
#
# a. Accessing Outliers:
car::outlierTest(mlr_fit) # Bonferonni p-value for most extreme obs
car::qqPlot(mlr_fit, main="QQ Plot") #qq plot for studentized resid 
#
# b. Influential Observations:
# added variable plots 
car::av.plots(mlr_fit)
# Influence Plot 
car::influencePlot(mlr_fit,	id.method="identify", main="Influence Plot", sub="Circle size is proportial to Cook's Distance" )
#
# c. Non-normality
# qq plot for studentized resid
car::qqPlot(mlr_fit, main="QQ Plot")
# distribution of studentized residuals
library(MASS)
sresid <- studres(mlr_fit) 
hist(sresid, freq=FALSE, 
     main="Distribution of Studentized Residuals")
xfit<-seq(min(sresid),max(sresid),length=40) 
yfit<-dnorm(xfit) 
lines(xfit, yfit)
#
# d. Variance Constancy
# Evaluate homoscedasticity
# non-constant error variance test
car::ncvTest(mlr_fit)
# plot studentized residuals vs. fitted values 
car::spreadLevelPlot(mlr_fit)
#
# e. Multi-colinearity
car::vif(mlr_fit) # variance inflation factors 
summary(mlr_fit)


