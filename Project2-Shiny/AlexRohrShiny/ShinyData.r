library(dplyr)

means = Reviews %>% group_by(score_phrase) %>% summarize(mean(score))

colnames(means)[2] <- "mean_score"
means

means_sorted = means[order(means$mean_score), ] 

means_sorted
