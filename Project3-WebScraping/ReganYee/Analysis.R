library(dplyr)
library(ggplot2)
library(plotly)
library(DT)

## Import and read data
setwd("~/Documents/bootcamp007_project/Project3-WebScraping/ReganYee/Wayback/")
reddit = read.csv("wayback.csv")
#reddit[reddit$snapshot_datetime == '20161109103912',]
reddit$upvotes = as.numeric(as.character(reddit$upvotes))
reddit$upvotes = imputedupvotes = Hmisc::impute(reddit$upvotes, "random")

reddit$snapshot_datetime = as.character(reddit$snapshot_datetime)
reddit$snapshot_date = as.character(reddit$snapshot_date)
reddit$snapshot_time = sapply(reddit$snapshot_datetime, function(x) substring(x,9,14))
reddit$submit_date = sapply(reddit$submit_datetime, function(x) substring(x,1,10))
reddit$submit_hour = sapply(reddit$submit_datetime, function(x) substring(x,12,13))
reddit = reddit %>% filter(snapshot_date != 20160629)

reddit$comments = as.character(reddit$comments)
delimited_list = strsplit(reddit$comments, split = " ")
comms = sapply(delimited_list,function(x) x[1])
reddit$comments = comms
reddit$comments_num = as.numeric(reddit$comments)
#Convert NAs to 0
reddit$comments_num[which(reddit$comments_num %in% NA)] = 0
reddit = reddit %>% mutate(comment_ratio = comments_num/upvotes)


saveRDS(reddit, "reddit.RDS")

## All caps analysis
temp = reddit %>% select(titles)
temp1 = unique(temp) %>% mutate(upper = toupper(temp1$titles))
temp2 = temp1 %>% mutate(eq = titles==upper) %>% group_by(eq) %>% summarize(count=n())

## Unique titles per day
date_analysis = reddit %>% select(titles,snapshot_date)
date_analysis = unique(date_analysis) %>% group_by(snapshot_date) %>% summarize(count=n())


colnames(reddit)
df = reddit %>% 
  mutate(datehour = sapply(reddit$snapshot_datetime, function(x) substring(x,1,10))) %>% 
  mutate(rank_hour = paste0(datehour,rank)) %>% 
  select(1:10, rank_hour, submit_date, submit_hour)

## Return a list of top 10 items that are unique per day and hour
df_unique_hour = df[!duplicated(df$rank_hour),]
df_unique_hour = df_unique_hour %>% select(snapshot_date, rank, titles, subreddit, upvotes, comments, submitter, snapshot_time, url, submit_datetime, submit_date, submit_hour)

## Reindex row indices
rownames(df_unique_hour) = NULL

df_unique_hour = df_unique_hour %>%
  mutate(snapshot_hour = substring(snapshot_time,1,2))

unique_subreddits_per_day = df_unique_hour %>% group_by(snapshot_date, subreddit) %>% summarize(count=n())

## Items per day_hour
head(df_unique_hour)
ipdh = df_unique_hour %>% select(titles, snapshot_date, snapshot_hour)
counts = unique(ipdh) %>% group_by(snapshot_date) %>% summarize(count=n()) %>% filter(count != 240)
counts_2 = unique(ipdh) %>% group_by(snapshot_date,snapshot_hour) %>% 
  filter(snapshot_date %in% counts$snapshot_date)

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
                                   
###
### Hottest Upvote time?
### mean and median reddit score by time (aggregate per day/ per hour)
reddit_score_mean = df_unique_hour %>% 
  select(snapshot_date,upvotes) %>% 
  group_by(snapshot_date) %>% 
  summarize(avg_score_mean = mean(upvotes))

reddit_score_median = df_unique_hour %>% 
  select(snapshot_date,upvotes) %>% 
  group_by(snapshot_date) %>% 
  summarize(avg_score_median = median(upvotes))


plot_ly (
  x = reddit_score_mean$snapshot_date,
  y = reddit_score_mean$avg_score_mean,
  type = 'scatter',
  mode = 'markers')

plot_ly (
  x = reddit_score_median$snapshot_date,
  y = reddit_score_median$avg_score_median,
  type = 'scatter',
  mode = 'markers')

## by hour
reddit_score_by_hour = df_unique_hour %>% 
  group_by(snapshot_hour) %>% summarize(score_mean = mean(upvotes), score_median = median(upvotes))

plot_ly (
  x = reddit_score_by_hour$snapshot_hour,
  y = reddit_score_by_hour$score_mean,
  type = 'scatter',
  mode = 'lines') %>% 
  add_trace(
    x = reddit_score_by_hour$snapshot_hour,
    y = reddit_score_by_hour$score_median,
    type = 'scatter',
    mode = 'lines'
  )

plot_ly (
  x = median_reddit_score_by_hour$snapshot_hour,
  y = median_reddit_score_by_hour$score,
  type = 'scatter',
  mode = 'markers')

##by submit time
mean_reddit_score_by_submit_hour = df_unique_hour %>% 
  group_by(submit_hour) %>% summarize(score = mean(upvotes))

median_reddit_score_by_submit_hour = df_unique_hour %>% 
  group_by(submit_hour) %>% summarize(score = median(upvotes))

p = plot_ly (
  x = mean_reddit_score_by_submit_hour$submit_hour,
  y = mean_reddit_score_by_submit_hour$score,
  type = 'scatter',
  mode = 'markers')

###Submit vs Snapshot!
q = plot_ly (
  x = median_reddit_score_by_submit_hour$submit_hour,
  y = median_reddit_score_by_submit_hour$score,
  type = 'scatter',
  mode = 'markers') 

plot_ly() %>% 
  add_trace(
    x = mean_reddit_score_by_submit_hour$submit_hour,
    y = mean_reddit_score_by_submit_hour$score,
    type = 'scatter',
    mode = 'lines',
    name = 'mean') %>% 
  add_trace(
    x = median_reddit_score_by_submit_hour$submit_hour,
    y = median_reddit_score_by_submit_hour$score,
    type = 'scatter',
    mode = 'lines',
    name = 'median')
    


### word cloud?

### subreddit analysis - what is popular?
test = reddit %>% group_by(subreddit,titles) %>%
  summarize(count=n()) %>% arrange(desc(count))
subreddit_analysis = test %>% 
  select(subreddit) %>% 
  summarize(count=n()) %>% 
  filter(count >=10) %>% 
  arrange(desc(count))

## Reorder to be descending
subreddit_analysis$subreddit = 
  factor(subreddit_analysis$subreddit, levels = unique(subreddit_analysis$subreddit)[order(subreddit_analysis$count, decreasing = TRUE)])

plot_ly (
  x = subreddit_analysis$subreddit,
  y = subreddit_analysis$count,
  type = 'bar',
  mode = 'markers',
  title = 'Posts by Subreddit'
)

### Relationship between number of comments and upvotes?
comment_analysis1 = reddit %>% group_by(titles,subreddit) %>% summarize(max = max(comment_ratio)) %>% arrange(desc(max)) 
head(comment_analysis1)

datatable(head(comment_analysis1),
          extensions = 'FixedColumns',
          options = list(
            dom = 't',
            scrollX = TRUE,
            scrollCollapse = TRUE)) %>% 
  formatStyle('titles', `font-size` = '11px') %>% 
  formatStyle('subreddit', `font-size` = '11px') %>% 
  formatStyle('max', `font-size` = '11px')


maxup = reddit %>% group_by(titles) %>% summarize(submit_hour = round(mean(as.numeric(submit_hour))))
head(maxup,25)
joined_df = left_join(reddit, maxup, by="titles")
head(joined_df)
maxup_1 = maxup %>% group_by(submit_hour) %>% summarize(count = n())
g = ggplot(maxup_1, aes(x = submit_hour, y = count))
g+ geom_point()
lm = joined_df %>% select(titles, submit_hour.x, subreddit, upvotes)
head(lm)

gogo = reddit %>% filter(titles == '\'Anti-Vaxxer\' Mom Changes Mind After Her Three Kids Fall Ill')

g = ggplot(reddit, aes(x=comments_num, y=upvotes))
g + geom_point()

reddit$comments_num
reddit[reddit$comments_num == max(reddit$comments_num),]
reddit[reddit$upvotes == max(reddit$upvotes),]


# Upvotes = Subreddit + submit_time

### boxplot of subreddit
### average life of top10?
### career redditors?