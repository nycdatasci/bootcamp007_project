library("dplyr", lib.loc="/Library/Frameworks/R.framework/Versions/3.3/Resources/library")
library(stringr)


fileYear = seq(0,14)
fileYear = str_pad(fileYear, 2, pad = "0")

allFiles = paste0('cbp', fileYear , 'co.txt')


wd = '~/datascience/Shiny/data'



setwd(wd)



firstLoopFlg = TRUE

for (f in allFiles) {
  print(paste("Working on file", f))
  
  l  <- read.csv(f, stringsAsFactors = FALSE)
  
  
  l <- l %>% filter((substr(l$naics,3, 6) == '----')  | substr(l$naics,4, 6) == '///') 
  l$yr <- as.numeric(paste0('20', substr(f,4, 5)))
  
# roll up by state and industry
  stateIndustry <- l %>% group_by(yr, fipstate, naics) %>%  
    summarize(num_emp = sum(emp), tot_payroll = sum(ap), num_est = sum(est),
              num_est_small = sum(n1_4, n5_9 + n5_9 + n10_19 + n10_19 + n20_49 + n20_49 + n50_99 + n50_99),
              num_est_med = sum(n100_249 + n250_499),
              num_est_large = sum(n500_999 + n1000)) %>% 
    ungroup
# roll up top level by county
  byCounty <- l %>% filter(naics=='------') %>% group_by(yr, fipstate, fipscty) %>%  
    summarize(num_emp = sum(emp), tot_payroll = sum(ap), num_est = sum(est),
              num_est_small = sum(n1_4, n5_9 + n5_9 + n10_19 + n10_19 + n20_49 + n20_49 + n50_99 + n50_99),
              num_est_med = sum(n100_249 + n250_499),
              num_est_large = sum(n500_999 + n1000)) %>% 
    ungroup
  
  
  
  if (firstLoopFlg) {
    busData = stateIndustry
    byCountyData = byCounty
    firstLoopFlg = FALSE
  }  else {
    busData <- bind_rows(busData, stateIndustry)
    byCountyData <- bind_rows(byCountyData, byCounty)
  }

}

save(busData, file='busData1')
save(byCountyData, file='byCountyData1')
rm(list=ls())



