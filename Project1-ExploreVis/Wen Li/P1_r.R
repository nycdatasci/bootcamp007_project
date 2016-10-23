######## library ########
library(ggplot2)
library(ggthemes)
library(dplyr)
library(RColorBrewer)
library(googleVis)
library(reshape2)


######## loading data ########
BenefitsCostSharing = read.csv("health-insurance-marketplace/BenefitsCostSharing.csv", header = T, stringsAsFactors = F)
Rate = read.csv("health-insurance-marketplace/Rate.csv", header = T, stringsAsFactors = F)
PlanAttributes = read.csv("health-insurance-marketplace/PlanAttributes.csv", header = T, stringsAsFactors = F)
StandardAgeRatio = read.csv("health-insurance-marketplace/StandardAgeRatio.csv", header = T, stringsAsFactors = F)
StandardAgeRatio$Age[StandardAgeRatio$Age == '64 and Older'] = '64+'

######## PRINT #0 ########
# convert the character Age back to continuous
StandardAgeRatio1 = StandardAgeRatio
StandardAgeRatio1$Age[StandardAgeRatio1$Age == '0-20'] = '20'
StandardAgeRatio1$Age[StandardAgeRatio1$Age == '64+'] = '64'
StandardAgeRatio1$Age = as.numeric(StandardAgeRatio1$Age)

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

######## dataset cleaning 1 ########
######## dataset cleaning 2 ########


######## Rate3: the length of Plan ########
duration2 =
  Rate3 %>%
  group_by(., RateEffectiveDate, RateExpirationDate) %>%
  summarise(., Avg = mean(months))
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
  ylab('Plan Average Rate (Dollars)') +
  theme(legend.position = 'right', plot.title = element_text(hjust = 0.5))

######## PRINT #2 ########
# use Rate4 to create a violin plot, has a general idea of all insurance plan for individual
r4a = ggplot(data = Rate4_1, aes(x = AgeGroup, y = IndividualRate1, na.rm = T))
Plot_AIR4ai = r4a +
  geom_violin(aes(fill = AgeGroup), alpha = 0.4) +
  coord_cartesian(ylim = c(0, 1200)) +
  theme_economist_white(gray_bg = F) +
  scale_fill_brewer(palette = 'Set2', name = 'Plan Length\n(Months)') +
  guides(color = 'legend') +
  ggtitle('Age and Plan Length vs. Plan Rate') +
  xlab('Age Group') +
  ylab('Plan Rate') +
  theme(legend.position = 'right', plot.title = element_text(hjust = 0.5))


######## Rate5: Add new variables (Tobacco4, IndividualRate4) ########
# combine a new subset add a new column Tobacco
# in general, the individual rate affected by Age and Tabacco
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


######## Family Option Explore ########
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
            Avg = mean(IndividualRate1, na.rm = T))
write.table(AvgGroup, file = 'AvgGroup.csv', sep = ',', row.names = F)

######## googleVis GeoChart 1 ########
######## PRINT #4 ########
Plot_State = gvisGeoChart(AvgGroup, 'StateCode', 'Avg', 
                        options = list(region = "US", 
                                       displayMode = "regions", 
                                       resolution = "provinces",
                                       colorAxis = "{colors: ['#e0f3db', '#a8ddb5', '#43a2ca']}",
                                       datalessRegionColor = '#ffffff'))
plot(Plot_State)


######## BenefitsCostSharing & PlanAttributes ########
BCS1 = mutate_each(BenefitsCostSharing, funs(tolower))
PA1 = PlanAttributes %>%
  group_by(., PlanType) %>% 
  summarise(., num = n())
PA2 = PlanAttributes[, c('PlanId', 'PlanType')]
PA2 = unique(PA2)
J1 = left_join(BenefitsCostSharing, PA2, by = 'PlanId')
J1$Covered = J1$IsCovered
J1 = mutate_each(J1, funs(toupper))
J1$Covered[J1$Covered == ''] = 'NOT COVERED'


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
  ylab('Number of Benefits') +
  xlab('Plan Type') +
  theme(plot.title = element_text(hjust = 0.5))

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
