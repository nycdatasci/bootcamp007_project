library(FactoMineR)

dt <- readRDS("dt.RDS")
dt <- dt[,-1]
set.seed(123)
idx10 <- sample(1:nrow(dt), 0.1*nrow(dt))
dt10 <- dt[idx10,]
mfa10 <- FAMD(dt10, ncp = 1300)

barplot(mfa10$eig[,1], names.arg = 1:length(mfa10$eig[,1]))

plot(x= 1:length(mfa10$eig[,1]), y= mfa10$eig[,1], ylab = "Eigen Values", xlab = "Multiple Factor Analysis")
abline(h=1, col="red")
