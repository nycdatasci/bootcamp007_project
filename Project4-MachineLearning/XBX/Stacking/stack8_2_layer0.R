setwd("c:/Users/Xinyuan Wu/Desktop/Xinyuan's Repo/kaggle_Project")
library(gbm)

## get framework
result <- read.csv("stack/test_encode2.csv")
e1_rf <- read.csv("stack/proc_s_RF_t.csv")
e1_xb <- read.csv("stack/proc_s_XGB2_t.csv")
e2_rf <- read.csv("stack/proc2b_s_RF_t.csv")
e2_xb <- read.csv("stack/proc2b_s_XGB2_t_n2235.csv")

df <- data.frame(loss = result$loss,
                 e1_rf = e1_rf$loss,
                 e1_xb = e1_xb$loss,
                 e2_rf = e2_rf$loss,
                 e2_xb = e2_xb$loss)

mean(abs(df$loss - df$e1_rf))   ### 1232.126
mean(abs(df$loss - df$e1_xb))   ### 1228.839
mean(abs(df$loss - df$e2_rf))   ### 1203.277
mean(abs(df$loss - df$e2_xb))   ### 1191.811

e1_rf_s <- read.csv("Prediction/proc_RF_submit_1263_ntree1000.csv")
e1_xb_s <- read.csv("Prediction/proc_XGB2_1209.csv")
e2_rf_s <- read.csv("Prediction/proc2b_s_RF_tAll.csv")
e2_xb_s <- read.csv("Prediction/proc2b_s_XGB2_tAll_n2235_1173.csv")

df_s <- data.frame(e1_rf = e1_rf_s$loss, 
                   e1_xb = e1_xb_s$loss,
                   e2_rf = e2_rf_s$loss,
                   e2_xb = e2_xb_s$loss)

## train gbm
set.seed(9999)
            ###str(test, list.len = length(train))
train_index <- sort(sample(1:nrow(df), 8*nrow(df)/10))
test_index <- -train_index
train <- df[train_index, ]
test <- df[test_index, ]

set.seed(9999)
stack_gbm <- gbm(log(loss) ~ ., data = train,
                 distribution = "laplace",
                 n.trees = 3500,
                 interaction.depth = 4)

n.trees <- seq(from = 100, to = 3500, by = 100)
predmat <- exp(predict(stack_gbm, newdata = test[, 2:5], n.trees = n.trees))
dim(predmat)

par(mfrow = c(1, 1))
mae <- with(test, apply(abs(predmat - loss), 2, mean))
plot(n.trees, mae, pch = 16,
     ylab = "Mean Absolute Error",
     xlab = "# Trees",
     main = "Boosting Test Error")

set.seed(9999)
stack_gbm_full <- gbm(log(loss) ~ ., data = df, 
                      distribution = "laplace",
                      n.trees = 3500,
                      interaction.depth = 4)

summary(stack_gbm_full)

pred_t_layer0 <- exp(predict(stack_gbm, newdata = df[, 2:5], n.trees = 2200))
pred_s_layer0 <- exp(predict(stack_gbm_full, newdata = df_s, n.trees = 3500))

mean(abs(df$loss - pred_t_layer0))   ### 1174.328

write.csv(data.frame(pred_t_layer0),
          file = 'pred_t_layer0.csv', row.names = F)
write.csv(data.frame(pred_s_layer0), 
          file = 'pred_s_layer0.csv', row.names = F)







