library(jsonlite)
library(stringr)
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
  data = select(data, Market_Name = market_name, Price = price, Item_Name_Full_Text = name, Time_Added = add_time, Shipped_From = ship_from, Sheet_Date)
  data = data[!is.na(data$Market_Name),]
  data$X = NULL
  data$Shipped_From = (as.character(data$Shipped_From))
  data$Item_Name_Full_Text = (as.character(data$Item_Name_Full_Text))
  data$Drug_Weight = NA
  data$Drug_Weight_Unit = NA
  data$Drug_Weight_Converted_To_Grams = NA
  data$Drug_Weight_With_Unit = NA
  data$Price_Per_Gram = NA
  # print(2)
  # data = removeStrangeCountries(data)
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
  data = addBTC(data)
  print(11)
  data = formatter(data)
  data$Item_Name_Full_Text = NULL
  data$Drug_Weight = NULL
  data$Price = NULL
  data$Drug_Weight_Unit = NULL
  return(data)
}

formatter = function(data) {
  data$Market_Name = str_title_case(data$Market_Name)
  data$Shipped_From = str_title_case(data$Shipped_From)
  data$Drug_Type = str_title_case(data$Drug_Type)
  return(data)
}

renameCountries = function(data) {
  countryList = tolower(c("argentina", "australia","austria", "bangladesh", "belgium", "bulgaria", "canada", "china","colombia","czech republic", "denmark", "finland", "france", "georgia", 
                          "germany", "germany ", "germany ", "guatemala","guernsey", "holland", "hong kong sar china", "hungary", "india", "ireland", "italy",  "latvia", "luxembourg", "mexico", "netherland", 
                          "netherlands", "new zealand", "nl", "norway", "peru", "poland", "serbia", "singapore","slovakia", "slovenia", "south africa", "spain", "sweden", "switzerland", 
                          "thailand", "the netherlands", "uk", "united kingdom", "united states", "united states of ame", "united states of america", "us", "usa", "usa and canada", "usa only", "venezuela",
                          "south africa","united states of","united states of a","italyu","armenia","massachusetts usa","united states of am","chile","morocco","panama","brazil","hong kong","ukraine","greece",
                          "bosnia and herzegovi","indonesia","portugal","estonia","ghana","russia","andorra","romania","aruba","malaysia","swaziland","japan","hong kong, (china)","israel","angola","u.s.a.","ussa",
                          "sri lanka","california","the neterlands", "oman","dominican republic","philippines","cuba","germany - others ask","fr","lithuania","us cali","us - cali"))
  countryNamesActual = tolower(c("argentina", "australia","austria", "bangladesh", "belgium", "bulgaria", "canada", "china","colombia","czech republic", "denmark", "finland", "france", "georgia", 
                                 "germany", "germany ", "germany ", "guatemala","guernsey", "netherlands", "china", "hungary", "india", "ireland", "italy",  "latvia", "luxembourg", "mexico", "netherlands", 
                                 "netherlands", "new zealand", "netherlands", "norway", "peru", "poland", "serbia", "singapore","slovakia", "slovenia", "south africa", "spain","sweden", "switzerland", 
                                 "thailand", "netherlands", "united kingdom", "united kingdom", "united states", "united states", "united states", "united states", "united states", "united states", "united states", "venezuela",
                                 "south africa","united states","united states","italy","armenia","united states","united states","chile","morocco","panama","brazil","hong kong","ukraine","greece",
                                 "Bosnia and Herzegovina","indonesia","portugal","estonia","ghana","russia","andorra","romania","aruba","malaysia","swaziland","japan","hong kong","israel","angola","united states","united states",
                                 "sri lanka","united states","netherlands", "oman","dominican republic","philippines","cuba","germany","france","lithuania","united states","united states"))
  names(countryNamesActual) = countryList
  data$Shipped_From = tolower(rm_white(trimws(data$Shipped_From)))
  Shipped_FromTemp = data$Shipped_From
  data$Shipped_From = countryNamesActual[data$Shipped_From]
  Shipped_FromTemp = unique(Shipped_FromTemp[is.na(data$Shipped_From) | data$Shipped_From == ""])
  write.csv(Shipped_FromTemp, "Unique_Shipped_From.csv")
  data = data[!is.na(data$Shipped_From)  & data$Shipped_From != "",]
  # print(Shipped_FromTemp)
  return(data)
}

labelDrugs = function(data) {
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
  # print(drugNamesRegex)
  keywordsToRemove <- sort(c("Brownie","Gummi","tobacco","kisses","home test","exemption","stronger than","butter","vape pen","Hashoel","sample","cookie","pollen","wax","Sachet","likes","seeds","gatorade","sampler","half price","pack","boxes"))
  keywordsToRemoveRegex = paste(keywordsToRemove, collapse = "|")
  keywordsToRemoveRegex =  gsub(pattern = " ", replacement = "*", x = keywordsToRemoveRegex,ignore.case = TRUE)
  # print(keywordsToRemoveRegex)
  data$Item_Name_Full_Text = tolower(data$Item_Name_Full_Text)
  data$Drug_Type = unlist(lapply(data$Item_Name_Full_Text, (function (x) str_extract(x,drugNamesRegex))))
  notRemoved = unlist(lapply(data$Item_Name_Full_Text, (function (x) !is.na(str_extract(x,keywordsToRemoveRegex)))))
  data$Drug_Type[notRemoved] = NA
  data = data[!is.na(data$Drug_Type),]
  return(data)
}


renameDrugs = function(data) {
  drugNamesActual = tolower(c("Speed (Amphetamine)","LSD (Lysergic Acid)","Ecstasy (MDMA)","Crystal Methamphetamine","Marijuana","Cocaine","Marijuana","Heroin","Methadone","Ketamine","Marijuana","Xanax (Alprazolam)","Ritalin","Speed (Amphetamine)","Mushrooms",
                      "Mushrooms","Marijuana","GHB","Marijuana","Masteron","Mephedrone","DMT","Ethylone","Xanax (Alprazolam)","Speed (Amphetamine)","Opium","Ecstasy (MDMA)", "Trenbolone","Nandrolone","Clomid",
                      "Testosterone Enanthate","Ambien","Morphine","Salvia","Cialis","Suboxone","Marijuana","Diazepam","Hydrocodone","Tramadol","Nitrazepam","Viagra",
                      "OxyContin", "Sustanon", "Buprenorphine", "T3 (Triiodothyronine)", "Restoril (Temazepam)", "Lorazepam", "Codeine","Lorazepam","Levitra (Vardenafil)","Ecstasy (MDMA)","Methylone","Testosterone Cypionate",
                      "Testosterone Cypionate","Testosterone Enanthate", "Testosterone Propionate", "Crystal Methamphetamine","Prozac (Fluoxetine)","Xenical","Celebrex","Cymbalta","Sulfasalazine","Flagyl (Metronidazole)","Zyban","Finasteride","Zopiclone","Carisoprodol",
                      "Methoxphenidine","Paxil", "Zithromax","2,4 Dinitrophenol","Alli","Valium","PCP (Phencyclidine)","Speed (Amphetamine)","Dianabol","Hydromorphone","Marijuana","Cocaine","LSD (Lysergic Acid)",
                      "LSD (Lysergic Acid)","Marijuana","Mushrooms","OxyContin","Synthetic Marijuana","Vicodin","Ritalin","Carisoprodol","Zopiclone","Finasteride","Modafinil","Modafinil","Nandrolone",
                      "Citalopram","Topiramate","Butyrfentanyl","rivotril","dormicum","mogadon","heroine"
                      ))
  names(drugNamesActual) = (tolower(c("Speed", "LSD", "MDMA", "Crystal Meth", "Kush","Cocaine","Hash","Heroin","Methadone","Ketamin","Weed","Xanax","Ritalin","Adderal","Mushroom",
                                            "Psilocybe","Bud","GHB","Cannabis","Mast","Mephedrone","DMT","Ethylone","alprazolam","Amphetamin","Opium","Ecstasy","Tren","Durabolin","Clomid",
                                            "Testosterone Enanthate","Ambien", "Morphine","Salvia", "Cialis", "Suboxone", "Marijuana", "Diazepam", "Hydrocodone","Tramadol","Nitrazepam","Viagra",
                                            "OxyContin", "Sustanon", "buprenorphine", "T3", "Restoril", "Ativan", "Codeine","Lorazepam","Levitra","Molly","Methylone","Testosterone Cypionate",
                                            "Test C","Test E","Test P","methAmphetamin", "Prozac","Xenical","Celebrex","Cymbalta","Azulfidine","Flagyl","Zyban","Propecia","Imovane","Soma",
                                            "METHOXPHENIDINE", "Paxil", "Zithromax", "DNP","Alli","Valium","PCP","Amfetamin","Dianabol","HYDROMORPHONE","Sativa","Coke","Lysergic","Acid","Hashish",
                                            "Shrooms","Oxycodon", "Spice","Vicodin","Concerta","Carisoprodol","Zopiclone","Finasteride","modafin","provigil","Nandrolone",
                                            "Citalopram","Topiramate","Butyrfentanyl","rivotril","dormicum","mogadon","Heroin"
                                      )))
  data$Drug_Type = tolower(data$Drug_Type)
 Drug_Temp = data$Item_Name_Full_Text
  data$Drug_Type = drugNamesActual[data$Drug_Type]
  Drug_Temp = unique(Drug_Temp[is.na(data$Drug_Type) | data$Drug_Type == ""])
  write.csv(Drug_Temp,"Unique_Drug_Type.csv")
  data = data[!is.na(data$Drug_Type) & data$Drug_Type != "",]
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
  
  data$Drug_Quantity_In_Order = NA
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
  data$Drug_Quantity_In_Order_Unit = NA
  for (multiplier in multiplierKeywords) {
    data$Drug_Quantity_In_Order_Unit[is.na(data$Drug_Quantity_In_Order_Unit)] = str_extract(tolower(data$Drug_Quantity_In_Order[is.na(data$Drug_Quantity_In_Order_Unit)]), pattern = paste0(multiplier))
  }
  data$Drug_Quantity_In_Order = NULL
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
  data$Drug_Quantity_In_Order_Unit = NULL
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

addBTC = function(data) {
  if (!file.exists('Bitcoin.csv')) {
    download.file(url = 'http://www.quandl.com/api/v1/datasets/BAVERAGE/USD.csv', destfile = 'Bitcoin.csv')
  } 
  bitcoinData = fread('./Data/Bitcoin.csv')
  colnames(bitcoinData)[colnames(bitcoinData) == 'Date'] = "Sheet_Date"
  colnames(bitcoinData)[colnames(bitcoinData) == '24h Average'] = "BitcoinPriceUSD"
  colnames(bitcoinData)[colnames(bitcoinData) == 'Total Volume'] = "BitcoinVolume"
  bitcoinData$Sheet_Date = as.Date(bitcoinData$Sheet_Date,'%Y-%m-%d')
  data$Sheet_Date = as.Date(data$Sheet_Date,'%Y-%m-%d')
  data = merge(x = data, y = bitcoinData, by = "Sheet_Date", all.x = TRUE)
  data$Price_Per_Gram_BTC = data$Price_Per_Gram/data$BitcoinPriceUSD
  return(data)
}

rm(list = setdiff(ls(), lsf.str()))
countryList = c("argentina", "australia","austria", "bangladesh", "belgium", "bulgaria", "canada", "china","colombia","czech republic", "denmark", "finland", "france", "georgia", 
                "germany", "germany ", "germany ", "guatemala","guernsey", "holland", "hong kong sar china", "hungary", "india", "ireland", "italy",  "latvia", "luxembourg", "mexico", "netherland", 
                "netherlands", "new zealand", "nl", "norway", "peru", "poland", "serbia", "singapore","slovakia", "slovenia", "south africa", "spain", "sweden", "switzerland", 
                "thailand", "the netherlands", "uk", "united kingdom", "united states", "united states of ame", "united states of america", "unknown", "us", "usa", "usa and canada", "usa only", "venezuela")
dnmData = as.data.frame(read.csv('./Data/DNMdataSomewhatSorted.csv'))
dnmData = cleanupCSV(dnmData)
write.csv(dnmData, './Data/DNMdata.csv')