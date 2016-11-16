library(dplyr)
library(Hmisc)
library(VIM)
library(car)
library(neuralnet)
data.Interest<-read.csv("Interest Rates, Discount Rate for United States.csv")
Ist<-data.Interest
Ist$DATE<-as.Date(Ist$DATE)
List<-list.files()
for (i in 1:length(List)){
  temp<-read.csv(List[i])
  temp[,1]=as.Date(temp[,1])
  temp[,2]=as.numeric(temp[,2])
  Ist<-left_join(Ist,temp)
}
column.name<-List

library(VIM)
aggr(Ist)
library(mice)
md.pattern(Ist)
which(is.na(Ist$DATE))
Ist[,4]
LST<-c("Date","Interest.Rate","LIBOR.Lodon","one.yr.Treasury.Rate","ten.yr.T.Rate","T.bill.MRate","Employee.payroll","Em_Pop.rate","LFP.rate","unem.rate","BankLoan","ConsumerPrice",
       "Brent.Oil","Taxas.Oil","Debt.rates","GDP_CHN","PrivateInvest","New.House.Start","Industrial.Index","Inflation","Light.vehicle.sale","Manufacturing.output",
       "Bond.Yield","NASDAQ","NetExport","NewHouse.permit","Psaving.rate","Disposable.income","RealExport","Personal.Consumption.Expenditures","RGDP",
       "Home.Price.Index","SP500","Stock.Capitalization.to.GDP","Total.Vehicle.Sales","U.S.Dollar.Index","US_Euro","Unemployment.Level","M1.velocity","M2.velocity")

names(Ist)=LST
write.csv(Ist,"Ist_mannul.csv")
Ist.select<-Ist[,-3]   ##LIBOR.Lodon removed
aggr(Ist.select)
Ist.select<-select(Ist.select,-Brent.Oil,-Taxas.Oil)
aggr(Ist.select)
####check first non-missing for each variable
for (i in 1:length(names(Ist.select))){
  for (j in 1:nrow(Ist.select)){
    if (is.na(Ist.select[j,i])==FALSE){
      cat(names(Ist.select)[i],j,"\n")
      break
    } 
  }
}
##Home.Price.Index,US_Euro,SP500,Home.Price.Index,Manufacturing.output,NASDAQ removed
Ist.select<-select(Ist.select,-Home.Price.Index,-US_Euro,-SP500,-Home.Price.Index,-Manufacturing.output,-NASDAQ)
Ist.complete.annual<-Ist.select[complete.cases(Ist.select),]
model.annual<-lm(Interest.Rate~ .-Date, data = Ist.complete.annual)
summary(model.annual)
library(car)
vif(model.annual)
avPlots(model.annual)

###huge colinearity,remove some variable caused by Interest rate
Ist.select_2<-select(Ist.select,-ten.yr.T.Rate,-one.yr.Treasury.Rate,-Bond.Yield,-T.bill.MRate)
Ist.complete.annual_2<-Ist.select_2[complete.cases(Ist.select_2),]
model.annual_2<-lm(Interest.Rate~ .-Date, data = Ist.complete.annual_2)
summary(model.annual_2)
vif(model.annual_2)
avPlots(model.annual_2)
AIC(model.annual_2)
library(ggplot2)
library(ggthemes)

###remove some similar variable Em_Pop.rate,Light.vehicle.sale 
Ist.select_3<-select(Ist.select_2,-Unemployment.Level,-Em_Pop.rate,-Light.vehicle.sale,-Employee.payroll,-LFP.rate,-NewHouse.permit,-Inflation)
Ist.complete.annual_3<-Ist.select_3[complete.cases(Ist.select_3),]
model.annual_3<-lm(Interest.Rate~ .-Date, data = Ist.complete.annual_3)
summary(model.annual_3)
vif(model.annual_3)
avPlots(model.annual_3)
AIC(model.annual_3)
####remove annual data not afacting the interest GDP_CHN,Stock.Capitalization.to.GDP
Ist.select_4<-select(Ist.select_3,-GDP_CHN,-Stock.Capitalization.to.GDP,-M2.velocity,-Industrial.Index,-ConsumerPrice,-NetExport,-Debt.rates)
Ist.complete_4<-Ist.select_4[complete.cases(Ist.select_4),]
model.season_4<-lm(Interest.Rate~ .-Date, data = Ist.complete_4)
summary(model.season_4)
vif(model.season_4)
avPlots(model.season_4)
AIC(model.season_4)

#### remove some viriable estimated important
Ist.select_final<-select(Ist.select_4,-PrivateInvest,-Disposable.income,-Psaving.rate,-New.House.Start,-M1.velocity)
Ist.complete_final<-Ist.select_final[complete.cases(Ist.select_final),]
#Ist.train<-Ist.select_final[1:781]
model.season_final<-lm(Interest.Rate~ .-Date, data = Ist.complete_final)
summary(model.season_final)

vif(model.season_final)
avPlots(model.season_final)
AIC(model.season_final)
plot(model.season_final)

###predict insterest 2016
newdata<-Ist.select_final[793:801,-2]
interest.predict<-predict(model.season_final,newdata)
interest.real<-Ist.select_final[793:801,2]
table(interest.predict,interest.real)
test<-data.frame("Date"=Ist.complete_final$Date,"Interest.Rate.Predict"=model.season_final$fitted.values,"Interest.Rate.Real"=Ist.complete_final$Interest.Rate)
library(reshape2)
test.melt<-melt(test,id="Date",measure.vars = c("Interest.Rate.Real","Interest.Rate.Predict"))
ggplot(test.melt)+geom_bar(aes(x=Date,y=value,fill=variable),stat = "identity",position = "dodge")+
  theme_economist() + scale_fill_economist()+labs(x="Date",y="Interest Rate",fill="Real V.S Prediction")

####Classfication
generator<-function(x){
  y=c()
  for (i in 1:length(x)){
    if (i==length(x)){
      y[i]<-NA
      break
    }
    else if (x[i] == x[i+1]){
      y[i]<-0
    }
    else {
      y[i]=1
      }
  }
  return(y)
}

generator.2<-function(x){
  y=c()
  for (i in 1:length(x)){
    if (i==length(x)){
      y[i]<-NA
      break
    }
    else if (x[i] == x[i+1]){
      y[i]<-0
    }
    else if (x[i] < x[i+1]){
      y[i]=1
    }
    else if (x[i] > x[i+1]){
      y[i]=-1
    }
  }
  return(y)
}
Ist.class.2<-mutate(Ist.complete_final,IR=as.factor(generator.2(Interest.Rate)))
Ist.class.2<-Ist.class.2[,-c(1,2)]
library(nnet)
model.class<-multinom(IR~ .,data = Ist.class.2)
plot(Ist.class.2)
summary(model.class)
model.class$fitted.values
test.class<-data.frame(Ist.class.2[163,1:7])
predict(model.class,test.class,"probs")



model.class.reduce<-glm(IR ~ unem.rate+RGDP+U.S.Dollar.Index+Total.Vehicle.Sales,family = "binomial",data = Ist.class.2)
pchisq(model.class.reduce$deviance,model.class.reduce$df.residual,lower.tail = FALSE)
summary(model.class.reduce)
#generator(Ist.complete_final$Interest.Rate)
Ist.class<-mutate(Ist.complete_4,IR=as.factor(generator(Interest.Rate)))
Ist.class.1<-Ist.class[,-c(1,2)]
plot(Ist.class.1)
library(neuralnet)
model.class<-glm(IR~ .,family = "binomial",data = Ist.class.1)
#ggplot()+geom_point(data=Ist.select,aes(x=Date, y=Interest.Rate+one.yr.Treasury.Rate,fill='Interest.Rate'))+theme_economist() + scale_fill_economist()
#ggplot(Ist.select,aes(x=one.yr.Treasury.Rate, y=Interest.Rate))+geom_point()
summary(model.class)
vif(model.class)
model.class.reduce<-glm(IR ~ New.House.Start,family = "binomial",data = Ist.class.1)
summary(model.class.reduce)
vif(model.class.reduce)
pchisq(model.class.reduce$deviance,model.class.reduce$df.residual,lower.tail = FALSE)
1-model.class.reduce$deviance/model.class.reduce$null.deviance
set.seed(1)
concrete_model = neuralnet(IR ~ unem.rate + BankLoan + U.S.Dollar.Index +     #Cannot use the shorthand
                             RealExport + Personal.Consumption.Expenditures + #dot (.) notation.
                             RGDP + Total.Vehicle.Sales,
                           hidden = 1, #Default number of hidden neurons.
                           data = Ist.class.2)
plot(concrete_model)
table(Ist.class$IR,concrete_model$response)




####redo the classification using monthly data

Ist.month.class<-Ist[,c(2,3,9,10,11,12,13,20)]

Ist.month.class.more.va.1<-Ist[110:801,c(2,3,9,10,11,12,13,20,28,29,31)]
Ist.month.class.more.va.2<-Ist[313:801,c(2,3,9,10,11,12,13,20,28,29,31,14,19,22,36,37,39)]

aggr(Ist.month.class)
Ist.month.class.bc<-mutate(Ist.month.class,IR=as.factor(generator(Interest.Rate)))[,-c(1,2)]

Ist.month.class.more.va.1.bc<-mutate(Ist.month.class.more.va.1,IR=as.factor(generator(Interest.Rate)))[,-c(1,2)]
Ist.month.class.more.va.2.bc<-mutate(Ist.month.class.more.va.2,IR=as.factor(generator(Interest.Rate)))[,-c(1,2)]
###### binary model using glm 
model.month.class.bc<-glm(IR ~ ., family = "binomial",data = Ist.month.class.bc)
model.month.class.bc.more.va.1<-glm(IR ~ ., family = "binomial",data = Ist.month.class.more.va.1.bc)
model.month.class.bc.more.va.2<-glm(IR ~ ., family = "binomial",data = Ist.month.class.more.va.2.bc)
summary(model.month.class.bc)
vif(model.month.class.bc)

model.month.class.bc.re<-glm(IR~. -LFP.rate -ConsumerPrice -Industrial.Index, family = "binomial",data = Ist.month.class.bc)
summary(model.month.class.bc.re)
vif(model.month.class.bc.re)
pchisq(model.month.class.bc.re$deviance,model.month.class.bc.re$df.residual,lower.tail = FALSE)
##0.0046
1-model.month.class.bc.re$deviance/model.month.class.bc.re$null.deviance
##0.061
result.pre.bc<-predict(model.month.class.bc.re, Ist.month.class.bc[,-7], type = "response")
table(Ist.month.class.bc$IR,round.generator(result.pre.bc,0.3))



summary(model.month.class.bc.more.va.1)
vif(model.month.class.bc.more.va.1)
###Only LFP.rate,BankLoan,Industrial.Idex
model.month.class.bc.more.va.1.re<-glm(IR~ .-Em_Pop.rate -ConsumerPrice -Psaving.rate -unem.rate -Disposable.income -Personal.Consumption.Expenditures, family = "binomial",data = Ist.month.class.more.va.1.bc)
vif(model.month.class.bc.more.va.1.re)
summary(model.month.class.bc.more.va.1.re)
pchisq(model.month.class.bc.more.va.1.re$deviance,model.month.class.bc.more.va.1.re$df.residual,lower.tail = FALSE)
#####0.002014806639
1-model.month.class.bc.more.va.1.re$deviance/model.month.class.bc.more.va.1.re$null.deviance
###0.0355555


summary(model.month.class.bc.more.va.2)
vif(model.month.class.bc.more.va.2)
model.month.class.bc.more.va.2.re<-glm(IR~. -Em_Pop.rate -Total.Vehicle.Sales -Unemployment.Level-Industrial.Index
                                       -Psaving.rate -Brent.Oil -Light.vehicle.sale -unem.rate -Disposable.income
                                       -ConsumerPrice -U.S.Dollar.Index, family = "binomial",data = Ist.month.class.more.va.2.bc)
#####only LFP,Bank Loan,Personal.Consumption.Expenditures,New.House.Start
summary(model.month.class.bc.more.va.2.re)
vif(model.month.class.bc.more.va.2.re)
influencePlot(model.month.class.bc.more.va.2.re)
pchisq(model.month.class.bc.more.va.2.re$deviance,model.month.class.bc.more.va.2.re$df.residual,lower.tail = FALSE)
##0.6256334512
1-model.month.class.bc.more.va.2.re$deviance/model.month.class.bc.more.va.2.re$null.deviance
##0.1276680975

result.pre<-predict(model.month.class.bc.more.va.2.re, Ist.month.class.more.va.2.bc[,-16], type = "response")
#model.month.class.bc.more.va.2.re<-glm(IR~ LFP.rate + BankLoan + Personal.Consumption.Expenditures + New.House.Start,
#                                       family = "binomial",data = Ist.month.class.more.va.2.bc)

round.generator<-function(x,n){
  for(i in 1:length(x)){
    if(x[i]>=n){
      y[i]=1
    }
    else {
      y[i]=0
    }
  }
  return(y)
}
table(Ist.month.class.more.va.2.bc$IR,round.generator(result.pre,0.35))


model.month.class.bc.re<-glm(IR ~ BankLoan + ConsumerPrice,family = "binomial",data = Ist.month.class.bc)
summary(model.month.class.bc.re)
vif(model.month.class.bc.re)
influencePlot(model.month.class.bc.re)
pchisq(model.month.class.bc.re$deviance,model.month.class.bc.re$df.residual,lower.tail = FALSE)
###0.0001633084769 bad model

###### binary model using neural network
normalize = function(x) { 
  return((x - min(x)) / (max(x) - min(x)))
}

#We now apply our normalization function to all the variables within our dataset;
#we store the result as a data frame for future manipulation.
Ist.month.class.bc_norm = as.data.frame(lapply(Ist.month.class.bc[,1:6], normalize))
Ist.month.class.bc_norm$IR=as.numeric(Ist.month.class.bc$IR)
Ist.month.class.bc_norm_train<-Ist.month.class.bc_norm[2:500,]
Ist.month.class.bc_norm_test<-Ist.month.class.bc_norm[501:801,]
set.seed(1)
model.month.bc.nn = neuralnet(IR~ Em_Pop.rate + LFP.rate + unem.rate + BankLoan + ConsumerPrice + Industrial.Index,
                              hidden = 3,#Default number of hidden neurons.
                           data = Ist.month.class.bc_norm_train)
results<-neuralnet::compute(model.month.bc.nn,Ist.month.class.bc_norm_test[,1:6])

plot(model.month.bc.nn)
table(Ist.month.class.bc_norm_test$IR[501:801],model_results)
model.month.bc.nn.re = neuralnet(IR~ BankLoan + ConsumerPrice,
                              hidden = 3,#Default number of hidden neurons.
                              data = Ist.month.class.bc_norm_train)

results.re<-neuralnet::compute(model.month.bc.nn.re,Ist.month.class.bc_norm_test[,4:5])

model.class<-multinom(IR~ .,data = Ist.class.2)
plot(Ist.class.2)
summary(model.class)
model.class$fitted.values
test.class<-data.frame(Ist.class.2[163,1:7])
predict(model.class,test.class,"probs")

