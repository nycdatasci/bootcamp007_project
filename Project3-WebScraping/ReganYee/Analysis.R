library(dplyr)

## Import and read data
setwd("~/Documents/bootcamp007_project/Project3-WebScraping/ReganYee/Wayback/")
reddit = read.csv("wayback.csv")

reddit$snapshot_datetime = as.character(reddit$snapshot_datetime)
reddit$snapshot_date = as.character(reddit$snapshot_date)
reddit$snapshot_time = sapply(reddit$snapshot_datetime, function(x) substring(x,9,14))

reddit %>% filter(titles=='Thanks, Obama.', submitter=='Nameless696')

df = reddit %>% 
  mutate(datehour = sapply(reddit$snapshot_datetime, function(x) substring(x,1,10))) %>% 
  mutate(rank_hour = paste0(datehour,rank)) %>% 
  select(1:10, rank_hour)

## Return a list of top 10 items that are unique per day and hour
df_unique_hour = df[!duplicated(df$rank_hour),]
df_unique_hour = df_unique_hour %>% select(snapshot_date, rank, titles, subreddit, upvotes, comments, submitter, snapshot_time, url, submit_datetime)

## Reindex row indices
rownames(df_unique_hour) = NULL

df_unique_hour = df_unique_hour %>%
  mutate(snapshot_hour = substring(snapshot_time,1,2))

unique_subreddits_per_day = df_unique_hour %>% group_by(snapshot_date, subreddit) %>% summarize(count=n())



######### Broken down by titles per day
df_date_title = reddit %>% 
  mutate(date_title = paste0(snapshot_date,titles)) %>% 
  select(2:10, date_title)

df_unique_title = df_date_title[!duplicated(df_date_title$date_title),]
unique_titles_per_day_r1 = df_unique_title %>% filter(rank==1)

######## Count of front page posts by user
front_page_by_user = reddit %>% select(titles, submitter)

t = unique(front_page_by_user) %>% filter(submitter=='Nameless696')
r = t %>% group_by(submitter) %>% summarize(count=n()) %>% filter(count > 2) %>% arrange(desc(count))
                                   