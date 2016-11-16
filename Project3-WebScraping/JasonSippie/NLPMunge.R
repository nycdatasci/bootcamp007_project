library(tidytext)
library(tidyr)
library(dplyr)



setwd('~/datascience/webscraping/greatschools')
com = read.table("comments.txt", 
                 sep="\t", 
                 stringsAsFactors = F, 
                 quote="", 
                 comment.char="", 
                 col.names= c("link","Comment","PerType","PostDate","Stars"))

gsRating = read.table("ratings.txt", 
                 sep="\t", 
                 stringsAsFactors = F, 
                 quote="", 
                 comment.char="", 
                 col.names= c("link","Rating"))

schoolNames = read.table("greatSchools/schoolLinks.txt", 
                      sep="\t", 
                      stringsAsFactors = F, 
                      quote="", 
                      comment.char="", 
                      col.names= c("schoolID","schoolName","link"))

schoolXRef = read.csv("schoolXRef.csv", stringsAsFactors = F)

dropoutRate = read.csv("dropoutRate.csv", stringsAsFactors = F)
SAT = read.csv("SAT scores.csv", stringsAsFactors = F)
grad = read.csv("graduation.csv", stringsAsFactors = F)
post.sec = read.csv("post sec.csv", stringsAsFactors = F)

testRes.c = read.csv("testResultsComment.csv", stringsAsFactors = T)

# clean up NJEdu data
dropoutRate = cbind(dropoutRate[,1:3], as.data.frame(apply(dropoutRate[,4:14], 2,function(y) as.numeric(gsub("[%-]","",y)))))
dropoutRate = inner_join(dropoutRate, schoolXRef, by = c(DISTRICT_CODE="District.Code", SCHOOL_CODE ='School.Code'))

grad = cbind(grad[,1:3], as.data.frame(apply(grad[,4:14], 2,function(y) as.numeric(gsub("[%-]","",y)))))
grad = inner_join(grad, schoolXRef, by = c(DISTRICT_CODE="District.Code", SCHOOL_CODE ='School.Code')) 

post.sec = cbind(post.sec[,1:4], as.data.frame(apply(post.sec[,5:7], 2,function(y) as.numeric(gsub("[%-]","",y)))))
post.sec = inner_join(post.sec, schoolXRef, by = c(DISTRICT_CODE="District.Code", SCHOOL_CODE ='School.Code'))

SAT = inner_join(SAT, schoolXRef, by = c(DISTRICT_CODE="District.Code", SCHOOL_CODE ='School.Code'))

# comment-level data:
# strip out subfolder so we can treat the school url as a primary key
com$link = sub("reviews/", "", com$link)
# cast to numeric
com$Stars = as.numeric(com$Stars)
com <- com %>% group_by(link) %>% mutate(ComID = row_number()) %>% ungroup
# clean up
com <- com[c("link","ComID","Comment","PerType","PostDate","Stars")]

# school-level data:
# strip out subfolder so we can treat the school url as a primary key
gsRating$link = sub("quality/", "", gsRating$link)
gsRating$RatingN = as.numeric(gsRating$Rating)

# Calculate average star rating
avgStar = com %>% group_by(link) %>% 
  summarize(avgStars = mean(Stars), minStars=min(Stars), maxStars=max(Stars), avgStarsR= round(mean(Stars),0)) %>% ungroup

# school-level data: gsRating, avg reviewer stars, pk
schoolRec = inner_join(gsRating, avgStar, by="link") %>% inner_join(schoolNames, by = "link")

# break out sentences
com.s <- com %>% dplyr::select(link, Comment, ComID) %>% 
  unnest_tokens(Sentence, Comment,token = "sentences") %>% 
  group_by(link, ComID) %>% 
  mutate(sNum = row_number()) %>% 
  ungroup

#save everything
save(com.s, file="commentSentence")
save(com, file="gsComments")
save(schoolRec,file = "schoolRec")
save(dropoutRate,file = "dropoutRate")
save(SAT,file = "SAT")
save(post.sec,file = "post.sec")
save(grad,file = "grad")

# SENTENCES
# sample some sentences and comments for manual tagging
com.train = sample_frac(com, 0.2,replace = F)[,c("link","ComID")]
com.s.train = inner_join(com.s, com.train, by = c("link","ComID"))
write.csv(com.s.train, "com.s.train.csv")


# COMMENTS
# remove NAs
sampPct = 1 # percentage to sample
com.trainAuto = sample_frac(subset(com, !(is.na(Stars))), sampPct,replace = F)

# save whole training file so we know which comments we trained on
write.csv(com.trainAuto, "com.train.csv") 


# save the training data as JSON file for Python
com.trainAuto$label=ifelse(com.trainAuto$Stars < 3, "neg",ifelse(com.trainAuto$Stars >3, "pos", "med"))
j = jsonlite::toJSON(com.trainAuto %>% dplyr::select(Comment, label) %>% rename(text=Comment),pretty=TRUE)
write(j, file="com.train.JSON")


# split off and save testing data
com.test = setdiff(com, com.trainAuto[-7])
j = jsonlite::toJSON(com.test, pretty=T)
write(j, file="com.NAs.test.JSON")


rm(list=ls())

