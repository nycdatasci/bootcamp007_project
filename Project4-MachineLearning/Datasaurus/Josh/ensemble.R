
submission_1 = read.csv('../Results/h2o_blend.csv')
submission_2 = read.csv('../Results/xgb_starter_v7.sub.csv')

ensemble_loss = (submission_1$loss + submission_2$loss) / 2
ids = submission_1$id

ensemble = data.frame(id = ids, loss = ensemble_loss)

write.csv(ensemble, '../Results/ensemble_better.csv', row.names = FALSE)
