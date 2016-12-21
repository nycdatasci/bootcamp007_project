# rm(list = ls()) #If I want my environment reset for testing.
#===============================================================================
#                                   LIBRARIES                                  #
#===============================================================================
library(jsonlite)
library(stringr)
library(dplyr)
library(ggplot2)
library(RColorBrewer)
library(scales)
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
  newNames = str_replace_all(newNames,"[[:punct:]]","")
  newNames = str_replace_all(newNames, "[^[:alnum:]]", " ")
  return(newNames)
}

#===============================================================================
#                               DIRECTORY SETUP                                #
#===============================================================================
if (dir.exists('/home/bc7_ntalavera/Dropbox/Data Science/Data Files/Steam/')) {
  dataLocale = '/home/bc7_ntalavera/Dropbox/Data Science/Data Files/Steam/' 
  figuresLocale = paste0(dataLocale,'/Figures/')
} else if (dir.exists('/Volumes/SDExpansion/Data Files/Steam/')) {
  dataLocale = '/Volumes/SDExpansion/Data Files/Steam/'
  figuresLocale = paste0(dataLocale,'/Figures/')
}
if (!dir.exists(figuresLocale)) {
  dir.create(figuresLocale)
}
#===============================================================================
#                                 READ IN DATA                                 #
#===============================================================================
steam = data.frame(read.csv(paste0(dataLocale, 'steamDatabaseAllCombined.csv')))
#===============================================================================
#                                GENERATE PLOTS                               #
#===============================================================================
# # #Overall Ownership and Game Age Compared to Percent Discounts
# labelsScores = c(paste(as.character(seq(1, 100, by=10)), "to", as.character(seq(10, 110, by=10))))
# metacriticScoresVSIncreaseSeventyPlus = steam
# title = paste("Sales Results of Games Of Varying Ownership Versus Percent Discounts")
# metacriticScoresVSIncreaseSeventyPlus$GameAge = floor(metacriticScoresVSIncreaseSeventyPlus$GameAge/365)
# metacriticScoresVSIncreaseSeventyPlus = metacriticScoresVSIncreaseSeventyPlus[!is.na(metacriticScoresVSIncreaseSeventyPlus$GameAge),]
# metacriticScoresVSIncreaseSeventyPlus$GameAge = cut_interval(metacriticScoresVSIncreaseSeventyPlus$GameAge, length = 3, rm.na = FALSE)
# factosokaf = 100000
# metacriticScoresVSIncreaseSeventyPlus$Owners_Before = round(metacriticScoresVSIncreaseSeventyPlus$Owners_Before/factosokaf)*factosokaf
# metacriticScoresVSIncreaseSeventyPlus = summarise(group_by(metacriticScoresVSIncreaseSeventyPlus, Owners_Before), meanSalePercent = mean(Sale_Percent), meanGameAge =  mean(GameAge), meanIncrease = mean(Increase), meanSales = mean(Sales))
# metacriticScoresVSIncreaseSeventyPlus = metacriticScoresVSIncreaseSeventyPlus[!is.na(metacriticScoresVSIncreaseSeventyPlus$meanSalePercent),]
# metacriticScoresVSIncreaseSeventyPlus$meanSalePercent = metacriticScoresVSIncreaseSeventyPlus$meanSalePercent/100
# metacriticScoresVSIncreaseSeventyPlus = metacriticScoresVSIncreaseSeventyPlus[metacriticScoresVSIncreaseSeventyPlus$meanIncrease < 300,]
# head(metacriticScoresVSIncreaseSeventyPlus)
# colourCount = length(unique(metacriticScoresVSIncreaseSeventyPlus$meanIncrease))
# getPalette = colorRampPalette(brewer.pal(8, "Accent"))
# platteNew = rev(getPalette(colourCount))
# g = ggplot(data = metacriticScoresVSIncreaseSeventyPlus, aes(x = Owners_Before, y = meanSalePercent)) + ggtitle(title)
# g + geom_point(aes(color=meanIncrease,size=meanSales)) + ylab('Mean Percent Discount') + scale_y_continuous(labels=percent) + xlab('Number of Owners Before the Sale') + scale_color_gradient(trans = "sqrt", low="blue", high="red") + expand_limits(x = 0, y = 0) +
#   labs(size="Mean Sales", color="Mean Increase (%)")
# ggsave(file=paste0(figuresLocale, removeSymbols(title), ".png"), limitsize = TRUE, width = 8, height = 4.5)



# #READY TO GO
#Histogram of Metacritic scores versus increase in sales if under vs over 70 #GOOD
labelsScores = c(paste(as.character(seq(1, 100, by=10)), "to", as.character(seq(10, 110, by=10))))
metacriticScoresVSIncreaseSeventyPlus = steam
title = 'Sales Increases Across Metacritic Score'
metacriticScoresVSIncreaseSeventyPlus = filter(metacriticScoresVSIncreaseSeventyPlus, metacriticScoresVSIncreaseSeventyPlus$Review_Score_Metacritic > -1000)
metacriticScoresVSIncreaseSeventyPlus = metacriticScoresVSIncreaseSeventyPlus[metacriticScoresVSIncreaseSeventyPlus$Increase < 2000,]
# metacriticScoresVSIncreaseSeventyPlus$Review_Score_Metacritic[as.numeric(metacriticScoresVSIncreaseSeventyPlus$Review_Score_Metacritic) >= reviewScore] = reviewScore
# metacriticScoresVSIncreaseSeventyPlus$Review_Score_Metacritic[as.numeric(metacriticScoresVSIncreaseSeventyPlus$Review_Score_Metacritic) < reviewScore] = 0
metacriticScoresVSIncreaseSeventyPlus$Review_Score_Metacritic = cut(metacriticScoresVSIncreaseSeventyPlus$Review_Score_Metacritic, breaks = seq(0, 100, by=10))
colourCount = length(unique(metacriticScoresVSIncreaseSeventyPlus$Review_Score_Metacritic))
getPalette = colorRampPalette(brewer.pal(11, "RdYlBu"))
platteNew = getPalette(colourCount)
g = ggplot(data = metacriticScoresVSIncreaseSeventyPlus, aes(x = Increase)) + ggtitle(title)
g + geom_histogram(aes(fill = Review_Score_Metacritic), position = "fill", binwidth = 10) + scale_y_continuous(labels=percent) + ylab('Percentage of Sales') + xlab('Increase of Owners')  + scale_fill_manual(values = platteNew, labels = labelsScores, guide = guide_legend(title = "Metacritic Score")) + guides(color = "colorbar")
ggsave(file=paste0(figuresLocale, removeSymbols(title), ".png"), limitsize = TRUE, width = 8, height = 4.5)
#END


# #Overall Ownership and Game Age Compared to Percent Discounts
title = 'Metacritic Scores against A Games\' Percent Discount'
metacriticScoresVSIncreaseSeventyPlusN = metacriticScoresVSIncreaseSeventyPlus
metacriticScoresVSIncreaseSeventyPlusN = metacriticScoresVSIncreaseSeventyPlusN[metacriticScoresVSIncreaseSeventyPlusN$Increase < 250,]
g = ggplot(data = metacriticScoresVSIncreaseSeventyPlusN, aes(x = Review_Score_Metacritic, y = Sale_Percent/100)) + ggtitle(title)
g + geom_point(aes(color=Increase)) + ylab('Percent Discount') + scale_y_continuous(labels=percent) + xlab('Metacritic Score') + scale_color_gradient(trans = "sqrt", low="blue", high="red") + expand_limits(x = 0, y = 0) +
  labs(size="Mean Sales", color="Increase (%)")
ggsave(file=paste0(figuresLocale, removeSymbols(title), ".png"), limitsize = TRUE, width = 8, height = 4.5)
metacriticScoresVSIncreaseSeventyPlusN = NULL


# READY TO GO
#Histogram of Metacritic scores versus increase in sales if under vs over 70 #GOOD
reviewScores = c(60, 70,85)
for (reviewScore in reviewScores) {
labelsScores = c(paste(c("Below","Above"),reviewScore))
metacriticScoresVSIncreaseSeventyPlus = steam
title = paste('Sales Increases for Games Above and Below a', reviewScore, "Metascritic Score")
metacriticScoresVSIncreaseSeventyPlus = filter(metacriticScoresVSIncreaseSeventyPlus, metacriticScoresVSIncreaseSeventyPlus$Review_Score_Metacritic > -1000)
metacriticScoresVSIncreaseSeventyPlus = metacriticScoresVSIncreaseSeventyPlus[metacriticScoresVSIncreaseSeventyPlus$Increase < 2000,]
metacriticScoresVSIncreaseSeventyPlus$Review_Score_Metacritic[as.numeric(metacriticScoresVSIncreaseSeventyPlus$Review_Score_Metacritic) >= reviewScore] = reviewScore
metacriticScoresVSIncreaseSeventyPlus$Review_Score_Metacritic[as.numeric(metacriticScoresVSIncreaseSeventyPlus$Review_Score_Metacritic) < reviewScore] = 0
metacriticScoresVSIncreaseSeventyPlus$Review_Score_Metacritic = cut_interval(metacriticScoresVSIncreaseSeventyPlus$Review_Score_Metacritic, n = 2, rm.na = TRUE)
colourCount = length(unique(metacriticScoresVSIncreaseSeventyPlus$Review_Score_Metacritic))
getPalette = colorRampPalette(brewer.pal(8, "Accent"))
platteNew = rev(getPalette(colourCount))
g = ggplot(data = metacriticScoresVSIncreaseSeventyPlus, aes(x = Increase, fill = Review_Score_Metacritic)) + ggtitle(title)
g + geom_histogram(position = "fill", binwidth = 30) + scale_y_continuous(labels=percent) + ylab('Percentage of Sales') + xlab('Increase of Owners') + guides(color = "colorbar") + scale_fill_manual(values = platteNew, labels = labelsScores, guide = guide_legend(title = "Metacritic Score")) +
  guides(fill = guide_legend(reverse = TRUE))
ggsave(file=paste0(figuresLocale, removeSymbols(title), ".png"), limitsize = TRUE, width = 8, height = 4.5)
}
#END

# #Over 85 Scatter
# reviewScore = 85
# labelsScores = c(paste(c("Below","Above"),reviewScore))
# metacriticScoresVSIncreaseSeventyPlus = steam
# title = paste("Sales and Percent Increase Compared to Overall Previous Ownership for Games Rated >85")
# metacriticScoresVSIncreaseSeventyPlus = filter(metacriticScoresVSIncreaseSeventyPlus, Review_Score_Metacritic >= 85)
# metacriticScoresVSIncreaseSeventyPlus = metacriticScoresVSIncreaseSeventyPlus[metacriticScoresVSIncreaseSeventyPlus$Increase < 70,]
# metacriticScoresVSIncreaseSeventyPlus$Sales = cut_interval(metacriticScoresVSIncreaseSeventyPlus$Sales, n=10)
# colourCount = length(metacriticScoresVSIncreaseSeventyPlus$Increase)
# getPalette = colorRampPalette(brewer.pal(8, "Accent"))
# platteNew = rev(getPalette(colourCount))
# g = ggplot(data = metacriticScoresVSIncreaseSeventyPlus, aes(x = metacriticScoresVSIncreaseSeventyPlus$Owners_Before, y = metacriticScoresVSIncreaseSeventyPlus$Increase)) + ggtitle(title)
# g + geom_point(aes(color = Sales)) + scale_y_continuous(labels=percent) + scale_x_log10() + ylab('Increase of Owners') + xlab('Number of Owners Before') + scale_fill_manual(values = platteNew, labels = labelsScores, guide = guide_legend(title = "Metacritic Score"))
# ggsave(file=paste0(figuresLocale, removeSymbols(title), ".png"), limitsize = TRUE, width = 8, height = 4.5)

#READY TO GO
#Steam User Reviews' Impact on the Increase of Sales'
title = 'Steam User Reviews\' Impact on the Increase of Sales'
steamScoresVSIncreaseThumbs = steam
steamScoresVSIncreaseThumbs = filter(steamScoresVSIncreaseThumbs, steamScoresVSIncreaseThumbs$Review_Score_Steam_Users > -1000)
steamScoresVSIncreaseThumbs$Review_Score_Steam_Users = cut(steamScoresVSIncreaseThumbs$Review_Score_Steam_Users, breaks = seq(0, 100, by=10))
steamScoresVSIncreaseThumbs = steamScoresVSIncreaseThumbs[is.na(steamScoresVSIncreaseThumbs$Review_Score_Steam_Users) == FALSE,]
steamScoresVSIncreaseThumbs = steamScoresVSIncreaseThumbs[is.na(steamScoresVSIncreaseThumbs$Increase) == FALSE,]
steamScoresVSIncreaseThumbs = steamScoresVSIncreaseThumbs[steamScoresVSIncreaseThumbs$Increase < 750,]
colourCount = length(unique(steamScoresVSIncreaseThumbs$Review_Score_Steam_Users))
getPalette = colorRampPalette(brewer.pal(9, "PiYG"))
platteNew = rev(getPalette(colourCount))
labelsYears = c(paste(as.character(seq(1, 100, by=10)), "to", as.character(seq(10, 110, by=10))))
g = ggplot(data = steamScoresVSIncreaseThumbs, aes(x = Increase)) + ggtitle(title)
g + geom_histogram(aes(fill = Review_Score_Steam_Users), position = "fill", binwidth = 90) + guides(color = "colorbar") + scale_fill_manual(values =platteNew, guide = guide_legend(title = "Steam User Percent Positive Reviews"), labels = labelsYears) + xlab('Increase of Owners')  + scale_y_continuous(labels=percent) + ylab('Percentage of Sales')
ggsave(file=paste0(figuresLocale, removeSymbols(title), ".png"), limitsize = TRUE, width = 8, height = 4.5)
#END

# #READY TO GO
# Game's age affecting the sale? If over ten, rounded up
gameAge = steam
# gameAge$GameAge[as.numeric(gameAge$GameAge) >= 9] = 10
gameAge = gameAge[gameAge$Increase < 200,]
gameAge = gameAge[!is.na(gameAge$GameAge) & !is.na(gameAge$Increase),]
# gameAge = filter(gameAge, gameAge$GameAge > -1000)
gameAge$GameAge = floor(gameAge$GameAge/365)
gameAge$GameAge = cut_interval(gameAge$GameAge, length = 1, rm.na = FALSE)
labelsYears = c(c('<1 year'), paste(as.character(1:100), "to", as.character(2:101), "years"))
title = 'The Age of a Game Compared to the Increase of Owners'
g = ggplot(data = gameAge, aes(x = Increase, fill = GameAge)) + ggtitle(title)
g + geom_histogram(aes(y=..density..), position = "fill", binwidth = 5) + scale_y_continuous(labels=percent, expand = c(0, 0)) + ylab('Percentage of Sales') + xlab('Increase of Owners') +
  scale_fill_discrete(h =c(24,350), guide = guide_legend(title = "Game's Age (years)"), labels = labelsYears) + xlim(0, NA)
ggsave(file=paste0(figuresLocale, removeSymbols(title), ".png"), limitsize = TRUE, width = 8, height = 4.5)
# # #END

#Scatter Metacritic vs How long to beat
title = 'Metacritic Scores Compared to Campaign Length'
labelsGameType = c('Indie Games','Action Games', 'Adventure Games',"Role Playing Games")
MetacriticVSCampaign = select(steam, CampaignLength, Review_Score_Metacritic, Increase)
maxLength = 75
metacriticReview = 70
MetacriticVSCampaign = MetacriticVSCampaign[!is.na(MetacriticVSCampaign$CampaignLength) & !is.na(MetacriticVSCampaign$Review_Score_Metacritic),]
MetacriticVSCampaign = MetacriticVSCampaign[MetacriticVSCampaign$CampaignLength < maxLength,]
MetacriticVSCampaign$hoursRange[between(MetacriticVSCampaign$CampaignLength,0,6)] = 6
MetacriticVSCampaign$hoursRange[between(MetacriticVSCampaign$CampaignLength,6,12)] = 12
MetacriticVSCampaign$hoursRange[between(MetacriticVSCampaign$CampaignLength,12,17)] = 17
MetacriticVSCampaign$hoursRange[MetacriticVSCampaign$CampaignLength >= 17] = 40
colourCount = length(unique(MetacriticVSCampaign$hoursRange))
getPalette = colorRampPalette(brewer.pal(11, "Spectral"))
platteNew = getPalette(colourCount)
g = ggplot(MetacriticVSCampaign, aes(x = CampaignLength , y = Review_Score_Metacritic)) + ggtitle(title)
g + geom_point(aes(color=factor(hoursRange))) + geom_hline(yintercept = metacriticReview, color="red") + ylab('Metacritic Score') + xlab("Game Campaign Length (hours)") + scale_color_manual(values = platteNew, name ="Typical Game Type",
                                                                                                                                                                                                                                     labels=labelsGameType) + geom_smooth(method = "lm", color = "black") + geom_smooth(aes(group= hoursRange)) +
  scale_x_continuous(breaks = pretty(MetacriticVSCampaign$CampaignLength, n = 20))
ggsave(file=paste0(figuresLocale, removeSymbols(title), ".png"), limitsize = TRUE, width = 8, height = 4.5)

# Campaign Length Compared to the Increase of Owners
title = 'Campaign Length Compared to the Increase of Owners'
difference = 5
maxHours = 40
labelsScores = c(paste(seq(0, maxHours, by=difference), "to", seq(difference, maxHours+difference, by=difference), "hours"))
labelsScores = replace(labelsScores, length(labelsScores), paste0(">",40," hours"))
MetacriticVSCampaign$Rounded = round(MetacriticVSCampaign$CampaignLength/difference)*difference
MetacriticVSCampaign$Rounded[MetacriticVSCampaign$Rounded > maxHours] = maxHours
colourCount = length(unique(MetacriticVSCampaign$Rounded))
getPalette = (colorRampPalette(brewer.pal(9, "PiYG")))
platteNew = rev(getPalette(colourCount))
g = ggplot(data = MetacriticVSCampaign, aes(x = Increase)) + ggtitle(title)
g + geom_histogram(aes(fill = factor(Rounded)), position = "fill", binwidth = 20) + scale_y_continuous(labels=percent) + ylab('Percentage of Sales') + xlab('Increase of Owners') + guides(color = "colorbar") + scale_fill_manual(values = platteNew, labels = labelsScores, guide = guide_legend(title = "Campaign Length"))
ggsave(file=paste0(figuresLocale, removeSymbols(title), ".png"), limitsize = TRUE, width = 8, height = 4.5)


# Game Type Approximated by Campaign Length Compared to the Increase of Owners
labelsGameType = c('Indie Games','Action Games', 'Adventure Games',"Role Playing Games")
title = 'Game Type Approximated by Campaign Length Compared to the Increase of Owners'
colourCount = length(unique(MetacriticVSCampaign$hoursRange))
getPalette = colorRampPalette(brewer.pal(11, "Spectral"))
platteNew = getPalette(colourCount)
g = ggplot(data = MetacriticVSCampaign, aes(x = Increase)) + ggtitle(title)
g + geom_histogram(aes(fill = factor(hoursRange)), position = "fill", binwidth = 20) + scale_y_continuous(labels=percent) + ylab('Percentage of Sales') + xlab('Increase of Owners') + guides(color = "colorbar") + scale_fill_manual(values = platteNew, labels = labelsGameType, guide = guide_legend(title = "Typical Game Type"))
ggsave(file=paste0(figuresLocale, removeSymbols(title), ".png"), limitsize = TRUE, width = 8, height = 4.5)


# Release date relation to the start of the Summer sale?
title = 'Release Date Relation to the Start of the Summer Sale For Games Released in the Past Year?'
gameAge = steam
gameAge$GameAgeMonths = floor(gameAge$GameAge/31)
# gameAge$GameAge[as.numeric(gameAge$GameAge) >= 9] = 10
gameAge = gameAge[gameAge$GameAge <= 365,]
gameAge = gameAge[!is.na(gameAge$GameAge) & !is.na(gameAge$Increase),]
# gameAge = filter(gameAge, gameAge$GameAge > -1000)
gameAge$GameAge = cut_interval(gameAge$GameAge, length = 1, rm.na = FALSE)
labelsYears = c(c('<1 year'), paste(as.character(1:100), "to", as.character(2:101), "years"))
g = ggplot(data = gameAge, aes(x = GameAgeMonths)) + ggtitle(title)
g + geom_density() + scale_y_continuous(labels=percent) + ylab('Percentage of Sales') + xlab('Age of Game (months)')
ggsave(file=paste0(figuresLocale, removeSymbols(title), ".png"), limitsize = TRUE, width = 8, height = 4.5)