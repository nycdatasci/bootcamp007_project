library(kknn) #Load the weighted knn library.
library(VIM) #For the visualization and imputation of missing values.
library(ggplot2)
library(dplyr)
library(stringr)
library(Hmisc)
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
  data$isRemastered = TRUE
  return(data)
}

fixWikipediaXB360Kinect = function(data) {
  data$gameName = str_trim(data$gameName)
  data$isKinectRequired = as.character(data$kinectRequired)
  data = data[data$gameName != "",]
  data$isKinectSupported = TRUE
  data$kinectRequired[data$kinectRequired == 'No'] = FALSE
  data$kinectRequired[data$kinectRequired == 'Yes'] = TRUE
  data$kinectSupport = NULL
  data$kinectRequired = NULL
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

fixMSXBone = function(data) {
  data = select(data, gameName)
  data$isOnXboxOne = TRUE
  return(data)
}

fixUserVoice = function(data) {
  data$gameName = str_trim(data$gameName)
  data$isInProgress = as.character(data$in_progress)
  # data = data[data$gameName != "",]
  # data$kinectSupport = TRUE
  data$isOnUserVoice = TRUE
  data$isInProgress[data$isInProgress == 'In-Progress'] = TRUE
  # data$kinectRequired[data$kinectRequired == 'Yes'] = TRUE
  data$in_progress = NULL
  return(data)
}

fixXbox360_MS_Site = function(data) {
  # data = unique.data.frame(data)/
  data = unique(data)
  
## FIX LATER
  # data = data[!is.na(data$releaseDate) & !is.na(as.numeric(gsub("/", "",as.character(data$releaseDate)))),]
  releaseDateds = as.Date(data$releaseDate, format = "%m/%d/%Y")
  data$releaseDate = as.character(releaseDateds)
  data$gameName = str_trim(as.character(data$gameName))
  data$hasDemoAvailable[data$DLdemos>0] = TRUE
  data$hasDemoAvailable[is.na(data$DLdemos)] = FALSE
  data$isListedOnMSSite = TRUE
  data$DLdemos = NULL
  data$isAvailableToPurchaseDigitally[data$gameCount == 1] = TRUE
  # data$isAvailableToPurchaseDigitally[is.na(data$gameCount)] = TRUE
  data[data == ""] = NA
  data$gameCount = NULL
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
  dataX$gameName = gsub("Full Version", "", dataX$gameName)
  dataX$gameName = gsub(" - FREE OFFER", "", dataX$gameName)
  dataX$gameName = gsub(" - Full", "", dataX$gameName)
  removeWords = tolower(c('Base Game','free to play','full game','(TM)$','NA$'))
  for (i in removeWords) {
    dataX$gameName = gsub(i, "", dataX$gameName, ignore.case = TRUE)
  }
  dataX$gameName = gsub("DW:", "Dynasty Warriors:", dataX$gameName, ignore.case = FALSE)
  dataX$gameName = gsub("PES", "Pro Evolution Soccer", dataX$gameName, ignore.case = FALSE)
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
                   'Transformers: War for Cybertron','Asteroids & Deluxe','Viva Pinata: Trouble in Paradise','Tom Clancy\'s Splinter Cell Double Agent','Armored Core for Answer','Every Extend Extra Extreme','Geometry Wars Retro Evolved',
                   'Hydro Thunder Hurricane','Kameo: Elements of Power','Monkey Island 2 Special Edition: LeChuck\'s Revenge','Monkey Island: Special Edition','Operation Flashpoint: Dragon Rising','Watchmen: The End is Nigh','Watchmen: The End is Nigh Part 2',
                   'Phantom Breaker:Battle Grounds','Zone of the Enders HD Collection','Puzzle Quest: Challenge of the Warlords','BIT.TRIP Presents… Runner2: Future Legend of Rhythm Alien',
                   "Sam & Max Beyond Time & Space",'Sonic The Hedgehog 4 Episode II','Soul Calibur II HD','Jane\'s Advanced Strike Fighters','Tour de France 2009','Tour de France 2013',
                   "50 Cent: Blood on the Sand",'Brave: The Video Game','Battlefield 2: Modern Combat','Dragon Ball Z for Kinect','Dragon Ball Z: BURST LIMIT','LEGO Indiana Jones 2: The Adventure Continues',
                   'LEGO Indiana Jones: The Original Adventures','LEGO Star Wars III: The Clone Wars','LEGO The Lord of the Rings','LEGO Harry Potter: Years 1-4','The Walking Dead: Survival Instinct','Transformers: Revenge of the Fallen',
                   'The Warriors: Street Brawl','The Raven - Legacy of a Master Thief Episode 1','Metal Gear Solid HD Collection','Metal Gear Solid HD Collection','The Witcher 2: Assassins of Kings',
                   'Tony Hawk\'s American Wasteland','A.R.E.S. Extinction Agenda EX','Sonic\'s Ultimate Genesis Collection','Tom Clancy\'s Splinter Cell Conviction','World Series of Poker: Tournament of Champions','Where the Wild Things Are','Titanfall','Worms Revolution','Valiant Hearts: The Great War',
                   'Young Justice: Legacy','Zeno Clash Ultimate Edition','Thrillville: Off the Rails','The Price is Right: Decades','Penguins of Madagascar: Dr. Blowhole Returns - Again','The King of Fighters 2002 Ultimate Match','Tom Clancy\'s H.A.W.X',
                   'Star Wars: The Clone Wars - Republic Heroes','Superstars V8 Next Challenge','Street Fighter II Hyper Fighting','Dead or Alive 5 Last Round','Super Hero Squad: The Infinity Gauntlet','Are You Smarter Than a 5th Grader: Game Time','Are You Smarter Than a 5th Grader: Game Time',
                   "Cabela's Alaskan Adventures",'Deadliest Catch: Alaskan Storm','Hannah Montana The Movie','Ace Combat: Assault Horizon','Chronicles of Riddick: Assault on Dark Athena','Naval Assault: The Killing Tide','Cabela\'s African Safari','Chivalry: Medieval Warfare',
                   'Civil War: Secret Missions','Civil War: Secret Missions','Call of Duty: Black Ops III','Cabela\'s Big Game Hunter: Hunting Party','Command & Conquer 3: Kane\'s Wrath','Command & Conquer Red Alert 3','Commanders: Attack of the Genos','Batman: Arkham Origins Blackgate - Deluxe Edition',
                   'Zero D Beat Drop','Bakugan: Defenders of the Core','Bakugan Battle Brawlers','Dance Dance Revolution Universe','Dance Dance Revolution Universe 2','Dance Dance Revolution Universe 3','Pirates of the Caribbean: At World\'s End','UEFA Champions League 2006-2007',
                   'Zeit Squared','WWE Legends of WrestleMania','007: Quantum of Solace','Nickelodeon Teenage Mutant Ninja Turtles','Bass Pro Shops: The Strike','Dynasty Warriors: Strikeforce','Strania - The Stella Machina -','Naruto Shippuden: Ultimate Ninja Storm Generations','Bladestorm: The Hundred Years\' War','Naruto Shippuden: Ultimate Ninja Storm 3',
                   'Naruto Shippuden: Ultimate Ninja Storm 2','Naruto Shippuden: Ultimate Ninja Storm 3 Full Burst','Naruto Shippuden: Ultimate Ninja Storm 2','Naruto Shippuden: Ultimate Ninja Storm 3 Full Burst','SpongeBob\'s Truth or Square','SpongeBob Sparepants: Underpants Slam!','SpongeBob Sparepants: Underpants Slam!',
                   'Star Ocean: The Last Hope','High School Musical 3: Senior Year Dance','DeathSpank: Thongs of Virtue','Digimon: All-Star Rumble','RAW - Realms of Ancient War','Super Puzzle Fighter II Turbo HD Remix','Don King Presents Prizefighter','Prison Break: The Conspiracy',
                   'Spider-Man: Shattered Dimensions','Penny Arcade Adventures: Episode One','Penny Arcade Adventures: Episode Two','Project Gotham Racing 4','Viva Pinata: Party Animals','Ninety-Nine Nights II','Naruto Shippuden: Ultimate Ninja Storm 3 Full Burst','The Chronicles of Narnia: Prince Caspian',
                   'Need for Speed: Undercover','SpongeBob HeroPants','SpongeBob Squarepants: Plankton\'s Robotic Revenge','Leela','Diablo III: Reaper of Souls','Diablo III: Reaper of Souls','Destroy All Humans! Path of the Furon',
                   ''
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
                          'Transformers: WFC','ATARI ASTEROIDS/ASTEROIDS DELUXE','Viva Pinata: TIP','TC\'s SC Double Agent','AC for Answer','E4','Geometry Wars Evolved',
                          'Hydro Thunder','Kameo','Monkey Island 2: Special Edition','The Secret of Monkey Island: S.E.','OF: Dragon Rising','WATCHMEN','WATCHMEN PART 2',
                          'Phantom Breaker:Battle Grounds -Cocoa\'s Nightmare Attack-','Zone of the Elders HD','Puzzle Quest','Runner2',
                          'Sam & Max Beyond Time and Space','SONIC 4 Episode II','SOULCALIBURII HD ONLINE','JASF','Tour de France 2009 - The Official Game','Tour de France 2013 - 100th Edition',
                          "50 Cent: BotS",'Disney/Pixar: Brave The Video Game','Battlefield 2: MC','DBZ for Kinect','DBZ: BURST LIMIT','LEGO Indiana Jones 2',
                          'LEGO Indiana Jones','LEGO Star Wars III','LEGO Lord of the Rings','LEGO Harry Potter','TWD: Survival Instinct','Transformers 2',
                          'The Warriors: SB','The Raven Episode 1','METAL GEAR SOLID 2 AND 3 HD','Metal Gear Solid 2 & 3: HD Edition','The Witcher 2: Assassins of Kings Enhanced Edition',
                          'American Wasteland','A.R.E.S.','Sonic\'s UGC','SplinterCellConviction','WSOP: TOC','WtWTA','Titanfall Deluxe Edition','Worms The Revolution Collection','Valiant Hearts',
                          'Young Justice','Zeno Clash UE','Thrillville: OTR','The Price Is Right','The Penguins of Madagascar','THE KING OF FIGHTERS 2002 UNLIMITED MATCH','TCs H.A.W.X',
                          'SWTCW: Republic Heroes','Superstars V8 NC','Street Fighter II\' HF','DOA5 Last Round','Super Hero Squad: TIG','5th Grader','5th Grader: Game Time',
                          'Alaskan Adventures','Alaskan Storm','Hannah The Movie','ASSAULTHORIZON','Assault on Dark Athena','Naval Assault','Cabela\'s Safari','Chivalry',
                          'Civil War','CW: Secret Missions','COD: Black Ops III','Cabela\'s Hunting Party','C&C3: Kane\'s Wrath','C&C Red Alert 3','Commanders: Attack','Blackgate Deluxe Ed.',
                          '0D Beat Drop','Bakugan: DOTC','Bakugan','DDR/DS Universe','DDR/DS Universe 2','DDR Universe 3','At Worlds End','UEFA CL 2006-2007',
                          'Zeit²','WWE Legends','Quantum of Solace','Teenage Mutant Ninja Turtles','The Strike','DW: Strikeforce','Strania','STORM Generations','BLADESTORM','NARUTO STORM 3',
                          'Naruto: Ninja Storm 2','Naruto Shippuden: Ultimate Ninja Storm 3','NINJA STORM 2','Naruto Shippuden: Ultimate Ninja Storm 3','SpongeBob: Truth-Sq.','SpongeBob UnderPants!','SpongeBob SquarePants: Underpants Slam!',
                          'Star Ocean: TLH','HSM3 Senior Year DANCE','Deathspank T.O.V.','Digimon: ASR','RAW','Puzzle Fighter HD','Prizefighter','Prison Break',
                          'Spider-Man:Dimensions','Penny Arcade Episode 1','Penny Arcade Episode Two','PGR 4','Party Animals','N3II: Ninety-Nine Nights','Naruto Shippuden: Ultimate Ninja Storm 3','Narnia: Prince Caspian',
                          'NFS Undercover','SBHP','SB: Robotic Revenge','Deepak Chopras Leela','Diablo III: Reaper of Souls – Ultimate Evil Edition','Diablo III','DAH! Path of the Furon',
                          ''
                          ))
  dataX$gameName[tolower(dataX$gameName)%in%names(gameNameDict)] = gameNameDict[tolower(dataX$gameName[tolower(dataX$gameName)%in%names(gameNameDict)])]
  return(dataX)
}

gameRemover = function(data) {
  gamesToRemove = c('Assassins Creed The Americas Collection','ACE COMBAT: AH Demo','Adidas miCoach','Batman: AA GOTY',"XNA Creators Club", "Xbox 360 HD DVD Player", "Xbox 360 Summer Blockbusters", "Xbox 360 Team", "Xbox 360 Team", "Xbox LIVE Event Registrations",
                    'Photo Party','Deus Ex: Human Revolution – Director’s Cut','Xbox Live Arcade Unplugged Vol. 1','LEGO Lord of the Rings - Demo','Windows Media Center','World of Tanks Public Test',
                    'Black','Transformers: The Cybertron Experience','Burnout 3: Takedown','Command and Conquer 3','Bobble Head','Crimson Skies: High Road to Revenge','crimson dragon','Crash Bandicoot: Wrath of Cortex',
                    'Cyber Troopers Virtual On Oratorio Tangram','DB: Raging Blast','DB: Raging Blast 2','DDR/DS Universe','Zuma\'s Revenge! Collection','This is Vegas','Vampires and Werewolves','Zapper','Max Payne',
                    'Grabbed by the Ghoulies','Metal Arms: Glitch in the System','Max Payne 2: The Fall of Max Payne','Fable','Guilty Gear X2 #Reload','Psychonauts','Raze\'s Hell','Jade Empire','Sid Meier\'s Pirates!',
                    'Ninja Gaiden Black','Indigo Prophecy','Gauntlet: Seven Sorrows','Halo Waypoint','Halo Wars 2 Avatar Store','Boxing Fight','Build A Buddy','Darts Vs Zombies','Gears of War 4 Store','Gears of War: Ultimate Edition Store',
                    'Project Natal','Prey 2','PlayOnline Viewer','Ninety-Nine Nights/JP','Obut Ptanque 2','Destiny: The Taken King - Digital Collector\'s Edition','Destiny: The Taken King - Legendary Edition'
                    )
  keywordsToRemove <- tolower(sort(c("bundle","pack",'(PC)')))
  keywordsToRemoveRegex = paste(keywordsToRemove, collapse = "|")
  keywordsToRemoveRegex =  gsub(pattern = " ", replacement = "*", x = keywordsToRemoveRegex,ignore.case = TRUE)
  gameNameMissed = tolower(data$gameName)
  notRemoved = unlist(lapply(gameNameMissed, (function (x) !is.na(str_extract(x,keywordsToRemoveRegex)))))
  # notRemoved = unlist(lapply(data$gameNameMissed, (function (x) !is.na(str_match(x,keywordsToRemoveRegex)))))
  for (i in tolower(gamesToRemove)) {
    # print(i)
    data = data[tolower(data$gameName) != i,]
  }
  # print(sort(data$gameName[notRemoved]))
  data = data[!notRemoved,]
  return(data)
}
generousNameMerger = function(dataX,dataY,mergeType="all",keep = "x") {
  dataX$gameNameModded = tolower(dataX$gameName)
  dataY$gameNameModded = tolower(dataY$gameName)
  removeWords = tolower(c('s',"[^[:alnum:] ]"," ",'&','and',"™","®",'of','DX','disney','for','edition','standard','special','game', 'the','Base Game','free to play','full game', 'year','hd','movie','TM','Cabela\'s','NA$',"s$","x$"))
  for (i in removeWords) {
    dataX$gameNameModded = gsub(i, "", dataX$gameNameModded, ignore.case = TRUE)
    dataY$gameNameModded = gsub(i, "", dataY$gameNameModded, ignore.case = TRUE)
  }
  
  dataX$gameNameModded = gsub("IV$", "4", dataX$gameNameModded, ignore.case = TRUE)
  dataY$gameNameModded = gsub("IV$", "4", dataY$gameNameModded, ignore.case = TRUE)
  dataX$gameNameModded = gsub("III$", "3", dataX$gameNameModded, ignore.case = TRUE)
  dataY$gameNameModded = gsub("III$", "3", dataY$gameNameModded, ignore.case = TRUE)
  dataX$gameNameModded = gsub("II$", "2", dataX$gameNameModded, ignore.case = TRUE)
  dataY$gameNameModded = gsub("II$", "2", dataY$gameNameModded, ignore.case = TRUE)
  dataX$gameNameModded = gsub("I$", "1", dataX$gameNameModded, ignore.case = TRUE)
  dataY$gameNameModded = gsub("I$", "1", dataY$gameNameModded, ignore.case = TRUE)
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
  # data$gameNameModded = NULL
  data = gameRemover(data)
  return (data)
}

rm(list = setdiff(ls(), lsf.str()))
setwd('/Volumes/SDExpansion/Data Files/bootcamp007_project/Project3-WebScraping/NickTalavera/CSV Processing')
setwd('/Volumes/SDExpansion/Data Files/Xbox Back Compat Data')
MajorNelsionBCList = namePrettier(fixMajorNelson(read.csv('Major_Nelson_Blog_BC_List.csv', stringsAsFactors = FALSE, header = TRUE)))
UserVoice = namePrettier(fixUserVoice(read.csv('UserVoice.csv', stringsAsFactors = FALSE, header = TRUE)))
WikipediaXB360Exclusive = namePrettier(fixWikipediaXB360KExclusive(read.csv('WikipediaXB360Exclusive.csv', stringsAsFactors = FALSE, header = TRUE)))
WikipediaXB360Kinect = namePrettier(fixWikipediaXB360Kinect(read.csv('WikipediaXB360Kinect.csv', stringsAsFactors = FALSE, header = TRUE)))
Xbox360_MS_Site = namePrettier(fixXbox360_MS_Site(as.data.frame(read.csv('Xbox360_MS_Site.csv', stringsAsFactors = TRUE, header = TRUE))))
XboxOne_MS_Site = namePrettier(fixMSXBone(read.csv('XboxOne_MS_Site.csv', stringsAsFactors = FALSE, header = TRUE)))
Remasters = namePrettier(fixRemasters(read.csv('RemastersXB.csv', stringsAsFactors = FALSE, header = TRUE)))
MetacriticXbox360 = namePrettier(fixMetacritic(namePrettier(read.csv('MetacriticXbox360.csv', stringsAsFactors = FALSE))))


dataUlt = generousNameMerger(WikipediaXB360Exclusive, WikipediaXB360Kinect)
dataUlt = generousNameMerger(dataUlt, MajorNelsionBCList)
dataUlt = generousNameMerger(dataUlt, UserVoice)
dataUlt = generousNameMerger(dataUlt, Xbox360_MS_Site, "all","x")
dataUlt = generousNameMerger(dataUlt, MetacriticXbox360, "all.x","x")
dataUlt = generousNameMerger(dataUlt, XboxOne_MS_Site, "all.x","x")
dataUlt = generousNameMerger(dataUlt, Remasters, "all.x","x")
# Remasters
# XboxOne_MS_Site

dataUlt[dataUlt == ""] = NA
dataUlt$isListedOnMSSite[is.na(dataUlt$isListedOnMSSite)] = FALSE
dataUlt$isMetacritic[is.na(dataUlt$isMetacritic)] = FALSE
dataUlt$isBCCompatible[is.na(dataUlt$isBCCompatible)] = FALSE
dataUlt$isOnUserVoice[is.na(dataUlt$isOnUserVoice)] = FALSE
dataUlt$isExclusive[is.na(dataUlt$isExclusive)] = FALSE
dataUlt$isKinectSupported[is.na(dataUlt$isKinectSupported)] = FALSE
dataUlt$isConsoleExclusive[is.na(dataUlt$isConsoleExclusive)] = FALSE
dataUlt$isKinectRequired[is.na(dataUlt$isKinectRequired)] = FALSE
dataUlt$isDiscOnly[is.na(dataUlt$isDiscOnly)] = FALSE
dataUlt$isInProgress[is.na(dataUlt$isInProgress)] = FALSE
dataUlt$isOnXboxOne[dataUlt$isRemastered == TRUE] = TRUE
dataUlt$isOnXboxOne[is.na(dataUlt$isOnXboxOne)] = FALSE
dataUlt$isRemastered = NULL
# dataUlt$kinectRequired[is.na(dataUlt$kinectRequired)] = FALSE
# dataUlt$in_progress[dataUlt$in_progress == ""] = FALSE

# dataUlt = select(dataUlt, gameName, votes, kinectSupport)
dataUlt = unique(dataUlt)
dataUlt = gameRemover(dataUlt)
dataUlt = moveMe(dataUlt, c("gameName","gameNameModded","isListedOnMSSite","isMetacritic","isBCCompatible","isOnUserVoice","isExclusive","isKinectSupported"), "first")
# dataUlt = dataUlt[is.na(dataUlt$votes) | !dataUlt$c,]
dataUltA = dataUlt[dataUlt$isListedOnMSSite == TRUE  & (dataUlt$isMetacritic == TRUE | dataUlt$isBCCompatible == TRUE | dataUlt$isOnUserVoice == TRUE | dataUlt$isKinectSupported == TRUE | dataUlt$isExclusive == TRUE),]
dataUltN = dataUlt[dataUlt$isListedOnMSSite == TRUE  & !(dataUlt$isMetacritic == TRUE | dataUlt$isBCCompatible == TRUE | dataUlt$isOnUserVoice == TRUE | dataUlt$isKinectSupported == TRUE | dataUlt$isExclusive == TRUE),]
dataUltG = dataUlt[dataUlt$isListedOnMSSite == FALSE  & (dataUlt$isMetacritic == TRUE | dataUlt$isBCCompatible == TRUE | dataUlt$isOnUserVoice == TRUE | dataUlt$isKinectSupported == TRUE | dataUlt$isExclusive == TRUE),]

dataUltKNN = kNN(dataUlt, k = sqrt(nrow(dataUlt)))
