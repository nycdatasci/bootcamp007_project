rm(list = ls()) #If I want my environment reset for testing.
#===============================================================================
#                                   LIBRARIES                                  #
#===============================================================================
library(jsonlite)
library(dplyr)
library(stringr)
library(qdapRegex)

#===============================================================================
#                               GENERAL FUNCTIONS                              #
#===============================================================================
removeSymbols = function(namesArray) {
  newNames = namesArray
  newNames = str_replace_all(newNames,"[[:punct:]]","")
  newNames = str_replace_all(newNames, "[^[:alnum:]]", " ")
  newNames = str_trim(newNames)
  newNames = rm_white(newNames)
  return(newNames)
}
'%!in%' <- function(x,y)!('%in%'(x,y))
#===============================================================================
#                          DATA PROCESSING FUNCTIONS                           #
#===============================================================================
steamSpySaleCSVPreparer <- function() {
  steamSummerSaleNew = as.data.frame(read.csv(paste0(dataLocale, 'Steam Summer Sale - SteamSpy - All the data and stats about Steam games.csv'),sep=',', stringsAsFactors = FALSE))
  steamSummerSaleNew = dplyr::select(steamSummerSaleNew, 'Name' = Game,
                                     'Price_Before_Sale' = Price,
                                     'Maximum_Percent_Sale_and_Minimum_Price_With_Sale' = Max.discount,
                                     'Owners_Before' = Owners.before,
                                     'Owners_After' = Owners.after,
                                     "Userscore_And_Metascore" = Userscore..Metascore.,
                                     Increase
  )
  steamSummerSaleNew = data.frame(lapply(steamSummerSaleNew, sub, pattern = "N/A", replacement = NA, fixed = TRUE))
  steamSummerSaleNew = data.frame(lapply(steamSummerSaleNew, gsub, pattern = "\\±|\\,|\\$|\\%|\\(|\\)", replacement = "", fixed = FALSE))
  saleStrings = str_split_fixed(steamSummerSaleNew$Maximum_Percent_Sale_and_Minimum_Price_With_Sale, " ", 2)
  steamSummerSaleNew$Sale_Percent = saleStrings[,1]
  steamSummerSaleNew$Price_After_Sale = saleStrings[,2]
  reviewScoreStrings = str_split_fixed(steamSummerSaleNew$Userscore_And_Metascore, " ", 2)
  steamSummerSaleNew$Review_Score_Steam_Users = reviewScoreStrings[,1]
  steamSummerSaleNew$Review_Score_Metacritic = reviewScoreStrings[,2]
  steamSummerSaleNew = dplyr::select(steamSummerSaleNew, -Userscore_And_Metascore, -Maximum_Percent_Sale_and_Minimum_Price_With_Sale)
  return(steamSummerSaleNew)
}

steamspyJson = function() {
  if (file.exists(paste0(dataLocale,'steamSpyAll.csv'))) {
    print('The SteamSpy API data named \"steamSpyAll.csv\" exists')
    steamSpyCSV = read.csv(paste0(dataLocale,'steamSpyAll.csv'))
    steamSpyCSV = dplyr::select(steamSpyCSV, -X, -median_forever, -average_forever)
    return(steamSpyCSV)
  }
  else {
    steamSpyDataJsonFormat <- fromJSON(paste0(dataLocale,"steamSpyAll.json"))
    steamSpyDataToOutput <- data.frame()
    for (i in steamSpyDataJsonFormat) {
      tmp <- data.frame(Name=i$name, appid=i$appid, Owners_As_Of_Today=i$owners, Players_Forever_As_Of_Today=i$players_forever, average_forever=i$average_forever, median_forever=i$median_forever)
      steamSpyDataToOutput <- rbind(steamSpyDataToOutput, tmp)  
    }
    steamSpyDataToOutput$Name = removeSymbols(d$Name)
    dplyr::select(steamSpyDataToOutput, -X, -median_forever, -average_forever)
    write.csv(steamSpyDataToOutput,paste0(dataLocale,'steamSpyAll.csv'))
    return(steamSpyDataToOutput)
  }
}

metacriticCSVPreparer <- function() {
  metacriticReviews = read.csv(paste0(dataLocale,'metacritic-20151227.csv'),sep=';')
  metacriticReviews = rename(metacriticReviews, "Name" = title)
  metacriticReviews$release = as.Date(as.character(metacriticReviews$release),'%b %d, %Y')
  metacriticReviews = metacriticReviews[metacriticReviews$platform %!in% c('ios','gba','ds','3ds','psp','vita'),] 
  metacriticReviews = metacriticReviews[metacriticReviews$platform %in% c('pc'),]
  metacriticReviews = dplyr::select(metacriticReviews, -user_score)
  return(metacriticReviews)
}

ignCSVPreparer <- function() {
  ignReviews = read.csv(paste0(dataLocale,'ign.csv'),sep=',')
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

howLongToBeatCSVPreparer <- function() {
  howLongToBeat = read.csv(paste0(dataLocale,'howlongtobeat.csv'),sep=';')
  howLongToBeat = dplyr::select(howLongToBeat, Name = title, main_story_length, platform)
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
  ignMetacritcMerged = merge(x = dplyr::select(steamSummerSale,Name), y = ignMetacritcMerged, by = "Name", all.x = TRUE)
  hltbMerged = merge(x = dplyr::select(steamSummerSale, Name), y = howLongToBeat, by = "Name", all.x = TRUE)
  hltbMerged = hltbMerged[is.na(hltbMerged$main_story_length) == FALSE,]
  print(head(hltbMerged))
  ignMetacritcMerged = merge(x = ignMetacritcMerged, y = hltbMerged, by = "Name", all.x = TRUE)
  ignMetacritcMerged = ignMetacritcMerged[ignMetacritcMerged$platform == 'pc',]
  ignMetacritcMerged$platform = NULL
  ignMetacritcMerged = unique(ignMetacritcMerged)
  return(ignMetacritcMerged)
}

if (dir.exists('/home/bc7_ntalavera/Dropbox/Data Science/Data Files/Steam/')) {
  dataLocale = '/home/bc7_ntalavera/Dropbox/Data Science/Data Files/Steam/' 
} else if (dir.exists('/Volumes/SDExpansion/Data Files/Steam/')) {
  dataLocale = '/Volumes/SDExpansion/Data Files/Steam/'
}
steamSummerSaleFirstDay = as.Date('2016-07-04', "%Y-%m-%d")
steamSummerSaleLastDay = as.Date('2016-06-23', "%Y-%m-%d")
steamSummerSaleData = steamSpySaleCSVPreparer()
steamSpyAllData = steamspyJson()
metacriticReviewsData = metacriticCSVPreparer()
howLongToBeatData = howLongToBeatCSVPreparer()
ignReviewsData = ignCSVPreparer()
ignMetacritcHLTBMergedData = ignMetacritcHLTBMerged(ignReviewsData,metacriticReviewsData,steamSummerSaleData,howLongToBeatData)
steamMerged = merge(x = steamSummerSaleData, y = steamSpyAllData, by = "Name", all.x = TRUE)
steamMerged = merge(x = steamMerged, y = ignMetacritcHLTBMergedData, by = "Name", all.x = TRUE)
steamMerged$GameAge = steamSummerSaleFirstDay - steamMerged$Release_Date
steamMerged$GameAge[steamMerged$GameAge < 0] = NA
write.csv(steamMerged, file = 'steamDatabaseAllCombined.csv')