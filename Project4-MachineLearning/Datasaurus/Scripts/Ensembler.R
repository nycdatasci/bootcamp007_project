appendName = "gbm_xgboost"
submission_1 = read.csv('./Results/Nominees/xgbTree_submission.csv')
submission_2 = read.csv('./Results/Nominees/gbm_submission.csv')

ensemble_loss = (submission_1$loss + submission_2$loss) / 2
ids = submission_1$id

ensemble = data.frame(id = ids, loss = ensemble_loss)

write.csv(ensemble, paste0('./Results/Nominees/ensemble_',appendName,'.csv'), row.names = FALSE)