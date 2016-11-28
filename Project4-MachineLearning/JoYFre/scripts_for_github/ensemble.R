stack_xgb <- data.frame(data.table::fread("stack_minifeat2_opt.csv"))
stack_nnet <- data.frame(data.table::fread("stack_nnet.csv"))
submission_xgb <- data.frame(data.table::fread("submission_minifeat2_opt.csv"))
submission_nnet <- data.frame(data.table::fread("submission_nnet.csv"))
stack_nnet <- stack_nnet[order(stack_nnet$id),]


test_id<- readRDS("test_id.RDS")

new_submission <- data.frame(id = test_id, loss = 0.5*submission_xgb$loss + 0.5*submission_nnet$loss)
write.csv(new_submission, "submission_stack.csv", row.names = FALSE)
