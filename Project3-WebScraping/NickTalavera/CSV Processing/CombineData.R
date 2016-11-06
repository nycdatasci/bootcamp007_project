library(dplyr)
library(stringr)

moveMe <- function(data, tomove, where = "last", ba = NULL) {
  temp <- setdiff(names(data), tomove)
  x <- switch(
    where,
    first = data[c(tomove, temp)],
    last = data[c(temp, tomove)],
    before = {
      if (is.null(ba)) stop("must specify ba column")
      if (length(ba) > 1) stop("ba must be a single character string")
      data[append(temp, values = tomove, after = (match(ba, temp)-1))]
    },
    after = {
      if (is.null(ba)) stop("must specify ba column")
      if (length(ba) > 1) stop("ba must be a single character string")
      data[append(temp, values = tomove, after = (match(ba, temp)))]
    })
  x
}


fixRemasters = function(data) {
  data$Remastered = TRUE
  return(data)
}

fixWikipediaXB360Kinect = function(data) {
  data$gameName = str_trim(data$gameName)
  data$kinectRequired = as.character(data$kinectRequired)
  data = data[data$gameName != "",]
  data$isKinectSupported = TRUE
  data$kinectRequired[data$kinectRequired == 'No'] = FALSE
  data$kinectRequired[data$kinectRequired == 'Yes'] = TRUE
  data$kinectSupport = NULL
  return(data)
}
fixWikipediaXB360KExclusive = function(data) {
  # print(data$exclusiveType[data$exclusiveType == "Console"])
  data$isConsoleExclusive[data$exclusiveType == "Console"] = TRUE
  data$isConsoleExclusive[data$exclusiveType != "Console"] = FALSE
  data$isExclusive = TRUE
  data$exclusiveType = NULL
  return(data)
}

fixUserVoice = function(data) {
  data$gameName = str_trim(data$gameName)
  data$in_progress = as.character(data$in_progress)
  # data = data[data$gameName != "",]
  # data$kinectSupport = TRUE
  data$in_progress[data$in_progress == 'In-Progress'] = TRUE
  # data$kinectRequired[data$kinectRequired == 'Yes'] = TRUE
  return(data)
}

fixXbox360_MS_Site = function(data) {
  data = unique.data.frame(data)
  data$gameName = str_trim(as.character(data$gameName))
  data$hasDemoAvailable[data$DLdemos>0] = TRUE
  data$hasDemoAvailable[is.na(data$DLdemos)] = FALSE
  data$DLdemos = NULL
  data[data == ""] = NA
  return(data)
}

fixMetacritic = function(data) {
  data$gameName = str_trim(as.character(data$gameName))
  return(data)
}

namePrettier = function(dataX) {
  dataX$gameName = as.character(dataX$gameName)
  dataX = dataX[dataX$gameName != "" & dataX$gameName != "gameName",]
  gameNameDict = c('Call of Duty: Modern Warfare 2','Call of Duty: Modern Warfare 3','Call of Duty 4: Modern Warfare','Battlefield: Bad Company 2','Call of Duty: Black Ops II','Dead Rising',
                   'Halo 3: ODST','Halo: Combat Evolved Anniversary', 'Lost Planet 2','Need for Speed: ProStreet','Plants vs Zombies: Garden Warfare','Resident Evil 5',
                   'World of Tanks','Tom Clancy\'s Ghost Recon Advanced Warfighter 2','Assassin\'s Creed: Revelations','Samurai Shodown: Sen','Prototype',
                   'Ace Combat: Assault Horizon','Battlefield: Bad Company','Dynasty Warriors 6','Dynasty Warriors 6 Empires','DmC: Devil May Cry','Pac-Man and the Ghostly Adventures','Pac-Man and the Ghostly Adventures 2',
                   'Assassin\'s Creed IV: Black Flag','Zone of the Enders HD Collection','Dance Evolution','Blackwater'
                   )
  names(gameNameDict) = tolower(c('Modern Warfare 2','Modern Warfare 3','Modern Warfare','Battlefield: Bad Co. 2','COD: Black Ops II','DEAD RISING',
                          'Halo 3: ODST Campaign Edition','Halo: Combat Evolved', 'LOST PLANET 2','NFS ProStreet','Plants vs Zombies Garden Warfare','RESIDENT EVIL 5',
                          'World of Tanks: Xbox 360 Edition','TC\'s GRAW2','Assassin\'s Creed Revelations','Samurai Shodown SEN','[PROTOTYPE]',
                          'ACE COMBAT: AH','Battlefield: Bad Co.','DW6','DW6 Empires','DmC','PAC-MAN GHOSTLY ADV','PAC-MAN GHOSTLY ADV 2',
                          'Assassins Creed IV','ZOE HD','Dance Evolution / DanceMasters','Blackwater (video game)'
                          ))
  a = dataX$gameName[tolower(dataX$gameName)%in%names(gameNameDict)]
  print(a)
  # print(gameNameDict[tolower('DW6')])
  # print(gameNameDict[a])
  dataX$gameName[tolower(dataX$gameName)%in%names(gameNameDict)] = gameNameDict[tolower(dataX$gameName[tolower(dataX$gameName)%in%names(gameNameDict)])]
  return(dataX)
}

gameRemover = function(data) {
  keywordsToRemove <- tolower(sort(c("bundle","pack")))
  keywordsToRemoveRegex = paste(keywordsToRemove, collapse = "|")
  keywordsToRemoveRegex =  gsub(pattern = " ", replacement = "*", x = keywordsToRemoveRegex,ignore.case = TRUE)
  data$gameNameModded = tolower(data$gameNameModded)
  notRemoved = unlist(lapply(data$gameNameModded, (function (x) !is.na(str_extract(x,keywordsToRemoveRegex)))))
  # print(sort(data$gameNameModded[notRemoved]))
  data = data[!notRemoved,]
  return(data)
}
generousNameMerger = function(dataX,dataY) {
  dataX$gameNameModded = tolower(dataX$gameName)
  dataY$gameNameModded = tolower(dataY$gameName)
  dataX = gameRemover(dataX)
  dataY = gameRemover(dataY)
  dataX$gameNameModded = gsub("[^[:alnum:] ]", "", dataX$gameNameModded)
  dataY$gameNameModded = gsub("[^[:alnum:] ]", "", dataY$gameNameModded)
  dataX$gameNameModded = gsub(" ", "", dataX$gameNameModded)
  dataY$gameNameModded = gsub(" ", "", dataY$gameNameModded)
  data = merge(x = dataX, y = dataY, by = "gameNameModded", all = TRUE)
  data = unique(data)
  data$gameName.x[is.na(data$gameName.x)] =  data$gameName.y[is.na(data$gameName.x)]
  data$gameName.y = NULL
  data$gameName = data$gameName.x
  data$gameName.x = NULL
  return (data)
}

rm(list = setdiff(ls(), lsf.str()))
setwd('/Volumes/SDExpansion/Data Files/bootcamp007_project/Project3-WebScraping/NickTalavera/CSV Processing')
setwd('/Volumes/SDExpansion/Data Files/Xbox Back Compat Data')
MajorNelsionBCList = read.csv('Major_Nelson_Blog_BC_List.csv', stringsAsFactors = FALSE, header = TRUE)
UserVoice = namePrettier(fixUserVoice(read.csv('UserVoice.csv', stringsAsFactors = FALSE, header = TRUE)))
WikipediaXB360Exclusive = namePrettier(fixWikipediaXB360KExclusive(read.csv('WikipediaXB360Exclusive.csv', stringsAsFactors = FALSE, header = TRUE)))
WikipediaXB360Kinect = namePrettier(fixWikipediaXB360Kinect(read.csv('WikipediaXB360Kinect.csv', header = TRUE)))
Xbox360_MS_Site = namePrettier(fixXbox360_MS_Site(read.csv('Xbox360_MS_Site.csv', stringsAsFactors = FALSE, header = TRUE)))
XboxOne_MS_Site = namePrettier(read.csv('XboxOne_MS_Site.csv', stringsAsFactors = FALSE, header = TRUE))
Remasters = namePrettier(fixRemasters(read.csv('Remasters.csv', stringsAsFactors = FALSE, header = TRUE)))
MetacriticXbox360 = fixMetacritic(namePrettier(read.csv('MetacriticXbox360.csv')))


# dataUlt = generousNameMerger(MetacriticXbox360,Xbox360_MS_Site)
dataUlt = generousNameMerger(WikipediaXB360Exclusive, WikipediaXB360Kinect)
# dataUlt = generousNameMerger(dataUlt, WikipediaXB360Kinect)
# dataUlt = generousNameMerger(dataUlt, WikipediaXB360Exclusive)
# dataUlt = generousNameMerger(dataUlt, MajorNelsionBCList)

# dataUlt = merge(x = dataUlt, y = WikipediaXB360Exclusive, by = "gameName", all = TRUE)
# dataUlt = merge(x = dataUlt, y = Remasters, by = "gameName", all = TRUE)
# dataUlt = merge(x = dataUlt, y = MajorNelsionBCList, by = "gameName", all = TRUE)


# dataUlt$Remastered[is.na(dataUlt$Remastered)] = FALSE
# dataUlt$kinectRequired[is.na(dataUlt$kinectRequired)] = FALSE
# dataUlt$kinectSupport[is.na(dataUlt$kinectSupport)] = FALSE
# dataUlt$in_progress[is.na(dataUlt$in_progress)] = FALSE
# dataUlt$in_progress[dataUlt$in_progress == ""] = FALSE
# dataUlt = dataUlt[dataUlt$gameName != "",]
# dataUlt = select(dataUlt, gameName, votes, kinectSupport)
dataUlt = moveMe(dataUlt, c("gameName"), "first")
dataUlt = unique(dataUlt)
# dataUlt = dataUlt[(!is.na(dataUlt$reviewScorePro) & is.na(dataUlt$dayRecorded)) | (is.na(dataUlt$reviewScorePro) & !is.na(dataUlt$dayRecorded)),]