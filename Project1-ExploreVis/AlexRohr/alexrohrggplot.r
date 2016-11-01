catan = read.csv("catanstats.csv")
catan1 = mutate(catan, NTG = (tradeGain-tradeLoss))
catan2 = mutate(catan1, NRG = (robberCardsGain-robberCardsLoss))
catan3 = mutate(catan2, openingprod = (settlement2prod+settlement1prod))

with(catan3, cor(totalAvailable, points))^2
data(catan3)
g = ggplot(data = catan3, aes(x = totalAvailable, y = points))
g + geom_point(shape=15, color="red") + geom_smooth(method = lm)

with(catan3, cor(NRG, points))^2
data(catan3)
g = ggplot(data = catan3, aes(x = NRG, y = points))
g + geom_point(shape=15, color="green") + geom_smooth(method = lm)

with(catan3, cor(NTG, points))^2

with(catan3, cor(openingprod, points))^2
data(catan3)
g = ggplot(data = catan3, aes(x = openingprod, y = points))
g + geom_point(shape=15, color="red") + geom_smooth(method = lm)

with(catan3, cor(tribute, points))^2
data(catan3)
g = ggplot(data = catan3, aes(x = tribute, y = points))
g + geom_point(shape=15, color="blue") + geom_smooth(method = lm)

with(catan3, cor(settlement1prod, points))^2
data(catan3)
g = ggplot(data = catan3, aes(x = settlement1prod, y = points))
g + geom_point(shape=15, color="green") + geom_smooth(method = lm)

with(catan3, cor(settlement2prod, points))^2
data(catan3)
g = ggplot(data = catan3, aes(x = settlement2prod, y = points))
g + geom_point(shape=15, color="red") + geom_smooth(method = lm)

with(catan3, cor(production, points))^2
data(catan3)
g = ggplot(data = catan3, aes(x = production, y = points))
g + geom_point(shape=15, color="blue") + geom_smooth(method = lm)

with(catan3, cor(totalGain, points))^2
data(catan3)
g = ggplot(data = catan3, aes(x = totalGain, y = points))
g + geom_point(shape=15, color="green") + geom_smooth(method = lm)

with(catan3, cor(totalLoss, points))^2
data(catan3)
g = ggplot(data = catan3, aes(x = totalLoss, y = points))
g + geom_point(shape=15, color="blue") + geom_smooth(method = lm)


catan3 %>% group_by(gameNum) %>% summarize(mean(points))
catan4 = catan3 %>% group_by(gameNum) %>% summarize(mean(points))

colnames(catan4)[2] <- "mean_points"

g = ggplot(data = catan4, aes(x = gameNum, y = mean_points))
g + geom_bar(stat ="identity")

mean(catan3$points)



