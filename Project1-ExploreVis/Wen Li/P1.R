getwd()
setwd("~/Documents/Bootcamp/Projects/Project 1")

######## library ########
library(ggplot2)
library(car)
library(ggthemes)
library(dplyr)
library(RColorBrewer)
library(googleVis)
library(reshape2)


######## loading data ########
BenefitsCostSharing = read.csv("health-insurance-marketplace/BenefitsCostSharing.csv", header = T, stringsAsFactors = F)
Rate = read.csv("health-insurance-marketplace/Rate.csv", header = T, stringsAsFactors = F)
# BusinessRules = read.csv("health-insurance-marketplace/BusinessRules.csv", header = T, stringsAsFactors = F)
# Network = read.csv("health-insurance-marketplace/Network.csv", header = T, stringsAsFactors = F)
# ServiceArea = read.csv("health-insurance-marketplace/ServiceArea.csv", header = T, stringsAsFactors = F)
PlanAttributes = read.csv("health-insurance-marketplace/PlanAttributes.csv", header = T, stringsAsFactors = F)
UnifiedRate = read.csv("health-insurance-marketplace/2015_Unified_Rate_Review__URR__Data_Extract___Annual_2015_PY.csv", header = T, stringsAsFactors = F)
# Crosswalk2015 = read.csv("health-insurance-marketplace/Crosswalk2015.csv", header = T, stringsAsFactors = F)
# Crosswalk2016 = read.csv("health-insurance-marketplace/Crosswalk2016.csv", header = T, stringsAsFactors = F)
StandardAgeRatio = read.csv("health-insurance-marketplace/StandardAgeRatio.csv", header = T, stringsAsFactors = F)
StandardAgeRatio$Age[StandardAgeRatio$Age == '64 and Older'] = '64+'
Plot_SARatio = 
  ggplot(StandardAgeRatio, aes(x = Age, y = PremiumRatio)) +
  geom_bar(stat = 'identity', fill = '#31a354', alpha = 0.9) +
  theme_economist_white(gray_bg = F)

# convert the character Age back to continuous
StandardAgeRatio1 = StandardAgeRatio
StandardAgeRatio1$Age[StandardAgeRatio1$Age == '0-20'] = '20'
StandardAgeRatio1$Age[StandardAgeRatio1$Age == '64+'] = '64'
StandardAgeRatio1$Age = as.numeric(StandardAgeRatio1$Age)
str(StandardAgeRatio1)
Plot_SARatio1 = 
  ggplot(StandardAgeRatio1, aes(x = Age, y = PremiumRatio)) +
  geom_line(stat = 'identity', color = '#66c2a5', alpha = 0.9, size = 1) +
  theme_bw() +
  geom_point(alpha = 0.7, size = 0.5, color = '#f46d43') +
  geom_text(aes(label = ifelse(Age == 21,as.character(Age), '')),
            hjust = 0.5, vjust = -0.5, color = '#3288bd') +
  ylab('Premium Ratio') +
  ggtitle('HHS Default Standard Age Curve') +
  scale_x_continuous(breaks = c(20, 30, 40, 50, 60, 64), 
                     labels = c('~ 20   ', '30', '40', '50', '60', '    64 ~'))


######## code: States & Age, other info ########
levels(as.factor(BenefitsCostSharing$StateCode))
levels(as.factor(Rate$StateCode))
levels(as.factor(BusinessRules$StateCode))
levels(as.factor(Network$StateCode))
levels(as.factor(ServiceArea$StateCode))
levels(as.factor(PlanAttributes$StateCode))
# same answer for each line of code
# [1] "AK" "AL" "AR" "AZ" "DE" "FL" "GA" "HI" "IA" "ID" "IL" "IN" "KS" "LA" "ME" "MI" "MO" "MS"
# [19] "MT" "NC" "ND" "NE" "NH" "NJ" "NM" "NV" "OH" "OK" "OR" "PA" "SC" "SD" "TN" "TX" "UT" "VA"
# [37] "WI" "WV" "WY"
levels(as.factor(Rate$Age))
levels(as.factor(Rate$RateEffectiveDate))
levels(as.factor(Rate$RateExpirationDate))


######## dataset cleaning 1 ########
levels(as.factor(Rate$Tobacco))
subset(Rate, Tobacco == "Tobacco User/Non-Tobacco User")[1,]
which(is.na(Rate$IndividualRate))
mean(Rate$IndividualRate)
max(Rate$IndividualRate)
sum(max(Rate$IndividualRate))
which(Rate$IndividualRate == max(Rate$IndividualRate))

# create new dataset in case need the raw data: Rate
Rate1 = 
  Rate %>%
  mutate(., IndividualRate1 = ifelse(IndividualRate == 999999, NA, IndividualRate))
mean(Rate1$IndividualRate1, na.rm = T)
max(Rate1$IndividualRate1, na.rm = T)

# correct missing value 1
Rate1$IndividualRate1[Rate1$IndividualRate1 == 9999.99] = NA
max(Rate1$IndividualRate1, na.rm = T)

# correct missing value 2
Rate1$IndividualRate1[Rate1$IndividualRate1 == 9999] = NA
max(Rate1$IndividualRate1, na.rm = T)

# test if the effective/expiration date will affect the rate
duration =
  Rate1 %>%
  group_by(., RateEffectiveDate, RateExpirationDate) %>%
  summarise(., Avg = mean(IndividualRate1, na.rm = T))
duration = duration %>% arrange(., RateEffectiveDate)

######## Rate2: New Age Group ########
# group variable "Age" into a new group "AgeGroup", create a new data.frame Rate2
# AgeGroup: 0-20, 21-29, 30-39, 40-49, 50-59, 60-64, 65 and over, Family Option
w1 = c('21', '22', '23', '24', '25', '26', '27', '28', '29')
w2 = c('30', '31', '32', '33', '34', '35', '36', '37', '38', '39')
w3 = c('40', '41', '42', '43', '44', '45', '46', '47', '48', '49')
w4 = c('50', '51', '52', '53', '54', '55', '56', '57', '58', '59')
w5 = c('60', '61', '62', '63', '64')
Rate2 = 
  Rate1 %>%
  mutate(., AgeGroup = Age)

# regroup AgeGroup
Rate2$AgeGroup[Rate2$AgeGroup %in% w1] = '21-29'
Rate2$AgeGroup[Rate2$AgeGroup %in% w2] = '30-39'
Rate2$AgeGroup[Rate2$AgeGroup %in% w3] = '40-49'
Rate2$AgeGroup[Rate2$AgeGroup %in% w4] = '50-59'
Rate2$AgeGroup[Rate2$AgeGroup %in% w5] = '60-64'


######## dataset cleaning 2 ########
temp1 = Rate2[Rate2$IndividualRate1 > 1500,]
temp1 = temp1 %>% arrange(., IndividualRate1)
r2013 = Rate2[Rate2$RateEffectiveDate == '2013-01-01',]
Rate3 = Rate2 %>% mutate(., months = 12)
levels(as.factor(Rate3$RateEffectiveDate))
# [1] "2004-01-01" "2013-01-01" "2014-01-01" "2014-04-01" "2014-07-01" "2014-10-01" "2015-01-01"
# [8] "2015-04-01" "2015-07-01" "2015-10-01" "2016-01-01" "2016-04-01" "2016-07-01" "2016-10-01"

levels(as.factor(Rate3$RateExpirationDate))
# [1] "2014-03-31" "2014-06-30" "2014-09-29" "2014-09-30" "2014-10-31" "2014-12-03" "2014-12-30"
# [8] "2014-12-31" "2015-01-01" "2015-02-28" "2015-03-31" "2015-05-31" "2015-06-03" "2015-06-30"
# [15] "2015-08-31" "2015-09-30" "2015-11-30" "2015-12-13" "2015-12-31" "2016-01-01" "2016-03-31"
# [22] "2016-06-30" "2016-09-30" "2016-12-31" "2017-01-01" "2104-12-31"

r2004 = Rate2[Rate2$RateEffectiveDate == '2004-01-01',]
Rate3$RateEffectiveDate[Rate3$RateEffectiveDate == '2004-01-01'] = '2014-01-01'
Rate3$RateExpirationDate[Rate3$RateExpirationDate == '2104-12-31'] = '2014-12-31'
Rate3$months[Rate3$RateEffectiveDate == '2013-01-01'] = 24
Rate3$months[Rate3$RateEffectiveDate == '2014-01-01' & Rate3$RateExpirationDate == '2014-03-31'] = 3
duration1 =
  Rate3 %>%
  group_by(., RateEffectiveDate, RateExpirationDate) %>%
  summarise(., Avg = mean(months)) %>%
  arrange(., RateEffectiveDate)
Rate3$months[Rate3$RateEffectiveDate == '2014-01-01' & Rate3$RateExpirationDate == '2014-06-30'] = 6
Rate3$months[Rate3$RateEffectiveDate == '2014-01-01' & Rate3$RateExpirationDate == '2015-02-28'] = 14
Rate3$months[Rate3$RateEffectiveDate == '2014-01-01' & Rate3$RateExpirationDate == '2015-11-30'] = 23
Rate3$months[Rate3$RateEffectiveDate == '2014-04-01' & Rate3$RateExpirationDate == '2014-06-30'] = 3
Rate3$months[Rate3$RateEffectiveDate == '2014-04-01' & Rate3$RateExpirationDate == '2015-05-31'] = 14
Rate3$months[Rate3$RateEffectiveDate == '2014-07-01' & Rate3$RateExpirationDate == '2014-09-29'] = 3
Rate3$months[Rate3$RateEffectiveDate == '2014-07-01' & Rate3$RateExpirationDate == '2014-09-30'] = 3
Rate3$months[Rate3$RateEffectiveDate == '2014-07-01' & Rate3$RateExpirationDate == '2014-10-31'] = 4
Rate3$months[Rate3$RateEffectiveDate == '2014-07-01' & Rate3$RateExpirationDate == '2014-12-31'] = 6
temp2 = Rate3[Rate3$RateExpirationDate %in% c('2015-06-03', '2015-06-30'),]
temp3 = Rate3[Rate3$RateExpirationDate == '2015-06-03',]
temp4 = temp3 %>% group_by(., IssuerId, PlanId) %>% summarise(., mean(IndividualRate1, na.rm = T))
Rate3$months[Rate3$RateEffectiveDate == '2014-07-01' & Rate3$RateExpirationDate == '2015-08-31'] = 14
Rate3$months[Rate3$RateEffectiveDate == '2014-07-01' & Rate3$RateExpirationDate == '2015-11-30'] = 17
Rate3$months[Rate3$RateEffectiveDate == '2015-01-01' & Rate3$RateExpirationDate == '2015-03-31'] = 3
Rate3$months[Rate3$RateEffectiveDate == '2015-01-01' & Rate3$RateExpirationDate == '2015-06-30'] = 6
Rate3$months[Rate3$RateEffectiveDate == '2015-04-01' & Rate3$RateExpirationDate == '2015-06-30'] = 3
Rate3$months[Rate3$RateEffectiveDate == '2015-07-01' & Rate3$RateExpirationDate == '2015-09-30'] = 3
Rate3$months[Rate3$RateEffectiveDate == '2015-07-01' & Rate3$RateExpirationDate == '2015-12-31'] = 6
Rate3$months[Rate3$RateEffectiveDate == '2015-10-01' & Rate3$RateExpirationDate == '2015-12-31'] = 3
Rate3$months[Rate3$RateEffectiveDate == '2016-01-01' & Rate3$RateExpirationDate == '2016-03-31'] = 3
Rate3$months[Rate3$RateEffectiveDate == '2016-01-01' & Rate3$RateExpirationDate == '2016-06-30'] = 6
Rate3$months[Rate3$RateEffectiveDate == '2016-04-01' & Rate3$RateExpirationDate == '2016-06-30'] = 3
Rate3$months[Rate3$RateEffectiveDate == '2016-07-01' & Rate3$RateExpirationDate == '2016-09-30'] = 3
Rate3$months[Rate3$RateEffectiveDate == '2016-07-01' & Rate3$RateExpirationDate == '2016-12-31'] = 6
Rate3$months[Rate3$RateEffectiveDate == '2016-10-01' & Rate3$RateExpirationDate == '2016-12-31'] = 3
duration2 =
  Rate3 %>%
  group_by(., RateEffectiveDate, RateExpirationDate) %>%
  summarise(., Avg = mean(months))


######## Rate3: the length of Plan ########
FamilyOption3 = Rate3[Rate3$Age == 'Family Option',]
Rate3_1 = Rate3[Rate3$AgeGroup != 'Family Option',]

# mean rates by AgeGroup, Plot_AIR(Average Individual Rate)
AIR_AgeMonths3 = 
  Rate3_1 %>%
  group_by(., AgeGroup, months) %>%
  summarise(., Avg = mean(IndividualRate1, na.rm = T))


######## Rate4: omit data of 2013 ########
Rate4 = Rate3[Rate3$RateEffectiveDate != '2013-01-01',]
# subset Rate4 without Family Option Group
Rate4_1 = Rate4[Rate4$AgeGroup != 'Family Option',]
FamilyOption4 = Rate4[Rate4$Age == 'Family Option',]

AIR_AgeMonths4 = 
  Rate4_1 %>%
  group_by(., AgeGroup, months) %>%
  summarise(., Avg = mean(IndividualRate1, na.rm = T))

######## PRINT #1 ########
# in general, the individual rate affected by Age and plan length
r4 = ggplot(data = AIR_AgeMonths4, aes(x = AgeGroup, y = Avg))
Plot_AIR4 = r4 + 
geom_bar(aes(fill = as.factor(months)),
         stat = 'identity',
         position = 'dodge',
         alpha = 0.9) + 
  theme_economist_white(gray_bg = F) +
  scale_fill_brewer(palette = 'GnBu', name = 'Plan Length\n(Months)') +
  guides(color = 'legend') +
  ggtitle('Age and Plan Length vs. Plan Rate') +
  xlab('Age Group') +
  ylab('Plan Average Rate') +
  theme(legend.position = 'right', plot.title = element_text(hjust = 0.5))

######## PRINT #2 ########
# use Rate4 to create a boxplot/violin plot, has a general idea of all insurance plan for individual
r4a = ggplot(data = Rate4_1, aes(x = AgeGroup, y = IndividualRate1, na.rm = T))
Plot_AIR4a = r4a +
  geom_boxplot(outlier.shape = NA, color = 'grey', alpha = 0.9) +
  coord_cartesian(ylim = c(0, 1000)) +
  theme_economist_white(gray_bg = F)
# violin plots
Plot_AIR4ai = r4a +
  geom_violin(aes(fill = AgeGroup), alpha = 0.8) +
  coord_cartesian(ylim = c(0, 1200)) +
  theme_economist_white(gray_bg = F) +
  scale_fill_brewer(palette = 'Set2', name = 'Plan Length\n(Months)') +
  guides(color = 'legend') +
  ggtitle('Age and Plan Length vs. Plan Rate') +
  xlab('Age Group') +
  ylab('Plan Rate') +
  theme(legend.position = 'right', plot.title = element_text(hjust = 0.5))

# in general, the individual rate affected by Age and State, bar chart
AIR_AgeStates4 = 
  Rate4_1 %>%
  group_by(., AgeGroup, StateCode) %>%
  summarise(., Avg = mean(IndividualRate1, na.rm = T))
r4b = ggplot(data = AIR_AgeStates4, aes(x = AgeGroup, y = Avg))
Plot_AIR4b = r4b + 
  geom_bar(aes(color = as.factor(StateCode)),
           stat = 'identity',
           position = 'dodge',
           alpha = 0.3) + 
  theme_economist_white(gray_bg = F)


######## Rate5: Add new variables (Tobacco4, IndividualRate4) ########
# combine a new subset add a new column Tobacco
# in general, the individual rate affected by Age and Tabacco
which(is.na(Rate4_1$Tobacco))
# returns integer(0)
Rate4_2 = 
  Rate4_1[Rate4_1$Tobacco == 'No Preference',] %>%
  mutate(., IndividualRate4 = IndividualRate1,
         Tobacco4 = 'No Preference')
Rate4_3 = 
  Rate4_1[Rate4_1$Tobacco == 'Tobacco User/Non-Tobacco User',] %>%
  mutate(., IndividualRate4 = IndividualTobaccoRate,
         Tobacco4 = 'Tobacco User')
Rate4_4 = 
  Rate4_1[Rate4_1$Tobacco == 'Tobacco User/Non-Tobacco User',] %>%
  mutate(., IndividualRate4 = IndividualRate1,
         Tobacco4 = 'Non-Tobacco User')
Rate5 = rbind(Rate4_2, Rate4_3, Rate4_4)

# Tobacco Effect on Individual Rates
AvgTobacco5 = Rate5 %>%
  group_by(., AgeGroup, Tobacco4) %>%
  summarise(., Avg = mean(IndividualRate4, na.rm = T))

######## PRINT #3 ########
# bar plot of AvgTobacco5
r5 = ggplot(AvgTobacco5, aes(x = AgeGroup, y = Avg))
Plot_AIR5 = r5 +
  geom_bar(aes(fill = as.factor(Tobacco4)),
           stat = 'identity',
           position = 'dodge',
           alpha = 0.8) + 
  theme_economist_white(gray_bg = F) +
  scale_fill_brewer(palette = 'Set2', name = 'Tobacco Policy') +
  guides(color = 'legend') +
  ggtitle('Age and Tobacco Policy vs. Plan Rate') +
  xlab('Age Group') +
  ylab('Plan Average Rate') +
  theme(legend.position = 'right', plot.title = element_text(hjust = 0.5))
r5a = ggplot(Rate5, aes(x = AgeGroup, y = IndividualRate4, na.rm = T))
Plot_AIR5a = r5a +
  geom_violin(aes(fill = Tobacco4), alpha = 0.8)  +
  scale_fill_brewer(palette = 'Set2', name = 'Tobacco Policy') +
  coord_cartesian(ylim = c(0, 1200)) +
  guides(color = 'legend') +
  ggtitle('Age and Tobacco Policy vs. Plan Rate') +
  xlab('Age Group') +
  ylab('Plan Rate') +
  theme(legend.position = 'right', plot.title = element_text(hjust = 0.5))


######## Year Trend ########
r4e = ggplot(Rate4_1, aes(x = BusinessYear, y = IndividualRate1))
Plot_AIR4e = r4e +
  geom_line(aes(color = AgeGroup), alpha = 0.8)  +
  scale_fill_brewer(palette = 'Set2', name = 'Age Group') +
  coord_cartesian(ylim = c(0, 1200)) +
  guides(color = 'legend') +
  ggtitle('Year Trend and Age vs. Plan Rate') +
  xlab('Business Year') +
  ylab('Plan Rate') +
  theme(legend.position = 'right', plot.title = element_text(hjust = 0.5))


######## Family Option Explore ########
# to see if there's any missing value in FamilyOption4
which(is.na(FamilyOption4$PrimarySubscriberAndOneDependent))
which(is.na(FamilyOption4$PrimarySubscriberAndTwoDependents))
which(is.na(FamilyOption4$PrimarySubscriberAndThreeOrMoreDependents))
which(is.na(FamilyOption4$CoupleAndOneDependent))
which(is.na(FamilyOption4$CoupleAndTwoDependents))
which(is.na(FamilyOption4$CoupleAndThreeOrMoreDependents))
# all returns integer(0)

# to check if Rate4_1 has multiple-person plan in individual plan
sum(is.na(Rate4_1$PrimarySubscriberAndOneDependent))
sum(is.na(Rate4_1$PrimarySubscriberAndTwoDependents))
sum(is.na(Rate4_1$PrimarySubscriberAndThreeOrMoreDependents))
sum(is.na(Rate4_1$CoupleAndOneDependent))
sum(is.na(Rate4_1$CoupleAndTwoDependents))
sum(is.na(Rate4_1$CoupleAndThreeOrMoreDependents))
# all returns [1] 12653458, which is the obs number in Rate4_1

# to check variable months has been converted completely
levels(as.factor(FamilyOption4$months))
# returns [1] "3"  "6"  "12"
# finish all the check-up, multiple-person plan only exist in Family Option Group

# compare rates plan
FamilyOption5 =
  FamilyOption4 %>%
  mutate(., Avg =
  (FamilyOption4$PrimarySubscriberAndOneDependent +
  FamilyOption4$PrimarySubscriberAndTwoDependents +
  FamilyOption4$PrimarySubscriberAndThreeOrMoreDependents +
  FamilyOption4$Couple +
  FamilyOption4$CoupleAndOneDependent +
  FamilyOption4$CoupleAndTwoDependents +
  FamilyOption4$CoupleAndThreeOrMoreDependents)/(2 + 3 + 4 + 2 + 3 + 4 +5))
# average rate through states
AvgGroup =
  FamilyOption5 %>%
  group_by(., StateCode) %>%
  summarise(., AvgP1 = mean(PrimarySubscriberAndOneDependent),
            AvgP2 = mean(PrimarySubscriberAndTwoDependents),
            AvgP3 = mean(PrimarySubscriberAndThreeOrMoreDependents),
            AvgC = mean(Couple),
            AvgC1 = mean(CoupleAndOneDependent),
            AvgC2 = mean(CoupleAndTwoDependents),
            AvgC3 = mean(CoupleAndThreeOrMoreDependents),
            Avg = mean(Avg))
AvgGroup1 =
  FamilyOption5 %>%
  group_by(., StateCode) %>%
  summarise(., AvgP1 = mean(PrimarySubscriberAndOneDependent/2),
            AvgP2 = mean(PrimarySubscriberAndTwoDependents/3),
            AvgP3 = mean(PrimarySubscriberAndThreeOrMoreDependents/4),
            AvgC = mean(Couple/2),
            AvgC1 = mean(CoupleAndOneDependent/3),
            AvgC2 = mean(CoupleAndTwoDependents/4),
            AvgC3 = mean(CoupleAndThreeOrMoreDependents/5),
            Avg = mean(Avg))


######## googleVis GeoChart 1 ########
######## PRINT #4 ########
Plot_State = gvisGeoChart(AvgGroup, 'StateCode', 'Avg', 
                        options = list(region = "US", 
                                       displayMode = "regions", 
                                       resolution = "provinces",
                                       colorAxis = "{colors: ['#e0f3db', '#a8ddb5', '#43a2ca']}",
                                       datalessRegionColor = '#ffffff'))
plot(Plot_State)
write.table(AvgGroup, file = 'AvgGroup.csv', sep = ',', row.names = F)

state_P1 = gvisGeoChart(AvgGroup, 'StateCode', 'AvgP1', 
                         options = list(region = "US", 
                                        displayMode = "regions", 
                                        resolution = "provinces",
                                        colorAxis = "{colors: ['#e0f3db', '#a8ddb5', '#43a2ca']}",
                                        datalessRegionColor = '#ffffff'))
plot(state_P1)

state_P2 = gvisGeoChart(AvgGroup, 'StateCode', 'AvgP2', 
                         options = list(region = "US", 
                                        displayMode = "regions", 
                                        resolution = "provinces",
                                        colorAxis = "{colors: ['#e0f3db', '#a8ddb5', '#43a2ca']}",
                                        datalessRegionColor = '#ffffff'))
plot(state_P2)

state_P3 = gvisGeoChart(AvgGroup, 'StateCode', 'AvgP3', 
                         options = list(region = "US", 
                                        displayMode = "regions", 
                                        resolution = "provinces",
                                        colorAxis = "{colors: ['#e0f3db', '#a8ddb5', '#43a2ca']}",
                                        datalessRegionColor = '#ffffff'))
plot(state_P3)


######## BenefitsCostSharing & PlanAttributes ########
n1 = names(PlanAttributes)
n2 = names(BenefitsCostSharing)
levels(as.factor(PlanAttributes$PlanType))
levels(as.factor(PlanAttributes$BenefitPackageId))
levels(as.factor(BenefitsCostSharing$BenefitName))
BCS1 = mutate_each(BenefitsCostSharing, funs(tolower))
levels(as.factor(BCS1$BenefitName))
PA1 = PlanAttributes %>%
  group_by(., PlanType) %>% 
  summarise(., num = n())
PA2 = PlanAttributes[, c('PlanId', 'PlanType')]
PA2 = unique(PA2)
J1 = left_join(BenefitsCostSharing, PA2, by = 'PlanId')
which(is.na(J1$PlanType))
# integer(0)
J1$Covered = J1$IsCovered
J1 = mutate_each(J1, funs(toupper))
J1$Covered[J1$Covered == ''] = 'NOT COVERED'
levels(as.factor(J1$Covered))

# correct the typos in BenefitsCostSharing
J1$BenefitName1 = J1$BenefitName
J1$BenefitName1[J1$BenefitName1 == 'ABA AUTISM SPECTRUM DISORDERS'] = 'ABA FOR AUTISM SPECTRUM DISORDERS'
J1$BenefitName1[J1$BenefitName1 == 'ABA FOR AUTISM SPECTRUM DISPRDERS'] = 'ABA FOR AUTISM SPECTRUM DISORDERS'
J1$BenefitName1[J1$BenefitName1 == 'ACCIDENTAL DENTAL-ADULT'] = 'ACCIDENTAL DENTAL - ADULT'
J1$BenefitName1[J1$BenefitName1 == 'ADULT VISION FRAMES AND LENSES'] = 'ADULT VISION FRAMES OR LENSES'
J1$BenefitName1[J1$BenefitName1 == 'ADULT VISION FRAMES AND LENSES'] = 'ADULT VISION FRAMES OR LENSES'
J1$BenefitName1[J1$BenefitName1 == 'ADULT VISION- FRAMES'] = 'ADULT VISION FRAMES OR LENSES'
J1$BenefitName1[J1$BenefitName1 == 'ADULTS FRAMES OR LENSES'] = 'ADULT VISION FRAMES OR LENSES'
J1$BenefitName1[J1$BenefitName1 == 'APEXIFICATION, RECALCIFICATION -CHILD'] = 'APEXIFICATION AND RECALCIFICATION - CHILD'
J1$BenefitName1[J1$BenefitName1 == 'AUTISM SPECTRUM DISORDER SERVICES - INTENSIVE LEVEL SERVICES'] = 'AUTISM SPECTRUM DISORDER - INTENSIVE LEVEL SERVICES'
J1$BenefitName1[J1$BenefitName1 == 'AUTISM SPECTRUM DISORDER SERVICES - NON-INTENSIVE'] = 'AUTISM SPECTRUM DISORDER - NON-INTENSIVE LEVEL SERVICES'
J1$BenefitName1[J1$BenefitName1 == 'AUTISM SPECTRUM DISORDERS ABA'] = 'AUTISM SPECTRUM DISORDERS (ABA)'
J1$BenefitName1[J1$BenefitName1 == 'AUTISM SPECTRUM DISORDERS - AGE 19 & ABOVE'] = 'AUTISM SPECTRUM DISORDERS: AGE 19 AND UP'
J1$BenefitName1[J1$BenefitName1 == 'BITE WING X-RAY - CHILD'] = 'BITEWING X-RAYS - CHILD'
J1$BenefitName1[J1$BenefitName1 == 'BITEWING X-RAYS: CHILD'] = 'BITEWING X-RAYS - CHILD'
J1$BenefitName1[J1$BenefitName1 == 'BLOOS AND BLOOD SERVICES'] = 'BLOOD AND BLOOD SERVICES'
J1$BenefitName1[J1$BenefitName1 == 'BREAST CANCER PAIN MEDICATION AND PAIN THERAPY'] = 'BREAST CANCER PAIN MEDICATION AND THERAPY'
J1$BenefitName1[J1$BenefitName1 == 'BRIDGES -CHILD'] = 'BRIDGES - CHILD'
J1$BenefitName1[J1$BenefitName1 == 'CARDIAC & PULMONARY REHABILITAION'] = 'CARDIAC AND PULMONARY REHABILITATION'
J1$BenefitName1[J1$BenefitName1 == 'CARDIAC &$135:$135PULMONARY REHABILITATION'] = 'CARDIAC AND PULMONARY REHABILITATION'
J1$BenefitName1[J1$BenefitName1 == 'CARDIAC & PULMONARY REHABILITATION'] = 'CARDIAC AND PULMONARY REHABILITATION'
J1$BenefitName1[J1$BenefitName1 == 'CARDIAC AND PULMONARY REHABILITATION SERVICES'] = 'CARDIAC AND PULMONARY REHABILITATION'
J1$BenefitName1[J1$BenefitName1 == 'CARDIAC REHABILITATION THERAPY'] = 'CARDIAC REHABILITATION'
J1$BenefitName1[J1$BenefitName1 == 'CAST METAL, STAINLESS STEEL, PORCELAIN/CERAMIC, ALL CERAMIC AND RESINBASED COMPOSITE ONLAY, OR CROWN'] = 'CAST METAL, STAINLESS STEEL, PORCELAIN/CERAMIC, ALL CERAMIC AND RESIN-BASED COMPOSITE ONLAY, OR CROWN'
J1$BenefitName1[J1$BenefitName1 == 'CHIROPRACTIC'] = 'CHIROPRACTIC CARE'
J1$BenefitName1[J1$BenefitName1 == 'CLAMYDIA SCREENING'] = 'CHLAMYDIA SCREENING'
J1$BenefitName1[J1$BenefitName1 == 'CLINICAL - TRIALS'] = 'CLINICAL TRIALS'
J1$BenefitName1[J1$BenefitName1 == 'COMPLEMENTARY MEDICINE'] = 'COMPLEMENTARY MEDICINE SERVICES'
J1$BenefitName1[J1$BenefitName1 == 'COMPLEMENTARY MEDICINCE SERVICES'] = 'COMPLEMENTARY MEDICINE SERVICES'
J1$BenefitName1[J1$BenefitName1 == 'CONTRACEPTIVE DEVICES'] = 'CONTRACEPTIVE SERVICES'
J1$BenefitName1[J1$BenefitName1 == 'COSMETIC ORTHODONTIA'] = 'COSMETIC ORTHODONTICS'
J1$BenefitName1[J1$BenefitName1 == 'COSMETIC ORTHODONTIA - CHILD'] = 'COSMETIC ORTHODONTICS - CHILD'
J1$BenefitName1[J1$BenefitName1 == 'COSMETIC ORTHODONTIA-CHILD'] = 'COSMETIC ORTHODONTICS - CHILD'
J1$BenefitName1[J1$BenefitName1 == 'COSMETIC ORTHODONTICS-CHILD'] = 'COSMETIC ORTHODONTICS - CHILD'
J1$BenefitName1[J1$BenefitName1 == 'COVERAGE FOR AUTISM SPECTRUM DISORDERS'] = 'AUTISM SPECTRUM DISORDERS'
J1$BenefitName1[J1$BenefitName1 == 'CROWN BUILD-UP -CHILD'] = 'CROWN BUILD-UP - CHILD'
J1$BenefitName1[J1$BenefitName1 == 'DENTAL ANESTHESIA CHILD'] = 'DENTAL ANESTHESIA - CHILD'
J1$BenefitName1[J1$BenefitName1 == 'DENTAL ANETHESIA'] = 'DENTAL ANESTHESIA'
J1$BenefitName1[J1$BenefitName1 == 'DENTURE RELINE OR REBASE'] = 'DENTURE RELINE AND REBASE'
J1$BenefitName1[J1$BenefitName1 == 'DENTURE REPAIR -CHILD'] = 'DENTURE REPAIR - CHILD'
J1$BenefitName1[J1$BenefitName1 == 'DENTURES -CHILD'] = 'DENTURE REPAIR - CHILD'
J1$BenefitName1[J1$BenefitName1 == 'DIABETES - CARE MANAGEMENT'] = 'DIABETES CARE MANAGEMENT'
J1$BenefitName1[J1$BenefitName1 == 'DIABETES-CARE MANAGEMENT'] = 'DIABETES CARE MANAGEMENT'
J1$BenefitName1[J1$BenefitName1 == 'DIAGNOTIC AND PREVENTIVE'] = 'DIAGNOSTIC AND PREVENTIVE'
J1$BenefitName1[J1$BenefitName1 == 'ELECTROCONVULSIVE THERAPY (ECT)'] = 'ELECTROCONVULSIVE THERAPY'
J1$BenefitName1[J1$BenefitName1 == 'EMERGENCY CARE OUTSIDE U8NITED STATES'] = 'EMERGENCY CARE OUTSIDE UNITED STATES'
J1$BenefitName1[J1$BenefitName1 == 'EOSINOPHILIC GASTROINTESTINAL DISORDER FORMULA'] = 'EOSINOPHILIC GASTROINTESTINAL DISORDER'
J1$BenefitName1[J1$BenefitName1 == 'EYE GLASSES ADULT'] = 'EYEGLASSES FOR ADULTS'
J1$BenefitName1[J1$BenefitName1 == 'EYE GLASSES FOR ADULTS'] = 'EYEGLASSES FOR ADULTS'
J1$BenefitName1[J1$BenefitName1 == 'EYE GLASSES FOR CHILDREN'] = 'EYEGLASSES FOR CHILDREN'
J1$BenefitName1[J1$BenefitName1 == 'FAMILY PLANNING'] = 'FAMILY PLANNING SERVICES'
J1$BenefitName1[J1$BenefitName1 == 'FILINGS'] = 'FILLINGS'
J1$BenefitName1[J1$BenefitName1 == 'FLUORIDE TREATMENT: CHILD'] = 'FLUORIDE TREATMENTS - CHILD'
J1$BenefitName1[J1$BenefitName1 == 'FLUORIDE TREATMENTS: CHILD'] = 'FLUORIDE TREATMENTS - CHILD'
J1$BenefitName1[J1$BenefitName1 == 'GENETIC TESTING'] = 'GENETIC DISEASE TESTING SERVICES'
J1$BenefitName1[J1$BenefitName1 == 'GENETIC TESTING LAB SERVICES'] = 'GENETIC DISEASE TESTING SERVICES'
J1$BenefitName1[J1$BenefitName1 == 'HABILITATIVE SERVICES - PT/OT/ST AND ABA (COMBINED) FOR AUTISM SPECTRUM DISORDER - THROUGH 18 YRS OF AGE ONLY'] = 'HABILITATION SERVICES - PT/OT/ST AND ABA (COMBINED) FOR AUTISM SPECTRUM DISORDER - THROUGH 18 YRS OF AGE ONLY'
J1$BenefitName1[J1$BenefitName1 == 'HABILITATIVE SPEECH THERAPY (NON-AUTISM RELATED'] = 'HABILITATIVE SPEECH THERAPY (NON-AUTISM RELATED)'
J1$BenefitName1[J1$BenefitName1 == 'HEARING TESTS/EXAMS'] = 'HEARING EXAMS/TESTING'
J1$BenefitName1[J1$BenefitName1 == 'HEARING EXAM'] = 'HEARING EXAMS/TESTING'
J1$BenefitName1[J1$BenefitName1 == 'HOME HEALTH CARE - VISITS 46-60'] = 'HOME HEALTH CARE SERVICES - VISITS 46-60'
J1$BenefitName1[J1$BenefitName1 == 'HOME HEALTH CARE SERVICES: VISITS 31-60'] = 'HOME HEALTH CARE SERVICES - VISITS 31-60'
J1$BenefitName1[J1$BenefitName1 == 'IMAGING -- HOSPITAL (CT/PET SCANS, MRI)'] = 'IMAGING (CT/PET SCANS, MRIS)'
J1$BenefitName1[J1$BenefitName1 == 'IMAGING (CT, PET SCANS, MRIS) CENTER/ OFFICE'] = 'IMAGING (CT/PET SCANS, MRIS)'
J1$BenefitName1[J1$BenefitName1 == 'IMAGING (CT, PET SCANS, MRIS) CENTER/OFFICE'] = 'IMAGING (CT/PET SCANS, MRIS)'
J1$BenefitName1[J1$BenefitName1 == 'IMAGING (CT, PET SCANS, MRIS) OFFICE/CENTER'] = 'IMAGING (CT/PET SCANS, MRIS)'
J1$BenefitName1[J1$BenefitName1 == 'IMAGING (CT/PET SCANS, MRIS) CENTER/OFFICE'] = 'IMAGING (CT/PET SCANS, MRIS'
J1$BenefitName1[J1$BenefitName1 == 'IMMEDIATE DENTIURES'] = 'IMMEDIATE DENTURES'
J1$BenefitName1[J1$BenefitName1 == 'IMPLANT ADULT'] = 'IMPLANT - ADULT'
J1$BenefitName1[J1$BenefitName1 == 'IMPLANTS - ADULTS'] = 'IMPLANT - ADULT'
J1$BenefitName1[J1$BenefitName1 == 'IMPLANTS - CHILD'] = 'IMPLANT - CHILD'
J1$BenefitName1[J1$BenefitName1 == 'IMPLANTS'] = 'IMPLANT'
J1$BenefitName1[J1$BenefitName1 == 'INITIAL PLACEMENT OF BRIDGES OR DENTURES'] = 'INITIAL PLACEMENT OF BRIDGES AND DENTURES'
J1$BenefitName1[J1$BenefitName1 == 'INJECTABLE AND OTHER DRUGS ADMINISTERED IN A PROVIDE OFFICE/OTHER OUTPATIENT SETTING'] = "INJECTABLE DRUGS AND OTHER DRUGS ADMINISTERED IN A PROVIDER'S OFFICE OR OTHER OUTPATIENT SETTING"
J1$BenefitName1[J1$BenefitName1 == 'INJECTABLES AND OTHER DRUGS ADMINISTERED IN A PROVIDE OFFICE/OTHER OUTPATIENT SETTINGS'] = "INJECTABLE DRUGS AND OTHER DRUGS ADMINISTERED IN A PROVIDER'S OFFICE OR OTHER OUTPATIENT SETTING"
J1$BenefitName1[J1$BenefitName1 == 'INPATIENT REHABILATION SERVICES'] = "INPATIENT REHABILITATION SERVICES"
J1$BenefitName1[J1$BenefitName1 == 'INPATIENT REHABILIATION SERVICES'] = 'INPATIENT REHABILITATION SERVICES'
J1$BenefitName1[J1$BenefitName1 == 'INPATIENT REHABILITATION'] = 'INPATIENT REHABILITATION SERVICES'
J1$BenefitName1[J1$BenefitName1 == 'INPATIENT REHABILITATION - PHYSICIAN FEES'] = 'INPATIENT REHABILITATION FACILITIES - PHYSICIAN FEES'
J1$BenefitName1[J1$BenefitName1 == 'INPATIENT REHABILITATION FACILITIES - INPATIENT'] = 'INPATIENT REHABILITATION FACILITIES - INPATIENT SERVICES'
J1$BenefitName1[J1$BenefitName1 == 'INPATIENT REHABILITATION FACILITIES - INPATIENT FEES'] = 'INPATIENT REHABILITATION FACILITIES - INPATIENT SERVICES'
J1$BenefitName1[J1$BenefitName1 == 'INPATIENT REHABILITATION FACILITIES-INPATIENT SERVICES'] = 'INPATIENT REHABILITATION FACILITIES - INPATIENT SERVICES'
J1$BenefitName1[J1$BenefitName1 == 'INPATIENT REHABILITATION FACILITIES-PHYSICIAN FEES'] = 'INPATIENT REHABILITATION FACILITIES - PHYSICIAN FEES'
J1$BenefitName1[J1$BenefitName1 == 'INPATIENT REHABILITATION SERVICES - INPATIENT SERVICES'] = 'INPATIENT REHABILITATION FACILITIES - INPATIENT SERVICES'
J1$BenefitName1[J1$BenefitName1 == 'INPATIENT REHABILITIATION FACILITIES - INPATIENT FEES'] = 'INPATIENT REHABILITATION FACILITIES - INPATIENT SERVICES'
J1$BenefitName1[J1$BenefitName1 == 'INPATIENT REHABILITIATION FACILITIES - PHYSICIAN FEES'] = 'INPATIENT REHABILITATION FACILITIES - PHYSICIAN FEES'
J1$BenefitName1[J1$BenefitName1 == 'INPATIENT REHABILITION SERVICES'] = 'INPATIENT REHABILITATION SERVICES'
J1$BenefitName1[J1$BenefitName1 == 'INPATIENT REHABILTIATION FACILITIES - INPATIENT SERVICES'] = 'INPATIENT REHABILITATION FACILITIES - INPATIENT SERVICES'
J1$BenefitName1[J1$BenefitName1 == 'LAB SERVICES IN OFFICE'] = 'LABORATORY SERVICES IN OFFICE'
J1$BenefitName1[J1$BenefitName1 == 'LABORATORY SERVICES (HOSPITAL)'] = 'LABORATORY SERVICES IN OFFICE'
J1$BenefitName1[J1$BenefitName1 == 'MANDATED / PREVENTIVE PRESCRIPTIONS'] = 'MANDATED PREVENTIVE PRESCRIPTIONS'
J1$BenefitName1[J1$BenefitName1 == 'MANDATED PREVENTATIVE PRESCRIPTIONS'] = 'MANDATED PREVENTIVE PRESCRIPTIONS'
J1$BenefitName1[J1$BenefitName1 == 'MANDATED/PREVENTIVE PRESCRIPTIONS'] = 'MANDATED PREVENTIVE PRESCRIPTIONS'
J1$BenefitName1[J1$BenefitName1 == 'MASTECTOMY-RELATED SERVICES'] = 'MASTECTOMY-RELATED COVERAGE'
J1$BenefitName1[J1$BenefitName1 == "MEDICAL FOODS/METABOLIC SUPPLIMENT/GASTRIC DISORDER FORMULA"] = "MEDICAL FOODS/METABOLIC SUPPLEMENTS/GASTRIC DISORDER FORMULA"
J1$BenefitName1[J1$BenefitName1 == "MEDICAL FOODS/METABOLIC SUPPLIMENTS/GASTRIC DISORDER FORMULA"] = "MEDICAL FOODS/METABOLIC SUPPLEMENTS/GASTRIC DISORDER FORMULA"
J1$BenefitName1[J1$BenefitName1 == "MENTAL HEALTH OTHER"] = "MENTAL HEALTH - OTHER"
J1$BenefitName1[J1$BenefitName1 == "MENTAL HEALTH INTERMEDIATE"] = "MENTAL HEALTH - INTERMEDIATE"
J1$BenefitName1[J1$BenefitName1 == "MENTAL HEALTH - INTERMEDATE"] = "MENTAL HEALTH - INTERMEDIATE"
J1$BenefitName1[J1$BenefitName1 == "MINOR DENTAL CARE - ADULTS"] = "MINOR DENTAL CARE - ADULT"
J1$BenefitName1[J1$BenefitName1 == "MINOR DENTAL CARE ADULT"] = "MINOR DENTAL CARE - ADULT"
J1$BenefitName1[J1$BenefitName1 == "MINOR DENTAL CARE CHILD"] = "MINOR DENTAL CARE - CHILD"
J1$BenefitName1[J1$BenefitName1 == "NAPRAPATHIC SERVICE"] = "NAPRAPATHIC SERVICES"
J1$BenefitName1[J1$BenefitName1 == "NATUROPATHY"] = "NATUROPATHY SERVICES"
J1$BenefitName1[J1$BenefitName1 == "NON PREFERRED SPECIALTY DRUG"] = "NON PREFERRED SPECIALTY DRUGS"
J1$BenefitName1[J1$BenefitName1 == "NON PREFERRED SPECIALITY DRUGS"] = "NON PREFERRED SPECIALTY DRUGS"
J1$BenefitName1[J1$BenefitName1 == "NON_PREFERRED GENERIC DRUG"] = "NON PREFERRED GENERIC DRUGS"
J1$BenefitName1[J1$BenefitName1 == "NON_PREFERRED GENERICS"] = "NON PREFERRED GENERIC DRUGS"
J1$BenefitName1[J1$BenefitName1 == "NON-"] = "NON-EMERGENCY MEDICAL TRANSPORT"
J1$BenefitName1[J1$BenefitName1 == "NON- EMERGENCY NON-MEDICAL TRANSPORTATION"] = "NON-EMERGENCY MEDICAL TRANSPORT"
J1$BenefitName1[J1$BenefitName1 == "NON-EMERGENCY MEDICAL AND NON-MEDICAL TRANSPORTATION"] = "NON-EMERGENCY MEDICAL TRANSPORT"
J1$BenefitName1[J1$BenefitName1 == "NON-EMERGENCY MEDICAL TRANSPORT"] = "NON-EMERGENCY MEDICAL TRANSPORT"
J1$BenefitName1[J1$BenefitName1 == "NON-EMERGENCY MEDICAL TRANSPORTATION"] = "NON-EMERGENCY MEDICAL TRANSPORT"
J1$BenefitName1[J1$BenefitName1 == "NON-EMERGENCY NON-MEDICAL TRANSPORT"] = "NON-EMERGENCY MEDICAL TRANSPORT"
J1$BenefitName1[J1$BenefitName1 == "NON-MEDICALLY NECESSARY ORTHO"] = "NON-MEDICALLY NECESSARY ORTHODONTIA"
J1$BenefitName1[J1$BenefitName1 == "NON-MEDICALLY NECESSARY ORTHODONTIA -CHILD"] = "NON-MEDICALLY NECESSARY ORTHODONTIA - CHILD"
J1$BenefitName1[J1$BenefitName1 == "NON-MEDICALLY NECESSARY ORTHODONTIA- CHILD"] = "NON-MEDICALLY NECESSARY ORTHODONTIA - CHILD"
J1$BenefitName1[J1$BenefitName1 == "NON-MEDICALLY NECESSARY ORTHODONTIA-CHILD"] = "NON-MEDICALLY NECESSARY ORTHODONTIA - CHILD"
J1$BenefitName1[J1$BenefitName1 == "NON-MEDICALLY NECESSARY ORTHONDONTIA - CHILD"] = "NON-MEDICALLY NECESSARY ORTHODONTIA - CHILD"
J1$BenefitName1[J1$BenefitName1 == "NON-PREFERRED GENERIC DRUG"] = "NON PREFERRED GENERIC DRUGS"
J1$BenefitName1[J1$BenefitName1 == "NON-PREFERRED GENERIC DRUGS"] = "NON PREFERRED GENERIC DRUGS"
J1$BenefitName1[J1$BenefitName1 == "NON-PREFERRED GENERIC PRESCRIPTION DRUGS"] = "NON PREFERRED GENERIC PRESCRIPTION DRUGS"
J1$BenefitName1[J1$BenefitName1 == "NON-PREFERRED SPECIALTY DRUGS"] = "NON PREFERRED SPECIALTY DRUGS"
J1$BenefitName1[J1$BenefitName1 == "NON-PREGERRED GENERIC DRUGS"] = "NON PREFERRED GENERIC DRUGS"
J1$BenefitName1[J1$BenefitName1 == "NONPREFERRED GENERIC DRUGS"] = "NON PREFERRED GENERIC DRUGS"
J1$BenefitName1[J1$BenefitName1 == "NONPREFERRED SPECIALTY DRUGS"] = "NON PREFERRED SPECIALTY DRUGS"
J1$BenefitName1[J1$BenefitName1 == "OCALUSAL ADJUSTMENTS"] = "OCCLUSAL ADJUSTMENTS"
J1$BenefitName1[J1$BenefitName1 == "OCCLUSAL ADJUSTMENT"] = "OCCLUSAL ADJUSTMENTS"
J1$BenefitName1[J1$BenefitName1 == "OCCLUSAL GUARD - CHILD"] = "OCCLUSAL GUARDS - CHILD"
J1$BenefitName1[J1$BenefitName1 == "OFF LABEL PRESCRIPTION DRUGS - PREFERRED BRAND"] = "OFF LABEL PRESCRIPTION DRUGS- PREFERRED BRAND"
J1$BenefitName1[J1$BenefitName1 == "OFF LABEL PRESCRIPTION DRUGS - NON-PREFERRED BRAND"] = "OFF LABEL PRESCRIPTION DRUGS- NON-PREFERRED BRAND"
J1$BenefitName1[J1$BenefitName1 == "OPTIONAL LENS TREATMENT FOR CHILDREN"] = "OPTIONAL LENS TREATMENTS FOR CHILDREN"
J1$BenefitName1[J1$BenefitName1 == "ORTHOGNATIC SURGERY"] = "ORTHOGNATHIC SURGERY"
J1$BenefitName1[J1$BenefitName1 == "ORTHOGNATIC TREATMENT/SURGERY AND CERTAIN DENTAL/ORTHODONTIC SERVICES"] = "ORTHOGNATHIC TREATMENT/SURGERY AND CERTAIN DENTAL/ORTHODONTIC SERVICES"
J1$BenefitName1[J1$BenefitName1 == "OSTOMY"] = "OSTOMY SUPPLIES"
J1$BenefitName1[J1$BenefitName1 == "OUTPATIENT NON-DIAGNOSTIC IMAGING SERVICE/PROCEDURE"] = "OUTPATIENT NON-IMAGING DIAGNOSTIC SERVICE/PROCEDURE"
J1$BenefitName1[J1$BenefitName1 == "OUTPATIENT REHABILIATION SERVICES - COGNITIVE REHABILITATION THERAPY"] = "OUTPATIENT REHABILITATION SERVICES - COGNITIVE REHABILITATION THERAPY"
J1$BenefitName1[J1$BenefitName1 == "OUTPATIENT REHABILIATION SERVICES - POST-COCHLEAR IMPLANT AURAL THERAPY"] = "OUTPATIENT REHABILITATION SERVICES - POST-COCHLEAR IMPLANT AURAL THERAPY"
J1$BenefitName1[J1$BenefitName1 == "OUTPATIENT REHABILIATION SERVICES - PULMONARY REHABILITATION THERAPY"] = "OUTPATIENT REHABILITATION SERVICES - PULMONARY REHABILITATION THERAPY"
J1$BenefitName1[J1$BenefitName1 == "OUTPATIENT REHABILITATION SERVICES - COGNITIVE REHAB THERAPY"] = "OUTPATIENT REHABILITATION SERVICES - COGNITIVE REHABILITATION THERAPY"
J1$BenefitName1[J1$BenefitName1 == "OUTPATIENT REHABILITATION SERVICES - POST-COCHLEAR IMPLANT AND AURAL THERAPY"] = "OUTPATIENT REHABILITATION SERVICES - POST-COCHLEAR IMPLANT AURAL THERAPY"
J1$BenefitName1[J1$BenefitName1 == "PERIODONTAL ROOT SCALNG AND PLANING"] = "PERIODONTAL ROOT SCALING AND PLANING"
J1$BenefitName1[J1$BenefitName1 == "PERIODONTAL SCALING & ROOT PLANING (QUADRANT) - CHILD"] = "PERIODONTAL SCALING & ROOT PLANING - CHILD"
J1$BenefitName1[J1$BenefitName1 == "PERIRADICULAR SURGICAL PROCEDURS"] = "PERIRADUCULAR SURGICAL PROCEDURES"
J1$BenefitName1[J1$BenefitName1 == "PERIRADICULAR SURGICAL PROCEDURES"] = "PERIRADUCULAR SURGICAL PROCEDURES"
J1$BenefitName1[J1$BenefitName1 == "POST AND CORE -CHILD"] = "POST AND CORE - CHILD"
J1$BenefitName1[J1$BenefitName1 == "POST AND CORE BUILD -UP"] = "POST AND CORE BUILD-UP"
J1$BenefitName1[J1$BenefitName1 == "POSTERIOR COMPOSITE FILLINGS - ADULT"] = "POSTERIOR COMPOSITE FILLING - ADULT"
J1$BenefitName1[J1$BenefitName1 == "POSTERIOR COMPOSITE FILLINGS - ADULTS"] = "POSTERIOR COMPOSITE FILLING - ADULT"
J1$BenefitName1[J1$BenefitName1 == "POSTERIOR COMPOSITE FILLINGS - CHILD"] = "POSTERIOR COMPOSITE FILLING - CHILD"
J1$BenefitName1[J1$BenefitName1 == "POSTERIOR COMPOSITES - CHILD"] = "POSTERIOR COMPOSITE FILLING - CHILD"
J1$BenefitName1[J1$BenefitName1 == "PRESCRIPTION DRUG OTHER"] = "PRESCRIPTION DRUGS - OTHER"
J1$BenefitName1[J1$BenefitName1 == "PRESCRIPTION DRUGS OTHER"] = "PRESCRIPTION DRUGS - OTHER"
J1$BenefitName1[J1$BenefitName1 == "PRESCRIPTION DRUGS PREVENTIVE"] = "PRESCRIPTION DRUGS - PREVENTIVE"
J1$BenefitName1[J1$BenefitName1 == "PULMONARY REHABILITATIVE SERVICES"] = "PULMONARY REHABILITATION THERAPY"
J1$BenefitName1[J1$BenefitName1 == "PULMONARY REHABILATATIVE SERVICES"] = "PULMONARY REHABILITATION THERAPY"
J1$BenefitName1[J1$BenefitName1 == "PULMONARY REHABILIATION THERAPY"] = "PULMONARY REHABILITATION THERAPY"
J1$BenefitName1[J1$BenefitName1 == "PULMONARY REHABILITATION"] = "PULMONARY REHABILITATION THERAPY"
J1$BenefitName1[J1$BenefitName1 == "PULMONARY REHABILITATIVE THERAPY"] = "PULMONARY REHABILITATION THERAPY"
J1$BenefitName1[J1$BenefitName1 == "RADIOLOGY OFFICE"] = "RADIOLOGY CENTER"
J1$BenefitName1[J1$BenefitName1 == "RECEMENTATION OF SPACE MAINTAINER"] = "RECEMENTATION OF SPACE MAINTAINERS"
J1$BenefitName1[J1$BenefitName1 == "RECONSTRUCTIVE SERVICES"] = "RECONSTRUCTIVE SURGERY"
J1$BenefitName1[J1$BenefitName1 == "REMOVAL OF FIXED SPACE MAINTAINER"] = "REMOVAL OF FIXED SPACE MAINTAINERS"
J1$BenefitName1[J1$BenefitName1 == "REMOVAL OF FXED SPACE MAINTAINERS"] = "REMOVAL OF FIXED SPACE MAINTAINERS"
J1$BenefitName1[J1$BenefitName1 == "RETAIL HEALTH CLLINICS"] = "RETAIL HEALTH CLINICS"
J1$BenefitName1[J1$BenefitName1 == "RETROGRADE FILLINGS -CHILD"] = "RETROGRADE FILLINGS - CHILD"
J1$BenefitName1[J1$BenefitName1 == "ROOT CANAL THERAPY -CHILD"] = "ROOT CANAL THERAPY - CHILD"
J1$BenefitName1[J1$BenefitName1 == "ROOT CANAL THERAPY AND TREATMENT"] = "ROOT CANAL THERAPY AND RETREATMENT"
J1$BenefitName1[J1$BenefitName1 == "SEALANTS: CHILD"] = "SEALANTS - CHILD"
J1$BenefitName1[J1$BenefitName1 == "SELF-INJECTABLE AND/OR MEDICATION INJECTED IN A PRACTITIONER'S OFFICE"] = "SELF-INJECTABLE AND/OR MEDICATION INJECTED IN A PRACTITIONER OFFICE"
J1$BenefitName1[J1$BenefitName1 == "SELF INJECTABLE AND/OR MEDICATION INJECTED IN A PRACTITIONER OFFICE"] = "SELF-INJECTABLE AND/OR MEDICATION INJECTED IN A PRACTITIONER OFFICE"
J1$BenefitName1[J1$BenefitName1 == "SELF-INJECTABLE AND/OR MEDICATION INJECTED IN A PRACTITIIONER OFFICE"] = "SELF-INJECTABLE AND/OR MEDICATION INJECTED IN A PRACTITIONER OFFICE"
J1$BenefitName1[J1$BenefitName1 == "SERVICES CHARGES"] = "SERVICE CHARGES"
J1$BenefitName1[J1$BenefitName1 == "SKILLED NURSING FACILITY: DAYS 26-30"] = "SKILLED NURSING FACILITY - DAYS 26-30"
J1$BenefitName1[J1$BenefitName1 == "SKILLED NURSING FACILITY - 26-30"] = "SKILLED NURSING FACILITY - DAYS 26-30"
J1$BenefitName1[J1$BenefitName1 == "SKILLED NURSINGING FACILITY - DAYS 26-30"] = "SKILLED NURSING FACILITY - DAYS 26-30"
J1$BenefitName1[J1$BenefitName1 == "SLEEP STUDY"] = "SLEEP STUDIES"
J1$BenefitName1[J1$BenefitName1 == "SOFT LENSES OR SCLERA SHELLS FOR THE TREATMENT OF APHAKIC GLAUCOMA"] = "SOFT LENSES OR SCLERA SHELLS FOR THE TREATMENT OF APHATIC GLAUCOMA"
J1$BenefitName1[J1$BenefitName1 == "SPACE MAINTAINER: CHILD"] = "SPACE MAINTAINERS - CHILD"
J1$BenefitName1[J1$BenefitName1 == "SPACE MAINTAINER - CHILD"] = "SPACE MAINTAINERS - CHILD"
J1$BenefitName1[J1$BenefitName1 == "SPECIALTY DRUG NON-PREFERRED"] = "SPECIALTY DRUGS NON-PREFERRED"
J1$BenefitName1[J1$BenefitName1 == "SPECIFIED NON-ROUTINE DENTAL"] = "SPECIFIED NON-ROUTINE DENTAL SERVICES"
J1$BenefitName1[J1$BenefitName1 == "STERILIZATION NON WPS SERVICES"] = "STERILIZATION NON-WPS SERVICES"
J1$BenefitName1[J1$BenefitName1 == "SUBSTANCE USE DISORDER INTERMEDIATE"] = "SUBSTANCE USE DISORDERS - INTERMEDIATE"
J1$BenefitName1[J1$BenefitName1 == "SURGICAL EXTRACTIONS - CHILD"] = "SURGICAL EXTRACTION - CHILD"
J1$BenefitName1[J1$BenefitName1 == "TELEHEALTH / TELEMEDICINE"] = "TELEHEALTH/TELEMEDICINE"
J1$BenefitName1[J1$BenefitName1 == "TELEMEDICINE SERVICES"] = "TELEMEDICINE"
J1$BenefitName1[J1$BenefitName1 == "TELEMEDECINE SPECIALTY VISIT"] = "TELEMEDICINE SPECIALTY VISIT"
J1$BenefitName1[J1$BenefitName1 == "TELEMEDICINE/TELEHEALTH"] = "TELEHEALTH/TELEMEDICINE"
J1$BenefitName1[J1$BenefitName1 == "TISSSUE CONDITIONING"] = "TISSUE CONDITIONING"
J1$BenefitName1[J1$BenefitName1 == "TOBACCO USE CESSATION"] = "TOBACCO CESSATION PROGRAM"
J1$BenefitName1[J1$BenefitName1 == "VISION CORRECTION AFTER SURGERY"] = ""
J1$BenefitName1[J1$BenefitName1 == "VISION COREECTION AFTER SURGERY OR ACCIDENT"] = "VISION CORRECTION AFTER SURGERY OR ACCIDENT"
J1$BenefitName1[J1$BenefitName1 == "VISION CORRECTION AFTER SURGERY OR ACCIDENT"] = "VISION CORRECTION AFTER SURGERY OR ACCIDENT"
J1$BenefitName1[J1$BenefitName1 == "VISION HARDWARE FOR CHILDREN > $300"] = "VISION HARDWARE FOR CHILDREN >$300"
J1$BenefitName1[J1$BenefitName1 == "WELLNESS REWARDS"] = "WELLNESS PLAN BENEFIT"
J1$BenefitName1[J1$BenefitName1 == "XRAYS AND DIAGNOSTIC IMAGING (HOSPITAL)"] = "X-RAYS AND DIAGNOSTIC IMAGING"
J1$BenefitName1[J1$BenefitName1 == "VISION COREECTION AFTER SURGERY OR ACCIDENT"] = "VISION CORRECTION AFTER SURGERY OR ACCIDENT"
J1$BenefitName1[J1$BenefitName1 == "VISION CORRECTION AFTER SURGERY"] = "VISION CORRECTION AFTER SURGERY OR ACCIDENT"
J1$BenefitName1[J1$BenefitName1 == "VISION CORRECTION AFTER SURGERY OR ACCIDENT\t"] = "VISION CORRECTION AFTER SURGERY OR ACCIDENT"
J1$BenefitName1[J1$BenefitName1 == "TISSSUE CONDITIONING"] = "TISSUE CONDITIONING"
J1$BenefitName1[J1$BenefitName1 == "TOPICAL FLUORIDE"] = "TOPICAL FLOURIDE"
J1$BenefitName1[J1$BenefitName1 == "TELEHEALTH / TELEMEDICINE"] = "TELEHEALTH/TELEMEDICINE"
J1$BenefitName1[J1$BenefitName1 == "SURGICAL EXTRACTIONS - CHILD"] = "SURGICAL EXTRACTION - CHILD"
J1$BenefitName1[J1$BenefitName1 == "SUBSTANCE USE DISORDER INTERMEDIATE"] = "SUBSTANCE USE DISORDERS - INTERMEDIATE"
J1$BenefitName1[J1$BenefitName1 == "STERILIZATION NON WPS SERVICES"] = "STERILIZATION NON-WPS SERVICES"

# new version of RStudio error
x = which(J1$BenefitName1 == 'LSKDJFLSDKJ')
J1 = J1[-x, ]

# summarise J1 into J1a
J1a = J1 %>% group_by(., PlanType, Covered) %>% summarise(., BeneNum = n())
J1 %>% group_by(., PlanType) %>% summarise(., num = n())

# reorder the levels of J1a$PlanType
J1a$Order = c(8, 7, 2, 1, 10, 9, 6, 5, 4, 3)
J1a$PlanType = factor(J1a$PlanType, levels = J1a$PlanType[order(J1a$Order)])
J1a1 = J1 %>% group_by(., PlanType) %>% summarise(., Num = n()) %>% arrange(., desc(Num))
J1a1$PlanType = factor(J1a1$PlanType, levels = J1a1$PlanType[order(J1a1$Num)])
######## PRINT #5 ########
# Benefits Covered/Not Covered Numbers and Ratio = Not Covered/Covered
r5b = ggplot(J1a, aes(x = PlanType, y = BeneNum))
Plot_AIR5b1 = 
  r5b + 
  geom_bar(aes(fill = Covered), stat = 'identity', position = 'fill', alpha = 0.8, width = 0.6) +
  theme_economist_white(gray_bg = F) +
  scale_fill_brewer(palette = 'Set2', name = 'Benefit Covered') +
  guides(color = 'legend') +
  ggtitle('Plan Type vs. Benefit Cover Ratio') +
  xlab('Plan Type') +
  ylab('Number of Benefits') +
  theme(legend.position = 'right', plot.title = element_text(hjust = 0.5)) 

r1a1 = ggplot(J1a1, aes(x = PlanType, y = Num))
Plot_B1 = r1a1 +
  geom_bar(aes(fill = rownames(J1a1)), stat = 'identity', alpha = 0.8, width = 0.6) +
  theme_bw() +
  coord_flip() +
  scale_fill_brewer(palette = 'Set2') +
  guides(fill = F) +
  ggtitle('Benefit Numbers of Different Plan Types') +
  xlab('Number of Benefits') +
  ylab('Plan Type') +
  theme(plot.title = element_text(hjust = 0.5)) +
  geom_text(aes(label = Num), vjust = 0.5, hjust = -0.01)

Plot_AIR5b2 = 
  r5b + 
  geom_bar(aes(fill = Covered), stat = 'identity', position = 'dodge', alpha = 0.8) +
  theme_economist_white(gray_bg = F) +
  scale_fill_brewer(palette = 'Set2')

######## BenefitsCostSharing ########
# the next two steps help correct the typo error above
BCS2 = J1 %>% select(., PlanType, BenefitName) %>% arrange(., BenefitName, PlanType)
BCS2a = unique(BCS2)

# Common Benefits & Special Benefits
# count COVERED benefits number
J2 = J1 %>% filter(., Covered == 'COVERED') %>%
  group_by(., BenefitName1, PlanType) %>%
  summarise(., num = n()) %>%
  arrange(., desc(num))
# PlanType & its COVERED unique benefit number: Benefit Variety
J2a = J2 %>% group_by(., PlanType) %>%
  summarise(., num = n()) %>%
  arrange(., desc(num))
J2a$PlanType = factor(J2a$PlanType, levels = J2a$PlanType[order(J2a$num)])
######## PRINT #6 ########
b1 = ggplot(J2a, aes(x = PlanType, y = num))
Plot_B1 = b1 +
  geom_bar(aes(fill = rownames(J2a)), stat = 'identity', alpha = 0.8, width = 0.6) +
  theme_bw() +
  coord_flip() +
  scale_fill_brewer(palette = 'Set2',
                    name = 'Plan Type',
                    labels = c('PPO', 'HMO', 'POS', 'EPO', 'INDEMNITY')) +
  guides(color = 'legend') +
  ggtitle('Benefit Variety of Plan Type') +
  xlab('Plan Type') +
  ylab('Number of Benefits') +
  theme(legend.position = 'right', plot.title = element_text(hjust = 0.5)) 

######## may go to trash ########
# to get the covered benefits and its total number in each plan type
unique(J2$PlanType)
# [1] "HMO"       "PPO"       "POS"       "EPO"       "INDEMNITY"
J2hmo = J2 %>% filter(., PlanType == 'HMO')
J2ppo = J2 %>% filter(., PlanType == 'PPO')
J2pos = J2 %>% filter(., PlanType == 'POS')
J2epo = J2 %>% filter(., PlanType == 'EPO')
J2ind = J2 %>% filter(., PlanType == 'INDEMNITY')

# inner_jion by BenefitName to get the common benefits
J3 = inner_join(J2hmo, J2ppo, by = 'BenefitName1', suffix = c('.hmo', '.ppo'))
J3 = inner_join(J3, J2pos, by = 'BenefitName1', suffix = c('.', '.pos'))
J3 = J3[, -c(6, 7)]
J3 = inner_join(J3, J2epo, by = 'BenefitName1', suffix = c('.', '.epo'))
J3 = J3[, -c(8, 9)]
J4 = inner_join(J3, J2ind, by = 'BenefitName1', suffix = c('.', '.ind'))


######## new work flow ########
# anti_join to find the unique
J2b = J2 %>% select(., BenefitName1, PlanType) %>%
  group_by(., BenefitName1) %>%
  summarise(., num.bs = n()) %>%
  arrange(., desc(num.bs))
# to see common benefits and unique benefits
J2c = J2b %>% filter(., num.bs == 5 | num.bs == 1)
J2d = J2b %>% filter(., num.bs == 2 | num.bs == 1)
# join back with J2 to get the num
J4 = inner_join(J2b, J2, by = 'BenefitName1')
J4a = J4 %>% filter(., num.bs == 5 | num.bs == 1)
J4b = inner_join(J2d, J2, by = 'BenefitName1') %>% arrange(., desc(num.bs), desc(num))
J4c = J4b %>% group_by(., PlanType) %>% top_n(., 5)
J4c1 = J4c %>% arrange(., BenefitName1)
J4c2 = J4c %>% arrange(., PlanType)

chmo = J4c2 %>% filter(., PlanType == "HMO")
chmo$BenefitName1 = factor(chmo$BenefitName1, levels = chmo$BenefitName1[order(chmo$num)])
cppo = J4c2 %>% filter(., PlanType == "PPO")
cppo$BenefitName1 = factor(cppo$BenefitName1, levels = cppo$BenefitName1[order(cppo$num)])
cpos = J4c2 %>% filter(., PlanType == "POS")
cpos = cpos[6:13,]
cpos$BenefitName1 = factor(cpos$BenefitName1, levels = cpos$BenefitName1[order(cpos$num)])
cepo = J4c2 %>% filter(., PlanType == "EPO")
cepo$BenefitName1 = factor(cepo$BenefitName1, levels = cepo$BenefitName1[order(cepo$num)])
cind = J4c2 %>% filter(., PlanType == "INDEMNITY")
cind$BenefitName1 = factor(cind$BenefitName1, levels = cind$BenefitName1[order(cind$num)])

######## PRINT #7 #########
# HMO
bhmo = ggplot(chmo, aes(x = BenefitName1, y = num))
Plot_B2 = bhmo +
  geom_bar(aes(fill = BenefitName1), stat = 'identity', alpha = 0.8, width = 0.6) +
  theme_bw() +
  coord_flip() +
  scale_fill_brewer(palette = 'Set2') +
  guides(fill = F) +
  xlab('') +
  ylab('HMO') +
  geom_text(aes(label = BenefitName1), vjust = 0.4, hjust = 1) +
  theme(axis.text.x = element_blank(), axis.text.y = element_blank())
# PPO
bppo = ggplot(cppo, aes(x = BenefitName1, y = num))
Plot_B3 = bppo +
  geom_bar(aes(fill = BenefitName1), stat = 'identity', alpha = 0.8, width = 0.6) +
  theme_bw() +
  coord_flip() +
  scale_fill_brewer(palette = 'Set2') +
  guides(fill = F) +
  xlab('') +
  ylab('PPO') +
  geom_text(aes(label = BenefitName1), vjust = 0.4, hjust = 1) +
  theme(axis.text.x = element_blank(), axis.text.y = element_blank())
# POS
bpos = ggplot(cpos, aes(x = BenefitName1, y = num))
Plot_B4 = bpos +
  geom_bar(aes(fill = BenefitName1), stat = 'identity', alpha = 0.8, width = 0.6) +
  theme_bw() +
  coord_flip() +
  scale_fill_brewer(palette = 'Set2') +
  guides(fill = F) +
  xlab('') +
  ylab('POS') +
  geom_text(aes(label = BenefitName1), vjust = 0.4, hjust = 1) +
  theme(axis.text.x = element_blank(), axis.text.y = element_blank())
# EPO
bepo = ggplot(cepo, aes(x = BenefitName1, y = num))
Plot_B5 = bepo +
  geom_bar(aes(fill = BenefitName1), stat = 'identity', alpha = 0.8, width = 0.6) +
  theme_bw() +
  coord_flip() +
  scale_fill_brewer(palette = 'Set2') +
  guides(fill = F) +
  xlab('') +
  ylab('EPO') +
  geom_text(aes(label = BenefitName1), vjust = 0.4, hjust = 1) +
  theme(axis.text.x = element_blank(), axis.text.y = element_blank())
# INDEMNITY
bind = ggplot(cind, aes(x = BenefitName1, y = num))
Plot_B5 = bind +
  geom_bar(aes(fill = BenefitName1), stat = 'identity', alpha = 0.8, width = 0.6) +
  theme_bw() +
  coord_flip() +
  scale_fill_brewer(palette = 'Set2') +
  guides(fill = F) +
  xlab('') +
  ylab('INDEMNITY') +
  geom_text(aes(label = BenefitName1), vjust = 0.4, hjust = 1) +
  theme(axis.text.x = element_blank(), axis.text.y = element_blank())

######## TO BE CONTINUED ########
######## PlanType & AverageRate ########
PA3 = PlanAttributes %>% select(., PlanType, HIOSProductId)
UR1 = UnifiedRate %>% select(., Plan.Type, Product.ID, Plan.Average.Current.Rate.PMPM)
