source('cleaning.R')

#########################################################################################

# rating of cpu and gpu
cpurating <- cpu %>% select(rating, brand) %>% group_by(rating, brand) %>%
    summarize(count = n()) %>% as.data.frame()
cpurating$rating <- factor(cpurating$rating)
gpurating <- gpu %>% filter(!(chipmake == 'ati')) %>%
    select(rating, chipmake) %>% group_by(rating, chipmake) %>%
    summarize(count = n()) %>% as.data.frame()
gpurating$rating <- factor(gpurating$rating)

g1 <- ggplot(cpurating, aes(x = rating, y = count))
g1 <- g1 + geom_bar(aes(fill = brand), stat = "identity", position = "dodge")
g1 <- g1 + theme_gdocs()
g1 <- g1 + scale_color_manual("Brand", values = c("#FF3300", "#0066FF"))
g1 <- g1 + xlab("Rating") + ylab("Count") + ggtitle("CPU Rating")

g2 <- ggplot(gpurating, aes(x = rating, y = count))
g2 <- g2 + geom_bar(aes(fill = chipmake), stat = "identity", position = "dodge")
g2 <- g2 + theme_gdocs()
g2 <- g2 + scale_color_manual("Brand", values = c("#FF3300", "#0066FF"))
g2 <- g2 + xlab("Rating") + ylab("Count") + ggtitle("GPU Rating")

multiplot(g1, g2, cols = 2)

#########################################################################################

## 1. cpu, series in top100 products
data1 <- cpu %>% top_n(-100, rank) %>% select(brand, series) %>%
    group_by(brand, series) %>% summarise(count = n()) %>% as.data.frame()
data1$series <- factor(data1$series, 
                       levels = data1$series[sort.int(data1$count, decreasing = TRUE, index.return = TRUE)[[2]]])

g1 <- ggplot(data1, aes(x = series, y = count))
g1 <- g1 + geom_bar(aes(fill = brand), stat = "identity")
g1 <- g1 + xlab("Series") + ylab("Count") + ggtitle("Top100 best selling CPUs")
g1 <- g1 + theme_gdocs() + theme(axis.text.x = element_text(angle = 30, hjust = 1))
g1 <- g1 + scale_color_manual("Brand", values = c("#FF3300", "#0066FF"))


## 1.1 cpu, price of different series in top100 products
data1.1 <- cpu %>% top_n(-100, rank) %>% select(series, brand, price) %>%
    group_by(brand, series) %>% summarise(meanprice = mean(price)) %>% as.data.frame()
data1.1$series <- factor(data1$series, 
                         levels = data1$series[sort.int(data1.1$meanprice, decreasing = TRUE, index.return = TRUE)[[2]]])

g2 <- ggplot(data1.1, aes(x = series, y = meanprice))
g2 <- g2 + geom_bar(aes(fill = brand), stat = "identity")
g2 <- g2 + xlab("Series") + ylab("Average Price ($)") + ggtitle("Top100 best selling CPUs")
g2 <- g2 + theme_gdocs() + theme(axis.text.x = element_text(angle = 30, hjust = 1))
g2 <- g2 + scale_color_manual("Brand", values = c("#FF3300", "#0066FF"))

multiplot(g1, g2, cols = 1)

## 2. cpu, price vs. rank
data2 <- cpu %>% filter(rank <= 50) %>% 
    arrange(rank) %>% select(rank, name, brand, price)

g <- ggplot(data2, aes(x = rank, y = price))
g <- g + geom_point(aes(color = brand), size = 5, alpha = 0.2)
g <- g + geom_smooth(color = '#FF6633', size = 3, se = FALSE)
g <- g + theme_gdocs()
g <- g + coord_cartesian(xlim = c(0, 50), ylim = c(0, 600))
g <- g + scale_color_manual("Brand", values = c("#FF3300", "#0066FF"))
g <- g + xlab("Rank") + ylab("Price ($)") + ggtitle("Price vs. Rank")
g


## 3. cpu, price vs. core
data3 <- cpu %>% top_n(-211, rank) %>% select(core, price, brand) %>% filter(core < 10 & core > 1)
data3$core <- factor(data3$core)

g <- ggplot(data3, aes(x = core, y = price))
g <- g + geom_boxplot(aes(color = brand), position = "dodge")
g <- g + theme_gdocs()
g <- g + scale_color_manual("Brand", values = c("#FF3300", "#0066FF"))
g <- g + xlab("Number of Cores") + ylab("Price ($)") + ggtitle("Price vs. Core Number")
g

# 4. cpu, price vs. power
data4 <- cpu %>% top_n(-211, rank) %>% select(power, price, brand)

g <- ggplot(data4, aes(x = power, y = price))
g <- g + geom_point(aes(color = brand), size = 3)
g <- g + theme_gdocs()
g <- g + coord_cartesian(xlim = c(20, 150), ylim = c(0, 1800))
g <- g + scale_color_manual("Brand", values = c("#FF3300", "#0066FF"))
g <- g + xlab("Power Consumption (W)") + ylab("Price ($)") + ggtitle("Price vs. Power Consumption")
g

# 5 cpu, price vs. freq
data5 <- cpu %>% top_n(-211, rank) %>% select(freq, price, brand)

g <- ggplot(data5, aes(x = freq, y = price))
g <- g + geom_point(aes(color = brand), size = 3)
g <- g + theme_gdocs()
#g <- g + coord_cartesian(xlim = c(20, 150), ylim = c(0, 1800))
g <- g + scale_color_manual("Brand", values = c("#FF3300", "#0066FF"))
g <- g + xlab("Operating Frequency (GHz)") + ylab("Price ($)") + ggtitle("Price vs. Operating Frequency")
g

# 6 cpu, statistic exploration
## cor plot
data6 <- cpu %>% top_n(-211, rank) %>% select(brand, series, core, power, freq, price)
corplot <- cor(data6[, c(-1, -2)])
corrplot(corplot, method = "square")
## t-test
price_amd <- data6$price[data6$brand == 'amd']
price_intel <- data6$price[data6$brand == 'intel']
t.test(price_intel, price_amd,
       alternative = "greater", paired = FALSE, var.equal = FALSE, conf.level = 0.95)
## linear regression
model_empty = lm(price ~ 1, data = data6)
model_full = lm(price ~ ., data = data6)
scope = list(lower = formula(model_empty), upper = formula(model_full))
AICmodel_back = step(model_full, scope, direction = "backward", k = 2)
AICmodel_forward = step(model_empty, scope, direction = "forward", k = 2)
summary(AICmodel_back)   ### model is not good, should get more numeric features
                         ### like product release date
qqnorm(data6$price)      ### check the normality of response
boxCox(AICmodel_back)    ### check boxCox transformation, take log price

model_bc <- lm(log(price) ~ series + core + power, data = data6)
                         ### boxCox transformation explains more variance

#########################################################################################

# 7 gpu, rating as outcome glm

# goodrating <- factor(ifelse(gpu$rating == 5, 'good', 'soso'))
# gpu$goodrating <- goodrating
# 
# data7 <- gpu %>% select(goodrating, chipmake, brand,
#                         price, memorysize, memoryinterface, coreclock, memorytype)
# fullmodel <- glm(goodrating ~ ., family = "binomial", data = data7)
# emptymodel <- glm(goodrating ~ 1, family = "binomial", data = data7)
# scope = list(lower = formula(emptymodel), upper = formula(fullmodel))
# AICmodel_back = step(fullmodel, scope, direction = "backward", k = 2)
# AICmodel_forward = step(emptymodel, scope, direction = "forward", k = 2)


# 8 gpu, top 10 products
data8 <- gpu %>% top_n(-20, rank) %>% 
    select(brand, chipmake, gpu, coreclock,memorysize,
           memorytype, memoryinterface, price, rating, url)

# 9 cpu, top 10 products
data9 <- cpu %>% top_n(-10, rank) %>% 
    select(brand, name, core, freq, power, price, rating, url)


# 10 gpu, top 150 gpu vs. brands
data10 <- gpu %>% top_n(-200, rank) %>% group_by(chipmake, brand) %>%
    summarize(count = n()) %>% as.data.frame()

g <- ggplot(data10, aes(x = brand, y = count))
g <- g + geom_bar(aes(fill = chipmake), stat = "identity", position = "dodge")
g <- g + xlab("Brand") + ylab("Count") + ggtitle("Distribution of Top200 GPUs")
g <- g + theme_gdocs() + theme(axis.text.x = element_text(angle = 30, hjust = 1))
g <- g + scale_color_manual("Chip", values = c("#FF3300", "#0066FF"))
g
















