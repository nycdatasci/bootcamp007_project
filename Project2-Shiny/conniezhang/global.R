# convert matrix to dataframe
#state_stat <- data.frame(state.name = rownames(state.x77), state.x77)
# remove row names
#rownames(state_stat) <- NULL
# create variable with colnames as choice
#choice <- colnames(state_stat)[-1]

## loading libraries

library(dplyr)
library(varhandle)
library(googleVis)
library(DT)

## 1. loading the data into R

TimelyEffCare = read.csv("~/TimelyEffectiveCareHospital.csv")

## 2. data cleaning: remove all the entries without score

TimelyEffCare = TimelyEffCare %>% filter (Score != "Not Available")

sum(is.na(TimelyEffCare))  ## show 3 records with NA value
sum(is.na(TimelyEffCare$Provider.ID)) ## show 3 records with NA value

TimelyEffCare %>% filter(is.na(Provider.ID) == 1) ## get 3 blank rows

TimelyEffCare = TimelyEffCare %>% filter(is.na(Provider.ID) == 0) ## remove blk rows

## unfactor score and sample columns and remove the NA rows (3283 rows removed)

TimelyEffCare$Score = unfactor(TimelyEffCare$Score)
TimelyEffCare = filter(TimelyEffCare, is.na(TimelyEffCare$Score) == 0)
TimelyEffCare$Sample = unfactor(TimelyEffCare$Sample)

## build up total score from sample ( need to review after understanding the data)

###TimelyEffCare$TotalScore = TimelyEffCare$Score * TimelyEffCare$Sample

## investigate the data
conditionChk = list()
condChkMeasure = list()
CondtionsToCare = unique(TimelyEffCare$Condition)
for (i in 1:length(CondtionsToCare)) {
  conditionChk[[i]] = TimelyEffCare %>% filter(Condition == CondtionsToCare[i])
  condChkMeasure[[i]] = unique(conditionChk[[i]]$Measure.Name)
}

## create sub-dataframe to this projects:

PreventCare = filter(TimelyEffCare, Condition == 'Preventive Care')
Pneumonia = filter(TimelyEffCare, Condition == 'Pneumonia')
PegDelCare = filter(TimelyEffCare, Condition =='Pregnancy and Delivery Care')
HeartFailure = filter(TimelyEffCare, Condition == 'Heart Failure')
ChildrenAsthma = filter(TimelyEffCare, Condition == "Children's Asthma")
ColonoscopyCare = filter(TimelyEffCare, Condition == 'Colonoscopy care')

# add a coloumn for easy process
ChildrenAsthma$TScore = ChildrenAsthma$Score*ChildrenAsthma$Sample
ColonoscopyCare$TScore = ColonoscopyCare$Score*ColonoscopyCare$Sample
HeartFailure$TScore = HeartFailure$Score*HeartFailure$Sample
PegDelCare$TScore = PegDelCare$Score* PegDelCare$Sample
Pneumonia$TScore = Pneumonia$Score*Pneumonia$Sample
PreventCare$TScore = PreventCare$Score* PreventCare$Sample

# build input choice

choices = c("Colonoscopy Care",
               "Children's Asthma Care",
               "Heart Failure Care",
               "Pneumonia Care",
               "Preventive Care",
               "Pregnancy and Delivery Care")

regionChoice = list("United States" = "NationWide",
                    "Alabama" = "AL", "Alaska" =	"AK","Arizona" = "AZ",
                     "Arkansas"= "AR", "California"	= "CA", "Colorado" = "CO",
                     "Connecticut" = "CT", "Delaware"	= "DE","Florida" = "FL",
                     "Georgia" = "GA","Hawaii"	= "HI","Idaho" = "ID","Illinois" = "IL",
                     "Indiana"	="IN","Iowa"	=  "IA","Kansas"	="KS","Kentucky" ="KY",
                     "Louisiana"	= "LA","Maine"	=  "ME","Maryland" = "MD",
                     "Massachusetts" = "MA","Michigan" = "MI",
                     "Minnesota" = "MN","Mississippi" = "MS","Missouri" = "MO",
                     "Montana" = "MT","Nebraska"	=  "NE", "Nevada" =	"NV",
                     "New Hampshire" = "NH","New Jersey" = "NJ","New Mexico" = "NM",
                     "New York" = "NY","North Carolina" = "NC",
                     "North Dakota"	= "ND","Ohio" = "OH","Oklahoma" = "OK",
                     "Oregon" = "OR","Pennsylvania"	= "PA","Rhode Island" = "RI",
                     "South Carolina" = "SC","South Dakota" = "SD",
                     "Tennessee" = "TN","Texas" =	"TX","Utah" =	"UT",
                     "Vermont" = "VT","Virginia" = "VA","Washington" = "WA",
                     "West Virginia" = "WV","Wisconsin"	= "WI", "Wyoming"	=  "WY")

# convert abbrivation of state to full name

abbr2state <- function(abbr){
  ab    <- tolower(c("AL",
                     "AK", "AZ", "KS", "UT", "CO", "CT",
                     "DE", "FL", "GA", "HI", "ID", "IL",
                     "IN", "IA", "AR", "KY", "LA", "ME",
                     "MD", "MA", "MI", "MN", "MS", "MO",
                     "MT", "NE", "NV", "NH", "NJ", "NM",
                     "NY", "NC", "ND", "OH", "OK", "OR",
                     "PA", "RI", "SC", "SD", "TN", "TX",
                     "CA", "VT", "VA", "WA", "WV", "WI",
                     "WY", "DC"))
  st    <- c("Alabama",
             "Alaska", "Arizona", "Kansas",
             "Utah", "Colorado", "Connecticut",
             "Delaware", "Florida", "Georgia",
             "Hawaii", "Idaho", "Illinois",
             "Indiana", "Iowa", "Arkansas",
             "Kentucky", "Louisiana", "Maine",
             "Maryland", "Massachusetts", "Michigan",
             "Minnesota", "Mississippi", "Missouri",
             "Montana", "Nebraska", "Nevada",
             "New Hampshire", "New Jersey", "New Mexico",
             "New York", "North Carolina", "North Dakota",
             "Ohio", "Oklahoma", "Oregon",
             "Pennsylvania", "Rhode Island", "South Carolina",
             "South Dakota", "Tennessee", "Texas",
             "California", "Vermont", "Virginia",
             "Washington", "West Virginia", "Wisconsin",
             "Wyoming", "District of Columbia")
  st[match(tolower(abbr), ab)]
}
