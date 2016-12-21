# rm(list = ls()) #If I want my environment reset for testing.
#===============================================================================
#                                   LIBRARIES                                  #
#===============================================================================
library(jsonlite)
library(dplyr)
library(stringr)
library(kknn) #Load the weighted knn library.
library(VIM) #For the visualization and imputation of missing values.
library(class)
library(DataCombine)
#===============================================================================
#                                SETUP PARALLEL                                #
#===============================================================================
library(foreach)
library(parallel)
library(doParallel)
cores.Number = detectCores(all.tests = FALSE, logical = TRUE)
cl <- makeCluster(2)
registerDoParallel(cl, cores=cores.Number)
#===============================================================================
#                               GENERAL FUNCTIONS                              #
#===============================================================================
removeSymbols = function(namesArray) {
  newNames = namesArray
  newNames = stringr::str_replace_all(newNames,"[[:punct:]]","")
  newNames = stringr::str_replace_all(newNames, "[^[:alnum:]]", " ")
  newNames = stringr::str_trim(newNames)
  newNames = rm_white(newNames)
  return(newNames)
}
"%!in%" <- function(x,y)!("%in%"(x,y))
keepLargestDuplicate = function(data,duplicateColumn) {
  nums <- parSapply(cl = cl, data, is.numeric)
  nums = names(nums[nums==TRUE])
  columnsToKeep = ncol(data)
  # data = data.frame(foreach(i=1:length(nums)) %do% {
    # data <- data[order(data[,duplicateColumn], -abs(data[,nums[i]])),] #sort by id and reverse of abs(value)
    # data[!duplicated(data[,duplicateColumn]),]
    data = summarise_each(group_by(data,Name),funs(max))
  # })
  # data = data[,1:columnsToKeep]
  print(nums)
  return(data)
}
#===============================================================================
#                          DATA PROCESSING FUNCTIONS                           #
#===============================================================================
steamSpySaleCSVPreparer <- function() {
  steamSummerSaleNew = as.data.frame(read.csv(paste0(dataLocale, "Steam Summer Sale - SteamSpy - All the data and stats about Steam games.csv"),sep=",", stringsAsFactors = FALSE, na.strings=c("","NA")))
  steamSummerSaleNew = data.frame(parLapply(cl = cl, steamSummerSaleNew, sub, pattern = "N/A", replacement = NA, fixed = TRUE))
  steamSummerSaleNew = data.frame(parLapply(cl = cl, steamSummerSaleNew, as.character))
  steamSummerSaleNew = data.frame(parLapply(cl = cl, steamSummerSaleNew, gsub, pattern = "\\±|\\,|\\$|\\%|\\(|\\)", replacement = "", fixed = FALSE))
  steamSummerSaleNew = dplyr::select(steamSummerSaleNew, "Name" = Game,
                                     "Price_Before_Sale" = Price,
                                     "Maximum_Percent_Sale_and_Minimum_Price_With_Sale" = Max.discount,
                                     "Owners_Before" = Owners.before,
                                     "Owners_After" = Owners.after,
                                     "Userscore_And_Metascore" = Userscore..Metascore.,
                                     Increase
  )
  saleStrings = str_split_fixed(steamSummerSaleNew$Maximum_Percent_Sale_and_Minimum_Price_With_Sale, " ", 2)
  steamSummerSaleNew$Sale_Percent = saleStrings[,1]
  steamSummerSaleNew$Price_During_Sale = saleStrings[,2]
  reviewScoreStrings = str_split_fixed(steamSummerSaleNew$Userscore_And_Metascore, " ", 2)
  steamSummerSaleNew$Review_Score_Steam_Users = reviewScoreStrings[,1]
  steamSummerSaleNew$Review_Score_Metacritic = reviewScoreStrings[,2]
  steamSummerSaleNew$Owners_Before = stringr::str_replace_all(steamSummerSaleNew$Owners_Before," ","")
  steamSummerSaleNew$Owners_After = stringr::str_replace_all(steamSummerSaleNew$Owners_After," ","")
  steamSummerSaleNew$Price_Before_Sale = as.character(steamSummerSaleNew$Price_Before_Sale)
  columnsToNumeric = c("Sale_Percent","Price_During_Sale","Price_Before_Sale","Review_Score_Steam_Users","Review_Score_Metacritic","Owners_Before","Owners_After","Increase")
  steamSummerSaleNew[columnsToNumeric] <- parSapply(cl=cl, steamSummerSaleNew[columnsToNumeric], as.numeric)
  steamSummerSaleNew$Sales = steamSummerSaleNew$Owners_After - steamSummerSaleNew$Owners_Before
  steamSummerSaleNew = dplyr::select(steamSummerSaleNew, 
                                     -Userscore_And_Metascore, 
                                     -Maximum_Percent_Sale_and_Minimum_Price_With_Sale,
                                     -Owners_After,
                                     -Owners_Before)
  return(steamSummerSaleNew)
}

steamspyJson = function() {
  if (file.exists(paste0(dataLocale,"steamSpyAll.csv"))) {
    print("The SteamSpy API data named \"steamSpyAll.csv\" exists")
    steamSpyCSV = read.csv(paste0(dataLocale,"steamSpyAll.csv"), na.strings=c("","NA"))
    steamSpyCSV = dplyr::select(steamSpyCSV, -X, -median_forever, -average_forever, -Players_Forever_As_Of_Today, -Owners_As_Of_Today)
    return(steamSpyCSV)
  }
  else {
    steamSpyDataJsonFormat <- fromJSON(paste0(dataLocale,"steamSpyAll.json"))
    steamSpyDataToOutput <- data.frame()
    steamSpyDataToOutput = foreach (i = 1:length(steamSpyDataJsonFormat), .combine=rbind) %dopar% {
      return(data.frame(Name=steamSpyDataJsonFormat[i]$name, appid=steamSpyDataJsonFormat[i]$appid, Owners_As_Of_Today=steamSpyDataJsonFormat[i]$owners, Players_Forever_As_Of_Today=steamSpyDataJsonFormat[i]$players_forever, average_forever=steamSpyDataJsonFormat[i]$average_forever, median_forever=steamSpyDataJsonFormat[i]$median_forever))
    }
    dplyr::select(steamSpyDataToOutput, -X, -median_forever, -average_forever, -Players_Forever_As_Of_Today, -Owners_As_Of_Today)
    write.csv(steamSpyDataToOutput,paste0(dataLocale,"steamSpyAll.csv"))
    return(steamSpyDataToOutput)
  }
}

metacriticCSVPreparer <- function() {
  metacriticReviews = read.csv(paste0(dataLocale,"metacritic-20151227.csv"),sep=";",stringsAsFactors = FALSE, na.strings=c("","NA"))
  metacriticReviews = rename(metacriticReviews, "Name" = title)
  metacriticReviews = metacriticReviews[metacriticReviews$platform %!in% c("ios","gba","ds","3ds","psp","vita"),] 
  # metacriticReviews = metacriticReviews[metacriticReviews$platform %in% c("pc"),]
  metacriticReviews = dplyr::select(metacriticReviews, -user_score)
  metacriticReviews$release = as.Date(as.character(metacriticReviews$release),"%b %d, %Y")
  return(metacriticReviews)
}

ignCSVPreparer <- function() {
  ignReviews = read.csv(paste0(dataLocale,"ign.csv"),sep=",", stringsAsFactors = FALSE, na.strings=c("","NA"))
  ignReviews$Release_Date = as.Date(paste0(ignReviews$release_year,ignReviews$release_month,ignReviews$release_day), format = "%Y%m%d")
  ignReviews = dplyr::select(ignReviews, "Name" = title, "Review_Score_IGN" = score, "Genre" = genre, "Platform" = platform, Release_Date)
  colnames(ignReviews)[colnames(ignReviews) == "editors_choice"] = "IGN_Editors_Choice"
  # ignReviewsNotPCorMobile= ignReviews[ignReviews$Platform %!in% c("Wireless","PlayStation Vita","ios","3ds","PlayStation Portable","Nintendo DS","Nintendo 3DS","iPhone","iPad"),]
  ignReviews = ignReviews[ignReviews$Platform %in% c("PC"),]
  # ignReviews[is.na(ignReviews)] = ignReviews[is.na(ignReviews)]
  ignReviews = dplyr::select(ignReviews, -Platform)
  ignReviews = unique(ignReviews)
  return(ignReviews)
}

howLongToBeatCSVPreparer <- function() {
  howLongToBeat = read.csv(paste0(dataLocale,"howlongtobeat.csv"),sep=";", stringsAsFactors = FALSE, na.strings=c("","NA"))
  howLongToBeat = dplyr::select(howLongToBeat, Name = title, "CampaignLength" = main_story_length, platform)
  howLongToBeat = howLongToBeat[howLongToBeat$platform %in% c("PC","Linux","Mac"),]
  howLongToBeat = dplyr::select(howLongToBeat, -platform)
  return(howLongToBeat)
}
#===============================================================================
#                               SPECIALIZED MERGING                            #
#===============================================================================
generousNameMerger = function(dataX,dataY,mergeType="all",keepName = "x") {
  dataList = list(dataX, dataY)
  datasWNameModded = foreach(i=1:length(dataList)) %dopar% {
    datasOut = dataList[[i]]
    datasOut$Name = as.character(datasOut$Name)
    datasOut$NameModded = tolower(datasOut$Name)
    lastWords = as.integer(stringr::str_trim(stringr::str_extract(datasOut$NameModded,pattern="[0-9]+")))
    lastWords = as.character(as.roman(lastWords))
    datasOut$NameModded[!is.na(lastWords)] = stringr::str_replace(datasOut$NameModded[!is.na(lastWords)], replacement = lastWords[!is.na(lastWords)], pattern = "[0-9]+")
    removeWords = tolower(c("[^a-zA-Z0-9]"," ","Remastered","Videogame","WWE","EA*SPORTS","Soccer","&","™","®","DVD$","of","DX","disney","Deluxe","Complete","Ultimate","Encore","definitive","for","edition","standard","special","game", "the","Gold","Legendary","Base*Game","free*to*play","full*game", "year","hd","movie","TM","Cabela\"s","and"," x$","s$"))
    for (i in removeWords) {
      datasOut$NameModded = gsub(i, "", datasOut$NameModded, ignore.case = TRUE)
    }
    datasOut$NameModded[datasOut$NameModded == ""] = datasOut$Name
    return(datasOut)
  }
  dataX = datasWNameModded[[1]]
  dataY = datasWNameModded[[2]]
  if (tolower(mergeType) == "all") {
    data = merge(x = dataX, y = dataY, by = "NameModded", all = TRUE)
  } else if (tolower(mergeType) == "all.x") {
    data = merge(x = dataX, y = dataY, by = "NameModded", all.x = TRUE)
  } else if (tolower(mergeType) == "all.y") {
    data = merge(x = dataX, y = dataY, by = "NameModded", all.y = TRUE)
  }
  if (tolower(keepName) == "x") {
    data$Name.x[is.na(data$Name.x)] =  data$Name.y[is.na(data$Name.x)]
    data$Name = data$Name.x
  } else {
    data$Name.y[is.na(data$Name.y)] =  data$Name.x[is.na(data$Name.y)]
    data$Name = data$Name.y
  }
  data = VarDrop(data, c("Name.y", "Name.x", "NameModded"))
  data = gameRemover(data)
  data = keepLargestDuplicate(data)
  return (data)
}

gameRemover = function(data) {
  gamesToRemove = c(
  )
  keywordsToRemove <- tolower(sort(c("\\Sbundle","pack","(PC)","Team DZN","\\SDLC")))
  keywordsToRemoveRegex = paste(keywordsToRemove, collapse = "|")
  keywordsToRemoveRegex =  gsub(pattern = " ", replacement = "*", x = keywordsToRemoveRegex,ignore.case = TRUE)
  gameNameMissed = tolower(data$Name)
  notRemoved = unlist(lapply(gameNameMissed, (function (x) !is.na(str_extract(x,keywordsToRemoveRegex)))))
  data = data[!notRemoved,]
  for (i in tolower(gamesToRemove)) {
    data = data[tolower(data$Name) != i,]
  }
  return(data)
}

#===============================================================================
#                               DIRECTORY SETUP                                #
#===============================================================================
if (dir.exists("/home/bc7_ntalavera/Dropbox/Data Science/Data Files/Steam/")) {
  dataLocale = "/home/bc7_ntalavera/Dropbox/Data Science/Data Files/Steam/" 
} else if (dir.exists("/Volumes/SDExpansion/Data Files/Steam/")) {
  dataLocale = "/Volumes/SDExpansion/Data Files/Steam/"
}
#===============================================================================
#                               EXECUTE FUNCTIONS                              #
#===============================================================================
steamSummerSaleData = steamSpySaleCSVPreparer()
steamSpyAllData = steamspyJson()
metacriticReviewsData = metacriticCSVPreparer()
howLongToBeatData = howLongToBeatCSVPreparer()
ignReviewsData = ignCSVPreparer()
steamMerged = generousNameMerger(steamSummerSaleData,steamSpyAllData,mergeType="all.x",keepName = "x")
steamMerged = generousNameMerger(steamMerged,ignReviewsData,mergeType="all.x",keepName = "x")
steamMerged = generousNameMerger(steamMerged,metacriticReviewsData,mergeType="all.x",keepName = "x")
steamMerged = generousNameMerger(steamMerged,howLongToBeatData,mergeType="all.x",keepName = "x")
steamMerged$Release_Date[is.na(steamMerged$Release_Date)] = steamMerged$release[is.na(steamMerged$Release_Date)]
steamMerged$Review_Score_Metacritic[is.na(steamMerged$Release_Date)] = steamMerged$score[is.na(steamMerged$Release_Date)]
steamMerged$Review_Score_Metacritic[is.na(steamMerged$Genre)] = steamMerged$score[is.na(steamMerged$genre)]
steamMerged = MoveFront(steamMerged, c("Name",'CampaignLength',"Review_Score_Metacritic","Review_Score_Steam_Users","Review_Score_IGN","Release_Date"))
steamMerged = data.frame(VarDrop(steamMerged, c("release", "appid", "platform","genre","score")))
steamMerged$Genre = gsub("\\,.*","",steamMerged$Genre)
steamMerged$Release_Date = as.numeric(steamMerged$Release_Date)

rownames(steamMerged) = steamMerged$Name
steamMerged = DropNA(steamMerged, Var = c("Sales","Increase"))
library(mice)
md.pattern(steamMerged)
steamMerged = kNN(steamMerged, k = sqrt(ncol(steamMerged)), imp_var = FALSE)
# steamMerged = mice(steamMerged,m=5,maxit=50,meth='pmm',seed=500)
steamSummerSaleFirstDay = as.Date('2016-06-23', "%Y-%m-%d")
steamMerged$GameAge = as.numeric(steamSummerSaleFirstDay) - as.numeric(steamMerged$Release_Date) + 1
write.csv(steamMerged, file = paste0(dataLocale, "steamDatabaseAllCombined.csv"), row.names=FALSE)
steamMerged$Gross = log(steamMerged$Sales * steamMerged$Price_During_Sale)
steamMerged$Sales = log(steamMerged$Sales)
steamMerged$Sale_Percent = log(steamMerged$Sale_Percent)
steamMerged$CampaignLength = log(steamMerged$CampaignLength)
steamMerged$Price_Before_Sale = log(steamMerged$Price_Before_Sale)
steamMerged$Price_During_Sale = log(steamMerged$Price_During_Sale)
steamMerged$Gross[!is.finite(steamMerged$Gross)] = 0
steamMerged$Sale_Percent[!is.finite(steamMerged$Sale_Percent)] = 0
steamMerged$Price_During_Sale[!is.finite(steamMerged$Price_During_Sale)] = 0
steamMerged$Price_Before_Sale[!is.finite(steamMerged$Price_Before_Sale)] = 0
steamMerged$CampaignLength[is.nan(steamMerged$CampaignLength) | is.infinite(abs(steamMerged$CampaignLength))] = 0
sapply(steamMerged, function(y) sum(length(which(is.na(y)))))
model.empty = lm(Gross ~ 1, data = steamMerged) #The model with an intercept ONLY.
model.full = lm(Gross ~ . -Sales -Increase -Name -Genre -publisher -Release_Date, data = steamMerged) #The model with ALL variables.
scope = list(lower = formula(model.empty), upper = formula(model.full))
library(MASS)
forwardAIC = step(model.empty, scope, direction = "forward", k = 2)
model.overall = eval(forwardAIC$call)
library(car)
influencePlot(model.overall)
vif(model.overall)
avPlots(model.overall)
stopCluster(cl)
