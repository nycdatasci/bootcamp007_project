library(jsonlite)
library(stringr)
library(dplyr)
library(qdapRegex)

trim <- function (x) gsub("^\\s+|\\s+$", "", x)
steamCSVFinder <- function() {
  steamFilesList = list.files(path = ".", pattern = "steamdata-[0-9]{8}.csv")
  steamDatabase = list()
  for (i in 1:length(steamFilesList)) {
    dateRecorded = substr(steamFilesList[i], regexpr("[0-9]{8}",steamFilesList[i]), regexpr("[0-9]{8}",steamFilesList[i])+7)
    dateRecorded = as.Date(dateRecorded, format = "%Y%m%d")
    # print(str(steamDatabase))
    steamDatabase$dateRecorded = read.csv(steamFilesList[i], sep=',')
    steamDatabase$dateRecorded = steamCSVPreparer(steamDatabase$dateRecorded,dateRecorded)
    steamDatabase$players_forever_variance = NULL
    steamDatabase$players_2weeks_variance = NULL
    steamDatabase$median_forever = NULL
    steamDatabase$median_2weeks = NULL
    steamDatabase$average_forever = NULL
    steamDatabase$average_2weeks = NULL
    # steamDatabase$owners = NULL
    # steamDatabase$players = NULL
    steamDatabase$owners_variance = NULL
    steamDatabase$players_forever_variance = NULL
    steamDatabase$players_2weeks_variance = NULL
    steamDatabase$median_forever = NULL
    steamDatabase$median_2weeks = NULL
    steamDatabase$average_forever = NULL
    steamDatabase$average_2weeks = NULL
    # print(str(steamDatabase))
    # steamDatabase$Name = removeSymbols(steamDatabase$Name)
  }
  return(steamDatabase)
}

steamCSVPreparer <- function(steamDatabase,dateRecorded="2016-09-30") {
  # colnames(steamDatabase)[colnames(steamDatabase) == 'name'] = "Name"
  # steamDatabase$Name = removeSymbols(steamDatabase$Name)
  steamDatabase$name = NULL
  colnames(steamDatabase)[colnames(steamDatabase) == 'price'] = "Price_Now"
  steamDatabase[colnames(steamDatabase) == 'Price_Now'] = steamDatabase[colnames(steamDatabase) == 'Price_Now']/100
  steamDatabase$Recorded_Date = dateRecorded
  steamDatabase$median_forever = NULL
  steamDatabase$median_2weeks = NULL
  steamDatabase$average_forever = NULL
  steamDatabase$average_2weeks = NULL
  steamDatabase$players_forever_variance = NULL
  steamDatabase$owners = NULL
  steamDatabase$players_forever = NULL
  steamDatabase$median_2weeks = NULL
  steamDatabase$players_2weeks = NULL
  steamDatabase$players_2weeks_variance = NULL
  # steamDatabase$owners = NULL
  # steamDatabase$players = NULL
  steamDatabase$owners_variance = NULL
  steamDatabase$players_forever_variance = NULL
  steamDatabase$players_2weeks_variance = NULL
  steamDatabase$median_forever = NULL
  steamDatabase$average_forever = NULL
  steamDatabase$median_2weeks = NULL
  steamDatabase$average_2weeks = NULL
  return(steamDatabase)
}

steamSpySaleCSVPreparer <- function(steamSummerSaleNew) {
  colnames(steamSummerSaleNew)[colnames(steamSummerSaleNew) == 'Game'] = "Name"
  colnames(steamSummerSaleNew)[colnames(steamSummerSaleNew) == 'Price'] = "Price_Before_Sale"
  colnames(steamSummerSaleNew)[colnames(steamSummerSaleNew) == 'Max.discount'] = "Maximum_Percent_Sale_and_Minimum_Price_With_Sale"
  colnames(steamSummerSaleNew)[colnames(steamSummerSaleNew) == 'Owners.before'] = "Owners_Before"
  colnames(steamSummerSaleNew)[colnames(steamSummerSaleNew) == 'Owners.after'] = "Owners_After"
  saleStrings = unlist(lapply(steamSummerSaleNew[colnames(steamSummerSaleNew) == 'Maximum_Percent_Sale_and_Minimum_Price_With_Sale'][[1]], as.character))
  saleStrings = str_split_fixed(saleStrings, " ", 2)
  reviewScoreStrings = unlist(lapply(steamSummerSaleNew[colnames(steamSummerSaleNew) == 'Userscore..Metascore.'][[1]], as.character))
  salePercent = saleStrings[,1]
  salePercent = sub("%", "", salePercent)
  salePercent = gsub("\\(|\\)", "", salePercent)
  salePercent[salePercent == "N/A"] = NA
  salePercent = as.numeric(as.character(salePercent),na.rm = FALSE)
  salePrice = saleStrings[,2]
  salePrice = gsub("\\(|\\)", "", salePrice)
  salePrice = as.numeric(as.character(gsub("\\$", "", salePrice)),na.rm = FALSE)
  steamSummerSaleNew$Maximum_Percent_Sale_and_Minimum_Price_With_Sale = NULL
  steamSummerSaleNew$Userscore..Metascore. = NULL
  steamSummerSaleNew$X. <- NULL
  steamSummerSaleNew$X <- NULL
  reviewScoreStrings = str_split_fixed(reviewScoreStrings, " ", 2)
  reviewScoreSteam = sub("%", "", reviewScoreStrings[,1])
  reviewScoreSteam[reviewScoreSteam == "N/A"] <- NA
  reviewScoreSteam = as.numeric(reviewScoreSteam,na.rm = TRUE)
  reviewScoreMetacritic = reviewScoreStrings[,2]
  reviewScoreMetacritic = sub("%", "", reviewScoreMetacritic)
  reviewScoreMetacritic = gsub("\\(|\\)", "", reviewScoreMetacritic)
  reviewScoreMetacritic[reviewScoreMetacritic == "N/A"] <- NA
  reviewScoreMetacritic = as.numeric(as.character(reviewScoreMetacritic),na.rm = FALSE)
  steamSummerSaleNew$Review_Score_Metacritic = reviewScoreMetacritic
  steamSummerSaleNew$Review_Score_Steam_Users = reviewScoreSteam
  steamSummerSaleNew$Sale_Percent = salePercent
  steamSummerSaleNew$Price_After_Sale = as.numeric(salePrice)
  steamSummerSaleNew$Price_Before_Sale = as.numeric(as.character(gsub("\\$", "", steamSummerSaleNew$Price_Before_Sale)),na.rm = FALSE)
  steamSummerSaleNew$Sales = as.numeric(gsub(",","",steamSummerSaleNew$Sales))
  steamSummerSaleNew$Increase = as.numeric(gsub(",","",sub("%", "", steamSummerSaleNew$Increase)))
  steamSummerSaleNew$Owners_Before = gsub(",","",steamSummerSaleNew$Owners_Before)
  steamSummerSaleNew$Owners_Before = as.numeric(gsub("\\±.*","",steamSummerSaleNew$Owners_Before))
  steamSummerSaleNew$Owners_After = gsub(",","",steamSummerSaleNew$Owners_After)
  steamSummerSaleNew$Owners_After = as.numeric(gsub("\\±.*","",steamSummerSaleNew$Owners_After))
  steamSummerSaleNew$Review_Score_Metacritic_User = NULL
  steamSummerSaleNew$Review_Score_Metacritic = NULL
  steamSummerSaleNew$Name = removeSymbols(steamSummerSaleNew$Name)
  steamSummerSaleNew = unique(steamSummerSaleNew)
  return(steamSummerSaleNew)
}

steamspyJson = function() {
  if (file.exists('steamSpyAll.csv')) {
    print('steamSpyAll.csv exists')
    return(read.csv('steamSpyAll.csv'))
  }
  else {
  # steamspy.data <- fromJSON("http://steamspy.com/api.php?request=all")
  steamspy.data <- fromJSON("steamSpyAll.json")
  d <- data.frame()
  for (i in steamspy.data) {
    tmp <- data.frame(Name=i$name, appid=i$appid, Owners_As_Of_Today=i$owners, Players_Forever_As_Of_Today=i$players_forever, average_forever=i$average_forever, median_forever=i$median_forever)
    d <- rbind(d, tmp)  
  }
  d$Name = removeSymbols(d$Name)
  write.csv(d,'steamSpyAll.csv')
  return(d)
  }
}

metacriticCSVPreparer <- function(metacriticReviews) {
  metacriticReviews$genre = NULL
  colnames(metacriticReviews)[colnames(metacriticReviews) == 'title'] = "Name"
  metacriticReviews$release = as.Date(as.character(metacriticReviews$release),'%b %d, %Y')
  metacriticReviews = metacriticReviews[metacriticReviews$platform != 'ios' & metacriticReviews$platform !='gba' & metacriticReviews$platform !='ds' & metacriticReviews$platform !='3ds' & metacriticReviews$platform !='psp' & metacriticReviews$platform !='vita',]
  metacriticReviews$Review_Score_Metacritic_User = metacriticReviews$user_score * 10
  metacriticReviews$user_score = NULL
  metacriticReviews = metacriticReviews[metacriticReviews$platform == 'pc',]
  metacriticReviews$Name = removeSymbols(metacriticReviews$Name)
  return(metacriticReviews)
}

removeSymbols = function(namesArray) {
  newNames = namesArray
  newNames = str_replace_all(newNames,"[[:punct:]]","")
  newNames = str_replace_all(newNames, "[^[:alnum:]]", " ")
  newNames = trim(newNames)
  newNames = rm_white(newNames)
  return(newNames)
}

ignCSVPreparer <- function(ignReviews) {
  ignReviews$Release_Date = as.Date(paste0(ignReviews$release_year,ignReviews$release_month,ignReviews$release_day), format = "%Y%m%d")
  ignReviews$X = NULL
  ignReviews$url <- NULL
  ignReviews$score_phrase = NULL
  ignReviews$release_year = NULL
  ignReviews$release_month <- NULL
  ignReviews$Genre<- NULL
  ignReviews$release_day = NULL
  colnames(ignReviews)[colnames(ignReviews) == 'title'] = "Name"
  colnames(ignReviews)[colnames(ignReviews) == 'score'] = "Review_Score_IGN"
  colnames(ignReviews)[colnames(ignReviews) == 'genre'] = "Genre"
  colnames(ignReviews)[colnames(ignReviews) == 'platform'] = "Platform"
  ignReviews$Platform = as.character(ignReviews$Platform)
  colnames(ignReviews)[colnames(ignReviews) == 'editors_choice'] = "IGN_Editors_Choice"
  ignReviews = ignReviews[ignReviews$Platform != 'Wireless' & ignReviews$Platform != 'PlayStation Vita' & ignReviews$Platform != 'ios' & ignReviews$Platform != 'PlayStation Portable' & ignReviews$Platform != 'Nintendo DS' & ignReviews$Platform != 'Nintendo 3DS' & ignReviews$Platform != 'iPhone' & ignReviews$Platform != 'iPad',]
  # ignReviews = ignReviews[ignReviews$Platform != 'PC',]
  ignReviews$Platform = NULL
  ignReviews$Review_Score_IGN = as.numeric(ignReviews$Review_Score_IGN*10)
  ignReviews$IGN_Editors_Choice = NULL
  ignReviews$Name = removeSymbols(ignReviews$Name)
  ignReviews = unique(ignReviews)
  return(ignReviews)
}

howLongToBeatCSVPreparer <- function(howLongToBeat) {
  howLongToBeat = select(howLongToBeat, Name = title, main_story_length, platform)
  howLongToBeat$Name = removeSymbols(howLongToBeat$Name)
  howLongToBeat = howLongToBeat[howLongToBeat$platform == 'PC',]
  howLongToBeat$platform = NULL
  return(howLongToBeat)
}

ignMetacritcHLTBMerged <- function(ignReviews,metacriticReviews,steamSummerSale, howLongToBeat) {
  ignMetacritcMerged = merge(x = metacriticReviews, y = ignReviews, by = "Name", all.x = TRUE)
  ignMetacritcMerged$Release_Date[is.na(ignMetacritcMerged$Release_Date) == TRUE & is.na(ignMetacritcMerged$release) == FALSE  & as.character(ignMetacritcMerged$platform) == 'pc'] = ignMetacritcMerged$release[is.na(ignMetacritcMerged$Release_Date) == TRUE & is.na(ignMetacritcMerged$release) == FALSE & as.character(ignMetacritcMerged$platform) == 'pc']
  ignMetacritcMerged$Release_Date[is.na(ignMetacritcMerged$Release_Date) == TRUE & is.na(ignMetacritcMerged$release) == FALSE] = ignMetacritcMerged$release[is.na(ignMetacritcMerged$Release_Date) == TRUE & is.na(ignMetacritcMerged$release) == FALSE]
  ignMetacritcMerged$release = NULL
  ignMetacritcMerged$Review_Score_Metacritic[is.na(ignMetacritcMerged$Review_Score_Metacritic) == TRUE & is.na(ignMetacritcMerged$score) == FALSE] = ignMetacritcMerged$score[is.na(ignMetacritcMerged$Review_Score_Metacritic) == TRUE & is.na(ignMetacritcMerged$score) == FALSE]
  ignMetacritcMerged = ignMetacritcMerged[is.na(ignMetacritcMerged$Release_Date) == FALSE | is.na(ignMetacritcMerged$platform) == FALSE,]
  ignMetacritcMerged = merge(x = select(steamSummerSale,Name), y = ignMetacritcMerged, by = "Name", all.x = TRUE)
  hltbMerged = merge(x = select(steamSummerSale, Name), y = howLongToBeat, by = "Name", all.x = TRUE)
  hltbMerged = hltbMerged[is.na(hltbMerged$main_story_length) == FALSE,]
  print(head(hltbMerged))
  ignMetacritcMerged = merge(x = ignMetacritcMerged, y = hltbMerged, by = "Name", all.x = TRUE)
  ignMetacritcMerged = ignMetacritcMerged[ignMetacritcMerged$platform == 'pc',]
  ignMetacritcMerged$platform = NULL
  ignMetacritcMerged = unique(ignMetacritcMerged)
  return(ignMetacritcMerged)
}
rm(list = setdiff(ls(), lsf.str()))
setwd('/Users/nicktalavera/Coding/bootcamp007_project/Project1-ExploreVis/NickTalavera/Steam')
steamSummerSaleFirstDay = as.Date('20160704', "%Y%m%d")
steamSummerSaleLastDay = as.Date('20160623', "%Y%m%d")
metacriticReviews = metacriticCSVPreparer(read.csv('metacritic-20151227.csv',sep=';'))
howLongToBeat = howLongToBeatCSVPreparer(read.csv('howlongtobeat.csv',sep=';'))
ignReviews = ignCSVPreparer(read.csv('ign.csv',sep=','))
steamDatabaseHistory = steamCSVFinder()
steamSummerSale = steamSpySaleCSVPreparer(read.csv('Steam Summer Sale - SteamSpy - All the data and stats about Steam games.csv',sep=','))
steamSpyAll = steamspyJson()
ignMetacritcHLTBMerged = ignMetacritcHLTBMerged(ignReviews,metacriticReviews,steamSummerSale,howLongToBeat)
# giantBomb = as.data.frame(do.call(rbind, fromJSON('http://www.giantbomb.com/api/games/?api_key=6523d79b659cd6663ac630bab3bdcfc2e5851778&format=json&field_list=name')))
steamMerged = merge(x = steamSummerSale, y = steamSpyAll, by = "Name", all.x = TRUE)
steamMerged = merge(x = steamMerged, y = steamDatabaseHistory[[length(steamDatabaseHistory)]], by = "appid", all.x = TRUE)
steamMerged = merge(x = steamMerged, y = ignMetacritcHLTBMerged, by = "Name", all.x = TRUE)
# steamMerged$Players_Forever_As_Of_Today = numeric(Players_Forever_As_Of_Today)
steamMerged$median_forever = NULL
steamMerged$average_forever = NULL
steamMerged$X = NULL
steamMerged$GameAge = steamSummerSaleFirstDay - steamMerged$Release_Date
steamMerged$GameAge[steamMerged$GameAge < 0] = NA
write.csv(steamMerged, file = 'steamDatabaseAllCombined.csv')