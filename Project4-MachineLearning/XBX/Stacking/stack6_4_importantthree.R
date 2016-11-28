setwd("c:/Users/Xinyuan Wu/Desktop/Xinyuan's Repo/kaggle_Project")
library(gbm)

## get framework
result <- read.csv("stack/6_4/test_result.csv")
e0_nn <- read.csv("stack/6_4/proc0_nn_t.csv")
#e1_xb <- read.csv("stack/6_4/proc_s_XGB2_t_64.csv")
e2o_xb <- read.csv("stack/6_4/proc2o_XGB_64_t.csv")
e3o_xb <- read.csv("stack/6_4/proc3o_XGB_64_t.csv")

df <- data.frame(loss = result$loss,
                 e0_nn = e0_nn$loss,
                 #e1_xb = e1_xb$loss,
                 e2o_xb = e2o_xb$loss,
                 e3o_xb = e3o_xb$loss)

mean(abs(df$loss - df$e0_nn))    ###  1132.705
mean(abs(df$loss - df$e1_xb))    ###  1221.43
mean(abs(df$loss - df$e2o_xb))   ###  1131.601
mean(abs(df$loss - df$e3o_xb))   ###  1125.578

e0_nn_s <- read.csv("Prediction/proc0_nn.csv")
#e1_xb_s <- read.csv("Prediction/proc_XGB2_1209.csv")
e2o_xb_s <- read.csv("Prediction/proc2o_XGB_tAll.csv")
e3o_xb_s <- read.csv("Prediction/proc3o_XGB_tAll_1108.csv")

df_s <- data.frame(e0_nn = e0_nn_s$loss,
                   #e1_xb = e1_xb_s$loss,
                   e2o_xb = e2o_xb_s$loss,
                   e3o_xb = e3o_xb_s$loss)

## train gbm
set.seed(1314)
train_index <- sort(sample(1:nrow(df), 8*nrow(df)/10))
test_index <- -train_index
train <- df[train_index, ]
test <- df[test_index, ]

set.seed(1314)
stack_gbm <- gbm(log(loss) + 200 ~ ., data = train,
                 distribution = "laplace",
                 n.trees = 10000,
                 interaction.depth = 4)

summary(stack_gbm)

n.trees <- seq(from = 100, to = 10000, by = 100)
predmat <- exp(predict(stack_gbm, newdata = test[, 2:4], n.trees = n.trees)-200)
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
                      n.trees = 6400,
                      interaction.depth = 4)

summary(stack_gbm_full)

pred_s <- exp(predict(stack_gbm_full, newdata = df_s, n.trees = 6400))

submission <- read.csv("Prediction/sample_submission.csv")
submission$loss <- as.numeric(pred_s)
write.csv(submission, file = 'Nov27_64_2xb1nn_gbmstack4.csv', row.names = F)

















