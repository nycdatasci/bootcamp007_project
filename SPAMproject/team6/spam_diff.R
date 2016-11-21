library(kernlab)
library(dplyr)

data(spam)
spam_features = spam %>% select (-type)
spam_mean = sapply(spam_features, mean)

spam_mean_bytype = spam %>% group_by(type) %>% summarise_each(funs(mean))

spam_mean_bytype = as.data.frame(spam_mean_bytype)
difference = data.frame()
difference[1,1] = 'difference' 
  
  
for (i in(2:ncol(spam_mean_bytype))) {
  difference[1,i] = spam_mean_bytype[1,i] - spam_mean_bytype[2,i]
}

colnames = colnames(spam_mean_bytype)
names(difference) = colnames

NonspamVSspam = rbind(spam_mean_bytype, difference)

spam_mean_bytype[3,] = c("Difference", colSums(y[,2:3]))

