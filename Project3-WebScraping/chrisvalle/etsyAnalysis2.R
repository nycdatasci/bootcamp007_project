library(openxlsx)
library(ggplot2)
library(dplyr)
library(VIM)
library(MASS)
library(corrplot)
library(qtlcharts)
setwd("/Users/datascience/desktop/etsyParsedConsolidate")


#load preprocessed file
etsyCarrier = read.csv("allDFclean3.csv")
summary(etsyCarrier)
colnames(etsyCarrier)
etsyCarrier = etsyCarrier[,-grep("X", colnames(etsyCarrier))]
colname = data.frame(colnames(etsyCarrier))
#sellers = data.frame(unique(etsyCarrier$shopName))
#locations = data.frame(unique(etsyCarrier$shopLocation))

babyCsharebySeller = etsyCarrier%>%
  count(shopName) #listing share by seller for baby carriage

sum(sellerCount$n) #28143

shopCount = etsyCarrier%>%
  count(shopLocation)

shopNameLoc = etsyCarrier%>%
  select(shopName, feedback, itemCount, shopLocation)%>%
  group_by(shopName, shopLocation)

shopNameLoc = etsyCarrier%>%
  group_by(shopName)

shopNameLoc2 = group_by(etsyCarrier, shopName)



##################### EDA [Visualization] ##################### 

##################### UNIVARIATE##################### 
#1 Product Pricing Distribution (Univariate)
ggplot(etsyCarrier, aes(price)) +
  geom_histogram() + theme_bw() #too left skewed
ggplot(etsyCarrier, aes(log(price))) +
  geom_histogram() + theme_bw()

ggplot(etsyCarrier, aes(x= price))+ geom_density(fill="#eb6d20") + theme_bw()
ggplot(etsyCarrier, aes(x= log(price)))+ geom_density(fill="#eb6d20") + theme_bw()

#2 Item Count Distribution
ggplot(etsyCarrier, aes(x = itemCount)) +
  geom_density(fill="#eb6d20")+ theme_bw() # very right skewed, showing outliers seller with ~2k product types for sale

ggplot(etsyCarrier, aes(x = shopName,  y = itemCount)) +
  geom_boxplot()+ theme_bw() # does not really work

#3 Views Distribution
ggplot(etsyCarrier, aes(x = views)) +
  geom_density(fill="#eb6d20")+ theme_bw()

ggplot(etsyCarrier, aes(x = log(views))) +
  geom_density(fill="#eb6d20")+ theme_bw()

#4 feedback distribution
ggplot(etsyCarrier, aes(x = feedback)) +
  geom_density(fill="#eb6d20")+ theme_bw()

ggplot(etsyCarrier, aes(x = log(views))) +
  geom_density(fill="#eb6d20")+ theme_bw()

ggplot(etsyCarrier, aes(x ="", y= feedback)) + 
  geom_boxplot(fill="#eb6d20") + theme_bw() #

ggplot(etsyCarrier, aes(x ="", y= log(feedback))) + 
  geom_boxplot(fill="#eb6d20") + theme_bw()

#boxplot(etsyCarrier$feedback)

ggplot(data = mpg, aes(x = "", y = displ)) + 
  geom_boxplot() + 
  theme(axis.title.x = element_blank())


#5 ShopName
ggplot(etsyCarrier, aes(x = shopName, y=count, fill = shopName)) + 
  geom_bar(stat = "identity")

ggplot(etsyCarrier, aes(shopName, ..count..) + geom_bar(position = "dodge")
       
ggplot(sellerCount, aes(x = shopName, y=n)) + geom_point() + theme_bw()

ggplot(sellerCount, aes(x ="", y= n)) + geom_boxplot(fill="#eb6d20") + theme_bw()

ggplot(sellerCount, aes(x = n)) + geom_histogram(fill="#eb6d20", bins = 50)+ theme_bw()
       
summary(sellerCount)
       
# shopLocation
etsyCarrier%>%
  count(shopName)
       
Fruit <- c(rep("Apple",3),rep("Orange",5))
Bug <- c("worm","spider","spider","worm","worm","worm","worm","spider")
df <- data.frame(Fruit,Bug)
ggplot(etsyCarrier, aes(shopName, ..count..)) + geom_bar(aes(fill = shopName), position = "dodge")
       
##################### BI-VARIATE##################### 
       
# Price & Views
ggplot(etsyCarrier, aes(x=price, y=views, fill = priceRange)) +
  geom_point(shape = 21, size = 2, alpha=0.5) + theme_bw() #right screwed, no apparent linear relations
       
ggplot(etsyCarrier, aes(x=log(price), y=views)) + geom_point()

ggplot(etsyCarrier, aes(x=log(price), y=views)) +
  geom_point() 
       
       
# PriceRange & Views
ggplot(etsyCarrier, aes(x=priceRange, y=views, fill = priceRange)) +
  geom_point(shape = 21, size = 2, alpha=0.5) + theme_bw() +
  xlab("price range") + ylab("views")
# findings:
# most viewed $25-$50 items followed by $51-100
# least viewed are the most expensive $1000 up and $100-$499
       
#Min.   :   2.0
#1st Qu.:  50.0
#Median : 121.0   
#Mean   : 276.1
#3rd Qu.: 393.0
#Max.   :2403.0 

ggplot(etsyCarrier, aes(x=priceRange, y=log(views), fill = priceRange)) +
  geom_point(shape = 21, size = 2, alpha=0.5) + theme_bw()  #log version, not really sensible
       
       
##################### Modeling [Predictive: Linear Model] ##################### 
       
# predict views using product price, shop feedback
# see if LR applies

#correlation matrix


#drop all factor variables
etsyNumCol = etsyCarrier
etsyNumCol = etsyNumCol[,-grep("seq|product|listDate|shopName|shopLocation|priceRange|priceInt", colnames(etsyNumCol))]
dim(etsyNumCol)
length(dimnames(etsyNumCol))

#correlations test among variables
corrplot(cor(etsyNumCol))


# only itemCount and feedback appear to be correlated
cor.test(etsyCarrier$itemCount, etsyCarrier$feedback)
# cor = 0.61, t = 129.46, p-value < 2.2e-16

#regression line
plot(etsyCarrier$price, etsyCarrier$views)
# no linear association
# cannot use LM 

# test independence of price and shop feedback
chisq.test(etsyCarrier$price,etsyCarrier$feedback)
# H0 = price and feedback are independent of one another 
# HA = price and feedback are dependent of one another
# p-value < 2.2e-16, reject H0, accept HA
       
       
chisq.test(etsyCarrier$price,etsyCarrier$itemCount)
# H0 = price and feeditemCountback are independent of one another 
# HA = price and itemCount are dependent of one another
#p-value < 2.2e-16, reject H0, accept HA
       
chisq.test(etsyCarrier$priceRange,etsyCarrier$views)
# same as above
       

       
       
       