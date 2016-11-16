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

labelDrugs = function(data,column) {
  data = data[!is.na(data$market_name),]
  drugNames <- unique(tolower(c("Spice","Speed","LSD","MDMA","Crystal Meth","Kush","Cocaine","Hash","Heroin","Methadone","Ketamin","Weed","Xanax","Ritalin","Adderal","Mushroom",
                                "Psilocybe","Bud","GHB","Cannabis","Hashish","Mast","Mephedrone","DMT","Methylone","Ethylone","alprazolam","methAmphetamin","Amphetamin","Opium","Ecstasy","Tren","Durabolin","Clomid",
                                "Testosterone Enanthate","Ambien","Morphine","Salvia","Cialis","Suboxone","Marijuana","Diazepam","Hydrocodone","Tramadol","Nitrazepam","Viagra",
                                "OxyContin", "Sustanon", "buprenorphine", "T3", "Restoril", "Ativan", "Codeine","Lorazepam","Levitra","Molly","Testosterone Cypionate",
                                "Test C","Test E","Test P","Prozac","Xenical","Celebrex","Cymbalta","Azulfidine","Flagyl","Zyban","Propecia","Imovane","Soma",
                                "METHOXPHENIDINE","Paxil","Zithromax","DNP","Alli","Valium","PCP","Amfetamin","Dianabol","HYDROMORPHONE","Sativa","Coke","Lysergic","Acid",
                                "Shrooms","Oxycodon","Vicodin","Concerta","Carisoprodol","Zopiclone","Finasteride","modafin","provigil","Nandrolone", 
                                "Citalopram","Topiramate","Butyrfentanyl","rivotril","dormicum","mogadon","heroine"
  )))
  drugNamesRegex = paste(drugNames, collapse = "|")
  drugNamesRegex =  gsub(pattern = " ", replacement = "*", x = drugNamesRegex,ignore.case = TRUE)
  # drugNamesRegex = paste0("(",drugNamesRegex,")")
  keywordsToRemove <- sort(c("Brownie","Gummi","tobacco","kisses","home test","exemption","stronger than","butter","vape pen","Hashoel","sample","cookie","pollen","wax","Sachet","likes","seeds","gatorade","sampler","half price","pack","boxes"))
  keywordsToRemoveRegex = paste(keywordsToRemove, collapse = "|")
  keywordsToRemoveRegex =  gsub(pattern = " ", replacement = "*", x = keywordsToRemoveRegex,ignore.case = TRUE)
  data$column = tolower(data$column)
  Drug_Type = unlist(lapply(data$column, (function (x) str_extract(x,drugNamesRegex))))
  notRemoved = unlist(lapply(data$column, (function (x) !is.na(str_extract(x,keywordsToRemoveRegex)))))
  Drug_Type[notRemoved] = NA
  setwd(processedCSVDirectory)
  write.csv(unique(data$column[is.na(Drug_Type)]),'Unique_Drug_Info.csv')
  data = data[!is.na(Drug_Type),]
  return(data)
}

readIn = function(fName) {
  data = fread(fName, header = TRUE,showProgress= TRUE)
  data$hash = NULL
  # data$X = NULL
  data$description = NULL
  data$image_link = NULL
  data$item_link = NULL
  data$vendor_name = NULL
  data$V11 = NULL
  data$add_time = as.Date(as.numeric(data$add_time)/60/60/24, origin = "1970-01-01")
  data$Sheet_Date = as.Date(substr(fName,9,18),'%Y-%m-%d')
  print(fName)
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
dnmData = ldply(dnmData, data.frame)
# dnmData = as.data.frame(read.csv('DNMdataUnsorted.csv'))
dnmDataSorted = labelDrugs(dnmData,"name")
dnmDataDescriptions = labelDrugs(dnmData,"description")
# setwd(processedCSVDirectory)
write.csv(dnmDataSorted, 'DNMdataSomewhatSorted.csv')
write.csv(as.data.frame(dnmDataDescriptions$description), 'DNMdataDescriptionsOnly.csv')