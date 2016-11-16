library(jsonlite)
library(stringr)
library(plyr)
library(dplyr)
library(ggplot2)
library(RColorBrewer)
library(scales)
library(anonymizer)
library(parallel)
library(data.table)
library(stringr)
library(lettercase)
library(qdapRegex)
# library(sqldf)

labelDrugs = function(data) {
  # data = select(data)
  return(data)
}

readIn = function(fName) {
  data = fread(fName, header = TRUE,showProgress= TRUE)
  data = data$description
  return(data)
}

ec2 = FALSE
if (ec2 == TRUE) {
  darknetDirectory = "~/Data/Darknet"
  processedCSVDirectory = '~/Drug_Project/Data'
} else {
  darknetDirectory = "/Volumes/SDExpansion/Data Files/Darknet Data"
  processedCSVDirectory = "~/Coding/NYC_Data_Science_Academy/Projects/Drug_Project/Data"
}

setwd(darknetDirectory)
darkentMarketFiles = list.files(path = './grams', recursive = TRUE, pattern = "\\.csv$", no.. = TRUE, full.names = TRUE)
dnmData = lapply(darkentMarketFiles[1:length(darkentMarketFiles)], function(x) readIn(x))
# dnmData = lapply(darkentMarketFiles[1:4], function(x) readIn(x))
dnmData = ldply(dnmData, data.frame)
# dnmData = as.data.frame(read.csv('DNMdataUnsorted.csv'))
dnmData = labelDrugs(dnmData)
# setwd(processedCSVDirectory)
write.csv(dnmData, 'DNMdataDescriptionsOnly.csv')