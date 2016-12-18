library(caret)
library(elasticnet)
set.seed(825)

fitControl <- trainControl(method = "cv", number = 10)

fit.lasso.1 <- train(loss1~., justloss1, method='lasso', preProc=c('scale','center'),
                     trControl=fitControl)
fit.lasso.1

predict.enet(fit.lasso.1$finalModel, type='coefficients', s=fit.lasso.1$bestTune$fraction, mode='fraction')

lasso.pred.1 <- predict(fit.lasso.1, testing1)

RMSE(pred=lasso.pred.1, obs=testing1$loss1)

lasso.error.1 <- lasso.pred.1 - testing1$loss1
mae(lasso.error.1)
