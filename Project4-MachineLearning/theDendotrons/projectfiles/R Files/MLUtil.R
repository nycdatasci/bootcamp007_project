# utility library for doing some kaggle stuff
library(dplyr)
library(caret)
library(xgboost)
library(ModelMetrics)

# given a name get an index
getColIndex = function(cn, df) {
  return (which(colnames(df) == cn))
}

# function to return a vector column index
getColIndexes = function(cns, df) {
  indexes = c()
  
  for(cn in cns) {
    indexes = append(indexes, getColIndex(cn, df))
  }
  
  return(indexes)
}
#getColIndexes(c('cat1', 'cat15'), alls.trainSDF)

# function to sort by a particular column and plot
sortAndPlot = function(cn, skip) {
  index = getColIndex(cn, alls.trainSDF)
  df = alls.trainSDF[order(alls.trainSDF[index]), ]
  plotdf = df[seq(1, nrow(df), skip), ]
  plot(x = 1:nrow(plotdf), y = plotdf$loss)
}
#sortAndPlot('cat112', 100)

plotFeature = function(cn, skip) {
  plotdf = alls.trainSDF[seq(1, nrow(alls.trainSDF), skip), ]
  
  # let draw this plot to a file now
  png(file='featurePlot.png',width=600,height=500,res=72)
  
  #index = getColIndex(cn, alls.trainSDF)
   #print(boxplot(loss ~ plotdf[,index], data=plotdf, main="Feature vs. Loss", 
  #        xlab=paste("Feature", cn,"Values"), ylab="Log Loss + 1"))
  
  if(grepl('cat', cn)) {
    print(ggplot(data = plotdf, aes_string(x = cn, y = 'loss', fill = cn)) + geom_boxplot())
  } else {
    print(ggplot(data = plotdf, aes_string(x = cn, y = 'loss')) + geom_point() + geom_smooth(method=lm))
  }
  
  dev.off()
}
#plotFeature('cat57', 10)

# function to return the reduced dataframe
reduceDF = function(full.df, columns) {
  indexes = getColIndexes(columns, full.df)
  df = select(full.df, indexes)
  return(df)
}
#rdf <- reduceDF(alls.trainSDF, c('cat1','cat2'))

# create a subset of the data
cat112Subset = function() {
  train_e <<- filter(alls.trainSDF, cat112 == 'E')
  test_e <<- filter(alls.trainSDF, cat112 == 'E' )
  loss_e <<- train_e$loss
}

# function to create the data for training
createTrainDM = function(train.df) {
 dm_train <- model.matrix(loss ~ ., data = train.df)
 preProc <- preProcess(dm_train, method = "zv")
 dm_train <<- predict(preProc, dm_train)
}

# create the test data matrix
createTestDM = function(test.df) {
  dm_test <- model.matrix(id ~ ., data = test.df)
  preProc <- preProcess(dm_test, method = "zv")
  dm_test <<- predict(preProc, dm_test)
}

# this creates test function based on df
createSubTrainAndTest = function(dm_train, loss_data) {
  set.seed(321)
  trainIdx <- createDataPartition(loss_data, 
                                  p = .8,
                                  list = FALSE,
                                  times = 1)
  subTrain <<- dm_train[trainIdx,]
  subTest <<- dm_train[-trainIdx,]
  lossTrain <<- loss_data[trainIdx]
  lossTest <<- loss_data[-trainIdx]
}

# function to actually do the fit
fitDataLM = function() {
  lmFit <<- train(x = subTrain, 
               y = lossTrain,
               method = "lm")
  
  return(getTrainPerf(lmFit))
}

# function to make prediction with data
testFit = function() {
  predicted <- predict(lmFit, subTest)
  return(postResample(pred = predicted, obs = lossTest))
}

# let try running some gbm models
tuneGBM = function() {
  fitCtrl <<- trainControl(method = "cv",
                          number = 5,
                          verboseIter = TRUE,
                          summaryFunction=defaultSummary)
  
  gbmGrid <<- expand.grid( n.trees = seq(100,500,50), 
                          interaction.depth = c(1,3,5,7), 
                          shrinkage = 0.1,
                          n.minobsinnode = 20)
}

# run gbm fit
fitDataGBM = function() {
  gbmFit <<- train(x = subTrain, 
                  y = lossTrain,
                  method = "gbm", 
                  trControl = fitCtrl,
                  tuneGrid = gbmGrid,
                  metric = 'RMSE',
                  maximize = FALSE)
  
  #return(mean(gbmFit$resample$RMSE))
  return (getTrainPerf(gbmFit))
} 

# function to make prediction with data
testFitGBM = function() {
  predicted <- predict(gbmFit, subTest)
  return(postResample(pred = predicted, obs = lossTest))
}

# the mean absolute error for xgb
maeSummary = function (data,
                        lev = NULL,
                        model = NULL) {
  out <- mae(data$obs, data$pred)  
  names(out) <- "MAE"
  out
}

# tune xgb parameters
tuneXGB = function() {
  xgbCV <<- trainControl(method = "repeatedcv", 
                         repeats = 1,
                         number = 5, 
                         allowParallel=T,
                         verboseIter = TRUE,
                         summaryFunction = maeSummary)

  xgbGrid <<- expand.grid(nrounds = 5000,
                          max_depth = 12,
                          eta = 0.01,
                          gamma = 2,
                          colsample_bytree = 0.5,
                          min_child_weight = 1,
                          subsample = 0.8)
}

# use xgb to fit the data
fitDataXGB = function(threads) {
  xgbFit <<- train(x = subTrain, 
                   y = lossTrain,
                   method = "xgbTree", 
                   trControl = xgbCV,
                   tuneGrid = xgbGrid,
                   metric = 'MAE',
                   maximize = FALSE,
                   nthread = threads)
  
  return (getTrainPerf(xgbFit))  
}

# function to test the predicted power of the model
testFitXGB = function() {
  predicted <- predict(xgbFit, subTest)
  out <- mae(lossTest, predicted)  
  names(out) <- "Test MAE"
  return(out)
}

# function used to make prediction to submit to kaggle
createKaggleSubmit = function(modelFit) {
  if(!(exists('dm_test'))) {
    df_test = select(alls.testDF,cat1,cat2,cat3,cat4,cat5,cat6,cat7,cat8,cat9,cat10,cat11,cat12,cat13,cat16,cat20,cat23,cat24,cat25,cat26,cat27,cat28,cat29,cat30,cat31,cat32,cat36,cat37,cat38,cat40,cat41,cat44,cat49,cat50,cat52,cat53,cat54,cat57,cat66,cat72,cat73,cat75,cat79,cat80,cat81,cat82,cat83,cat84,cat86,cat87,cat88,cat91,cat92,cat93,cat94,cat95,cat96,cat97,cat98,cat99,cat100,cat101,cat102,cat103,cat104,cat105,cat106,cat107,cat108,cat109,cat111,cat113,cat114,cat115,cont1,cont2,cont3,cont4,cont5,cont6,cont7,cont8,cont9,cont10,cont11,cont13,id)
    createTestDM(df_test)
  }
  
  test.predict = predict(modelFit, dm_test)
  
  # convert all log loss + 1 back to orignal
  submission = data.frame(id=alls.testDF$id, loss_log = test.predict)
  submission = mutate(submission, loss = exp(loss_log) - 1)
  submission = select(submission, -loss_log)
  
  write.csv(submission, 'xgboost_submission.csv',row.names = FALSE)
}

# test the createTrainData
#cat112Subset()
#df_train = select(train_e,cat1,cat2,cat3,cat4,cat5,cat6,cat7,cat8,cat9,cat10,cat11,cat12,cat13,cat16,cat20,cat23,cat24,cat25,cat26,cat27,cat28,cat29,cat30,cat31,cat32,cat36,cat37,cat38,cat40,cat41,cat44,cat49,cat50,cat52,cat53,cat54,cat57,cat66,cat72,cat73,cat75,cat79,cat80,cat81,cat82,cat83,cat84,cat86,cat87,cat88,cat91,cat92,cat93,cat94,cat95,cat96,cat97,cat98,cat99,cat100,cat101,cat102,cat103,cat104,cat105,cat106,cat107,cat108,cat109,cat111,cat113,cat114,cat115,cont1,cont2,cont3,cont4,cont5,cont6,cont7,cont8,cont9,cont10,cont11,cont13,loss)
#createTrainDM(df_train)
#createSubTrainAndTest(dm_train, loss_e)

# fitDataLM()
# testFit()
# getTrainPerf(lmFit)

#tuneGBM()
#fitDataGBM()
#testFitGBM()

# test our xgb code
#set.seed(123)
#tuneXGB()
#fitDataXGB(3)
#testFitXGB()

# create file for submitting to kaggle
#createKaggleSubmit(xgbFit)
