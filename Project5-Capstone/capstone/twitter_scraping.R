library(twitteR)
library(ROAuth)
library(httr)
library(plyr)
library(stringr)
library(ggplot2)
library(plotly)
library(dplyr)

# Setup setup_twitter_oauth 
consumer_key <- "DurWk9N2HVnneoVQLKuTUTA6R"
consumer_secret <- "DOOv8PiXshqGR7H18T6s5o9AdL5TgtbxoaJWcJDIotgAPV7Gwj"
access_token <- "4903780331-7QV2fbWeEjnfrfBFbD7WYkGNo3VT9nemKSvnTF8"
access_secret <- "YMcziXyCrXTbTQDTEnFwYsbgWZLg76tjhYh3DausjrbSG"

setup_twitter_oauth(consumer_key = consumer_key, consumer_secret = consumer_secret,
                    access_token = access_token, access_secret = access_secret)


# @Adele and @Beyonce summary
user_adele <- getUser(user = 'Adele')
summary_adele <- user_adele$toDataFrame()

user_beyonce <- getUser(user = 'Beyonce')
summary_beyonce <- user_beyonce$toDataFrame()

# @Adele and @Beyonce sample fellowers

adele_followers <- user_adele$getFollowers(n = 20)
beyonce_followers <- user_beyonce$getFollowers(n = 20)

user_adele_followers = sapply(X = adele_followers, FUN = getUser)
user_beyonce_followers = sapply(X = beyonce_followers, FUN = getUser)


screenName_adele_followers = sapply(X = user_adele_followers, FUN = function(user) user$screenName)                     # Screen Name of followers
statuses_count_adele_followers = sapply(X = user_adele_followers, FUN = function(user) user$statusesCount)  # Number of tweets of each users
language_adele_followers = sapply(X = user_adele_followers, FUN = function(user) user$lang)                 # Language of each users
followers_count_adele_followers = sapply(X = user_adele_followers, FUN = function(user) user$followersCount) # Number of followers
followees_count_adele_followers = sapply(X = user_adele_followers, FUN = function(user) user$friendsCount) # Number of followees 

adele_followers_summary = data.frame(name = screenName_adele_followers,
                                     tweets = statuses_count_adele_followers,
                                     language = language_adele_followers,
                                     followers = followers_count_adele_followers,
                                     followees = followees_count_adele_followers)

screenName_beyonce_followers = sapply(X = user_beyonce_followers, FUN = function(user) user$screenName)                     # Screen Name of followers
statuses_count_beyonce_followers = sapply(X = user_beyonce_followers, FUN = function(user) user$statusesCount)  # Number of tweets of each users
language_beyonce_followers = sapply(X = user_beyonce_followers, FUN = function(user) user$lang)                 # Language of each users
followers_count_beyonce_followers = sapply(X= user_beyonce_followers, FUN = function(user) user$followersCount) # Number of followers
followees_count_beyonce_followers = sapply(X= user_beyonce_followers, FUN = function(user) user$friendsCount) # Number of followees

beyonce_followers_summary = data.frame(name = screenName_beyonce_followers,
                                       tweets = statuses_count_beyonce_followers,
                                       language = language_beyonce_followers,
                                       followers = followers_count_beyonce_followers,
                                       followees = followees_count_beyonce_followers)

#sapply(X = user_adele_followers, FUN = function(user) user$location)

unique(x = adele_followers_summary$language)
unique(x = beyonce_followers_summary$language)

lang_adele_followers <- as.data.frame(table(adele_followers_summary$language))
lang_beyonce_followers <- as.data.frame(table(beyonce_followers_summary$language))


# Tweets from @Adele and @Beyonce
tweets_adele <- searchTwitter(searchString = "@Adele", n = 100,
                              lang = 'en', since = '2016-12-06', until = '2016-12-07')
tweets_beyonce <- searchTwitter(searchString = "@Beyonce", n = 100,
                                lang = 'en', since = '2016-12-06', until = '2016-12-07')

pure_tweets_adele <- strip_retweets(tweets = tweets_adele)
pure_tweets_beyonce <- strip_retweets(tweets = tweets_beyonce)

# @Adele and @Beyonce text extraction 
text_adele <- laply(.data = pure_tweets_adele, .fun = function(tweets) tweets$getText())
text_beyonce <- laply(.data = pure_tweets_beyonce, .fun = function(tweets) tweets$getText())

# @Adele and @Beyonce tweets status source 
tweets_status_source_adele <- laply(.data = pure_tweets_adele, .fun = function(tweets) tweets$statusSource)
tweets_status_source_beyonce <- laply(.data = pure_tweets_beyonce, .fun = function(tweets) tweets$statusSource)

source_adele_followers <- as.data.frame(table(tweets_status_source_adele))
source_beyonce_followers <- as.data.frame(table(tweets_status_source_beyonce))