setwd("D:\\LiYuan\\Data_Science\\NYC DS Academy Bootcamp\\WebScrapProject\\TvShows")
library(dplyr)
library(ggplot2)

merged2 = read.csv("merge2_final.csv", na.string=c("","NA"))


score.sys = read.csv("score_sys.csv")

ggplot(score.sys, aes(x=score.sys, y=score), fill=score.sys) + geom_violin(aes(fill=score.sys)) + theme_bw() +
  xlab("Rating System") + ylab("Score") + 
  ggtitle("TV Show Rating Distribution")

ggplot(score.sys, aes(x=score.sys, y=score), fill=score.sys) + geom_violin(aes(fill=status)) + theme_bw() +
  xlab("Rating System") + ylab("Score") + 
  ggtitle("TV Show Rating Distribution by Show Status")

ggplot(score.sys, aes(x=score, fill=score.sys)) + geom_histogram(position="dodge") + theme_bw() +
  xlab("Score") + ylab("Frequency") + theme()
ggtitle("TV Show Rating Distribution")


scores.df = score.sys
scores.df$score.sys = factor(score.sys$score.sys, labels=c("TVDb", "Rotten Tomato", "IMDb"))


score.model = lm(score~score.sys, data=score.sys)
summary(score.model)
anova(score.model)



library(reshape2)

bygenre = merged2 %>% group_by(., genre) %>% summarise(., imdb_avg=mean(imdb_score), tmt_avg=mean(tmt_score), tv_db_avg = mean(tv_db_score))
bygenre = melt(bygenre, id="genre")

ggplot(bygenre, aes(x=reorder(genre, value, function(x) max(x)), y=value, fill=variable)) + 
  geom_bar(stat="identity", position="dodge") + theme_bw() + theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  xlab("Genre") + ylab("Score") + ggtitle("Rating by Genre")

bystatus = merged2 %>% group_by(., status) %>% summarise(., imdb_avg=mean(imdb_score), tmt_avg=mean(tmt_score), tv_db_avg = mean(tv_db_score)) %>% 
  melt(., id="status") %>% filter(., status!="Planned")

ggplot(bystatus, aes(x=reorder(status, value, function(x) max(x)), y=value, fill=variable)) + geom_bar(stat="identity", position="dodge") + theme_bw() + 
  xlab("Status") + ylab("Score") + ggtitle("Rating by Show Status")

networks = merged2 %>% group_by(., network) %>% summarise(., sum=n())
networks = networks[order(networks$sum, decreasing=T),]
network.top10 = networks[1:10, 1]

bynetwork = merged2 %>% group_by(., network) %>% summarise(., imdb_avg=mean(imdb_score), tmt_avg=mean(tmt_score), tv_db_avg = mean(tv_db_score)) %>% 
  filter(., network %in% network.top10$network) %>% melt(., id="network")
bynetwork[which(bynetwork$network=="American Broadcasting Company"),1] = "ABC"
bynetwork[which(bynetwork$network=="Fox Broadcasting Company"),1] = "Fox"

ggplot(bynetwork, aes(x=reorder(network, value, function(x) max(x)), y=value, fill=variable)) + 
  geom_bar(stat="identity", position="dodge") + theme_bw() + theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  xlab("Network") + ylab("Score") + ggtitle("Rating by Top 10 Network")


library(plotly)
plot_ly(merged2, x=~tv_db_score, y=~tmt_score, z=~imdb_score) %>% 
  layout(scene = list(xaxis = list(title = 'TMDb'),
                      yaxis = list(title = 'Rotten Tomato'),
                      zaxis = list(title = 'IMDb')))

