#setwd("~/Dropbox/Projects_NYCDSA7/Machine Learning")

library('dplyr')
library('ggplot2')
library('glmnet')

train.data <- read.csv('train.csv')

cont.var <- train.data[,118:132]
train.index <- sample(1:nrow(cont.var), 8*nrow(cont.var)/10)

test.index <- (-train.index)
x <- model.matrix(loss~ ., cont.var)
y <- cont.var$loss
x_test <- x[test.index,]
y_test <- y[test.index]
x_train <- x[train.index,]
y_train <- log(y[train.index])

grid <- 10^seq(-10, -20, length = 100)
ridge_train <- glmnet(x_train, y_train, alpha = 0, lambda = grid)

plot(ridge_train)
###continuous show that they do not have any correlation to the loss variable
###we conclude that most of the continuous variables will not contribute to our model
###for any linear regression  model, we will exclude them