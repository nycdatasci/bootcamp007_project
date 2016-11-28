library(mlr)
library(xgboost)
library(data.table)
library(parallelMap)
library(FeatureHashing)
library(BBmisc)
start_time <- Sys.time()
# create xgboost learner for mlr package
makeRLearner.regr.xgboost.latest = function() {
    makeRLearnerRegr(
        cl = "regr.xgboost.latest",
        package = "xgboost",
        par.set = makeParamSet(
            makeNumericLearnerParam(id = "eta", default = 0.3, lower = 0, upper = 1),
            makeNumericLearnerParam(id = "obj_par", default = 2, lower = 0),
            makeIntegerLearnerParam(id = "max_depth", default = 6L, lower = 1L),
            makeNumericLearnerParam(id = "min_child_weight", default = 1, lower = 0),
            makeNumericLearnerParam(id = "subsample", default = 1, lower = 0, upper = 1),
            makeNumericLearnerParam(id = "colsample_bytree", default = 1, lower = 0, upper = 1),
            makeNumericLearnerParam(id = "lambda", default = 0, lower = 0),
            makeNumericLearnerParam(id = "alpha", default = 0, lower = 0),
            makeNumericLearnerParam(id = "base_score", default = 0.5, tunable = FALSE),
            makeIntegerLearnerParam(id = "nthread", lower = 1L, tunable = FALSE),
            makeIntegerLearnerParam(id = "nrounds", default = 1L, lower = 1L),
            makeIntegerLearnerParam(id = "silent", default = 0L, lower = 0L, upper = 1L, tunable = FALSE),
            makeIntegerLearnerParam(id = "verbose", default = 1, lower = 0, upper = 2, tunable = FALSE),
            makeIntegerLearnerParam(id = "print_every_n", default = 1L, lower = 1L, tunable = FALSE, requires = quote(verbose == 1L))
        ),
        par.vals = list(nrounds = 1L, silent = 0L, verbose = 1L, obj_par = 2),
        properties = c("numerics", "factors", "weights"),
        name = "eXtreme Gradient Boosting",
        short.name = "xgboost",
        note = "All settings are passed directly, rather than through `xgboost`'s `params` argument. `nrounds` has been set to `1` and `verbose` to `0` by default."
    )
}

# create xgboost train and predict methods for mlr package
trainLearner.regr.xgboost.latest = function(.learner, .task, .subset, .weights = NULL,  ...) {
    data = getTaskData(.task, .subset, target.extra = TRUE)
    target = data$target
    data = FeatureHashing::hashed.model.matrix( ~ . - 1, data$data)
    
    myobj = function(preds, dtrain, c) {
        labels = getinfo(dtrain, "label")
        x = preds-labels
        # introduce hyperparameter for objective function
        c = .learner$par.vals$obj_par
        grad = tanh(c*x)
        hess = c*sqrt(1-grad^2)
        return(list(grad = grad, hess = hess))
    }
    
    xgboost::xgboost(data = data, label = target, objective = myobj, ...)
}
predictLearner.regr.xgboost.latest = function(.learner, .model, .newdata, ...) {
    m = .model$learner.model
    data = FeatureHashing::hashed.model.matrix( ~ . - 1, .newdata)
    xgboost:::predict(m, newdata = data, ...)
}

train = fread("./train.csv")
test = fread("./test.csv")
train_id = train$id
# remove id
train[, id := NULL]
test[, id := NULL]

# transform target variable and use factor variables 
train$loss = log(train$loss + 200) #fit log(loss)
test$loss = -99

# feature preprocess
dat = rbind(train, test)

char.feat = vlapply(dat, is.character)
char.feat = names(char.feat)[char.feat]
################### to use all features
#for (f in char.feat) {
#  dat[[f]] = as.integer(as.factor(dat[[f]]))   ####this line converts to all categorical variables to numeric values, ok with tree methods
#}

################# for 2nd round feature selection, remove the 47 features from 1st round 
feat_list = readRDS("minimum_feat.RDS")
#feat_list = c(feat_list, "loss")
all_feat = names(as.data.frame(dat))
diff_list = setdiff(all_feat, feat_list)
for (f in all_feat) {
    if (f %in% diff_list){
        if (f %in% char.feat){
            dat[[f]] = as.integer(as.factor(dat[[f]]))
        }
    }else{
        dat[[f]] = NULL
    }
}

dat = as.data.frame(dat)

# create task
train = dat[dat$loss != -99, ]
test = dat[dat$loss == -99, ]
train2 = train
train2$loss = -99
# create mlr measure for log-transformed target
mae.log = mae
mae.log$fun = function (task, model, pred, feats, extra.args) {
    measureMAE(exp(pred$data$truth), exp(pred$data$response))
}

# create mlr train and test task
trainTask = makeRegrTask(data = as.data.frame(train), target = "loss")
testTask = makeRegrTask(data = as.data.frame(test), target = "loss")

# specify mlr learner with some nice hyperpars
set.seed(123)
lrn = makeLearner("regr.xgboost.latest")
lrn = setHyperPars(lrn, 
                   base_score = 7.7,
                   subsample = 0.95,
                   colsample_bytree = 0.45,
                   max_depth = 10,
                   lambda = 10,
                   min_child_weight = 2.5, 
                   alpha = 8,
                   nthread = 16, 
                   nrounds = 200,
                   eta = 0.055,
                   #print_every_n = 50,
                   obj_par = 1.717274
)

## This is how you could do hyperparameter tuning with random search
# 1) Define the set of parameters you want to tune (here we use only 'obj_par')
ps = makeParamSet(
  makeNumericParam("obj_par", lower = 1.5, upper = 2),
  makeNumericParam("eta", lower = 0.1, upper = 1)
)
#ps = makeParamSet(
#    makeDiscreteParam("obj_par", values = c(1.5, 1.6, 1.7, 1.8, 1.9, 2.0))
#)

# 2) Use 3-fold Cross-Validation to measure improvements
rdesc = makeResampleDesc("CV", iters = 3L)

# 3) Here we use random search (with 5 Iterations) to find the optimal hyperparameter
ctrl =  makeTuneControlRandom(maxit = 5)
#ctrl = makeTuneControlGrid()
# 4) now use the learner on the training Task with the 3-fold CV to optimize your set of parameters in parallel
parallelStartMulticore(8)
res = tuneParams(lrn, task = trainTask, resampling = rdesc,
  par.set = ps, control = ctrl, measures = mae.log)
parallelStop()
print(res$x)



end_time <- Sys.time()
#run_time <- end_time-start_time

cat ("Run started at :", as.character(as.POSIXct(start_time, format = "%Y-%m-%d %H:%M:%S")))
cat("\n")
cat ("Run finished at :", as.character(as.POSIXct(end_time, format = "%Y-%m-%d %H:%M:%S")))

