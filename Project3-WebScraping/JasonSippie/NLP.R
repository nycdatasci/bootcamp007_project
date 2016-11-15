library(tidytext)
library(tidyr)
library(dplyr)
library(ggplot2)
library(RColorBrewer)




setwd('~/datascience/webscraping/greatschools')

# NLPMunge.R saved these:
# save(com.s, file="commentSentence")
# save(com, file="gsComments")
# save(schoolRec,file = "schoolRec")
# save(dropoutRate,file = "dropoutRate")
# save(SAT,file = "SAT")
# save(post.sec,file = "post.sec")
# save(grad,file = "grad")


fileList= c("commentSentence", "gsComments", "schoolRec", "dropoutRate","SAT","post.sec","grad")
for (f in fileList) {
  load(f)
}

# read in test results from Python TextBlob
testRes.NB = read.table("testResultsComment.csv", 
                      sep=",", 
                      stringsAsFactors = F, 
                      quote="\"", 
                      comment.char="",
                      header=T)


#------------------------------------------------------------------
# TidyText
#------------------------------------------------------------------

# break out words
w <- com.s %>% unnest_tokens(txt,Sentence ) %>% group_by(sNum) %>% mutate(wNum = row_number()) %>% ungroup

# stop words  
myStopWords = c("school","teacher","daughter","principal","child","student","students","kids","schools","staff")
w <- w %>% filter(!txt %in% stop_words$word) %>% filter(!txt %in% myStopWords)


# -------------------------------------------
# Emotion-mapping words
# -------------------------------------------
sentMode = "nrc"

sent <- sentiments %>%
  filter(lexicon == sentMode)

if (sentMode =="AFINN") {
  sent <- sent %>% dplyr::select(word, score) %>% rename(sentiment=score)
} else {
  sent <- sent %>% dplyr::select(word, sentiment)
  }
sent$sentimentS = as.character(sent$sentiment)

# word-level sentiment
ws <- left_join(w, sent, by=c("txt"="word")) %>% inner_join(schoolRec, by="link")

fsent = prop.table(table(ws[c(6,13)]),2) #relative frequencies across sentiments
ffsent = data.frame(fsent)

# plot relative sentiment across user ratings
ggplot(ffsent, aes(x=sentiment, y=Freq, fill=avgStarsR))+
    geom_bar(stat="identity", position="dodge") +
    theme_minimal() + scale_fill_brewer(name="User\nRating", palette = "Blues") +
    labs( x = "Sentiment", y = "Relative Frequency",
        title ="School Sentiments by User Rating") +
  scale_y_continuous(labels = scales::percent) + theme(axis.text=element_text(angle=90, size=14, margin=margin(0,0,0,0)))
  
ggsave("images/emotionByRating.png")

# -------------------------------------------
# Bing pos/negative
# -------------------------------------------
sentMode = "bing"

sent <- sentiments %>% filter(lexicon == sentMode) %>% dplyr::select(word, sentiment)
sent$sentiment <- ifelse(sent$sentiment=="positive",1,-1)

# word-level sentiment
wsBing <- left_join(w, sent, by=c("txt"="word")) %>% 
  inner_join(schoolRec, by="link") 

# roll up to comment level using mean word-level sentiment
wsBingAgg <- wsBing %>% filter(!is.na(avgStarsR)) %>% group_by(link, ComID, avgStarsR) %>% 
   summarize(sentiment=mean(sentiment, na.rm=TRUE)) %>% filter(!is.na(sentiment)) %>% ungroup

wsBingAvg <- wsBingAgg %>% group_by(avgStarsR) %>% summarize(sentiment=mean(sentiment)) %>% ungroup

# means show similar spread over a more narrow distribution

# plot bing sentiment
ggplot(wsBingAgg, aes(x=factor(avgStarsR), y=sentiment)) + geom_boxplot(fill="lightblue") +
  theme_minimal() + 
  labs( x = "User Rating", y = "Sentiment",title ="Comment Bing Sentiments\nby User Rating") +
   theme(axis.text=element_text(size=14, margin=margin(0,0,0,0)))

ggsave("images/bingSentimentByRating.png")


# statistical test

s = split(wsBingAgg, factor(wsBingAgg$avgStarsR))

# most of variance is similar
var.test(s[[2]]$sentiment,
         s[[5]]$sentiment,
         alternative = "two.sided")

# means are not the same
a = aov(sentiment~avgStarsR, wsBingAgg)
summary(a)




# -------------------------------------------
# Naive Bayes
# -------------------------------------------

testRes.NB$X = NULL
testRes.NB$neg = testRes.NB$neg * -1
testRes.NB$avg = (testRes.NB$neg+ testRes.NB$pos)/2


# NB test results
testRes.NB = inner_join(testRes.NB, schoolRec, by="link") %>% filter(!is.na(Stars))

# hits
testRes.NBc <- testRes.NB %>% filter((Stars > 3 & Choice=="pos") | (Stars< 3 & Choice=="neg")) %>%
  mutate(Correct=T)

#misses  
testRes.NBi <- testRes.NB %>% filter((Stars < 3 & Choice=="pos") | (Stars> 3 & Choice=="neg")) %>%
  mutate(Correct=F)

# leaving out 3's for now
testRes.NB = bind_rows(testRes.NBc, testRes.NBi)



table(testRes.NB[,c("Choice","Correct")])
# cross Validation was OK
# 225 negatives
# 527 pos
# 
# Correct
# Choice FALSE TRUE
# neg    27  102
# pos   124  504




# -------------------------------------------
# Gov't School Metrics
# -------------------------------------------


schoolMetrics = left_join(schoolRec, select(post.sec, schoolID,POSTSEC_ENROLLED_PERCENT), by="schoolID") %>% 
    left_join(select(SAT, schoolID, TOTAL), by="schoolID") %>% 
    left_join(select(grad, schoolID, TOTGRD), by="schoolID") %>% 
    left_join(select(dropoutRate, schoolID, TOTDRP), by="schoolID")
colnames(schoolMetrics)<-c("link","Rating","RatingN","avgStars","minStars","maxStars",
                           "avgStarsR","schoolID","schoolName","PctInCollege","SATScore",
                           "GradRate","DropoutRate")
schoolMetrics$SATRel <- percent_rank(schoolMetrics$SATScore)*100
schoolMetrics$SATScore = NULL

sml = gather(schoolMetrics, "Metric","Pct", 10:13) %>% filter(!is.na(Pct)) 

sml <- sml %>% group_by(avgStarsR, Metric) %>% 
  mutate(MetMax=max(Pct), MetMin=min(Pct)) %>% ungroup
# plot by sentiment

ggplot(sml, aes(x=avgStars, y=Pct, color=Metric)) + 
  geom_jitter(fill=NA, shape=21, size=6) + theme_minimal() + geom_smooth() +
  scale_color_brewer(name="Metric", palette = "Dark2", 
                     breaks=c("DropoutRate","GradRate","PctInCollege","SATRel"),
                     labels=c("Dropout Rate","Graduation Rate","% College-bound","SAT Rank")) +
  labs( x = "User Rating", y = "Percent",
        title ="School Metrics by User Rating") +
  theme(axis.text=element_text(size=6, margin=margin(0,0,0,0)))

ggsave("images/govtMetricsVsSentiment.png")

# plot by rating and sentiment

sml = schoolMetrics %>% group_by(RatingN, avgStarsR) %>% 
  summarize(SATRel=mean(SATRel, na.rm=TRUE)) %>% 
  filter(!is.na(SATRel)) %>%  ungroup
ggplot(sml, aes(x=RatingN, fill=SATRel, y=avgStarsR)) + geom_tile() + theme_minimal() +
  labs( x = "Expert Rating", y = "Sentiment",
        title ="SAT Scores by Expert Rating & Sentiment") +
  theme(axis.text=element_text(size=14, margin=margin(0,0,0,0))) +
  scale_fill_gradient(name="SAT Rank")
ggsave("images/SentimentVsExpertVsSAT.png")

# by expert rating
ggplot(sml, aes(x=RatingN, y=Pct, color=Metric)) + geom_jitter(fill=NA, shape=21, size=6) + theme_minimal() + geom_smooth() +
  scale_color_brewer(name="Metric", palette = "Dark2", 
                     breaks=c("DropoutRate","GradRate","PctInCollege","SATRel"),
                     labels=c("Dropout Rate","Graduation Rate","% College-bound","SAT Rank")) +
  labs( x = "Expert Rating", y = "Percent",
        title ="School Metrics by Expert Rating") +
  theme(axis.text=element_text(size=14, margin=margin(0,0,0,0)))

ggsave("images/govtMetricsVsExpert.png")

       

