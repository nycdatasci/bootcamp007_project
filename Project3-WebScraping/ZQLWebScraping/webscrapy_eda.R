###this file is for plot

library(dplyr)
library(ggplot2)
library(scales)
library(RColorBrewer)
library(ggthemes)
library(gridExtra)

airbnb <- read.csv("~/Downloads/airbnb_final.csv")      ##works:)
tripadvisor <- read.csv("~/Downloads/tripadvisor_final.csv") ##works:)



##tripadvisor price_low
plot6_violin = ggplot(data = tripadvisor, aes(x=reorder(review_score, price_low, median), y =price_low)) +
  geom_violin(aes(fill =review_score)) + scale_y_continuous(labels = comma) 

###tripadvisor price_high
plot7_violin = ggplot(data = tripadvisor, aes(x=reorder(review_score, price_high, median), y =price_high)) +
  geom_violin(aes(fill =review_score)) + scale_y_continuous(labels = comma) 

###tripadvisor hotel-star high
plot8_violin = ggplot(data = tripadvisor, aes(x=reorder(hotel_star, price_high, median), y =price_high)) +
  geom_violin(aes(fill =hotel_star)) + scale_y_continuous(labels = comma) 

### tripadvisor hotel-star low
plot9_violin = ggplot(data = tripadvisor, aes(x=reorder(hotel_star, price_low, median), y =price_low)) +
  geom_violin(aes(fill =hotel_star)) + scale_y_continuous(labels = comma) 

## airbnb amenities
airbnb_am= airbnb[,23:52]
Amenities <- names(airbnb_am)
Counts <- as.numeric(as.character(colSums(airbnb_am)))
AP <- data.frame(Amenities, Counts, stringsAsFactors = F)
g3 = ggplot(AP,aes(x = reorder(Amenities,-Counts) , y = Counts)) 
plot3 = g3 + geom_bar(aes(fill=Counts),stat = "identity")+ guides(fill=FALSE)+
  scale_fill_gradient(guide="colourbar",high = "#CC6666", low = "#9999CC", name= "Counts")+
  theme(axis.text.x = element_text(angle = 45, hjust = 1), 
        axis.ticks.y=element_blank(),
       axis.text.y=element_blank())+
  geom_text(aes(label = Counts ), size = 3,  hjust = 0.5, vjust = -0.3)+
  xlab("Amentities") +
   ylab("Counts") 
plot3


## tripadvisor amenities
trip_am= tripadvisor[,11:53]
Amenities_t <- names(trip_am)
Counts_t <- as.numeric(as.character(colSums(trip_am)))
AP_t <- data.frame(Amenities_t, Counts_t, stringsAsFactors = F)
g4 = ggplot(data=AP_t, aes(x = reorder(Amenities_t, -Counts_t) , y = Counts_t)) 
plot4 = g4 + geom_bar(aes(fill=Counts_t), stat = "identity")+ guides(fill=FALSE)+
  scale_fill_gradient(guide="colourbar",high = "#7fbf7b", low = "#ffffbf", name= "Counts_t")+
  theme(axis.text.x = element_text(angle = 60, hjust = 1), 
        axis.ticks.y=element_blank(),
        axis.text.y=element_blank())+
  geom_text(aes(label = Counts_t ), size = 3,  hjust = 0.5, vjust = -0.3)+
  xlab("Amentities") +
  ylab("Counts") 
plot4

##
amenities_count= airbnb%>%select(price,review_score_a, TV,                        
                                 Cable.TV,                  
                                 Internet,                
                                 Wireless.Internet,         
                                 Air.conditioning,          
                                 Wheelchair.accessible,    
                                 Pool,                     
                                 Kitchen,                   
                                 Free.parking.on.premises,
                                 Smoking.allowed,          
                                 Pets.allowed,              
                                 Doorman,                  
                                 Gym,                       
                                 Breakfast,                 
                                 Elevator.in.building,     
                                 Hot.tub,                  
                                 Indoor.fireplace,         
                                 Buzzer.wireless.intercom,
                                 Heating,                  
                                 Family.kid.friendly,      
                                 Suitable.for.events,      
                                 Washer,                   
                                 Dryer,                    
                                 Essentials,               
                                 Shampoo,                   
                                 Hangers,                   
                                 Hair.dryer,               
                                 Iron,                      
                                 Laptop.friendly.workspace, 
                                 Self.Check.In)%>%
  group_by(review_score_a)%>%sapply(sum, 2)





###chi test between amenities and price


### service of the hotel with star

### star and price

airbnb_am= airbnb%>%select(review_score_a, price)%>%
  group_by(.,YrSold)%>%summarise(.,total = n(), median_p=median(SalePrice))
house_yrsold$YrSold <- factor(house_yrsold$YrSold, levels=reorder(house_yrsold$YrSold, -house_yrsold$total))
g3 = ggplot(data=house_yrsold, aes(x = YrSold, y = total)) 
plot3 = g3 + geom_bar(aes(fill=median_p), stat = "identity") + 
  scale_fill_gradient(guide="colorbar",high = "#132B43", low = "#56B1F7", name= "Median Price($)")+
  geom_text(aes(label = median_p ), size = 4,  hjust = 0.5, vjust = -0.3)+
  xlab(" ") +
  ylab("Number of Houses Sold")+
  ggtitle(" House Sale vs. Year")
plot3

trip_map <- leaflet() %>%
  addTiles() %>%  # Add default OpenStreetMap map tiles
  addMarkers(lng = coords$lon,
             lat = coords$lat,
             popup = as.character(price_low))
trip_map


### plot price_low vs review

p <- ggplot(data = tripadvisor, aes(x = review_score, y = price_low)) +
  geom_point() +
  geom_smooth()

##density plot
ggplot(tripadvisor,aes(x=price_low)) +
  geom_histogram(data=subset(tripadvisor,review_score == '2.5'),fill = "red", alpha = 0.2) 
# geom_histogram(data=subset(dat,yy == 'b'),fill = "blue", alpha = 0.2) +
# geom_histogram(data=subset(dat,yy == 'c'),fill = "green", alpha = 0.2)

g <- ggplot(tripadvisor, aes(review_score))
# Number of cars in each class:
g + geom_bar(aes(fill = ))

plot(tripadvisor$price_low)

names(tripadvisor)


### plot a map with price
m <- leaflet() %>%
  addTiles() %>%  # Add default OpenStreetMap map tiles
  addMarkers(lng = airbnb$lon,
             lat = airbnb$lat,
             popup = as.character(airbnb$price))