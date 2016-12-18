# load the training data
setwd("C:/Users/Xinyuan Wu/Desktop/Xinyuan's Repo/Kaggle_Project")
train_full <- read.csv("data/train.csv/train.csv")
submit <- read.csv("data/test.csv/test.csv")
num_train_full <- train_full[, -c(1: 117, 132)]
num_submit <- submit[, -c(1:117)]
train_full_id <- train_full[, 1]
submit_id <- submit[, 1]

# encode 1
suppressPackageStartupMessages(library(plyr))
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(caret))

train_full <- train_full %>% select(-id)
submit <- submit %>% select(-id)
cat_train_full <- train_full[, 1:116]
cat_submit <- submit[, 1:116]

dmcat_train_full <- model.matrix(~ . + 0, data = cat_train_full, 
                                 contrasts.arg = lapply(cat_train_full, 
                                                        contrasts, contrasts = FALSE))
dmcat_submit <- model.matrix(~ . + 0, data = cat_submit, 
                             contrasts.arg = lapply(cat_submit, 
                                                    contrasts, contrasts = FALSE))
preProc_obj <- preProcess(dmcat_train_full, method = "nzv"); preProc_obj
dmcat_train_full_proc <- predict(preProc_obj, dmcat_train_full); dim(dmcat_train_full_proc)
dmcat_train_full_proc <- as.data.frame(dmcat_train_full_proc)

find_same_col <- function(subset, fullset) {
    for (i in colnames(fullset)) {
        if (!(i %in% colnames(subset))) {
            fullset <- fullset[, -which(colnames(fullset) == i)]
        }
    }
    return(fullset)
}

dmcat_submit_proc <- find_same_col(dmcat_train_full_proc, as.data.frame(dmcat_submit))

train_full_processed <- data.frame(id = train_full_id,
                                   dmcat_train_full_proc,
                                   train_full[, 118:132])
submit_processed <- data.frame(id = submit_id,
                               dmcat_submit_proc,
                               submit[, 118:131])

set.seed(520)
train_index <- sort(sample(1:nrow(train_full), 6*nrow(train_full)/10))
test_index <- -train_index
train_encode1 <- train_full_processed[train_index, ]
test_encode1 <- train_full_processed[test_index, -195]
submit_encode1 <- submit_processed

write.csv(train_encode1, file = 'train.csv', row.names = F)
write.csv(test_encode1, file = 'test.csv', row.names = F)

# no encode
train_nn <- train_full[train_index, ]
test_nn <- train_full[test_index, -132]
test_result <- train_full[test_index, 132]

write.csv(train_nn, file = 'train.csv', row.names = F)
write.csv(test_nn, file = 'test.csv', row.names = F)
write.csv(data.frame(loss = test_result), file = 'test_result.csv', row.names = F)






















