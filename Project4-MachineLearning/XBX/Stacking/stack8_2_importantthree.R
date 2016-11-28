setwd("c:/Users/Xinyuan Wu/Desktop/Xinyuan's Repo/kaggle_Project")
library(gbm)

## get framework
result <- read.csv("stack/test_encode2.csv")
e0_nn <- read.csv("stack/nn_t.csv")
e2o_xb <- read.csv("stack/proc2o_XGB_t.csv")
e3_xb <- read.csv("stack/proc3o_XGB_t.csv")

df <- data.frame(loss = result$loss,
                 e0_nn = e0_nn$loss,
                 e2o_xb = e2o_xb$loss,
                 e3_xb = e3_xb$loss)

mean(abs(df$loss - df$e0_nn))    ###  
mean(abs(df$loss - df$e2o_xb))   ###  
mean(abs(df$loss - df$e3o_xb))   ###  

e0_nn_s <- read.csv("Prediction/proc0_nn.csv")
e2o_xb_s <- read.csv("Prediction/proc2o_XGB_tAll.csv")
e3_xb_s <- read.csv("Prediction/proc3o_XGB_tAll_1108.csv")

df_s <- data.frame(e0_nn = e0_nn_s$loss,
                   e2o_xb = e2o_xb_s$loss,
                   e3_xb = e3_xb_s$loss)

## train gbm
set.seed(1314)
train_index <- sort(sample(1:nrow(df), 8*nrow(df)/10))
test_index <- -train_index
train <- df[train_index, ]
test <- df[test_index, ]

set.seed(1314)
stack_gbm <- gbm(log(loss) ~ ., data = train,
                 distribution = "laplace",
                 n.trees = 10000,
                 interaction.depth = 4)

n.trees <- seq(from = 100, to = 10000, by = 100)
predmat <- exp(predict(stack_gbm, newdata = test[, 2:4], n.trees = n.trees))
dim(predmat)

par(mfrow = c(1, 1))
mae <- with(test, apply(abs(predmat - loss), 2, mean))
plot(n.trees, mae, pch = 16,
     ylab = "Mean Absolute Error",
     xlab = "# Trees",
     main = "Boosting Test Error")

set.seed(1314)
stack_gbm_full <- gbm(log(loss) ~ ., data = df, 
                      distribution = "laplace",
                      n.trees = 10000,
                      interaction.depth = 4)

summary(stack_gbm_full)

pred_s <- exp(predict(stack_gbm_full, newdata = df_s, n.trees = 10000))

submission <- read.csv("Prediction/sample_submission.csv")
submission$loss <- as.numeric(pred_s)
write.csv(submission, file = 'submissionNov26_gbmstack13.csv', row.names = F)

















