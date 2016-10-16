library(jsonlite)
library(stringr)
library(dplyr)
library(ggplot2)
# library(corrplot)
library(RColorBrewer)
library(scales)
rm(list = setdiff(ls(), lsf.str()))

# Owners_before
# Owners_after
# Owners_As_Of_Today
# Players_As_Of_Today
# Sales
# Increase (%)
# Price_before_sale
# Review_Score_Metacritic
# Review_Score_Steam_Users
# Sale_Percent
# Sale Price
# GameNewness
removeSymbols = function(namesArray) {
  newNames = namesArray
  newNames = str_replace_all(newNames,"[[:punct:]]","")
  newNames = str_replace_all(newNames, "[^[:alnum:]]", " ")
  newNames = trim(newNames)
  return(newNames)
}
setwd('/Users/nicktalavera/Coding/bootcamp007_project/Project1-ExploreVis/NickTalavera/Steam')
steam = read.csv('steamDatabaseAllCombined.csv')
head(steam)

# today = as.Date(Sys.time(), "%Y %m %d")
steamSummerSaleFirstDay = as.Date('20160704', "%Y%m%d")
steamSummerSaleLastDay = as.Date('20160628', "%Y%m%d")
# steam$GameNewness = steam$Release_Date - steamSummerSaleFirstDay
# # Sale Percent vs Net Gross
# g = ggplot(data = steam, aes(x = Sale_Percent, y=Increase)) + ggtitle('Sale Percent vs Net Gross')
# g + geom_bar(aes(fill = Sale_Percent), stat = 'identity', position = 'dodge')


#Progress of numbers of ownership over time?
#line graph

# Compare prices before and after sales
class(steam$Price_Before_Sale)
g = ggplot(data = arrange(steam,Price_Before_Sale), aes(x = Price_Before_Sale, y=Price_Before_Sale)) + ggtitle('prices before and after sales')
g + geom_bar(aes(fill = Sale_Percent), stat = 'identity', position = 'dodge')

# Compare owners before and after sales


# Increase vs Review_Score_Metacritic
# g = ggplot(data = arrange(steam,Increase), aes(x = Increase, y = Review_Score_Steam_Users)) + ggtitle('prices before and after sales')
# g + geom_bar(aes(fill = Review_Score_Steam_Users), stat = 'identity', position = 'dodge')
# Increase vs Review_Score_Steam_Users
# # g = ggplot(data = steam, aes(x = Review_Score_Metacritic)) + ggtitle('prices before and after sales')
# # g + geom_histogram(bins = 15)
# # # Increase vs Review_Score_IGN
# g = ggplot(data = steam, aes(x = Review_Score_IGN)) + ggtitle('Review_Score_IGN_Users')
# g + geom_freqpoly(binwidth = 0.1)
# # g = ggplot(data = arrange(steam,Increase), aes(x = Increase, y = Review_Score_Steam_Users)) + ggtitle('prices before and after sales')
# # g + geom_bar(aes(fill = Review_Score_Steam_Users), stat = 'identity', position = 'dodge')
# # # Increase vs Review_Score_Metacritic
# g = ggplot(data = steam, aes(x = Review_Score_Metacritic)) + ggtitle('Review_Score_Metacritic') + xlim(0,100)
# g + geom_histogram(aes(fill = Price_Before_Sale), binwidth = 10, position = "fill")

# Review scores count
# g = ggplot(data = steam[!is.na(steam$Review_Score_Metacritic),], aes(x = Sales)) + ggtitle('Review scores count') + xlim(5000,250000)
# g + geom_histogram(binwidth = 5000)
# groupedByIncrease = summarise(group_by(steam, Increase), meanScore = round(mean(Review_Score_Metacritic)/5)*5)
# groupedByIncrease = groupedByIncrease[!is.na(groupedByIncrease$meanScore),]
# g = ggplot(data = groupedByIncrease, aes(x = Increase)) + ggtitle('Increase') + xlim(0,150)
# g + geom_density(aes(color = alpha("black", 1/3)))


# #IGN scores versus increase in sales
# ignScoresVSIncrease = steam
# ignScoresVSIncrease = ignScoresVSIncrease[!is.na(ignScoresVSIncrease$Review_Score_IGN) & !is.na(ignScoresVSIncrease$Increase),]
# ignScoresVSIncrease = filter(ignScoresVSIncrease, ignScoresVSIncrease$Review_Score_IGN >= 30)
# ignScoresVSIncrease$Review_Score_IGN = cut_interval(ignScoresVSIncrease$Review_Score_IGN, length = 10, rm.na = FALSE)
# ignScoresVSIncrease = select(ignScoresVSIncrease, Review_Score_IGN, Increase)
# g = ggplot(data = ignScoresVSIncrease, aes(x = Increase)) + ggtitle('Review_Score_IGN')
# g + geom_density(aes(color = Review_Score_IGN)) + xlim(0,75)
# 
# 
# #Histogram of IGN scores versus increase in sales #GOOD SHIT
# title = 'Comparing the Sales of Games That Were Not Reviewed by IGN vs Games with \"Bad\" (<70) Metacritic Scores'
# # labelsScores = c(paste(as.character(seq(1, 100, by=10)), "to", as.character(seq(10, 110, by=10))))
# # ignScoresVSIncrease = steam
# # ignScoresVSIncrease = ignScoresVSIncrease[is.na(ignScoresVSIncrease$Review_Score_IGN),]
# # ignScoresVSIncrease = select(ignScoresVSIncrease, Name, Review_Score_IGN, Increase, Review_Score_Metacritic)
# # # ignScoresVSIncreaseGrouped = group_by(ignScoresVSIncrease, )
# # g = ggplot(data = ignScoresVSIncrease, aes(x = Increase)) + ggtitle(title)
# # g + geom_histogram(aes(fill = Review_Score_IGN), position = "fill", binwidth = 5) + guides(color = "colorbar") + scale_y_continuous(labels=percent) + ylab('Percentage of Sales') + xlab('Increase of Owners') + guides(color = "colorbar") + scale_fill_brewer(palette = "Blues", labels = labelsScores, guide = guide_legend(title = "Metacritic Score"))
# 
# 
# #READY TO GO
#Histogram of Metacritic scores versus increase in sales if under vs over 70 #GOOD SHIT
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
ggsave(file=paste0(removeSymbols(title), ".eps"))
#END

# READY TO GO
#Histogram of Metacritic scores versus increase in sales if under vs over 70 #GOOD SHIT
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
g = ggplot(data = metacriticScoresVSIncreaseSeventyPlus, aes(x = Increase)) + ggtitle(title)
g + geom_histogram(aes(fill = Review_Score_Metacritic), position = "fill", binwidth = 10) + scale_y_continuous(labels=percent) + ylab('Percentage of Sales') + xlab('Increase of Owners') + guides(color = "colorbar") + scale_fill_manual(values = platteNew, labels = labelsScores, guide = guide_legend(title = "Metacritic Score")) +
  guides(fill = guide_legend(reverse = TRUE))
ggsave(file=paste0(removeSymbols(title), ".eps"))
}
#END

# FIGURE OUT BARS
#Histogram of Metacritic scores versus increase in sales if under vs over 70 #GOOD SHIT
# steamScoresVSIncreaseThumbs = steam
# steamScoresVSIncreaseThumbs = filter(steamScoresVSIncreaseThumbs, steamScoresVSIncreaseThumbs$Review_Score_Steam_Users > -1000)
# steamScoresVSIncreaseThumbs$Review_Score_Steam_Users[as.numeric(steamScoresVSIncreaseThumbs$Review_Score_Steam_Users) >= reviewScore] = reviewScore
# steamScoresVSIncreaseThumbs$Review_Score_Steam_Users[as.numeric(steamScoresVSIncreaseThumbs$Review_Score_Steam_Users) < reviewScore] = 0
# # steamScoresVSIncreaseThumbs$Review_Score_Steam_Users = cut_interval(steamScoresVSIncreaseThumbs$Review_Score_Steam_Users, n = 2, rm.na = TRUE)
# steamScoresVSIncreaseThumbs = steamScoresVSIncreaseThumbs[steamScoresVSIncreaseThumbs$Increase < 750,]
# # labelsYears = c(paste(as.character(seq(1, 100, by=10)), "to", as.character(seq(10, 110, by=10))))
# title = paste('Sales Increases Comparing an Ideal Review Score of', reviewScore)
# g = ggplot(data = steamScoresVSIncreaseThumbs, aes(factor(Review_Score_Steam_Users))) + ggtitle(title)
# g + geom_bar() + guides(color = "colorbar") + scale_fill_brewer(palette ="Blues",direction = 1, labels = c(paste(c('Less than',"Greater than"), reviewScore)), guide = guide_legend(title = "Metacritic Score"))
# ggsave(file=paste0(removeSymbols(title), ".eps"))


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
g + geom_histogram(aes(fill = Review_Score_Steam_Users), position = "fill", binwidth = 90) + guides(color = "colorbar") + scale_fill_manual(values =platteNew, guide = guide_legend(title = "Steam User Percent Positive Reviews"), labels = labelsYears) + xlab('Increase of Owners')  + scale_y_continuous(labels=percent) + ylab('Percentage of Increase')
ggsave(file=paste0(removeSymbols(title), ".eps"))
#END
# #
# # #READY TO GO
# # Game's age affecting the sale? If over ten, rounded up
# gameAge = steam
# gameAge$GameAge = floor(gameAge$GameAge/365)
# # gameAge$GameAge[as.numeric(gameAge$GameAge) >= 9] = 10
# gameAge = gameAge[gameAge$Increase < 200,]
# gameAge = gameAge[!is.na(gameAge$GameAge) & !is.na(gameAge$Increase),]
# # gameAge = filter(gameAge, gameAge$GameAge > -1000)
# gameAge$GameAge = cut_interval(gameAge$GameAge, length = 1, rm.na = FALSE)
# labelsYears = c(c('<1 year'), paste(as.character(1:100), "to", as.character(2:101), "years"))
# title = 'The Age of a Game Compared to the Increase of Owners'
# g = ggplot(data = gameAge, aes(x = Increase)) + ggtitle(title)
# g + geom_histogram(aes(fill = GameAge), position = "fill", binwidth = 10) + scale_y_continuous(labels=percent) + ylab('Percentage of Sales') + xlab('Increase of Owners') +
#   scale_fill_discrete( h =c(165,350), guide = guide_legend(title = "Game's Age (years)"), labels = labelsYears)
# ggsave(file=paste0(removeSymbols(title), ".eps"))
ggsave(file=paste0(removeSymbols(title), ".eps"))
# # #END
#
# # How many games go unplayed?
# unplayed = steam
# unplayed$Unplayed = unplayed$Players_Forever_As_Of_Today <= unplayed$Owners_As_Of_Today
# # unplayed$Unplayed = cut_interval(unplayed$Unplayed, length = 0.1, rm.na = FALSE)
# sumUnplayed = c(sum(unplayed$Players_Forever_As_Of_Today), sum(unplayed$Owners_As_Of_Today ))
# g <- ggplot(data = sumUnplayed, aes(x = sumUnplayed))
# g + geom_bar()
#
#Scatter Metacritic vs How long to beat
title = 'Metacritic Scores Compared to Campaign Length'
labelsGameType = c('Indie Games','Action Games', 'Adventure Games',"Role Playing Games")
MetacriticVSCampaign = select(steam, main_story_length, Review_Score_Metacritic, Increase)
maxLength = 75
metacriticReview = 70
MetacriticVSCampaign = MetacriticVSCampaign[!is.na(MetacriticVSCampaign$main_story_length) & !is.na(MetacriticVSCampaign$Review_Score_Metacritic),]
MetacriticVSCampaign = MetacriticVSCampaign[MetacriticVSCampaign$main_story_length < maxLength,]
MetacriticVSCampaign$hoursRange[between(MetacriticVSCampaign$main_story_length,0,6)] = 6
MetacriticVSCampaign$hoursRange[between(MetacriticVSCampaign$main_story_length,6,12)] = 12
MetacriticVSCampaign$hoursRange[between(MetacriticVSCampaign$main_story_length,12,17)] = 17
MetacriticVSCampaign$hoursRange[MetacriticVSCampaign$main_story_length >= 17] = 40
colourCount = length(unique(MetacriticVSCampaign$hoursRange))
getPalette = colorRampPalette(brewer.pal(11, "Spectral"))
platteNew = getPalette(colourCount)
g = ggplot(MetacriticVSCampaign, aes(x = main_story_length , y = Review_Score_Metacritic)) + ggtitle(title)
g + geom_point(aes(color=factor(hoursRange))) + geom_hline(yintercept = metacriticReview, color="red") + ylab('Metacritic Score') + xlab("Game Campaign Length (hours)") + scale_color_manual(values = platteNew, name ="Typical Game Type",
                                                                                                                                                                                                                                     labels=labelsGameType) + geom_smooth(method = "lm", color = "black") + geom_smooth(aes(group= hoursRange)) +
  scale_x_continuous(breaks = pretty(MetacriticVSCampaign$main_story_length, n = 20))
ggsave(file=paste0(removeSymbols(title), ".eps"))

# Campaign Length Compared to the Increase of Owners
difference = 5
maxHours = 40
labelsScores = c(paste(seq(0, maxHours, by=difference), "to", seq(difference, maxHours+difference, by=difference), "hours"))
labelsScores = replace(labelsScores, length(labelsScores), paste0(">",40," hours"))
title = 'Campaign Length Compared to the Increase of Owners'
MetacriticVSCampaign$Rounded = round(MetacriticVSCampaign$main_story_length/difference)*difference
MetacriticVSCampaign$Rounded[MetacriticVSCampaign$Rounded > maxHours] = maxHours
colourCount = length(unique(MetacriticVSCampaign$Rounded))
getPalette = colorRampPalette(brewer.pal(9, "PuBuGn"))
platteNew = getPalette(colourCount)
g = ggplot(data = MetacriticVSCampaign, aes(x = Increase)) + ggtitle(title)
g + geom_histogram(aes(fill = factor(Rounded)), position = "fill", binwidth = 20) + scale_y_continuous(labels=percent) + ylab('Percentage of Sales') + xlab('Increase of Owners') + guides(color = "colorbar") + scale_fill_manual(values = platteNew, labels = labelsScores, guide = guide_legend(title = "Campaign Length"))
ggsave(file=paste0(removeSymbols(title), ".eps"))


# Game Type Approximated by Campaign Length Compared to the Increase of Owners
labelsGameType = c('Indie Games','Action Games', 'Adventure Games',"Role Playing Games")
title = 'Game Type Approximated by Campaign Length Compared to the Increase of Owners'
colourCount = length(unique(MetacriticVSCampaign$hoursRange))
getPalette = colorRampPalette(brewer.pal(11, "Spectral"))
platteNew = getPalette(colourCount)
g = ggplot(data = MetacriticVSCampaign, aes(x = Increase)) + ggtitle(title)
g + geom_histogram(aes(fill = factor(hoursRange)), position = "fill", binwidth = 20) + scale_y_continuous(labels=percent) + ylab('Percentage of Sales') + xlab('Increase of Owners') + guides(color = "colorbar") + scale_fill_manual(values = platteNew, labels = labelsGameType, guide = guide_legend(title = "Typical Game Type"))
ggsave(file=paste0(removeSymbols(title), ".eps"))


# Release date relation to the start of the Summer sale?
title = 'Release Date Relation to the Start of the Summer Sale For Games Released in the Past Year?'
gameAge = steam
gameAge$GameAgeWeeks = floor(gameAge$GameAge/7)
# gameAge$GameAge[as.numeric(gameAge$GameAge) >= 9] = 10
gameAge = gameAge[gameAge$GameAge <= 365,]
gameAge = gameAge[!is.na(gameAge$GameAge) & !is.na(gameAge$Increase),]
# gameAge = filter(gameAge, gameAge$GameAge > -1000)
gameAge$GameAge = cut_interval(gameAge$GameAge, length = 1, rm.na = FALSE)
labelsYears = c(c('<1 year'), paste(as.character(1:100), "to", as.character(2:101), "years"))
g = ggplot(data = gameAge, aes(x = GameAgeWeeks)) + ggtitle(title)
g + geom_density() + scale_y_continuous(labels=percent) + ylab('Percentage of Sales') + xlab('Age of Game (weeks)')
ggsave(file=paste0(removeSymbols(title), ".eps"))


# + scale_y_continuous(labels=percent) + ylab('Percentage of Sales') + xlab('Increase of Owners') + guides(color = "colorbar") + scale_fill_brewer(palette = "Blues", labels = labelsScores, guide = guide_legend(title = "Typical Game Type"))
# How many games go unbeaten?
# Overlay the reviews at the intervals?
# Do higher percents yield more money?
# Should AAA games discount their products?

# Owners_before
# Owners_after
# Sales
# Owners_As_Of_Today
# Players_Forever_As_Of_Today
# Increase
# Price_Before_Sale
# Price_After_Sale
# Review_Score_Metacritic
# Review_Score_Metacritic_User
# Review_Score_Steam_Users
# Review_Score_IGN
# Sale_Percent


# average number of sales per period
# game age