rm(list = setdiff(ls(), lsf.str()))
library(MASS) #The Modern Applied Statistics library.
library(car)
setwd("~/Coding/NYC_Data_Science_Academy/bootcamp007_project/Project3-WebScraping/NickTalavera")
setwd('/Volumes/SDExpansion/Data Files/Xbox Back Compat Data')
dataUltKNN  = read.csv('dataUltKNN.csv', stringsAsFactors = TRUE)
dataUltKNN$X = NULL
dataUltKNN$releaseDate = as.Date(dataUltKNN$releaseDate)
lapply(dataUltKNN, class)
model.empty = lm(isBCCompatible ~ 1, data = dataUltKNN) #The model with an intercept ONLY.
model.full = lm(isBCCompatible ~ . -genre -developer -features -isBCCompatible -gameName, data = dataUltKNN) #The model with ALL variables.
summary(model.full)
scope = list(lower = formula(model.empty), upper = formula(model.full))

forwardAIC = step(model.full, scope, direction = "forward", k = sqrt(nrow(dataUltKNN)))
summary(forwardAIC)
plot(forwardAIC)
influencePlot(forwardAIC)
vif(forwardAIC)
avPlots(forwardAIC)

confint(forwardAIC)
notBCYet = dataUltKNN[dataUltKNN$isBCCompatible == FALSE,]
cPredict = predict(forwardAIC, notBCYet, interval = "confidence") 
pPredict = predict(forwardAIC, notBCYet, interval = "prediction")

