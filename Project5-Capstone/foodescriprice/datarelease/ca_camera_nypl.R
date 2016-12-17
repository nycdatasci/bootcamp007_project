# the main regression for the NYPL dataset, predicting $ versus $$ from the variables of interest

library(car)
rests=read.table("ca_final_nypl.out")
attach(rests)

rests$cheap= (rests$price=="$")
rests$exp= (rests$price=="$$")
rests$logwordlen = log(rests$avgwordlen+1)
rests$loglength = log(rests$numwords+1)
rests$adj = log(rests$adj+1)
rests$choice = log(rests$choice+1)
rests$traditional = log(rests$traditional+1)
rests$origin = log(rests$origin+1)
rests$generous = log(rests$generous+1)
rests$useless = log(rests$useless+1)
rests$sensoryadj = log(rests$sensoryadj+1)
rests$delicious = log(rests$delicious+1)
rests$vague = rests$useless
rests$provenance= rests$origin

rests$adjresid = residuals(lm(rests$adj ~ rests$loglength))
rests$choiceresid = residuals(lm(rests$choice ~ rests$loglength))
rests$traditionalresid = residuals(lm(rests$traditional ~ rests$loglength))
rests$originresid = residuals(lm(rests$origin ~ rests$loglength))
rests$generousresid = residuals(lm(rests$generous ~ rests$loglength))
rests$uselessresid = residuals(lm(rests$useless ~ rests$loglength))
rests$sensoryadjresid = residuals(lm(rests$sensoryadj ~ rests$loglength))
rests$deliciousresid = residuals(lm(rests$delicious ~ rests$loglength))
attach(rests)

m = glm(formula = rests$exp ~ avgwordlen + loglength + choiceresid + traditionalresid + adjresid, family = "binomial")
summary(m)
