library(dplyr)
library(ggplot2)
setwd("/Users/dmirij/Desktop/VIS_PROJECT")
mydata = read.csv(file = "U.S._Chronic_Disease_Indicators__CDI_.csv")
##################################################################################
####### trend in mammography use #################################################
subset1 = mydata[mydata$LocationDesc == "United States", ]
subset2 = subset1[subset1$Topic=="Cancer", ]
subset3 = subset2[subset2$Question=="Mammography use among women aged 50-74 years", ]
subset4 = subset3[subset3$DataValueType=="Crude Prevalence", ]
subset5 =select(subset4,YearStart,LocationAbbr,DataValueUnit,DataValue)
subset6 = mutate(subset5,number=as.numeric(as.character(DataValue)))
## plot with defined point size and line thickness
b = ggplot(data=subset6, aes(YearStart, number)) + geom_line(size = 2) + geom_point(size = 6)
## show years as integer values in plot x-axis
bb = b + scale_x_continuous(breaks=c(2012,2013,2014))
##label things
bbb = bb + ylab("%") + xlab("year") + labs(title = "mammography use among women age 50-74")
## set the size of labels and title
bbbb = bbb + theme(axis.text=element_text(size=18),axis.title=element_text(size=20,face="bold"), title=element_text(size=22,face="bold") )
bbbb
#################################################################################
############look for US mortality data for types of cancers avg (2008-2012)######
mortal1 = mydata[mydata$LocationDesc == "United States", ]
mortal2 = mortal1[grepl('mortality', as.character(mortal1$Question)), ]
mortal3 = mortal2[mortal2$Topic=="Cancer", ]
mortal4 = mortal3[mortal3$DataValueTypeID=="AvgAnnCrdRate", ]
mortal5=select(mortal4,Question,DataValue)
mortal6 = mutate(mortal5,number=as.numeric(as.character(DataValue)))
mortal7 = mortal6[ ! mortal6$DataValue == "185.5", ]
mortal8 = arrange(mortal7, desc(number))
#RENAME the levels in the Questions factor (first have to add the new name to the list)
levels(mortal8$Question) <- c(levels(mortal8$Question), "lung and bronchus")
mortal8$Question[mortal8$Question=="Cancer of the lung and bronchus, mortality"
                 ] = "lung and bronchus"

levels(mortal8$Question) <- c(levels(mortal8$Question), "female breast")
mortal8$Question[mortal8$Question=="Cancer of the female breast, mortality"] = "female breast"

levels(mortal8$Question) <- c(levels(mortal8$Question), "prostate")
mortal8$Question[mortal8$Question=="Cancer of the prostate, mortality"] = "prostate"

levels(mortal8$Question) <- c(levels(mortal8$Question), "colorectal")
mortal8$Question[mortal8$Question=="Cancer of the colon and rectum (colorectal), mortality"] = "colorectal"

levels(mortal8$Question) <- c(levels(mortal8$Question), "Melanoma")
mortal8$Question[mortal8$Question=="Melanoma, mortality"] = "Melanoma"

levels(mortal8$Question) <- c(levels(mortal8$Question), "oral and pharynx")
mortal8$Question[mortal8$Question=="Cancer of the oral cavity and pharynx, mortality"] = "oral and pharynx"

levels(mortal8$Question) <- c(levels(mortal8$Question), "female cervix")
mortal8$Question[mortal8$Question=="Cancer of the female cervix, mortality"] = "female cervix"
################ Done with renaming ########################
g = ggplot(data=mortal8, aes(Question, number)) + geom_bar(stat = "identity")
###flip coordinates, add labels and title
gg = g + coord_flip() + ylab("mortality per 100,000 people") + xlab("type of cancer") + labs(title = "Cancer Mortality")
###make the size of the labels and title bigger and do bolding
ggg=gg + theme(axis.text=element_text(size=18),axis.title=element_text(size=20,face="bold"), title=element_text(size=24,face="bold") )
ggg 
