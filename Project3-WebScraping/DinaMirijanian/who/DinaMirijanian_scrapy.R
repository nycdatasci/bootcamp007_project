setwd("~//Desktop/scrape-project/who/")
mydata = read.csv("listing.v1.csv",stringsAsFactors = FALSE)
mydata[mydata==" "]=NA  #make all empty cells NA
head(mydata)
class(mydata$total_population)
#remove the "," in the thousand etc. place holder.  Make everything except country numeric
mydata[] <- lapply(mydata, function(x) gsub("\\,", "", as.character(x)))
mydata$total_population = as.numeric(mydata$total_population)
mydata$p_15_60_m = as.numeric(mydata$p_15_60_m)
mydata$p_15_60_f = as.numeric(mydata$p_15_60_f)
mydata$health_per_capita = as.numeric(mydata$health_per_capita)
mydata$gnipc = as.numeric(mydata$gnipc)
mydata$life_ex_birth_m = as.numeric(mydata$life_ex_birth_m)
mydata$life_ex_birth_f = as.numeric(mydata$life_ex_birth_f)
mydata$expend_health_GDP = as.numeric(mydata$expend_health_GDP)
mydata$p_dying_five <- NULL
summary(mydata)
library(VIM)
##graphical EDA of mydata
aggr(mydata)
#plot(mydata)
plot(mydata$life_ex_birth_m,mydata$life_ex_birth_f)
plot(mydata$life_ex_birth_m,log(mydata$health_per_capita))
plot(mydata$life_ex_birth_m,log(mydata$gnipc))
plot(mydata$total_population)
##Plots
#countries with top 10 life_ex_birth_m
library(dplyr)
mydata1 = arrange(mydata,  desc(life_ex_birth_m))
mydata1.cut10 = mydata1[1:10,]
mydata1.cut10
library(ggplot2)
mydata1.cut10$country <- factor(mydata1.cut10$country, levels = mydata1.cut10$country[order(mydata1.cut10$life_ex_birth_m)])
g1 = ggplot(mydata1.cut10, aes(country,life_ex_birth_m))
g2 =g1 + geom_bar(stat="identity", fill = mydata1.cut10$life_ex_birth_m) + coord_flip()
g3 = g2 +ylab("male life expectancy") + xlab("country")
g3 + theme(axis.text=element_text(size=18),axis.title=element_text(size=20,face="bold"), title=element_text(size=20,face="bold"))
#countries with bottom 10 life_ex_birth_m
mydata2 = arrange(mydata, (life_ex_birth_m))
mydata2.cut10 = mydata2[1:10,]
mydata2.cut10
mydata2.cut10$country <- factor(mydata2.cut10$country, levels = mydata2.cut10$country[order(mydata2.cut10$life_ex_birth_m)])
p1 = ggplot(mydata2.cut10, aes(country,life_ex_birth_m))
p2 =p1 + geom_bar(stat="identity", fill = mydata2.cut10$life_ex_birth_m) + coord_flip()
p3 = p2 +ylab("male life expectancy") + xlab("country")
p3 + theme(axis.text=element_text(size=18),axis.title=element_text(size=20,face="bold"), title=element_text(size=20,face="bold"))
#countries with top 10 expend_health_GDP
mydata3 = arrange(mydata,  desc(expend_health_GDP))
mydata3.cut10 = mydata3[1:10,]
mydata3.cut10
mydata3.cut10$country <- factor(mydata3.cut10$country, levels = mydata3.cut10$country[order(mydata3.cut10$expend_health_GDP)])
b1 = ggplot(mydata3.cut10, aes(country,expend_health_GDP))
#b2 =b1 + geom_bar(stat="identity", fill = mydata3.cut10$expend_health_GDP) + coord_flip()
b2 =b1 + geom_bar(stat="identity") + coord_flip()
b3 = b2 +ylab("% of GDP expenditure") + xlab("country")
b3 + theme(axis.text=element_text(size=18),axis.title=element_text(size=20,face="bold"), title=element_text(size=20,face="bold"))
## female vs male life expectancy
a1 = ggplot(mydata, aes(life_ex_birth_m,life_ex_birth_f))
a2 = a1 + geom_point()
a3 = a2 + ylab("female life exp.") + xlab("male life expectancy")
a3 + theme(axis.text=element_text(size=18),axis.title=element_text(size=20,face="bold"), title=element_text(size=20,face="bold"))
## expend_health_GDP vs life_ex_birth_m
c1 = ggplot(mydata, aes(life_ex_birth_m,expend_health_GDP))
c2 = c1 + geom_point()
c3 = c2 + ylab("% of GDP exp.") + xlab("male life expectancy")
c3 + theme(axis.text=element_text(size=16),axis.title=element_text(size=16,face="bold"), title=element_text(size=16,face="bold"))
## health_per_capita vs life_ex_birth_m
d1 = ggplot(mydata, aes(life_ex_birth_m,health_per_capita))
d2 = d1 + geom_point()
d3 = d2 + ylab("exp. per capita ($)") + xlab("male life expectancy")
d3 + theme(axis.text=element_text(size=16),axis.title=element_text(size=16,face="bold"), title=element_text(size=16,face="bold"))
#  For the whole range of life_ex_birth_m, health_per_capita may be more predictive than % of GDP.  
###### IMPUTATIONS ######
# look at correlations before imputation
mydata.no.country = mydata
mydata.no.country$country <- NULL
cor(mydata.no.country, use = "complete.obs")
#cor between health_per_capita vs life_ex_birth_m = 0.6980869925
#cor between expend_health_GDP vs life_ex_birth_m = 0.35864894
##########Fill in the missing data for health_per_capita and life_ex_birth_m
###impute 2 missing data from health_per_capita with simple random imputation
# cor health_per_capita with life_ex_birth_m BEFORE imputation = 0.6980869925
mean(mydata$health_per_capita, na.rm = TRUE) ##mean BEFORE imputation = 1307.583
sd(mydata$health_per_capita, na.rm = TRUE) ##SD BEFORE imputation = 1606.372
library(Hmisc)
imputed.hpc = impute(mydata.no.country$health_per_capita, "random")
mydata.no.country$health_per_capita = imputed.hpc #Replacing the old vector.
# cor health_per_capita with life_ex_birth_m AFTER imputation = 0.6980869925
mean(mydata.no.country$health_per_capita) ## mean AFTER imputation = 1298.995
sd(mydata.no.country$health_per_capita)  ##SD AFTER imputation = 1600.712
###OK, 2 missing data from health_per_capita have been imputed
###impute 11 missing data from life_ex_birth_m with simple random imputation
mean(mydata.no.country$life_ex_birth_m, na.rm = TRUE) ##mean BEFORE imputation = 68.9071
sd(mydata.no.country$life_ex_birth_m, na.rm = TRUE)  ##SD BEFORE imputation = 7.688803
imputed.lebm = impute(mydata.no.country$life_ex_birth_m, "random")
mydata.no.country$life_ex_birth_m = imputed.lebm #Replacing the old vector.
# cor health_per_capita with life_ex_birth_m AFTER imputation = 0.6980869925
mean(mydata.no.country$life_ex_birth_m) ##mean AFTER imputation = 68.87113
sd(mydata.no.country$life_ex_birth_m)  ##SD AFTER imputation = 7.77327
###OK, 11 missing data from life_ex_birth_m have been imputed
##########Done with Fill in the missing data for health_per_capita and life_ex_birth_m

##build linear model bewteen y=life_ex_birth_m and x= log(health_per_capita)
plot(log(mydata.no.country$health_per_capita),mydata.no.country$life_ex_birth_m)
mydata.no.country$log_health_per_capita = log(mydata.no.country$health_per_capita)

model = lm(life_ex_birth_m ~ log_health_per_capita, data = mydata.no.country)
summary(model)
## both B0 and B1 have p<<0.05 and are significant. p-value: < 2.2e-16, R-squared:  0.6202
plot(model)
plot(log(mydata.no.country$health_per_capita),mydata.no.country$life_ex_birth_m,
     xlab="log(expenditure per capita)", ylab= "male life expectancy")
abline(model,col = "red")
#residuals vs fitted value gives flat line
#Normal Q-Q the lower tail deviates from normality
#Constant varience seems OK
#Residuals vs Leverage does not show problematic points.
# B0 = 38.916   B1 = 4.657


