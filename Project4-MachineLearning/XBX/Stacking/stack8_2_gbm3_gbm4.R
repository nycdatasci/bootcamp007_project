coef1 <- seq(0.25, 0.75, 0.25)
coef2 <- seq(0.75, 0.25, -0.25)

pred_s
pred_s_layer0

try1 <- coef1[1]*pred_s + coef2[1]*pred_s_layer0
try2 <- coef1[2]*pred_s + coef2[2]*pred_s_layer0
try3 <- coef1[3]*pred_s + coef2[3]*pred_s_layer0

submission <- read.csv("Prediction/sample_submission.csv")
submission$loss <- as.numeric(try2)
write.csv(submission, file = 'submissionNov26_gbm3_gbm4_0.5.csv', row.names = F)
