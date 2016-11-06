library(dplyr)
library(stringr)
library(stringi)
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
substrRight <- function(x, n){
  substr(x, nchar(x)-n+1, nchar(x))
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
  data$isOnUserVoice = TRUE
  data$in_progress[data$in_progress == 'In-Progress'] = TRUE
  # data$kinectRequired[data$kinectRequired == 'Yes'] = TRUE
  return(data)
}

fixXbox360_MS_Site = function(data) {
  # data = unique.data.frame(data)/
  data = unique(data)
  data$gameName = str_trim(as.character(data$gameName))
  data$hasDemoAvailable[data$DLdemos>0] = TRUE
  data$hasDemoAvailable[is.na(data$DLdemos)] = FALSE
  data$isListedOnMSSite = TRUE
  data$DLdemos = NULL
  data$isAvailableToPurchaseDigitally[data$gameCount == 1] = TRUE
  # data$isAvailableToPurchaseDigitally[is.na(data$gameCount)] = TRUE
  data[data == ""] = NA
  return(data)
}

fixMetacritic = function(data) {
  data$gameName = str_trim(as.character(data$gameName))
  data$isMetacritic = TRUE
  return(data)
}

fixMajorNelson = function(data){
  data$isDiscOnly[unlist(lapply(data$gameName, function(x) grepl('(disc only)',tolower(x))))] = TRUE
  data$isBCCompatible = TRUE
  data$BCCompatible = NULL
  data$gameName[unlist(lapply(data$gameName, function(x) grepl('(disc only)',tolower(x))))] =  gsub('(disc only)',"",data$isDiscOnly[unlist(lapply(data$gameName, function(x) grepl('(disc only)',tolower(x))))])
  return(data)
}
namePrettier = function(dataX) {
  dataX$gameName = as.character(dataX$gameName)
  dataX = dataX[dataX$gameName != "" & dataX$gameName != "gameName",]
  dataX$gameName = gsub("™", "", dataX$gameName)
  dataX$gameName = gsub("®", "", dataX$gameName)
  dataX$gameName = gsub("ñ", "n", dataX$gameName)
  dataX$gameName = gsub("Full Game - ", "", dataX$gameName)
  dataX$gameName = gsub(" - Full", "", dataX$gameName)
  gameNameDict = c('Call of Duty: Modern Warfare 2','Call of Duty: Modern Warfare 3','Call of Duty 4: Modern Warfare','Battlefield: Bad Company 2','Call of Duty: Black Ops II','Dead Rising',
                   'Halo 3: ODST','Halo: Combat Evolved Anniversary', 'Lost Planet 2','Need for Speed: ProStreet','Plants vs Zombies: Garden Warfare','Resident Evil 5',
                   'World of Tanks','Tom Clancy\'s Ghost Recon Advanced Warfighter 2','Assassin\'s Creed: Revelations','Samurai Shodown: Sen','Prototype',
                   'Ace Combat: Assault Horizon','Battlefield: Bad Company','Dynasty Warriors 6','Dynasty Warriors 6 Empires','DmC: Devil May Cry','Pac-Man and the Ghostly Adventures','Pac-Man and the Ghostly Adventures 2',
                   'Assassin\'s Creed IV: Black Flag','Zone of the Enders HD Collection','Dance Evolution','Blackwater','Ace Combat 6: Fires of Liberation','State of Decay',
                   'Army of Two: The 40th Day','Condemned: Criminal Origins','Lumines Live!','Bangai-O HD: Missile Fury','Banjo-Kazooie: Nuts & Bolts','Blackwater','Cabela\'s African Adventures',
                   'Cabela\'s Big Game Hunter 2010','Cabela\'s Dangerous Hunts 2011','Cabela\'s North American Adventure','Cabela\'s Survival: Shadows of Katmai',
                   'Viva Pinata: Trouble in Paradise','Life Is Strange','Marlow Briggs and the Mask of the Death','Fable II','Fable III','Falling Skies: The Game',
                   'Feeding Frenzy 2: Shipwreck Showdown','Luxor 2','The Elder Scrolls IV: Oblivion','The Elder Scrolls V: Skyrim','Grand Theft Auto V','Grand Theft Auto IV', 'Blacksite: Area 51',
                   'BlazBlue: Calamity Trigger','BlazBlue: Continuum Shift','Blazing Angels 2: Secret Missions of WWII','Blazing Angels: Squadrons of WWII','2010 FIFA World Cup South Africa',
                   '3D Ultra MiniGolf Adventures','Adventure Time: Explore the Dungeon Because I DON\'T KNOW!','Alien Breed: Evolution','Avatar: The Last Airbender -- The Burning Earth',
                   'Beijing 2008 - The Official Video Game of the Olympic Games','Bejeweled 2 Deluxe','Ben 10 Ultimate Alien: Cosmic Destruction','Beowulf: The Game','Bomberman Live: Battlefest',
                   'Brutal Legend','Bully: Scholarship Edition','Cabela\'s North American Adventures','America\'s Army: True Soldiers','Brothers in Arms: Hell\'s Highway','Castlevania: Lords of Shadow 2','Castlevania: Lords of Shadow',
                   'Castlevania: Harmony of Despair','Cloudy With a Chance of Meatballs','Tom Clancy’s Rainbow Six Vegas','Tom Clancy’s Rainbow Six Vegas 2','James Cameron\'s Avatar','James Cameron\'s Avatar',
                   'Transformers: War for Cybertron','Asteroids & Deluxe','Viva Pinata: Trouble in Paradise','Tom Clancy\'s Splinter Cell Double Agent','Armored Core for Answer'
                   )
  names(gameNameDict) = tolower(c('Modern Warfare 2','Modern Warfare 3','Modern Warfare','Battlefield: Bad Co. 2','COD: Black Ops II','DEAD RISING',
                          'Halo 3: ODST Campaign Edition','Halo: Combat Evolved', 'LOST PLANET 2','NFS ProStreet','Plants vs Zombies Garden Warfare','RESIDENT EVIL 5',
                          'World of Tanks: Xbox 360 Edition','TC\'s GRAW2','Assassin\'s Creed Revelations','Samurai Shodown SEN','[PROTOTYPE]',
                          'ACE COMBAT: AH','Battlefield: Bad Co.','DW6','DW6 Empires','DmC','PAC-MAN GHOSTLY ADV','PAC-MAN GHOSTLY ADV 2',
                          'Assassins Creed IV','ZOE HD','Dance Evolution / DanceMasters','Blackwater (video game)','Ace Combat 6','State of Decay (video game)',
                          'Army of TWO: TFD','Condemned','LUMINES LIVE! Standard Edition','Bangai-O HD','Banjo Kazooie: N and B','Blackwater Kinect','Cabela\'s African Adventure',
                          'Cabela\'s BGH 2010','Cabela\'s DH 2011','Cabela\'s NAA','Cabela\'s Survival: SoK',
                          'Viva Piata: TIP','Life Is Strange Episode 1','Marlow Briggs','Fable 2','Fable 3','Falling Skies',
                          'Feeding Frenzy 2','Full Game - Luxor 2','Oblivion','Skyrim','GTA V','GTA IV','Blacksite',
                          'BlazBlue','BLAZBLUE CS','Blazing Angels 2','Blazing Angels','2010 FIFA World Cup',
                          '3D Ultra Minigolf','Adventure Time: Explore','Alien Breed Episode 1','Avatar: TLA: TBE',
                          'Beijing 2008','Bejeweled 2','Ben 10 Ultimate Alien','Beowulf','Bomberman Live',
                          'Brütal Legend','Bully Scholarship Ed.','Cabela\'s North American Adventure','AA: True Soldiers','Brothers in Arms: HH','Castlevania: LoS 2','Castlevania LoS',
                          'Castlevania HD','Cloudy with a...','TC\'s RainbowSix Vegas','TC\'s RainbowSix Vegas2','James Cameron\'s Avatar: The Game','Cameron\'s Avatar',
                          'Transformers: WFC','ATARI ASTEROIDS/ASTEROIDS DELUXE','Viva Pinata: TIP','TC\'s SC Double Agent','AC for Answer'
                          ))
  dataX$gameName[tolower(dataX$gameName)%in%names(gameNameDict)] = gameNameDict[tolower(dataX$gameName[tolower(dataX$gameName)%in%names(gameNameDict)])]
  return(dataX)
}

gameRemover = function(data) {
  gamesToRemove = c('Assassins Creed The Americas Collection','ACE COMBAT: AH Demo','Adidas miCoach','Batman: AA GOTY',"XNA Creators Club", "Xbox 360 HD DVD Player", "Xbox 360 Summer Blockbusters", "Xbox 360 Team", "Xbox 360 Team", "Xbox LIVE Event Registrations",
                    'Photo Party')
  keywordsToRemove <- tolower(sort(c("bundle","pack",'Assassins Creed The Americas Collection','ACE COMBAT: AH Demo','Adidas miCoach','Batman: AA GOTY')))
  keywordsToRemoveRegex = paste(keywordsToRemove, collapse = "|")
  keywordsToRemoveRegex =  gsub(pattern = " ", replacement = "*", x = keywordsToRemoveRegex,ignore.case = TRUE)
  data$gameNameMissed = tolower(data$gameName)
  notRemoved = unlist(lapply(data$gameNameMissed, (function (x) !is.na(str_extract(x,keywordsToRemoveRegex)))))
  # notRemoved = unlist(lapply(data$gameNameMissed, (function (x) !is.na(str_match(x,keywordsToRemoveRegex)))))
  for (i in gamesToRemove) {
    print(i)
    data = data[data$gameName != i,]
  }
  print(sort(data$gameName[notRemoved]))
  data = data[!notRemoved,]
  return(data)
}
generousNameMerger = function(dataX,dataY,mergeType="all",keep = "x") {
  dataX$gameNameModded = tolower(dataX$gameName)
  dataY$gameNameModded = tolower(dataY$gameName)
  dataX$gameNameModded = gsub("[^[:alnum:] ]", "", dataX$gameNameModded)
  dataY$gameNameModded = gsub("[^[:alnum:] ]", "", dataY$gameNameModded)
  dataX$gameNameModded = gsub(" ", "", dataX$gameNameModded)
  dataY$gameNameModded = gsub(" ", "", dataY$gameNameModded)
  dataX$gameNameModded = gsub("™", "", dataX$gameNameModded)
  dataY$gameNameModded = gsub("™", "", dataY$gameNameModded)
  dataX$gameNameModded = gsub("®", "", dataX$gameNameModded)
  dataY$gameNameModded = gsub("®", "", dataY$gameNameModded)
  
  dataX$gameNameModded = gsub("s$", "", dataX$gameNameModded)
  dataY$gameNameModded = gsub("s$", "", dataY$gameNameModded)
  # dataX$gameNameModded = gsub("[^\x20-\x7E]", "", dataX$gameNameModded)
  # dataY$gameNameModded = gsub("[^\x20-\x7E]", "", dataY$gameNameModded)
  
  if (tolower(mergeType) == "all") {
  data = merge(x = dataX, y = dataY, by = "gameNameModded", all = TRUE)
  } else if (tolower(mergeType) == "all.x") {
    data = merge(x = dataX, y = dataY, by = "gameNameModded", all.x = TRUE)
  } else if (tolower(mergeType) == "all.y") {
    data = merge(x = dataX, y = dataY, by = "gameNameModded", all.y = TRUE)
  }
  data = unique(data)
  if (tolower(keep) == "x") {
  data$gameName.x[is.na(data$gameName.x)] =  data$gameName.y[is.na(data$gameName.x)]
  data$gameName = data$gameName.x
  } else {
    data$gameName.y[is.na(data$gameName.y)] =  data$gameName.x[is.na(data$gameName.y)]
    data$gameName = data$gameName.y
  }
  data$gameName.y = NULL
  
  data$gameName.x = NULL
  data$gameNameModded = NULL
  data = gameRemover(data)
  return (data)
}

rm(list = setdiff(ls(), lsf.str()))
setwd('/Volumes/SDExpansion/Data Files/bootcamp007_project/Project3-WebScraping/NickTalavera/CSV Processing')
setwd('/Volumes/SDExpansion/Data Files/Xbox Back Compat Data')
MajorNelsionBCList = namePrettier(fixMajorNelson(read.csv('Major_Nelson_Blog_BC_List.csv', stringsAsFactors = FALSE, header = TRUE)))
UserVoice = namePrettier(fixUserVoice(read.csv('UserVoice.csv', stringsAsFactors = FALSE, header = TRUE)))
WikipediaXB360Exclusive = namePrettier(fixWikipediaXB360KExclusive(read.csv('WikipediaXB360Exclusive.csv', stringsAsFactors = FALSE, header = TRUE)))
WikipediaXB360Kinect = namePrettier(fixWikipediaXB360Kinect(read.csv('WikipediaXB360Kinect.csv', header = TRUE)))
Xbox360_MS_Site = namePrettier(fixXbox360_MS_Site(read.csv('Xbox360_MS_Site.csv', stringsAsFactors = FALSE, header = TRUE)))
XboxOne_MS_Site = namePrettier(read.csv('XboxOne_MS_Site.csv', stringsAsFactors = FALSE, header = TRUE))
Remasters = namePrettier(fixRemasters(read.csv('Remasters.csv', stringsAsFactors = FALSE, header = TRUE)))
MetacriticXbox360 = namePrettier(fixMetacritic(namePrettier(read.csv('MetacriticXbox360.csv'))))


dataUlt = generousNameMerger(WikipediaXB360Exclusive, WikipediaXB360Kinect)
dataUlt = generousNameMerger(dataUlt, MajorNelsionBCList)
dataUlt = generousNameMerger(dataUlt, UserVoice)
dataUlt = generousNameMerger(dataUlt, Xbox360_MS_Site, "all","x")
dataUlt = generousNameMerger(dataUlt, MetacriticXbox360, "all.x","x")
# Remasters
# XboxOne_MS_Site

dataUlt[dataUlt == ""] = NA
dataUlt[is.na(dataUlt)] = FALSE
# dataUlt$in_progress[dataUlt$in_progress == ""] = FALSE

# dataUlt = select(dataUlt, gameName, votes, kinectSupport)
dataUlt = moveMe(dataUlt, c("gameName","isListedOnMSSite","isMetacritic","isBCCompatible","isOnUserVoice","isExclusive","isKinectSupported"), "first")
dataUlt = unique(dataUlt)
dataUlt = gameRemover(dataUlt)
# dataUlt = dataUlt[is.na(dataUlt$votes) | !dataUlt$c,]
dataUltA = dataUlt[dataUlt$isListedOnMSSite == TRUE  & (dataUlt$isMetacritic == TRUE | dataUlt$isBCCompatible == TRUE | dataUlt$isOnUserVoice == TRUE | dataUlt$isKinectSupported == TRUE | dataUlt$isExclusive == TRUE),]
dataUltN = dataUlt[dataUlt$isListedOnMSSite == TRUE  & !(dataUlt$isMetacritic == TRUE | dataUlt$isBCCompatible == TRUE | dataUlt$isOnUserVoice == TRUE | dataUlt$isKinectSupported == TRUE | dataUlt$isExclusive == TRUE),]
dataUltG = dataUlt[dataUlt$isListedOnMSSite == FALSE  & (dataUlt$isMetacritic == TRUE | dataUlt$isBCCompatible == TRUE | dataUlt$isOnUserVoice == TRUE | dataUlt$isKinectSupported == TRUE | dataUlt$isExclusive == TRUE),]