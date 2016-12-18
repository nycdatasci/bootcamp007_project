setwd("~/Dropbox/Projects_NYCDSA7/Machine Learning")
train.data <- read.csv('train.csv')
library(FactoMineR)
small.train <- train.data[,-c(1,132)]
smalltrain.index <- sample(1:nrow(small.train), 100)

mca <- FAMD(small.train[smalltrain.index,],ncp = 100)
plot(mca)
dim(mca$quali.var[[1]])
mca$eig[,1]
barplot(mca$eig[,1], names.arg = 1:length(mca$eig[,1]))

###after running an MCA it was shown that ~80 principle components had eigenvalues >1
###we ran this on a small training model before we sent the program off to the server

