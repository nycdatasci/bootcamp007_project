library(jsonlite)
library(stringr)
library(dplyr)
library(ggplot2)
library(RColorBrewer)
library(scales)
library(anonymizer)
library(parallel)
library(data.table)

anonymiseColumns <- function(df, colIDs) {
  id <- if(is.character(colIDs)) match(colIDs, names(df)) else colIDs
  for(id in colIDs) {
    prefix <- sample(LETTERS, 1)
    suffix <- as.character(as.numeric(as.factor(df[[id]])))
    df[[id]] <- paste(prefix, suffix, sep="")
  }
  names(df)[id] <- paste("V", id, sep="")
  df
}

simpleCap <- function(x) {
  s <- strsplit(x, " ")[[1]]
  paste(toupper(substring(s, 1,1)), substring(s, 2),
        sep="", collapse=" ")
}


cleanupCSV = function(data) {
  print(1)
  # print(head(data))
  data = select(data, Market_Name = market_name, Vendor_Name = vendor_name, Price = price, Item_Name_Full_Text = name, Time_Added = add_time, Shipped_From = ship_from, Sheet_Date)
  data = data[!is.na(data$Market_Name),]
  data$Time_Added = as.numeric(data$Time_Added)
  data$Time_Added = as.Date(data$Time_Added/60/60/24, origin = "1970-01-01")
  data$Drug_Quantity_In_Order = NA
  data$Drug_Quantity = NA
  data$Drug_Quantity_In_Order_Unit = NA
  data$Drug_Weight = NA
  data$Drug_Weight_Unit = NA
  data$Drug_Weight_Converted_To_Grams = NA
  data$Drug_Weight_With_Unit = NA
  data$Drug_Type = NA
  data$Price_Per_Gram = NA
  data$Shipped_From = (as.character(data$Shipped_From))
  data$Drug_Type = (as.character(data$Drug_Type))
  data$Item_Name_Full_Text = (as.character(data$Item_Name_Full_Text))
  data = addBTC(data)
  print(2)
  data = removeStrangeCountries(data)
  print(3)
  data = renameCountries(data)
  print(4)
  data = labelDrugs(data)
  print(5)
  data = renameDrugs(data)
  print(6)
  data = findQuantity(data)
  print(7)
  data = splitUnits(data)
  print(8)
  data = splitQuantities(data)
  print(9)
  data = find1g(data)
  print(10)

  data$Drug_Quantity_In_Order = NULL
  data$X = NULL
  data$Item_Name_Full_Text = NULL
  data$Vendor_Name = NULL
  data$Drug_Quantity = NULL
  data$Drug_Quantity_In_Order_Unit = NULL
  data$Drug_Weight = NULL
  data$Price = NULL
  data$Drug_Weight_Unit = NULL
  # data$Drug_Weight = round(data$Drug_Weight,3)
  return(data)
}

removeStrangeCountries = function(data) {
  
  keywords = c("n/a","Internet","Torland","Undeclared","Somewhere","eu","my pm","christmas","China or EU","World","anywhere","not specified", "undisclosed", "the united snakes of captivity", "the underground")
  for (i in 1:length(data$Shipped_From)) {
    for (j in keywords) {
      if (grepl(j, data$Shipped_From[i], ignore.case=TRUE) == TRUE) {
        data$Shipped_From[i] = "unknown"
        break
      }
    }
    if (data$Shipped_From[i] != "unknown") {
      for (j in countryList) {
        if (grepl(j, data$Shipped_From[i], ignore.case=TRUE) == TRUE) {
          data$Shipped_From[i] = j
          break
        }
      }
    }
  }
  return(data)
}

# removeStrangeCountries = function(data) {
#   keywords = c("n/a","Internet","Torland","Undeclared","Somewhere","eu","my pm","christmas","China or EU","World","anywhere","not specified", "undisclosed", "the united snakes of captivity", "the underground")
#   drugFoundMatrix = sapply(keywords, regexpr, data$Shipped_From, ignore.case=TRUE)
#   data$Shipped_From[apply(drugFoundMatrix > -1, 1, any)] = "Unknown"
#   data$Shipped_From[data$Shipped_From == ""] = "Unknown"
#   data$Shipped_From = tolower(data$Shipped_From)
#   # data$Shipped_From = simpleCap(data$Shipped_From)
#   return(data)
# }


renameCountries = function(data) {
  countryList = c("argentina", "australia","austria", "bangladesh", "belgium", "bulgaria", "canada", "china","colombia","czech republic", "denmark", "finland", "france", "georgia", 
                  "germany", "germany ", "germany ", "guatemala","guernsey", "holland", "hong kong sar china", "hungary", "india", "ireland", "italy",  "latvia", "luxembourg", "mexico", "netherland", 
                  "netherlands", "new zealand", "nl", "norway", "peru", "poland", "serbia", "singapore","slovakia", "slovenia", "south africa", "spain", "sweden", "switzerland", 
                  "thailand", "the netherlands", "uk", "united kingdom", "united states", "united states of ame", "united states of america", "unknown", "us", "usa", "usa and canada", "usa only", "venezuela")
  countryNamesActual = c("argentina", "australia","austria", "bangladesh", "belgium", "bulgaria", "canada", "china","colombia","czech republic", "denmark", "finland", "france", "georgia", 
                         "germany", "germany ", "germany ", "guatemala","guernsey", "netherlands", "china", "hungary", "india", "ireland", "italy",  "latvia", "luxembourg", "mexico", "netherlands", 
                         "netherlands", "new zealand", "netherlands", "norway", "peru", "poland", "serbia", "singapore","slovakia", "slovenia", "south africa", "spain","sweden", "switzerland", 
                         "thailand", "netherlands", "united kingdom", "united kingdom", "united states", "united states", "united states", "unknown", "united states", "united states", "united states", "united states", "venezuela")
  names(countryNamesActual) = countryList
  data$Shipped_From = countryNamesActual[data$Shipped_From]
  return(data)
}



labelDrugs = function(data) {
  drugNames <- unique(tolower(c("Spice","Speed","LSD","MDMA","Crystal Meth","Kush","Cocaine","Hash","Heroin","Methadone","Ketamin","Weed","Xanax","Ritalin","Adderal","Mushroom",
                                "Psilocybe","Bud","GHB","Cannabis","Hashish","Mast","Mephedrone","DMT","Methylone","Ethylone","alprazolam","methAmphetamin","Amphetamin","Opium","Ecstasy","Tren","Durabolin","Clomid",
                                "Testosterone Enanthate","Ambien","Morphine","Salvia","Cialis","Suboxone","Marijuana","Diazepam","Hydrocodone","Tramadol","Nitrazepam","Viagra",
                                "OxyContin", "Sustanon", "buprenorphine", "T3", "Restoril", "Ativan", "Codeine","Lorazepam","Levitra","Molly","Testosterone Cypionate",
                                "Test C","Test E","Test P","Prozac","Xenical","Celebrex","Cymbalta","Azulfidine","Flagyl","Zyban","Propecia","Imovane","Soma",
                                "METHOXPHENIDINE","Paxil","Zithromax","DNP","Alli","Valium","PCP","Amfetamin","Dianabol","HYDROMORPHONE","Sativa","Coke","Lysergic","Acid",
                                "Shrooms","Oxycodon","Vicodin","Concerta","Carisoprodol","Zopiclone","Finasteride","modafin","provigil","Nandrolone"
  )))
  keywordsToRemove <- sort(c("Brownie","Gummi","tobacco","x7c0mp4ny","kisses","home test","exemption","stronger than","butter","vape pen","Hashoel","sample","cookie","pollen","wax","Sachet","likes","seeds","gatorade","sampler","half price","pack","boxes"))
  
  for (i in 1:length(data$Item_Name_Full_Text)) {
    for (j in keywordsToRemove) {
      if (grepl(j, data$Item_Name_Full_Text[i], ignore.case=TRUE) == TRUE) {
        data$Drug_Type[i] = "Remove"
        break
      }
    }
    if (data$Drug_Type[i] != "Remove" | is.na(data$Drug_Type[i])) {
      for (j in drugNames) {
        if (grepl(j, data$Item_Name_Full_Text[i], ignore.case=TRUE) == TRUE) {
          data$Drug_Type[i] = j
          break
        }
      }
    }
  }
  data = data[data$Drug_Type != "Remove",]
  return(data)
}

# labelDrugs = function(data) {
#   drugNames <- unique(tolower(c("Spice","Speed","LSD","MDMA","Crystal Meth","Kush","Cocaine","Hash","Heroin","Methadone","Ketamin","Weed","Xanax","Ritalin","Adderal","Mushroom",
#                                 "Psilocybe","Bud","GHB","Cannabis","Hashish","Mast","Mephedrone","DMT","Methylone","Ethylone","alprazolam","methAmphetamin","Amphetamin","Opium","Ecstasy","Tren","Durabolin","Clomid",
#                                 "Testosterone Enanthate","Ambien","Morphine","Salvia","Cialis","Suboxone","Marijuana","Diazepam","Hydrocodone","Tramadol","Nitrazepam","Viagra",
#                                 "OxyContin", "Sustanon", "buprenorphine", "T3", "Restoril", "Ativan", "Codeine","Lorazepam","Levitra","Molly","Testosterone Cypionate",
#                                 "Test C","Test E","Test P","Prozac","Xenical","Celebrex","Cymbalta","Azulfidine","Flagyl","Zyban","Propecia","Imovane","Soma",
#                                 "METHOXPHENIDINE","Paxil","Zithromax","DNP","Alli","Valium","PCP","Amfetamin","Dianabol","HYDROMORPHONE","Sativa","Coke","Lysergic","Acid",
#                                 "Shrooms","Oxycodon","Vicodin","Concerta","Carisoprodol","Zopiclone","Finasteride","modafin","provigil","Nandrolone"
#   )))
#   keywordsToRemove <- sort(c("Brownie","Gummi","tobacco","x7c0mp4ny","kisses","home test","exemption","stronger than","butter","vape pen","Hashoel","sample","cookie","pollen","wax","Sachet","likes","seeds","gatorade","sampler","half price","pack","boxes"))
#   for (drug in drugNames) {
#     # print(str_extract(tolower(data$Item_Name_Full_Text[is.na(data$Drug_Type)]), pattern = drug))
#     data$Drug_Type[is.na(data$Drug_Type)] = str_extract(tolower(data$Item_Name_Full_Text[is.na(data$Drug_Type)]), pattern = drug)
#   }
#   # data = remover(data, keywords = drugNames, columnToReplace = 'Drug_Type', removeMissing = TRUE, removeKeyword = FALSE)
#   data = remover(data, keywords = keywordsToRemove, columnToReplace = 'Drug_Type', removeMissing = TRUE, removeKeyword = TRUE)
#   return(data)
# }


renameDrugs = function(data) {
  drugNamesActual = c("Speed (Amphetamine)","LSD (Lysergic Acid)","Ecstasy (MDMA)","Crystal Methamphetamine","Marijuana","Cocaine","Marijuana","Heroin","Methadone","Ketamine","Marijuana","Xanax (Alprazolam)","Ritalin","Speed (Amphetamine)","Mushrooms",
                      "Mushrooms","Marijuana","GHB","Marijuana","Masteron","Mephedrone","DMT","Ethylone","Xanax (Alprazolam)","Speed (Amphetamine)","Opium","Ecstasy (MDMA)", "Trenbolone","Nandrolone","Clomid",
                      "Testosterone Enanthate","Ambien","Morphine","Salvia","Cialis","Suboxone","Marijuana","Diazepam","Hydrocodone","Tramadol","Nitrazepam","Viagra",
                      "OxyContin", "Sustanon", "Buprenorphine", "T3 (Triiodothyronine)", "Restoril (Temazepam)", "Lorazepam", "Codeine","Lorazepam","Levitra (Vardenafil)","Ecstasy (MDMA)","Methylone","Testosterone Cypionate",
                      "Testosterone Cypionate","Testosterone Enanthate", "Testosterone Propionate", "Crystal Methamphetamine","Prozac (Fluoxetine)","Xenical","Celebrex","Cymbalta","Sulfasalazine","Flagyl (Metronidazole)","Zyban","Finasteride","Zopiclone","Carisoprodol",
                      "Methoxphenidine","Paxil", "Zithromax","2,4 Dinitrophenol","Alli","Valium","PCP (Phencyclidine)","Speed (Amphetamine)","Dianabol","Hydromorphone","Marijuana","Cocaine","LSD (Lysergic Acid)",
                      "LSD (Lysergic Acid)","Marijuana","Mushrooms","OxyContin","Synthetic Marijuana","Vicodin","Ritalin","Carisoprodol","Zopiclone","Finasteride","Modafinil","Modafinil","Nandrolone")
  names(drugNamesActual) = unique(tolower(c("Speed", "LSD", "MDMA", "Crystal Meth", "Kush","Cocaine","Hash","Heroin","Methadone","Ketamin","Weed","Xanax","Ritalin","Adderal","Mushroom",
                                            "Psilocybe","Bud","GHB","Cannabis","Mast","Mephedrone","DMT","Ethylone","alprazolam","Amphetamin","Opium","Ecstasy","Tren","Durabolin","Clomid",
                                            "Testosterone Enanthate","Ambien", "Morphine","Salvia", "Cialis", "Suboxone", "Marijuana", "Diazepam", "Hydrocodone","Tramadol","Nitrazepam","Viagra",
                                            "OxyContin", "Sustanon", "buprenorphine", "T3", "Restoril", "Ativan", "Codeine","Lorazepam","Levitra","Molly","Methylone","Testosterone Cypionate",
                                            "Test C","Test E","Test P","methAmphetamin", "Prozac","Xenical","Celebrex","Cymbalta","Azulfidine","Flagyl","Zyban","Propecia","Imovane","Soma",
                                            "METHOXPHENIDINE", "Paxil", "Zithromax", "DNP","Alli","Valium","PCP","Amfetamin","Dianabol","HYDROMORPHONE","Sativa","Coke","Lysergic","Acid","Hashish",
                                            "Shrooms","Oxycodon", "Spice","Vicodin","Concerta","Carisoprodol","Zopiclone","Finasteride","modafin","provigil","Nandrolone")))
  data$Drug_Type = drugNamesActual[data$Drug_Type]
  return(data)
}

findQuantity = function(data) {
  data$Item_Name_Full_Text_Backup = data$Item_Name_Full_Text
  data$Item_Name_Full_Text = str_replace(tolower(data$Item_Name_Full_Text), data$Drug_Type, "")
  metricKeywords = tolower(c("mg","ug","Grams","Gram","gr","g","kg","kilo","ml","Oz","lb","pound"))
  data$Item_Name_Full_Text = sub(" ", ".", data$Item_Name_Full_Text)
  # data$Item_Name_Full_Text = sub("..", ".", data$Item_Name_Full_Text)
  for (metricUnit in metricKeywords) {
    data$Drug_Weight_With_Unit[ is.na(data$Drug_Weight_With_Unit)] = str_extract(tolower(data$Item_Name_Full_Text[ is.na(data$Drug_Weight_With_Unit)]), pattern = paste0("\\d+\\.*\\d*\\s?",metricUnit))
  }
  # data$Item_Name_Full_Text = data$Item_Name_Full_Text_Backup
  data$Item_Name_Full_Text = str_replace(tolower(data$Item_Name_Full_Text), data$Drug_Weight_With_Unit, "")
  # data$Drug_Weight_With_Unit = stri_replace_all_charclass(data$Drug_Weight_With_Unit, "\\p{WHITE_SPACE}", "")
  
  
  xKeywords = tolower(c("x"))
  for (multiplier in xKeywords) {
    data$Drug_Quantity_In_Order[is.na(data$Drug_Quantity_In_Order)] = str_extract(data$Item_Name_Full_Text[is.na(data$Drug_Quantity_In_Order)], pattern = paste0("\\s?\\d+\\.*\\d*\\s?",multiplier))
    data$Drug_Quantity_In_Order[is.na(data$Drug_Quantity_In_Order)] = str_extract(data$Item_Name_Full_Text[is.na(data$Drug_Quantity_In_Order)], pattern = paste0(multiplier, "\\s?\\d+\\.*\\d*"))
    
  }
  
  multiplierKeywords = tolower(c("x","blotter","bar","pill","ml","Tab","vial","drop","capsule","shard"))
  for (multiplier in multiplierKeywords) {
    data$Drug_Quantity_In_Order[is.na(data$Drug_Quantity_In_Order)] = str_extract(data$Item_Name_Full_Text[is.na(data$Drug_Quantity_In_Order)], pattern = paste0("\\d+\\.*\\d*\\s?",multiplier))
    data$Drug_Quantity_In_Order[is.na(data$Drug_Quantity_In_Order)] = str_extract(data$Item_Name_Full_Text[is.na(data$Drug_Quantity_In_Order)], pattern = paste0(multiplier, "\\s?\\d+\\.*\\d*\\s?"))
  }
  
  multiplierKeywords = multiplierKeywords[2:length(multiplierKeywords)]
  for (multiplier in multiplierKeywords) {
    data$Drug_Quantity_In_Order[is.na(data$Drug_Quantity_In_Order)] = str_extract(data$Item_Name_Full_Text[is.na(data$Drug_Quantity_In_Order)], pattern = paste0("\\d+\\.*\\d*\\s?",".*?",multiplier))
  }
  data$Item_Name_Full_Text = data$Item_Name_Full_Text_Backup
  data$Item_Name_Full_Text_Backup = NULL
  data = data[!is.na(data$Drug_Weight_With_Unit),]
  return(data)
}

splitUnits = function(data) {
  metricKeywords = tolower(c("mg","ug","Grams","Gram","gr","g","kg","kilo","ml","Oz","lb","pound"))
  for (metricUnit in metricKeywords) {
    keepisna = is.na(data$Drug_Weight_Unit)
    data$Drug_Weight_Unit[keepisna] = str_extract(tolower(data$Drug_Weight_With_Unit[keepisna]), pattern = paste0(metricUnit))
  }
  data$Drug_Weight_With_Unit = str_replace(tolower(data$Drug_Weight_With_Unit), paste0('\\.?',data$Drug_Weight_Unit), "")
  data$Drug_Weight = str_extract(tolower(data$Drug_Weight_With_Unit), pattern = paste0("\\d+\\.*\\d*"))
  data$Drug_Weight = as.numeric(data$Drug_Weight)
  data = data[data$Drug_Weight > 0,]
  drugUnitsActual = c("mg","ug","g","g","g","g","kg","kg","ml","oz","lb","lb")
  names(drugUnitsActual) = tolower(c("mg","ug","Grams","Gram","gr","g","kg","kilo","ml","Oz","lb","pound"))
  data$Drug_Weight_Unit = drugUnitsActual[data$Drug_Weight_Unit]
  return(data)
}

remover = function(data, keywords, columnToReplace, removeMissing = TRUE, removeKeyword = FALSE) {
  drugFoundMatrix = sapply(keywords, regexpr, data$Item_Name_Full_Text, ignore.case=TRUE)
  if (removeMissing == TRUE) {
    if (removeKeyword == TRUE) {
      data = data[!apply(drugFoundMatrix > -1, 1, any),]
      drugFoundMatrix = drugFoundMatrix[!apply(drugFoundMatrix > -1, 1, any),]
    }
    else {
      data = data[apply(drugFoundMatrix > -1, 1, any),]
      drugFoundMatrix = drugFoundMatrix[apply(drugFoundMatrix > -1, 1, any),]
    }
  }
  if (removeKeyword == FALSE) {
    data[,columnToReplace] = colnames(drugFoundMatrix)[apply(drugFoundMatrix,1,which.max)]
  }
  return(data)
}

substrRight <- function(x, n){
  substr(x, nchar(x)-n+1, nchar(x))
}


splitQuantities = function(data) {
  data$Drug_Quantity = str_extract(data$Drug_Quantity_In_Order, pattern = paste0("\\d+\\.*\\d*\\s?"))
  data$Drug_Quantity_In_Order = str_replace(data$Drug_Quantity_In_Order, pattern = paste0("\\d+\\.*\\d*\\s?"),"")
  multiplierKeywords = tolower(c("blotter","bar","pill","ml","Tab","vial","drop","capsule","shard","x"))
  for (multiplier in multiplierKeywords) {
    data$Drug_Quantity_In_Order_Unit[is.na(data$Drug_Quantity_In_Order_Unit)] = str_extract(tolower(data$Drug_Quantity_In_Order[is.na(data$Drug_Quantity_In_Order_Unit)]), pattern = paste0(multiplier))
  }
  # data$Drug_Quantity = gsub("..", ".", x = data$Drug_Quantity)
  data$Drug_Quantity = as.numeric(data$Drug_Quantity)
  
  mdmaToRemove = (data$Drug_Quantity == '84' | data$Drug_Quantity == '89') & data$Drug_Type == "Ecstasy (MDMA)"
  data$Drug_Quantity[mdmaToRemove] = NA
  data$Drug_Quantity_In_Order_Unit[mdmaToRemove] = NA
  
  onlyOneRemove = data$Drug_Quantity == 1
  data$Drug_Quantity[onlyOneRemove] = NA
  data$Drug_Quantity_In_Order_Unit[onlyOneRemove] = NA
  
  drugUnitsActual = tolower(c(NA,NA,NA,"ml",NA,"vial","drop",NA,"shard",NA))
  names(drugUnitsActual) = tolower(c("blotter","bar","pill","ml","Tab","vial","drop","capsule","shard","x"))
  data$Drug_Quantity_In_Order_Unit = drugUnitsActual[data$Drug_Quantity_In_Order_Unit]
  data$Drug_Quantity[is.na(data$Drug_Quantity)] = 1
  return(data)
}

find1g = function(data){
  drugUnitMutiplier = c(1000,1e+6,1,0.001,NA,0.035274,0.0022046249999752)
  names(drugUnitMutiplier) = c("mg","ug","g","kg","ml","oz","lb")
  data$Price = as.numeric(data$Price)
  data$Drug_Weight_Converted_To_Grams = as.numeric(data$Drug_Weight_Converted_To_Grams)
  data$Drug_Weight_Converted_To_Grams = data$Drug_Weight/drugUnitMutiplier[data$Drug_Weight_Unit]*data$Drug_Quantity
  data$Price_Per_Gram = data$Price*(1/data$Drug_Weight_Converted_To_Grams)
  data = data[data$Price_Per_Gram <= 15000 | is.infinite(abs(data$Price_Per_Gram)) | data$Price_Per_Gram == 0,]
  data$Drug_Weight_With_Unit = NULL
  return(data)
}

addSheetDate = function(data,fName) {
  data$Sheet_Date = as.Date(substr(fName,9,18),'%Y-%m-%d')
  print(fName)
  return(data)
}

mround <- function(x,base){ 
  base*round(x/base) 
} 
addBTC = function(data) {
  if (!file.exists('Bitcoin.csv')) {
    download.file(url = 'http://www.quandl.com/api/v1/datasets/BAVERAGE/USD.csv', destfile = 'Bitcoin.csv')
  } 
  bitcoinData = fread('Bitcoin.csv')
  colnames(bitcoinData)[colnames(bitcoinData) == 'Date'] = "Sheet_Date"
  colnames(bitcoinData)[colnames(bitcoinData) == '24h Average'] = "BitcoinPriceUSD"
  colnames(bitcoinData)[colnames(bitcoinData) == 'Total Volume'] = "BitcoinVolume"
  # bitcoinData = select(bitcoinData, Sheet_Date = Date, BitcoinPriceUSD =  "24h Average", BitcoinVolume = "Total Volume")
  bitcoinData$Sheet_Date = as.Date(bitcoinData$Sheet_Date,'%Y-%m-%d')
  data$Sheet_Date = as.Date(data$Sheet_Date,'%Y-%m-%d')
  print(class(data$Sheet_Date))
  print(class(bitcoinData$Sheet_Date))
  # print(bitcoinData)
  # print(bitcoinData$Sheet_Date)
  # dnmData$BitcoinPriceUSD = as.numeric(dnmData$BitcoinPriceUSD)
  #Merge Bitcoin data into Darknet Data
  data = merge(x = data, y = bitcoinData, by = "Sheet_Date", all.x = TRUE)
  print(head(data))
  data$Price_Per_Gram_BTC = data$Price_Per_Gram*data$BitcoinPriceUSD
  return(data)
}

rm(list = setdiff(ls(), lsf.str()))
ec2 = TRUE
if (ec2 == TRUE) {
  darknetDirectory = "~/Data/Darknet"
  processedCSVDirectory = '~/Drug_Project/Data'
} else {
  darknetDirectory = "/Volumes/SDExpansion/Data Files/Darknet Data"
  processedCSVDirectory = '/Users/nicktalavera/Coding/NYC_Data_Science_Academy/Projects/Drug_Project/Data'
}

countryList = c("argentina", "australia","austria", "bangladesh", "belgium", "bulgaria", "canada", "china","colombia","czech republic", "denmark", "finland", "france", "georgia", 
                "germany", "germany ", "germany ", "guatemala","guernsey", "holland", "hong kong sar china", "hungary", "india", "ireland", "italy",  "latvia", "luxembourg", "mexico", "netherland", 
                "netherlands", "new zealand", "nl", "norway", "peru", "poland", "serbia", "singapore","slovakia", "slovenia", "south africa", "spain", "sweden", "switzerland", 
                "thailand", "the netherlands", "uk", "united kingdom", "united states", "united states of ame", "united states of america", "unknown", "us", "usa", "usa and canada", "usa only", "venezuela")

setwd(processedCSVDirectory)
if (!file.exists('DNMdataUnsorted.csv')) {
  setwd(darknetDirectory)
  # options(scipen = 999)
  darkentMarketFiles = list.files(path = './grams', recursive = TRUE, pattern = "\\.csv$", no.. = TRUE, full.names = TRUE)
  federalBudgetFiles = list.files(path = './Federal Budget', recursive = TRUE, pattern = "\\.csv$", no.. = TRUE, full.names = TRUE)
  count = 1
  
  
  start <- Sys.time ()
  crashVal = NA
  if (crashVal == 1 | is.na(crashVal) | is.null(crashVal) | !file.exists('DNMdataUnsorted.csv')) {
    lowerend = 1
  } else {
    lowerend = crashVal
    dnmData = as.data.frame(fread('DNMdataUnsorted.csv'))
  }
  
  
  # dnmData = addSheetDate(as.data.frame(fread(darkentMarketFiles[1])), darkentMarketFiles[1])
  # dnmData = lapply(darkentMarketFiles[2810:length(darkentMarketFiles)], function(csvFile) rbind.fill(dnmData, addSheetDate(as.data.frame(fread(csvFile)), csvFile)))
  
  for (csvFile in darkentMarketFiles[seq(1,length(darkentMarketFiles),length(darkentMarketFiles)/20)]) {
    setwd(darknetDirectory)
    print(csvFile)
    print(paste0(count,"th file (",round(count/length(darkentMarketFiles)*100,4),"%)"))
    if (exists(x = 'dnmData') == TRUE) {
      dnmData = rbind(dnmData, addSheetDate(fread(csvFile), csvFile))
    } else {
      dnmData = addSheetDate(fread(csvFile), csvFile)
    }
    count = count+1
  }
  setwd(processedCSVDirectory)
  write.csv(dnmData, 'DNMdataUnsorted.csv')
}
setwd(processedCSVDirectory)
dnmData = cleanupCSV(as.data.frame(fread('DNMdataUnsorted.csv')))
setwd(processedCSVDirectory)
write.csv(dnmData, 'DNMdata.csv')