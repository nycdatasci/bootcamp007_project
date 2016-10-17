
rm(list = ls())

library(dplyr)
library(ggplot2)
library(scales)
library(RColorBrewer)
library(ggthemes)

house_0= read.csv("~/Downloads/train.csv")

house_1 = filter(house_0, GrLivArea<4000)

names = c("MSZoning",
          "HouseStyle", "OverallQual", "YearBuilt","Foundation",
          "MoSold", "YrSold", "SalePrice")

house_data = house_1[, names]

g1 = ggplot(data= house_data, aes(x= YearBuilt, y =SalePrice))
plot1 = g1 + geom_point(aes(color=HouseStyle),position = "jitter", pch=8, cex=.8)+
  geom_smooth(method='lm',size = 0.5, se = T) + 
  scale_y_continuous(labels = comma) +
  ggtitle(" House Sale Price Trend ") +
  ylab("Sale Price ($)") +
  xlab("Year Built") +
  scale_color_manual(values = c('#fc8d62', '#dfc27d', '#7fbc41', '#80cdc1', '#a6cee3', '#4eb3d3', '#984ea3', '#e7298a'),
                     name = "House Style", labels=c("1.5-Story", "1.5-Story(U)", "1-Story",
                                                    "2.5-Story", "2.5-Story(U)","2-Story",
                                                    "Split Foyer", "Split Level"))
plot1 

g2 = ggplot(data= house_data, aes(x= YearBuilt, y =SalePrice, color = HouseStyle))
plot2 = g2 + geom_point(aes(color=HouseStyle),position = "jitter", pch=8, cex=.3)+
  geom_smooth(method='lm',size = 1.0, se = FALSE)+ 
  scale_y_continuous(labels = comma) +
  ggtitle(" House SalePrice Trend for HouseStyles") +
  scale_color_manual(values = c('#fc8d62', '#dfc27d', '#7fbc41', '#80cdc1', '#a6cee3', '#4eb3d3', '#984ea3', '#e7298a'),
                     name = "House Style", labels=c("1.5-Story", "1.5-Story(U)", "1-Story",
                                                    "2.5-Story", "2.5-Story(U)","2-Story",
                                                    "Split Foyer", "Split Level"))
plot2

house_yrsold= house_data%>%select(.,YrSold, SalePrice)%>%
  group_by(.,YrSold)%>%summarise(.,total = n(), median_p=median(SalePrice))
house_yrsold$YrSold <- factor(house_yrsold$YrSold, levels=reorder(house_yrsold$YrSold, -house_yrsold$total))
g3 = ggplot(data=house_yrsold, aes(x = YrSold, y = total)) 
plot3 = g3 + geom_bar(aes(fill=median_p), stat = "identity") + 
  scale_fill_gradientn(colours=rainbow(6), name= "Median Price($)")+
  xlab(" ") +
  ylab("Number of Houses Sold")+
  ggtitle(" House Sale vs. Year")
plot3

house_mosold= house_data%>%select(.,YrSold, MoSold,SalePrice)%>%
  group_by(.,MoSold)%>%summarise(.,total = n(), median_p=median(SalePrice))
house_mosold$MoSold <- factor(house_mosold$MoSold, levels=reorder(house_mosold$MoSold, -house_mosold$total))
g4 = ggplot(data=house_mosold, aes(x = MoSold, y = total)) 
plot4 = g4 + geom_bar(aes(fill=median_p), stat = "identity") + 
  xlab("") +
  ylab("Number of Houses Sold")+
  scale_fill_continuous(name ="Median Price ($)") +
  scale_x_discrete(labels=c("Jan", "Feb", "Mar","Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct","Nov", "Dec"))+
  ggtitle("Houses Sale vs. Month")
plot4

plot5_violin = ggplot(data = house_data, aes(x= reorder(MSZoning,SalePrice, median), y =SalePrice)) +
  geom_violin(aes(fill = MSZoning)) + scale_y_continuous(labels = comma) +
  xlab("Zone Classification")+ 
  xlab("Zoning Classification")+
  ylab("Sale Price ($)")+
  ggtitle("General Zonning Classification vs. Sale Price")+
  scale_fill_manual(values = c('#66c2a5','#fc8d62','#8da0cb','#e78ac3','#a6d854'),
                    name = " ", labels=c("Others", "Floating Village(FV)", "Residential High Density(RH)",
                                         "Residential Low Density(RL)", "Residential Medium Density(RM)"))+
  scale_x_discrete(labels=c("Others", "RM", "RH","RL", "FV")) +
  theme(legend.position ="bottom")

plot5_violin

house_data$OverallQual = as.factor(house_data$OverallQual)
house_overqual= house_data%>%select(.,OverallQual, SalePrice, Foundation)%>%
  group_by(.,OverallQual)
g6 = ggplot(data=house_overqual, aes(x = OverallQual)) 
plot6=g6+geom_bar(aes(fill= Foundation), position = "fill") + 
  theme(legend.position ="bottom") + 
  scale_fill_manual(values = c('#66c2a5','#fc8d62','#8da0cb','#e78ac3','#a6d854','#ffd92f'),
                    name = "Foundation", labels=c("Poured Contrete", "Cinder Block", "Brik&Tile",
                                                  "Slab", "Stone","Wood"))+
  xlab("Overall Quality") +
  ylab("Percent")+
  ggtitle("House Foundation VS. Overall House Quality ")

plot6

