library(dplyr)
library(ggplot2)
setwd("/Users/dmirij/Desktop/VIS_PROJECT")
mydata = read.csv(file = "U.S._Chronic_Disease_Indicators__CDI_.csv")
###diabetes diagnosis in adults - line plot #############
dset1 = mydata[mydata$LocationDesc == "United States", ]
dset2 = dset1[dset1$Topic=="Diabetes", ]
dset3 = dset2[dset2$StratificationCategory1=="Overall", ]
dset4 = dset3[dset3$DataValueType=="Crude Prevalence", ]
dset5=dset4[dset4$Question=="Prevalence of diagnosed diabetes among adults aged >= 18 years", ]
dset6 = mutate(dset5,number=as.numeric(as.character(DataValue)))
d = ggplot(data=dset6, aes(YearStart, number)) + geom_line(size = 2) + geom_point(size = 6)
dd = d + scale_x_continuous(breaks=c(2012,2013,2014))
ddd = dd + ylab("%") + xlab("year") + labs(title = "diabetes diagnosis among adults")
dddd = ddd + theme(axis.text=element_text(size=18),axis.title=element_text(size=20,face="bold"), title=element_text(size=22,face="bold") )
dddd
#########################################################
###looking for state wise map of diabetes in 2014
library(googleVis)
diab1 = mydata[mydata$Topic=="Diabetes", ]
diab2 = diab1[diab1$Question=="Prevalence of diagnosed diabetes among adults aged >= 18 years", ]
diab3=diab2[diab2$StratificationCategory1=="Overall", ]
diab4=diab3[diab3$DataValueType=="Crude Prevalence", ]
diab5=diab4[diab4$YearStart==2014, ]
diab6=select(diab5,LocationDesc,DataValue)
write.csv(diab6, file = "diab_state_pre.csv")
###run upto here and write out diab6. copy diab_state_pre.csv to diab_state.csv
###and delete the id column.  read back in diab_state.csv. 
###(I'll figure out a better way to do this)
diab_state=read.csv(file="diab_state.csv")

state_em <- gvisGeoChart(diab_state, "LocationDesc", "DataValue", 
                         options=list(region="US", 
                                      displayMode="regions", 
                                      resolution="provinces",
                                      colorAxis="{colors: ['blue', 'white', 'red']}"))
plot(state_em)
#########################################################################
##Prevalence of depressive disorders among adults with diagnosed diabetes
##State wise map
dep1=mydata[mydata$Question=="Prevalence of depressive disorders among adults aged >= 18 years with diagnosed diabetes", ]
dep2 = dep1[dep1$StratificationCategory1=="Overall", ]
dep3 = dep2[dep2$DataValueType=="Crude Prevalence", ]
dep4 = dep3[dep3$YearStart==2014, ]
dep5=select(dep4,LocationDesc,DataValue)
write.csv(dep5,file="depression_state1.csv")
###run upto here and write out diab6. copy depression_state1.csv to depression_state.csv
###and delete the id column.  read back in depression_state.csv. 
###(I'll figure out a better way to do this)
depression_state=read.csv(file="depression_state.csv")
state_em <- gvisGeoChart(depression_state, "LocationDesc", "DataValue", 
                         options=list(region="US", 
                                      displayMode="regions", 
                                      resolution="provinces",
                                      colorAxis="{colors: ['green', 'white', 'red']}"))
plot(state_em)
#########################################################################


