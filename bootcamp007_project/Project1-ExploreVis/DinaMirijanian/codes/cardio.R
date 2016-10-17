library(dplyr)
library(ggplot2)
setwd("/Users/dmirij/Desktop/VIS_PROJECT")
mydata = read.csv(file = "U.S._Chronic_Disease_Indicators__CDI_.csv")
###cardio mortality - line plot #############
card1=mydata[mydata$Topic=="Cardiovascular disease" | mydata$Topic=="Cardiovascular Disease", ]
card2=card1[card1$LocationDesc == "United States", ]
card3=card2[card2$Question == "Mortality from total cardiovascular disease", ]
card4=card3[card3$DataValueType == "Number", ]
card5 = select(card4,YearStart,DataValue)
card6 = mutate(card5,number=as.numeric(as.character(DataValue)))
c = ggplot(data=card6, aes(YearStart, number)) + geom_line(size = 2) + geom_point(size = 6)
cc = c + scale_x_continuous(breaks=c(2010,2011,2012,2013,2014))
ccc = cc + ylab("number of deaths") + xlab("year") + labs(title = "mortality from cardiovascular disease")
cccc = ccc + theme(axis.text=element_text(size=18),axis.title=element_text(size=20,face="bold"), title=element_text(size=22,face="bold") )
cccc
##################################################################################
######Cardio mortality state wise in 2014
library(googleVis)
ccard2 = card1[card1$Question == "Mortality from total cardiovascular disease", ]
ccard3 = ccard2[ccard2$YearStart == 2014, ]
ccard4 = ccard3[ccard3$Stratification1 == "Overall", ]
ccard5 = ccard4[ccard4$DataValueType == "Crude Rate", ]
ccard6=select(ccard5,LocationDesc,DataValue)
write.csv(ccard6, file = "cardio_state_pre.csv")
###run upto here and write out ccard6. copy  cardio_state_pre.csv to cardio_state.csv
###and delete the id column.  read back in cardio_state.csv. 
###(I'll figure out a better way to do this)
cardio_state=read.csv(file="cardio_state.csv")

state_em <- gvisGeoChart(cardio_state, "LocationDesc", "DataValue", 
                         options=list(region="US", 
                                      displayMode="regions", 
                                      resolution="provinces",
                                      colorAxis="{colors: ['blue', 'white', 'red']}"))
plot(state_em)



