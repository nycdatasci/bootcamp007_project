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
  # data = data[!is.na(data$market_name),]
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
  # data$description = tolower(data$description)
  Drug_Type = unlist(lapply(data$description, (function (x) str_extract(x,drugNamesRegex))))
  notRemoved = unlist(lapply(data$description, (function (x) !is.na(str_extract(x,keywordsToRemoveRegex)))))
  Drug_Type[notRemoved] = NA
  setwd(processedCSVDirectory)
  write.csv(unique(data$description[is.na(Drug_Type)]),'Unique_Drug_Info.csv')
  # data = as.data.frame(data[!is.na(Drug_Type),])
  return(data)
}

readIn = function(fName) {
  data = fread(fName, header = TRUE,showProgress= TRUE, stringsAsFactors = FALSE)
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
darkentMarketFiles = list.files(path = './grams', recursive = TRUE, pattern = "Silk\\S*\\.csv$", no.. = TRUE, full.names = TRUE)
# dnmData = lapply(darkentMarketFiles[1:length(darkentMarketFiles)], function(x) readIn(x))
dnmData = lapply(darkentMarketFiles[seq.int(from = 1, to = length(darkentMarketFiles), length(darkentMarketFiles)/2)], function(x) readIn(x))
dnmData = ldply(dnmData, data.frame)
# dnmData = as.data.frame(read.csv('DNMdataUnsorted.csv'))
dnmData = labelDrugs(dnmData)
# setwd(processedCSVDirectory)
write.csv(dnmData, 'DNMdataDescriptionsOnly.csv')