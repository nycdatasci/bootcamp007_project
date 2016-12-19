# load the training data
setwd("C:/Users/Xinyuan Wu/Desktop/Xinyuan's Repo/Kaggle_Project")
train <- read.csv("data/train.csv/train.csv")
submit <- read.csv("data/test.csv/test.csv")
num_train <- train[, -c(1: 117, 132)]
num_submit <- submit[, -c(1:117)]
train_full_id <- train[, 1]
submit_id <- submit[, 1]
# str(num_train); str(num_test)

## correlation plot
# suppressPackageStartupMessages(library(corrplot))
# correlations <- cor(num_train)
# corrplot.mixed(correlations, upper = "square", order = "hclust")

## explore continuous variables
# draw_cont <- function(data, col) {
#     len <- sapply(data, function(x) length(unique(x)))
#     plot(1:len[col], sort(unique(data[, col]), decreasing = FALSE),
#          xlab = paste0('Cont', col), ylab = "Value")
# }
# 
# par(mfrow = c(3, 5))
# for (i in 1:14) {
#     draw_cont(num_train, col = i)
# }
# 
# par(mfrow = c(3, 5))
# for (i in 1:7) {
#     draw_cont(num_train, col = i)
#     draw_cont(num_test, col = i)
# }
# 
# par(mfrow = c(3, 5))
# for (i in 8:14) {
#     draw_cont(num_train, col = i)
#     draw_cont(num_test, col = i)
# }
# 
# ## check level consistency between train and test
# compare_level <- function(data1, data2) {
# }
# 
# ## back-transformation of cont variables
# back_trans <- function(data) {
#     for (i in 1:dim(data)[2]) {
#         a <- factor(data[, i], 
#                     levels = sort(unique(data[, i]), decreasing = FALSE))
#         levels(a) <- 1:length(unique(data[, i]))
#         data[, i] <- as.numeric(as.character(a))
#     }
#     return(data)
# }
# 
# num_train_trans <- back_trans(num_train)
# num_test_trans <- back_trans(num_test)


## Feature Selection
suppressPackageStartupMessages(library(plyr))
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(caret))
# str(dm_train, list.len = ncol(dm_train))   ### used to check the complete structure

train <- train %>% select(-id)   ### remove id column
submit <- submit %>% select(-id)
cat_train <- train[, 1:116]
cat_submit <- submit[, 1:116]

# dm_train <- model.matrix(loss ~ ., data = train)   ### convert cate to dummy
# dm_test <- model.matrix(~ ., data = test)
# preProc <- preProcess(dm_train, method = "nzv"); preProc   ### get preProcess obj
# dm_train_proc <- predict(preProc, dm_train); dim(dm_train_proc)   ### remove nzv
# dm_test_proc <- predict(preProc, dm_test); dim(dm_test_proc)
# dm_train_proc <- as.data.frame(dm_train_proc)
# dm_test_proc <- as.data.frame(dm_test_proc)


dmcat_train <- model.matrix(~ . + 0, data = cat_train, 
                            contrasts.arg = lapply(cat_train, contrasts, contrasts = FALSE))
dmcat_submit <- model.matrix(~ . + 0, data = cat_submit, 
                           contrasts.arg = lapply(cat_submit, contrasts, contrasts = FALSE))
preProc_obj <- preProcess(dmcat_train, method = "nzv"); preProc_obj
dmcat_train_proc <- predict(preProc_obj, dmcat_train); dim(dmcat_train_proc)
# dmcat_test_proc <- predict(preProc_obj, dmcat_test); dim(dmcat_test_proc)
dmcat_train_proc <- as.data.frame(dmcat_train_proc)
# dmcat_test_proc <- as.data.frame(dmcat_test_proc)

find_same_col <- function(subset, fullset) {
    for (i in colnames(fullset)) {
        if (!(i %in% colnames(subset))) {
            fullset <- fullset[, -which(colnames(fullset) == i)]
        }
    }
    return(fullset)
}

dmcat_submit_proc <- find_same_col(dmcat_train_proc, as.data.frame(dmcat_submit))

train_processed <- data.frame(dmcat_train_proc, train[, 117:131])
submit_processed <- data.frame(dmcat_submit_proc, submit[, 117:130])

# data subset
set.seed(1314)
train_index <- sample(1:nrow(train), 8*nrow(train)/10)
test_index <- -train_index
train_id <- train_full_id[train_index]
test_id <- train_full_id[test_index]
train <- train_processed[train_index, ]
test <- train_processed[test_index, ]
submit <- submit_processed

write.csv(data.frame(train_id), file = "train_id.csv", row.names = F)
write.csv(data.frame(test_id), file = "test_id.csv", row.names = F)
write.csv(train, file = 'train.csv', row.names = F)
write.csv(test, file = 'test.csv', row.names = F)
write.csv(train_processed, file = 'train_full.csv', row.names = F)
write.csv(submit, file = 'submit.csv', row.names = F)

## encoding 2
#str(submit_encoded2, list.len = ncol(submit_encoded2)) 

submit2 <- submit
submit2$loss <- NA
submit2_cat <- submit2[, 1:116]
submit2_num <- submit2[, 117:131]
submit2_cat_conv <- data.frame(lapply(submit2_cat, as.character), 
                               loss = submit2$loss, stringsAsFactors = FALSE)

train2 <- train
train2_cat <- train2[, 1:116]
train2_num <- train2[, 117:131]
train2_cat_conv <- data.frame(lapply(train2_cat, as.character),
                              loss = train2$loss, stringsAsFactors = FALSE)

full <- rbind(train2_cat_conv, submit2_cat_conv)

find_different <- function(x, y) {
    return(c(setdiff(x, y), setdiff(y, x)))
}

filter_cat <- function(x, remove) {
    return(mapvalues(x, remove, rep('NA', length(remove))))
}

sum(sapply(full[, 1:116], function(x) sum(x == 'NA')))   ### before
for (i in 1:116) {
    remove <- find_different(train2_cat_conv[, i], submit2_cat_conv[, i])
    if (length(remove) > 0) {
        print(paste('========', i))
        print(remove)
        full[, i] <- filter_cat(full[, i], remove)
        print('===================================================================')}
}
sum(sapply(full[, 1:116], function(x) sum(x == 'NA')))   ### after

full_factorize <- data.frame(lapply(full[, 1:116], function(x) as.numeric(factor(x))),
                             loss = full$loss, stringsAsFactors = FALSE)

train_encoded2 <- cbind(full_factorize[!is.na(full_factorize$loss), 1:116], train2_num)
submit_encoded2 <- cbind(full_factorize[is.na(full_factorize$loss), 1:116], submit2[, 117:130])

train_version2 <- train_encoded2[train_index, ]
test_version2 <- train_encoded2[test_index, ]
submit_version2 <- submit_encoded2

write.csv(train_version2, file = 'train_encode2.csv', row.names = F)
write.csv(test_version2, file = 'test_encode2.csv', row.names = F)
write.csv(train_encoded2, file = 'train_full_encode2.csv', row.names = F)
write.csv(submit_version2, file = 'submit_encode2.csv', row.names = F)


## encoding 2 version 2
submit2 <- submit
submit2$loss <- NA
submit2_cat <- submit2[, 1:116]
submit2_num <- submit2[, 117:131]
submit2_cat_conv <- data.frame(lapply(submit2_cat, as.character), 
                               loss = submit2$loss, stringsAsFactors = FALSE)

train2 <- train
train2_cat <- train2[, 1:116]
train2_num <- train2[, 117:131]
train2_cat_conv <- data.frame(lapply(train2_cat, as.character),
                              loss = train2$loss, stringsAsFactors = FALSE)

full <- rbind(train2_cat_conv, submit2_cat_conv)

find_different <- function(x, y) {
    return(c(setdiff(x, y), setdiff(y, x)))
}

filter_cat <- function(x, remove) {
    return(mapvalues(x, remove, rep('ZZZ', length(remove))))
}

sum(sapply(full[, 1:116], function(x) sum(x == 'ZZZ')))   ### before
for (i in 1:116) {
    remove <- find_different(train2_cat_conv[, i], submit2_cat_conv[, i])
    if (length(unique(train2_cat_conv[, i])) != length(unique(submit2_cat_conv[, i])) &
        length(remove) > 0) {
        print(paste('========', i))
        print(remove)
        full[, i] <- filter_cat(full[, i], remove)
        print('===================================================================')}
}
sum(sapply(full[, 1:116], function(x) sum(x == 'ZZZ')))   ### after

full_factorize <- data.frame(lapply(full[, 1:116], function(x) as.numeric(factor(x))),
                             loss = full$loss, stringsAsFactors = FALSE)

train_encoded2 <- cbind(id = train_full_id, 
                        full_factorize[!is.na(full_factorize$loss), 1:116], 
                        train2_num)
submit_encoded2 <- cbind(id = submit_id,
                         full_factorize[is.na(full_factorize$loss), 1:116], 
                         submit2[, 117:130])

train_version2 <- train_encoded2[train_index, ]
test_version2 <- train_encoded2[test_index, ]
submit_version2 <- submit_encoded2

write.csv(train_version2, file = 'train_encode2_v2.csv', row.names = F)
write.csv(test_version2, file = 'test_encode2_v2.csv', row.names = F)
write.csv(train_encoded2, file = 'train_full_encode2_v2.csv', row.names = F)
write.csv(submit_version2, file = 'submit_encode2_v2.csv', row.names = F)

## subset train and test for NN
str(submit_nn, list.len = ncol(train))

train_nn <- train[sort(train_index), ]
test_nn <- train[test_index, -132]
train_full_nn <- train
submit_nn <- submit

write.csv(train_nn, file = 'train_nn_1.csv', row.names = F)
write.csv(test_nn, file = 'test_nn_1.csv', row.names = F)
write.csv(train_full_nn, file = 'train_nn_2.csv', row.names = F)
write.csv(submit_nn, file = 'test_nn_2.csv', row.names = F)


