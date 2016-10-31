# load diply library
library(dplyr)
library(googleVis)
source('helpers.R')

# global.R for storing the data frame
load('data/infections.rda')

# load the infections to use
infectionChoices = list('ALL' = 'ALL',
                        'Central Line -- Bloodstream' = 'CLABSI',
                        'Catheter -- Urinary Tract' = 'CAUTI',
                        'Clostridium Difficile' = 'C.diff',
                        'Methicillin-Resistant Staphylococcus Aureu (MRSA)' = 'MRSA',
                        'Surgical Site -- Abdominal' = 'SSI: Abdominal',
                        'Surgical Site -- Colon' = 'SSI: Colon'
                        )

# get information about the state and territories
stateAbbrs = sort(levels(infectionsDF$State))
stateCount = length(stateAbbrs)

# create data from for state choices which list the
stateChoices = list()
for(abb in stateAbbrs) {
  stateName = abb2state(abb)
  if(typeof(stateName) == 'character') {
    stateChoices[[stateName]] = abb
  }
}