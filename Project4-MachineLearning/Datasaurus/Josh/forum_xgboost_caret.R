# Aim of this script to to demonstrate simple amendments to
# R port of Faron's script that can materially improve the score.
# All amendments are from existing forum posts/kernels
#
# https://www.kaggle.com/mmueller/allstate-claims-severity/yet-another-xgb-starter
# https://www.kaggle.com/iglovikov/allstate-claims-severity/xgb-1114
#
# scores 1113.93 on public leaderboard when run with all features 
# and an eta of 0.01. But to achieve that will need to be run
# locally and edited as directed, due to time out from low eta in Kaggle kernels.

library(data.table)
library(Matrix)
library(xgboost)
library(Metrics)
library(dplyr)

ID = 'id'
TARGET = 'loss'
set.seed(0)
SHIFT = 1

#Remove columns where all factors had non-zero variance according to exploratory data analysis
removeableVariablesEDA = c("cat7","cat14", "cat15", "cat16", "cat17", "cat18", "cat19", "cat20", "cat21", "cat22", "cat24", "cat28", "cat29", "cat30", "cat31", 
                           "cat32", "cat33", "cat34", "cat35", "cat39", "cat40", "cat41", "cat42", "cat43", "cat45", "cat46", "cat47", "cat48", "cat49", "cat51", 
                           "cat52", "cat54", "cat55", "cat56", "cat57", "cat58", "cat59", "cat60", "cat61", "cat62", "cat63", "cat64", "cat65", "cat66", "cat67", 
                           "cat68", "cat69", "cat70", "cat74", "cat76", "cat77", "cat78", "cat85", "cat89")
features_to_drop <- c("cat67","cat21","cat60","cat65", "cat32", "cat30",
                                             "cat24", "cat74", "cat85", "cat17", "cat14", "cat18",
                                             "cat59", "cat22", "cat63", "cat56", "cat58", "cat55",
                                             "cat33", "cat34", "cat46", "cat47", "cat48", "cat68",
                                             "cat35", "cat20", "cat69", "cat70", "cat15", "cat62")

as_train <- fread(file.path('../Data', "train.csv"), stringsAsFactors = TRUE,
                  drop = features_to_drop)
# Store and remove ids
train_ids = as_train$id
loss = as_train$loss
as_train = as_train %>% dplyr::select(-id, -loss)

as_test <- fread(file.path('../Data', "test.csv"), stringsAsFactors = TRUE,
                 drop = features_to_drop)
# Store and remove ids
test_ids = as_test$id
as_test = as_test %>% dplyr::select(-id)

# Subset the data
library(caret)
subset_ratio = 0.01
training_subset = createDataPartition(y = train_ids, p = subset_ratio, list = FALSE)
as_train <- as_train[training_subset, ]


# Pre-processing
print("Pre-processing...")

# Transform the loss to log?
shift = 1 # from forums
loss = log(loss + shift)

# Convert categorical to dummy variables
#as_train = model.matrix(loss ~ . -1, data = as_train) # - 1 to ignore intercept
# as_test = model.matrix( ~ . -1, data = as_test)
ntrain = nrow(as_train)
train_test = rbind(as_train, as_test)

# Convert to dummy variables
library(caret)
train_test_dummies = model.matrix( ~ ., data = train_test)

x_train = train_test_dummies[1:ntrain,]
x_test = train_test_dummies[(ntrain+1):nrow(train_test),]

dtrain = xgb.DMatrix(as.matrix(x_train), label=loss[training_subset])
dtest = xgb.DMatrix(as.matrix(x_test))


# established best _nrounds with eta=0.05 from a local cv run 
best_nrounds = 545 # comment this out when doing local 1113 run

xgb_params = list(
  colsample_bytree = 0.5,
  subsample = 0.8,
  eta = 0.05, 
  objective = 'reg:linear',
  max_depth = 12,
  #alpha = 1,
  gamma = 2,
  min_child_weight = 1,
  nrounds = as.integer(best_nrounds/0.8)
  #base_score = 7.76
)

gbdt = xgb.train(xgb_params, dtrain, nrounds = as.integer(best_nrounds/0.8))

caret_params = list(
  colsample_bytree = 0.5,
  subsample = 0.8,
  eta = 0.05, 
  max_depth = 12,
  gamma = 2,
  min_child_weight = 1,
  nrounds = as.integer(best_nrounds/0.8)
)

fitCtrl <- trainControl(method = "none")
args = list(x = x_train, 
                y = loss[training_subset], 
                method = "xgbTree", 
                trControl = fitCtrl, 
                tuneGrid = as.data.frame(caret_params))
training_model = do.call(train, args)

caret_predict = exp(predict(training_model, dtest)) - SHIFT
xgboost_predict = exp(predict(gbdt, dtest)) - SHIFT

submission = fread(SUBMISSION_FILE, colClasses = c("integer", "numeric"))
submission$loss = exp(predict(gbdt,dtest)) - SHIFT
write.csv(submission,'xgb_simple.csv',row.names = FALSE)

