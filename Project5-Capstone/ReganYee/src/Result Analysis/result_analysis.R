library(dplyr)
library(scales)

setwd("~/results")
predict = read.csv("without_augmentation_testing_set.csv")

predict$actual= sapply(as.character(predict$img), function(x) strsplit(x, '\\.')[[1]][1])
predict = predict %>% mutate(prediction = colnames(predict)[apply(predict,1,which.max)], result = actual == prediction)
predict$adidas = percent(predict$adidas)
predict$jordan = percent(predict$jordan)
predict$newbalance = percent(predict$newbalance)
predict$nike = percent(predict$nike)

predict = predict %>% arrange(img)
predict

predict %>% select(jordan,img,actual,prediction,result) %>% filter(grepl('jordan.b1',img))


acc = predict %>% group_by(result) %>% summarize(count=n())
acc


4803/(1197+4803)
