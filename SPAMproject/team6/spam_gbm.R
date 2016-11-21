library(kernlab)
library(gbm)
data(spam)
spam_scaled <- scale(spam[,-58])
spam_scaled <- as.data.frame(spam_scaled)
train <- sample(c(1:nrow(spam_scaled)), 0.7*nrow(spam_scaled))
spam_scaled$type <- spam$type
spam_scaled$type <- as.numeric(spam_scaled$type)-1  #1: spam; 0: nonspam
sp_train <- spam_scaled[train,]
sp_test <- spam_scaled[-train,]
set.seed(0)
boost_sp <- gbm(type ~ ., data = sp_train,
                distribution = "bernoulli",
                n.trees = 10000,
                interaction.depth = 4,
                shrinkage = 0.001)
n_trees <- seq(from = 100, to = 10000, by = 100)
predmat <- predict(boost_sp, newdata = sp_test, n.trees = n_trees, type = "response")
predmat <- round(predmat)
berr <- with(sp_test, apply((predmat - type)^2, 2, mean))
which.min(berr) 
#9500 
#95 

1-min(berr)
#[1] 0.9464156
pred <- predmat[,95]
pred <- as.factor(pred)
truth <- sp_test$type
table(truth, pred)
#      pred
#truth   0   1
#     0 794  30
#     1  44 513
accuracy = (table(truth, pred)[1,1]+table(truth, pred)[2,2])/1381
accuracy

sensitivity = (table(truth, pred)[2,2])/(table(truth, pred)[2,2]+table(truth, pred)[2,1]) #tpr
sensitivity

specificity = (table(truth, pred)[1,1])/(table(truth, pred)[1,1]+table(truth, pred)[1,2]) #tnr
specificity

plot(n_trees, berr, pch = 16,
     ylab = "Classification Error",
     xlab = "# Trees",
     main = "Boosting Test Classification Error")
abline(h = min(berr), col = "blue")  #boosted
