#after pre-processing as per our common preprocessing script, just that I have name the logged loss
# variable loss1

set.seed(0)
inTrain1<- createDataPartition(y=new.all.cd.train$loss1, p=0.80, list=FALSE, times=1)

# it doesn't matter which in Train since it's the same variable just transformed
training<-new.all.cd.train[inTrain1,]
dim(training)
testing<-new.all.cd.train[-inTrain1,]
dim(testing)

# tried 3 different specifications - the first two (all variables, and omitting variables that 
# were ommitted by R - had NA instead of coefficeints) produce the following warnings 
# "prediction from a rank deficient fit may be misleading"  - this is can occur because of 
# multicollinearity or if we are trying to fit more parameters than avilable variables - for a more
# detailed explanation read this:
# http://stackoverflow.com/questions/26558631/predict-lm-in-a-loop-warning-prediction-from-a-rank-deficient-fit-may-be-mis

# To get rid of this problem I fitted model 3 in which I eliminated both the variables omitted by R
# and those that were not significant at least at the 90% confidence level
lmFit1<-train(loss1~., data=training, method='lm')
summary(lmFit1)

lmFit1adj2 <- train(loss1~. - cat114.OTHER -cat111.OTHER -cat103.OTHER -cat101.OTHER
                    -cat102.OTHER -cat90.OTHER -cat89.OTHER, data=training, method='lm')
summary(lmFit1adj2)

lmFit1adj3 <- train(loss1~. - cat114.OTHER -cat111.OTHER -cat103.OTHER -cat101.OTHER
                    -cat102.OTHER -cat90.OTHER -cat89.OTHER -cat6.B -cat8.B -cat10.B
                    -cat10.B -cat15.B -cat19.B -cat19.B -cat24.B -cat30.B -cat33.B 
                    -cat43.B -cat45.B -cat46.B -cat58.B -cat60.B -cat62.B -cat64.B
                    -cat66.B -cat68.B -cat69.B -cat70.B -cat81.OTHER -cat82.B -cat82.B
                    -cat83.B -cat84.OTHER -cat86.D -cat88.D -cat88.OTHER -cat92.OTHER
                    -cat96.OTHER -cat97.C -cat97.E -cat97.OTHER -cat98.C -cat98.D
                    -cat98.OTHER -cat99.R -cat99.T -cat100.I -cat104.F -cat104.G -cat104.H 
                    -cat104.K -cat104.OTHER -cat105.E -cat105.F -cat105.H -cat106.F
                    -cat106.G -cat106.J -cat107.H -cat108.F -cat108.G -cat108.G -cat109.BI
                    -cat109.OTHER -cat110.CL -cat110.CO -cat110.EG -cat110.OTHER -cat113.AX
                    -cat113.OTHER -cat115.K -cat115.L -cat115.L -cat115.M -cat115.N -cat115.N
                    -cat115.O -cat115.OTHER -cat115.P -cont3 -cont5 -cont6 -cont13, 
                    data=training, method='lm')
summary(lmFit1adj3)

lmImp1 <- varImp(lmFit1, scale = FALSE)
lmImp1

lmImp2 <- varImp(lmFit1adj2, scale = FALSE)
lmImp2

lmImp3 <- varImp(lmFit1adj3, scale = FALSE)
lmImp3

mean(lmFit1$resample$RMSE)
mean(lmFit1adj3$resample$RMSE)
mean(lmFit1adj2$resample$RMSE)

predicted3 <- predict(lmFit1, testing)
predicted2 <- predict(lmFit1adj2, testing)
predicted3 <- predict(lmFit1adj3, testing)

RMSE(pred = predicted1, obs = testing$loss1)
RMSE(pred = predicted2, obs = testing$loss1)
RMSE(pred = predicted3, obs = testing$loss1)

# in general the RMSE does not go below 0.5053

mae <- function(error)
{
  mean(abs(error))
}

error.3 <- predicted3 - testing1$loss1
mae(error.3) # 0.397099

error.2 <- predicted2 - testing1$loss1
mae(error.2) # 0.3969672

error.1 <- predicted1 - testing1$loss1
mae(error.1) # 0.3969672

