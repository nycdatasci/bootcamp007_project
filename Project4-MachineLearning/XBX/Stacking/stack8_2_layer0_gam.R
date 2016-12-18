setwd("c:/Users/Xinyuan Wu/Desktop/Xinyuan's Repo/kaggle_Project")
library(caret)

## get framework
result <- read.csv("stack/test_encode2.csv")
e1_rf <- read.csv("stack/proc_s_RF_t.csv")
e1_xb <- read.csv("stack/proc_s_XGB2_t.csv")
e2_rf <- read.csv("stack/proc2b_s_RF_t.csv")
e2_xb <- read.csv("stack/proc2b_s_XGB2_t_n2235.csv")

df <- data.frame(loss = result$loss,
                 e1_rf = e1_rf$loss,
                 e1_xb = e1_xb$loss,
                 e2_rf = e2_rf$loss,
                 e2_xb = e2_xb$loss)

mean(abs(df$loss - df$e1_rf))   ### 1232.126
mean(abs(df$loss - df$e1_xb))   ### 1228.839
mean(abs(df$loss - df$e2_rf))   ### 1203.277
mean(abs(df$loss - df$e2_xb))   ### 1191.811

e1_rf_s <- read.csv("Prediction/proc_RF_submit_1263_ntree1000.csv")
e1_xb_s <- read.csv("Prediction/proc_XGB2_1209.csv")
e2_rf_s <- read.csv("Prediction/proc2b_s_RF_tAll.csv")
e2_xb_s <- read.csv("Prediction/proc2b_s_XGB2_tAll_n2235_1173.csv")

df_s <- data.frame(e1_rf = e1_rf_s$loss, 
                   e1_xb = e1_xb_s$loss,
                   e2_rf = e2_rf_s$loss,
                   e2_xb = e2_xb_s$loss)

## train gam
stack_gam <- train(log(loss) ~ ., method = "gam", data = df)
pred_t_layer0 <- exp(predict(stack_gam, df))
mean(abs(df$loss - pred_t_layer0))   ### 1131.987

pred_s_layer0 <- exp(predict(stack_gam, newdata = df_s))

# write.csv(data.frame(pred),
#           file = 'pred_t_layer0_gam.csv', row.names = F)
# write.csv(data.frame(pred_s), 
#           file = 'pred_s_layer0_gam.csv', row.names = F)







