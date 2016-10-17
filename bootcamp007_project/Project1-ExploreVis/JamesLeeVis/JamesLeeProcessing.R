#Clean/ Sort/ Arrange/ Join/ ggplot Data Here
setwd("C:/Users/James/bootcamp007_project/Project1-ExploreVis/JamesLeeVis")
library(dplyr)
library(ggplot2)
library(reshape2)
library(gridExtra)

GINI = read.csv("Data/GINI.csv", stringsAsFactors = FALSE)
GINI = filter(GINI, !AverageGINI %in% "#DIV/0!")
GINIA = select(GINI, Country.Code,Country.Name, AverageGINI)
GINIA$AverageGINI=as.numeric(GINIA$AverageGINI)

GDPpCAP = read.csv("Data/GDP_P_CAP.csv", stringsAsFactors = FALSE)
GDPpCAP = filter(GDPpCAP, !AVG.GDP.P.CAP %in% "#DIV/0!")
GDPpCAP = filter(GDPpCAP, !Avg2000 %in% "#DIV/0!")
GDPpCAP = filter(GDPpCAP, !Avg2012 %in% "#DIV/0!")
GDPpCAPA = select(GDPpCAP, Country.Code, Country.Name, AVG.GDP.P.CAP, Avg2000, Avg2012)
GDPpCAPA$AVG.GDP.P.CAP = as.numeric(GDPpCAPA$AVG.GDP.P.CAP)
GDPpCAPA$Avg2012 = as.numeric(GDPpCAPA$Avg2012)
GDPpCAPA$Avg2000 = as.numeric(GDPpCAPA$Avg2000)

LIFEEXP = read.csv("Data/LifeExpectancy.csv", stringsAsFactors = FALSE)
LIFEEXP = filter(LIFEEXP, Year %in% c(2000:2014))
CLIFEEXP = group_by(LIFEEXP, Country) %>%
  summarise_each(.,funs(mean), 
                 AvgBothBirth = Both.sexes..birth., 
                 AvgFemaleBirth = Female..birth., 
                 AvgMaleBirth = Male..birth., 
                 AvgBoth60 = Both.sexes..at.60.years., 
                 AvgFemale60 = Female..at.60.years., 
                 AvgMale60 = Male..at.60.years.)
colnames(CLIFEEXP)[1] = "Country.Name"
YLIFEEXP = filter(LIFEEXP, Year %in% c(2000,2012))
YLIFEEXP = melt(YLIFEEXP, id.vars = c('Country','Year')) %>% 
  mutate(variableYear = paste0(variable, Year)) %>% 
  dcast(Country~variableYear)
colnames(YLIFEEXP)[1] = "Country.Name"

POP = read.csv("Data/Population.csv", stringsAsFactors = FALSE)
POPA = select(POP ,Country.Name, Country.Code, Average.POP)

MetDat = read.csv("Data/Metadata.csv", stringsAsFactors = FALSE)

Table = inner_join(GDPpCAPA,CLIFEEXP, by = "Country.Name")
Table = inner_join(MetDat, Table, by = "Country.Code")
Table = inner_join(POPA, Table, by = c("Country.Code","Country.Name"))

#Table with Income Gap
Table2 = inner_join(GINIA, Table, by = c("Country.Code","Country.Name"))

#Table with Life Expectancy in 2000/ 2012
Table3 = inner_join(Table, YLIFEEXP, by = "Country.Name")

#Make Income Gap into factors
for (i in 1:nrow(Table2)){
  if (Table2$AverageGINI[i] < 27.18) {
    Table2$IncomeGap[i] = "Low"}
  else if (Table2$AverageGINI[i] >= 27.18 & Table2$AverageGINI[i] < 32.42) {
    Table2$IncomeGap[i] = "Middle-Low"}
  else if (Table2$AverageGINI[i] >= 32.42 & Table2$AverageGINI[i] < 37.59) {
    Table2$IncomeGap[i] = "Middle"}
  else if (Table2$AverageGINI[i] >= 37.59 & Table2$AverageGINI[i] < 44.14) {
    Table2$IncomeGap[i] = "Middle-High"}
  else {
    Table2$IncomeGap[i] = "High"}
}
for (i in 1:nrow(Table2)){
  if (Table2$AverageGINI[i] < 34) {
    Table2$IncomeGap2[i] = "Low"}
  else Table2$IncomeGap2[i] = "High"
}
#Reorder levels in order of Income Gap
Table2$IncomeGap = as.factor(Table2$IncomeGap)
Table2$IncomeGap = factor(Table2$IncomeGap, levels=c("Low", "Middle-Low", "Middle", "Middle-High", "High")) 
Table2$IncomeGap2 = as.factor(Table2$IncomeGap2)
Table2$IncomeGap2 = factor(Table2$IncomeGap2, levels=c("Low", "High")) 
#Reorder levels in order of Income Group
Table$IncomeGroup = as.factor(Table$IncomeGroup)
Table2$IncomeGroup = as.factor(Table2$IncomeGroup)
Table$IncomeGroup = factor(Table$IncomeGroup, levels = c("High income", "Upper middle income", "Lower middle income", "Low income"))
Table2$IncomeGroup = factor(Table2$IncomeGroup, levels = c("High income", "Upper middle income", "Lower middle income", "Low income"))

g = ggplot(data = Table, aes(x = AVG.GDP.P.CAP, y = AvgBothBirth))
#initial graph
gg = g + geom_point() +
  ylab("Average Life Expectancy") +
  xlab("Average GDP per Capita") +
  ggtitle("Life Expectancy v. GDP per Capita")

gbcap = ggplot(data = Table, aes(x = log(AVG.GDP.P.CAP), y = AvgBothBirth))

#graph with regions highlighted
Rbc = g + 
  geom_point(aes(color = Region, size = Average.POP)) +
  ylab("Average Life Expectancy") +
  xlab("Average GDP per Capita") +
  ggtitle("Life Expectancy v. GDP per Capita") +
  labs(color = "Region", size = "Population")
Rbclog = gbcap + 
  geom_point(aes(color = Region, size = Average.POP)) +
  ylab("Average Life Expectancy") +
  xlab("Log Average GDP per Capita") +
  ggtitle("Life Expectancy v. GDP per Capita") +
  labs(color = "Region", size = "Population")

#graph with income groups highlighted
Ibc = gbcap + geom_point(aes(color = IncomeGroup, size = Average.POP)) +
  ylab("Average Life Expectancy") +
  xlab("Log Average GDP per Capita") +
  ggtitle("Life Expectancy v. GDP per Capita") +
  labs(color = "Income Group",size = "Population")

#Percent of Income Gap
Ibar = ggplot(data = Table2, aes(x = IncomeGroup)) + 
  geom_bar(aes(fill = IncomeGap), position = "fill") +
  ylab("Percent (%)") +
  ggtitle("Income Gap on Income Regions") +
  scale_fill_discrete(name = "Income Gap")


#half half incomegap
Ibar2 = ggplot(data = Table2, aes(x = IncomeGroup)) + 
  geom_bar(aes(fill = IncomeGap2), position = "fill") +
  ylab("Percent (%)") +
  ggtitle("Income Gap on Income Regions") +
  scale_fill_discrete(name = "Income Gap")

#Death Count
MortLower = read.csv("Data/MORT_Lower.csv", stringsAsFactors = FALSE)
MortLowerMiddle = read.csv("Data/MORT_LowerMiddle.csv", stringsAsFactors = FALSE)
MortUpperMiddle = read.csv("Data/MORT_UpperMiddle.csv", stringsAsFactors = FALSE)
MortUpper = read.csv("Data/MORT_Upper.csv", stringsAsFactors = FALSE)

LowLSub = filter(MortLower, Group == "LargeSubgroup")
LowerMiddleLSub = filter(MortLowerMiddle, Group == "LargeSubgroup")
UpperMiddleLSub = filter(MortUpperMiddle, Group == "LargeSubgroup")
UpperLSub = filter(MortUpper, Group == "LargeSubgroup")
TotalLSub = rbind(LowLSub, LowerMiddleLSub, UpperMiddleLSub, UpperLSub)
TotalLSub$Region = factor(TotalLSub$Region, levels = c("High-income", "Upper-middle-income", "Lower-middle-income", "Low-income"))

#Look Inside Change in Years
gbcapY = ggplot(data = Table3, aes(x = log(Avg2000), y = Both.sexes..birth.2000)) + 
  geom_point(aes(color = IncomeGroup, shape = "2000")) + 
  geom_point(data = Table3, aes(log(x = Avg2012), y = Both.sexes..birth.2012, color = IncomeGroup, shape = "2012"))  +
  ylab("Average Life Expectancy") +
  xlab("Log Average GDP per Capita") +
  ggtitle("Life Expectancy v. GDP per Capita \n Year 2000 & 2012") +
  labs(color = "Income Group", shape = "Year")

#General Causes of Death
gLSub2012 = ggplot(data = TotalLSub, aes(x = Region, y = Both.sexes..2012.)) +
  geom_bar(aes(fill = Causes), position = "fill", stat = "identity") +
  xlab("Income Group") +
  ylab("Percent (%)") +
  ggtitle("Cause of Death on Income Regions \n Year 2012") +
  scale_fill_discrete(name = "Cause of Death", labels = c("Communicable Diseases", "Injuries", "Noncommunicable diseases"))
gLSub2000 = ggplot(data = TotalLSub, aes(x = Region, y = Both.sexes..2000.)) +
  geom_bar(aes(fill = Causes), position = "fill", stat = "identity") +
  xlab("Income Group") +
  ylab("Percent (%)") +
  ggtitle("Cause of Death on Income Regions \n Year 2000") +
  scale_fill_discrete(name = "Cause of Death", labels = c("Communicable Diseases", "Injuries", "Noncommunicable diseases"))


LowerM = filter(MortLower, Group == "Subgroup")
LowerM2012 = LowerM
LowerM2012$Causes = reorder(LowerM2012$Causes, -LowerM2012$Both.sexes..2012.)
LowerM2000 = LowerM
LowerM2000$Causes = reorder(LowerM2000$Causes, -LowerM2000$Both.sexes..2000.)
LowerMT = filter(Table3, IncomeGroup == "Low income")


#Lower Income Death Graphs by Years
gbcapYLower = ggplot(data = LowerMT, aes(x = log(Avg2000), y = Both.sexes..birth.2000)) + 
  geom_point(aes(color = "2000")) + 
  geom_point(data = LowerMT, aes(log(x = Avg2012), y = Both.sexes..birth.2012, color = "2012"))  +
  ylab("Average Life Expectancy") +
  xlab("Log Average GDP per Capita") +
  ggtitle("Life Expectancy v. GDP per Capita \n in Low Income Regions") +
  labs(color = "Year")

gLowerM2012 = ggplot(data = LowerM2012, aes(x = Region, y = Both.sexes..2012.)) +
  geom_bar(aes(fill = Causes), position = "dodge", stat = "identity") +
  xlab("") +
  ylab("Deaths") +
  ggtitle("Causes of Death \n Low Income Regions \n Year 2012") +
  scale_fill_discrete(name = "Cause of Death")
gLowerM2000 = ggplot(data = LowerM2000, aes(x = Region, y = Both.sexes..2000.)) +
  geom_bar(aes(fill = Causes), position = "dodge", stat = "identity") +
  xlab("") +
  ylab("Deaths") +
  ggtitle("Causes of Death \n Low Income Regions \n Year 2000") +
  scale_fill_discrete(name = "Cause of Death")


LowerMiddleM = filter(MortLowerMiddle, Group == "Subgroup")
LowerMiddleM2012 = LowerMiddleM
LowerMiddleM2012$Causes = reorder(LowerMiddleM2012$Causes, -LowerMiddleM2012$Both.sexes..2012.)
LowerMiddleM2000 = LowerMiddleM
LowerMiddleM2000$Causes = reorder(LowerMiddleM2000$Causes, -LowerMiddleM2000$Both.sexes..2000.)
LowerMiddleMT = filter(Table3, IncomeGroup == "Lower middle income")

#Lower-Middle Income Death Graphs by Years
gbcapYLowerMiddle = ggplot(data = LowerMiddleMT, aes(x = log(Avg2000), y = Both.sexes..birth.2000)) + 
  geom_point(aes(color = "2000")) + 
  geom_point(data = LowerMiddleMT, aes(log(x = Avg2012), y = Both.sexes..birth.2012, color = "2012"))  +
  ylab("Average Life Expectancy") +
  xlab("Log Average GDP per Capita") +
  ggtitle("Life Expectancy v. GDP per Capita \n in Lower-Middle Income Regions") +
  labs(color = "Year")

gLowerMiddleM2012 = ggplot(data = LowerMiddleM2012, aes(x = Region, y = Both.sexes..2012.)) +
  geom_bar(aes(fill = Causes), position = "dodge", stat = "identity") +
  xlab("") +
  ylab("Deaths") +
  ggtitle("Causes of Death \n Lower-Middle Income Regions \n Year 2012") +
  scale_fill_discrete(name = "Cause of Death")
gLowerMiddleM2000 = ggplot(data = LowerMiddleM2000, aes(x = Region, y = Both.sexes..2000.)) +
  geom_bar(aes(fill = Causes), position = "dodge", stat = "identity") +
  xlab("") +
  ylab("Deaths") +
  ggtitle("Causes of Death \n LowerMiddle Income Regions \n Year 2000") +
  scale_fill_discrete(name = "Cause of Death")

UpperMiddleM = filter(MortUpperMiddle, Group == "Subgroup")
UpperMiddleM2012 = UpperMiddleM
UpperMiddleM2012$Causes = reorder(UpperMiddleM2012$Causes, -UpperMiddleM2012$Both.sexes..2012.)
UpperMiddleM2000 = UpperMiddleM
UpperMiddleM2000$Causes = reorder(UpperMiddleM2000$Causes, -UpperMiddleM2000$Both.sexes..2000.)
UpperMiddleMT = filter(Table3, IncomeGroup == "Upper middle income")

#Upper-Middle Income Death Graphs by Years
gbcapYUpperMiddle = ggplot(data = UpperMiddleMT, aes(x = log(Avg2000), y = Both.sexes..birth.2000)) + 
  geom_point(aes(color = "2000")) + 
  geom_point(data = UpperMiddleMT, aes(log(x = Avg2012), y = Both.sexes..birth.2012, color = "2012"))  +
  ylab("Average Life Expectancy") +
  xlab("Log Average GDP per Capita") +
  ggtitle("Life Expectancy v. GDP per Capita \n in Upper-Middle Income Regions") +
  labs(color = "Year")

gUpperMiddleM2012 = ggplot(data = UpperMiddleM2012, aes(x = Region, y = Both.sexes..2012.)) +
  geom_bar(aes(fill = Causes), position = "dodge", stat = "identity") +
  xlab("") +
  ylab("Deaths") +
  ggtitle("Causes of Death \n Upper-Middle Income Regions \n Year 2012") +
  scale_fill_discrete(name = "Cause of Death")
gUpperMiddleM2000 = ggplot(data = UpperMiddleM2000, aes(x = Region, y = Both.sexes..2000.)) +
  geom_bar(aes(fill = Causes), position = "dodge", stat = "identity") +
  xlab("") +
  ylab("Deaths") +
  ggtitle("Causes of Death \n Upper-Middle Income Regions \n Year 2000") +
  scale_fill_discrete(name = "Cause of Death")


UpperM = filter(MortUpper, Group == "Subgroup")
UpperM2012 = UpperM
UpperM2012$Causes = reorder(UpperM2012$Causes, -UpperM2012$Both.sexes..2012.)
UpperM2000 = UpperM
UpperM2000$Causes = reorder(UpperM2000$Causes, -UpperM2000$Both.sexes..2000.)
UpperMT = filter(Table3, IncomeGroup == "High income")

#Upper Income Death Graphs by Years
gbcapYUpper = ggplot(data = UpperMT, aes(x = log(Avg2000), y = Both.sexes..birth.2000)) + 
  geom_point(aes(color = "2000")) + 
  geom_point(data = UpperMT, aes(log(x = Avg2012), y = Both.sexes..birth.2012, color = "2012"))  +
  ylab("Average Life Expectancy") +
  xlab("Log Average GDP per Capita") +
  ggtitle("Life Expectancy v. GDP per Capita \n in High Income Regions" ) +
  labs(color = "Year")

gUpperM2012 = ggplot(data = UpperM2012, aes(x = Region, y = Both.sexes..2012.)) +
  geom_bar(aes(fill = Causes), position = "dodge", stat = "identity") +
  xlab("") +
  ylab("Deaths") +
  ggtitle("Causes of Death \n High Income Regions \n Year 2012") +
  scale_fill_discrete(name = "Cause of Death")
gUpperM2000 = ggplot(data = UpperM2000, aes(x = Region, y = Both.sexes..2000.)) +
  geom_bar(aes(fill = Causes), position = "dodge", stat = "identity") +
  xlab("") +
  ylab("Deaths") +
  ggtitle("Causes of Death \n High Income Regions \n Year 2000") +
  scale_fill_discrete(name = "Cause of Death")