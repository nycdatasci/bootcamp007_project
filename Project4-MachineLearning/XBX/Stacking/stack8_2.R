setwd("c:/Users/Xinyuan Wu/Desktop/Xinyuan's Repo/kaggle_Project")
library(caret)
library(gbm)
library(Matrix)
library(xgboost)
library(Metrics)

## get framework
result <- read.csv("stack/test_encode2.csv")
e0_nn <- read.csv("stack/nn_t.csv")
e1_rf <- read.csv("stack/proc_s_RF_t.csv")
e1_xb <- read.csv("stack/proc_s_XGB2_t.csv")
e2_rf <- read.csv("stack/proc2b_s_RF_t.csv")
e2_xb <- read.csv("stack/proc2b_s_XGB2_t_n2235.csv")
e2o_xb <- read.csv("stack/proc2o_XGB_t.csv")
e3_xb <- read.csv("stack/proc3o_XGB_t.csv")
layer0 <- read.csv("stack/pred_t_layer0.csv")

df <- data.frame(loss = result$loss,
                 e0_nn = e0_nn$loss,
                 #e1_rf = e1_rf$loss,
                 #e1_xb = e1_xb$loss,
                 #e2_rf = e2_rf$loss,
                 #e2_xb = e2_xb$loss,
                 e2o_xb = e2o_xb$loss,
                 e3_xb = e3_xb$loss,
                 layer0 = layer0$pred_t_layer0)

mae_e0_nn <- mean(abs(df$loss - df$e0_nn))   ### 1133.931
mae_e1_rf <- mean(abs(df$loss - df$e1_rf))   ### 1232.126
mae_e1_xb <- mean(abs(df$loss - df$e1_xb))   ### 1228.839
mae_e2_rf <- mean(abs(df$loss - df$e2_rf))   ### 1203.277
mae_e2_xb <- mean(abs(df$loss - df$e2_xb))   ### 1191.811
mae_e2o_xb <- mean(abs(df$loss - df$e2o_xb)) ### 1131.767
mae_e3_xb <- mean(abs(df$loss - df$e3_xb))   ### 1124.145
mae_layer0 <- mean(abs(df$loss - df$layer0)) ### 1126.487

e0_nn_s <- read.csv("Prediction/proc0_nn.csv")
e1_rf_s <- read.csv("Prediction/proc_RF_submit_1263_ntree1000.csv")
e1_xb_s <- read.csv("Prediction/proc_XGB2_1209.csv")
e2_rf_s <- read.csv("Prediction/proc2b_s_RF_tAll.csv")
e2_xb_s <- read.csv("Prediction/proc2b_s_XGB2_tAll_n2235_1173.csv")
e2o_xb_s <- read.csv("Prediction/proc2o_XGB_tAll.csv")
e3_xb_s <- read.csv("Prediction/proc3o_XGB_tAll_1108.csv")
layer0_s <- read.csv("Prediction/pred_s_layer0.csv")

df_s <- data.frame(e0_nn = e0_nn_s$loss,
                   #e1_rf = e1_rf_s$loss, 
                   #e1_xb = e1_xb_s$loss,
                   #e2_rf = e2_rf_s$loss,
                   #e2_xb = e2_xb_s$loss,
                   e2o_xb = e2o_xb_s$loss,
                   e3_xb = e3_xb_s$loss,
                   layer0 = layer0_s$pred_s_layer0)

## train gam
stack_gam <- train(log(loss) ~ ., method = "gam", data = df)
pred <- exp(predict(stack_gam, df))
mean(abs(df$loss - pred))   ### 1158.359

pred_s <- exp(predict(stack_gam, newdata = df_s))

submission <- read.csv("Prediction/sample_submission.csv")
submission$loss <- as.numeric(pred_s)
write.csv(submission, file = 'submissionNov25_gamstack2.csv', row.names = F)

## train gbm
set.seed(1314)
            ###str(test, list.len = length(train))
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
predmat <- exp(predict(stack_gbm, newdata = test[, 2:5], n.trees = n.trees))
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
                      n.trees = 7000,
                      interaction.depth = 4)

summary(stack_gbm_full)

pred_s <- exp(predict(stack_gbm_full, newdata = df_s, n.trees = 7000))

submission <- read.csv("Prediction/sample_submission.csv")
submission$loss <- as.numeric(pred_s)
write.csv(submission, file = 'submissionNov26_gbmstack9.csv', row.names = F)

## train xgboost
x_train <- df[, 2:4]
y_train <- log(df$loss)
x_test <- df_s
dtrain <- xgb.DMatrix(as.matrix(x_train), label = y_train)
dtest <- xgb.DMatrix(as.matrix(x_test))


xgb_params = list(
    seed = 520,
    colsample_bytree = 1,
    subsample = 0.8,
    eta = 0.03,
    objective = 'reg:linear',
    max_depth = 4,
    num_parallel_tree = 1,
    min_child_weight = 1,
    base_score = 7
)

xg_eval_mae <- function (yhat, dtrain) {
    y = getinfo(dtrain, "label")
    err= mae(exp(y),exp(yhat) )
    return (list(metric = "error", value = err))
}

res <- xgb.cv(xgb_params,
             dtrain,
             nrounds = 1000,
             nfold = 5,
             early_stopping_rounds = 15,
             print_every_n = 10,
             verbose = 1,
             feval = xg_eval_mae,
             maximize = FALSE)

best_nrounds <- res$best_iteration
cv_mean <- res$evaluation_log$test_error_mean[best_nrounds]
cv_std <- res$evaluation_log$test_error_std[best_nrounds]
cat(paste0('CV-Mean: ',cv_mean,' ', cv_std))

gbdt <- xgb.train(xgb_params, dtrain, best_nrounds)

pred_s <- exp(predict(gbdt,dtest))

submission <- read.csv("Prediction/sample_submission.csv")
submission$loss <- as.numeric(pred_s)
write.csv(submission, file = 'submissionNov26_xgbstack2.csv', row.names = F)

# predict submit

pred_s <- exp(predict(stack_gbm_full, newdata = df_s, n.trees = 6200))

submission <- read.csv("Prediction/sample_submission.csv")
submission$loss <- as.numeric(pred_s)
write.csv(submission, file = 'submissionNov25_xgbstack1.csv', row.names = F)
