start_time <- Sys.time()
library(data.table)
setwd("~/Desktop/Project4")
dt_train <- as.data.frame(fread("train.csv", stringsAsFactors = T))
dt_test <- as.data.frame(fread("test.csv", stringsAsFactors = T))
test_id <- dt_test[[1]]
temp <- dt_test[,-1]
temp$loss <- NA
test_num <- nrow(temp)
train_num <- nrow(dt_train)
k_value <- round(sqrt(train_num))
ht_env <- new.env(hash=TRUE)
with(ht_env, temp_train <- dt_train)
with(ht_env, temp_train <- temp_train[,-1])
with(ht_env, temp_train$loss <- log(temp_train$loss + 200))
with(ht_env, temp_test <- temp)
rm(dt_test)
rm(dt_train)
rm(temp)
with(ht_env, submission <- data.frame(id = numeric(), loss = numeric()))
for (i in seq(1, (test_num + 454), 2000)){
    if (nrow(ht_env$temp_test) > 2000){
        with(ht_env, temp_train <- rbind(temp_train, temp_test[1:2000,]))
        with(ht_env, temp_test <- temp_test[-(1:2000),])
    }else{
        with(ht_env, temp_train <- rbind(temp_train, temp_test))
    }
    with(ht_env, pred <- VIM::kNN(ht_env$temp_train, k = k_value))
    with(ht_env, temp_train <- temp_train[1:train_num,])
    if (nrow(ht_env$temp_test) > 2000){
        with(ht_env, submission_temp <- exp(pred$loss[(train_num+1):(train_num+2000)]) - 200)
    }else{
        with(ht_env, submission_temp <- exp(pred$loss[(train_num+1):(train_num+1546)]) - 200)
    }
    with(ht_env, temp_sub <- data.frame(id = test_id[i:(i+length(submission_temp)-1)], loss = submission_temp))
    with(ht_env, submission <- rbind(submission, temp_sub))
    print(i)
    print(Sys.time())
    print(ht_env$temp_sub)
}
write.csv(ht_env$submission, "submission_knn.csv", row.names = FALSE)
end_time <- Sys.time()
cat ("Run started at :", as.character(as.POSIXct(start_time, format = "%Y-%m-%d %H:%M:%S")))
cat ("\n")
cat ("Run finished at :", as.character(as.POSIXct(end_time, format = "%Y-%m-%d %H:%M:%S")))