library(stringr)


#Expedia charts

library(ggplot2); library(scales); library(grid); library(RColorBrewer)

minim_theme <- function() {
  
  # Generate the colors for the chart procedurally with RColorBrewer
  palette <- brewer.pal("Greys", n=9)
  color.background = palette[2]
  color.grid.major = palette[3]
  color.axis.text = palette[6]
  color.axis.title = palette[7]
  color.title = palette[9]
  
  # Begin construction of chart
  theme_bw(base_size=9) +
    
    # Set the entire chart region to a light gray color
    theme(panel.background=element_rect(fill=color.background, color=color.background)) +
    theme(plot.background=element_rect(fill=color.background, color=color.background)) +
    theme(panel.border=element_rect(color=color.background)) +
    
    # Format the grid
    theme(panel.grid.major=element_line(color=color.grid.major,size=.25)) +
    theme(panel.grid.minor=element_blank()) +
    theme(axis.ticks=element_blank()) +
    
    # Format the legend, but hide by default
    theme(legend.position="none") +
    theme(legend.background = element_rect(fill=color.background)) +
    theme(legend.text = element_text(size=7,color=color.axis.title)) +
    
    # Set title and axis labels, and format these and tick marks
    theme(plot.title=element_text(color=color.title, size=10, vjust=1.25)) +
    theme(axis.text.x=element_text(size=7,color=color.axis.text)) +
    theme(axis.text.y=element_text(size=7,color=color.axis.text)) +
    theme(axis.title.x=element_text(size=8,color=color.axis.title, vjust=0)) +
    theme(axis.title.y=element_text(size=8,color=color.axis.title, vjust=1.25)) +
    
    # Plot margins
    theme(plot.margin = unit(c(0.35, 0.2, 0.3, 0.35), "cm"))
}

countryID = as.data.frame(table(expedia$visitor_location_country_id))
reorder(countryID$Var1, countryID$Freq)
sort(countryID$Freq)

ggplot(countryID, aes(reorder(Var1, Freq, desc), Freq)) + 
  geom_bar(stat = "identity", fill = "steelblue", alpha = 0.8) +
  labs(title="Country ID of Visitors", ylab = "Count")
  
barplot(table(expedia$visitor_location_country_id), main = "Country ID of Visitors", ylab = "Count", col="steelblue", border = "steelblue")


by_srchID =
  as.data.frame(
    expedia_US %>%
      select(srch_id, booking_bool) %>%
      group_by(srch_id) %>%
      summarize(count = n(), booking = sum(booking_bool)) %>%
      ungroup() %>%
      group_by(count) %>%
      summarize(amount = n(), avg_booking = mean(booking)) %>%
      arrange(desc(count))
  )

ggplot(by_srchID, aes(count, amount)) + 
  geom_bar(stat = "Identity", fill = "steelblue", alpha = 1) + 
  labs(title= "Number of Searches Results Returned To User", x="Search Results Returned", y="Count") +
  #theme(plot.margin = unit(c(0.35, 0.2, 0.3, 0.35), "cm")) +
  theme(axis.title.y=element_text(margin=margin(0,15,0,0))) +
  theme(axis.title.x=element_text(margin=margin(10,0,0,0))) +
  theme(plot.title=element_text(margin=margin(0,0,20,0)))
  

ggplot(by_srchID, mapping = aes(count, avg_booking)) + 
  geom_line(stat = "Identity") + 
  labs(title= "Booking Rate by Number of Searches", x="Search Count", y="Booking Rate") +
  theme(axis.title.y=element_text(margin=margin(0,15,0,0))) +
  theme(axis.title.x=element_text(margin=margin(10,0,0,0))) +
  theme(plot.title=element_text(margin=margin(0,0,20,0))) 

# booked or not ==========
trip_booked =
  as.data.frame(
    expedia_US %>%
      select(srch_id, booking_bool) %>%
      group_by(srch_id) %>%
      summarize(booking = sum(booking_bool)) %>%
      ungroup() %>%
      group_by(booking) %>%
      summarize(count = n())
  )
trip_booked$booking = c("Not Booked", "Booked")
ggplot(trip_booked, aes(booking, count)) + 
  geom_bar(stat = "Identity", fill = "steelblue") + 
  labs(title= "Trip Searches Ending with a Booking ", x="", y="Count") +
  #theme(plot.margin = unit(c(0.35, 0.2, 0.3, 0.35), "cm")) +
  theme(axis.title.y=element_text(margin=margin(0,15,0,0))) +
  theme(axis.title.x=element_text(margin=margin(10,0,0,0))) +
  theme(plot.title=element_text(margin=margin(0,0,20,0)))
  
ggplot(trip_booked, aes(booking, count)) + 
  geom_bar(stat = "Identity", fill = "steelblue") + 
  labs(title= "Overall Trip Searches Ending with a Booking ", x="", y="Count") +
  #theme(plot.margin = unit(c(0.35, 0.2, 0.3, 0.35), "cm")) +
  theme(axis.title.y=element_text(margin=margin(0,15,0,0))) +
  theme(axis.title.x=element_text(margin=margin(10,0,0,0))) +
  theme(plot.title=element_text(margin=margin(0,0,20,0)))
  
overall_bookings = as.data.frame(table(expedia_US$booking_bool))
colnames(overall_bookings) = c("booking", "count")
overall_bookings$booking = c("Not Booked", "Booked")
ggplot(overall_bookings, aes(booking, count)) + 
  geom_bar(stat = "Identity", fill = "steelblue") + 
  labs(title= "Individual Search Results Booked", x="", y="Count") +
  #theme(plot.margin = unit(c(0.35, 0.2, 0.3, 0.35), "cm")) +
  theme(axis.title.y=element_text(margin=margin(0,15,0,0))) +
  theme(axis.title.x=element_text(margin=margin(10,0,0,0))) +
  theme(plot.title=element_text(margin=margin(0,0,20,0)))


# gross bookings / historical stars / historical ADR

hist(kmean_data$gross_bookings_usd, xlim=c(0,1000), breaks = 10000)
hist(expedia_US$gross_bookings_usd, xlim=c(0,1000), breaks = 10000) #same

ggplot(kmean_data, aes(x = gross_bookings_usd)) +
  geom_histogram(binwidth = 25, col = "white", fill = "steelblue") +
  xlim(c(0,1000)) +
  labs(title= "Gross Bookings By Trip", x="Gross Bookings in USD", y="Count") +
  #theme(plot.margin = unit(c(0.35, 0.2, 0.3, 0.35), "cm")) +
  theme(axis.title.y=element_text(margin=margin(0,15,0,0))) +
  theme(axis.title.x=element_text(margin=margin(10,0,0,0))) +
  theme(plot.title=element_text(margin=margin(0,0,20,0)))

gross_bookings_by_room =
  as.data.frame(
    kmean_data %>%
      select(hist_adr_usd, gross_bookings_usd, srch_length_of_stay, srch_room_count)
  )

length(is.na(gross_bookings_by_room$gross_bookings_usd))
length(gross_bookings_by_room$hist_adr_usd == "NjAvas")
dim(gross_bookings_by_room)
gross_bookings_by_room$gross_per = gross_bookings_by_room$gross_bookings_usd/gross_bookings_by_room$srch_length_of_stay/gross_bookings_by_room$srch_room_count
plot(gross_bookings_by_room$hist_adr_usd, gross_bookings_by_room$gross_per, ylim = c(0,2000))

ggplot(gross_bookings_by_room, aes(hist_adr_usd, gross_per)) + 
  geom_point(colour="steelblue", shape=21, size = 2) +
  geom_density2d(colour="purple") +
  ylim(0,500) +
  xlim(0,500) +
  labs(title= "Current ADR vs. Historical ADR", x="Visitor's Historical ADR in USD", y="Approximate ADR of Booking") +
  #theme(plot.margin = unit(c(0.35, 0.2, 0.3, 0.35), "cm")) +
  theme(axis.title.y=element_text(margin=margin(0,15,0,0))) +
  theme(axis.title.x=element_text(margin=margin(10,0,0,0))) +
  theme(plot.title=element_text(margin=margin(0,0,20,0)))
  
  smoothScatter(gross_bookings_by_room[c(1,5)])

# ggplot(kmean_data, aes(x = hist_adr_usd)) +
#   geom_density(col = "steelblue", fill = "steelblue", alpha = 0.75) +
#   xlim(c(0,600)) +
#   labs(title= "Gross Bookings By Trip", x="Gross Bookings in USD", y="Count") +
#   #theme(plot.margin = unit(c(0.35, 0.2, 0.3, 0.35), "cm")) +
#   theme(axis.title.y=element_text(margin=margin(0,15,0,0))) +
#   theme(axis.title.x=element_text(margin=margin(10,0,0,0))) +
#   theme(plot.title=element_text(margin=margin(0,0,20,0)))

ggplot(kmean_data, mapping = aes(hist_starrating, prop_starrating)) + 
  geom_bin2d() +
  # geom_point(colour="steelblue", shape=21, size = 2) +
  # geom_density2d(colour="purple") +
  labs(title="Star Rating of Historical and Current Booking", x="Visitor's Historical Star Rating", y="Star Rating of Hotel Booked") +
  theme(axis.title.y=element_text(margin=margin(0,15,0,0))) +
  theme(axis.title.x=element_text(margin=margin(10,0,0,0))) +
  theme(plot.title=element_text(margin=margin(0,0,20,0)))


# by adults / children / rooms
by_adults=
  as.data.frame(
    kmean_data %>%
  group_by(srch_adults_count) %>%
  summarize(count = n())
  )
ggplot(by_adults, aes(srch_adults_count, count)) +
  geom_bar(stat="identity", col = "white", fill = "steelblue") +
  scale_x_continuous("hi", breaks=1:9,
                     labels=c(seq(1,9))) +
  theme(axis.title.x=element_text(margin=margin(10,0,0,0))) 
  

ggplot(kmean_data, aes(x = srch_adults_count)) +
  geom_bar(col = "white", fill = "steelblue") +
  scale_x_continuous("Adults", breaks=1:9,
                     labels=c(seq(1,9))) +
  # geom_histogram(bins = 9, col = "white", fill = "steelblue") +
  labs(title= "Number of Adults", x="Adults", y="Count") +
  # theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  #theme(plot.margin = unit(c(0.35, 0.2, 0.3, 0.35), "cm")) +
  theme(axis.title.y=element_text(margin=margin(0,15,0,0))) +
  theme(axis.title.x=element_text(margin=margin(10,0,0,0))) +
  theme(plot.title=element_text(margin=margin(0,0,20,0)))

ggplot(kmean_data, aes(x = srch_children_count)) +
  geom_bar(col = "white", fill = "steelblue") +
  scale_x_continuous("Children", breaks=0:9,
                     labels=c(seq(0,9))) +
  # geom_histogram(bins = 9, col = "white", fill = "steelblue") +
  labs(title= "Number of Children", x="Children", y="Count") +
  # theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  #theme(plot.margin = unit(c(0.35, 0.2, 0.3, 0.35), "cm")) +
  theme(axis.title.y=element_text(margin=margin(0,15,0,0))) +
  theme(axis.title.x=element_text(margin=margin(10,0,0,0))) +
  theme(plot.title=element_text(margin=margin(0,0,20,0)))

ggplot(kmean_data, aes(x = srch_room_count)) +
  geom_bar(col = "white", fill = "steelblue") +
  scale_x_continuous("Rooms", breaks=1:8,
                     labels=c(seq(1,8))) +
  # geom_histogram(bins = 9, col = "white", fill = "steelblue") +
  labs(title= "Number of Rooms", x="Children", y="Count") +
  # theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  #theme(plot.margin = unit(c(0.35, 0.2, 0.3, 0.35), "cm")) +
  theme(axis.title.y=element_text(margin=margin(0,15,0,0))) +
  theme(axis.title.x=element_text(margin=margin(10,0,0,0))) +
  theme(plot.title=element_text(margin=margin(0,0,20,0)))

table(kmean_data$srch_adults_count, kmean_data$srch_children_count#, kmean_data$srch_room_count)

#most common combos
by_combo = cbind(combo=
  c(
"1 room: 2 adults, 0 children", 
"1 room: 1 adults, 0 children", 
"1 room: 2 adults, 2 children", 
"1 room: 2 adults, 1 children", 
"1 room: 1 adults, 1 children", 
"1 room: 3 adults, 0 children", 
"2 rooms: 1 adults, 1 children", 
"1 room: 4 adults, 0 children", 
"2 rooms: 4 adults, 0 children"
),
count = c(99577, 32521, 14563, 12875, 4656, 4600, 4109, 3631, 3531))
by_combo = as.data.frame(by_combo)
by_combo$count = as.numeric(as.character(by_combo$count))

ggplot(by_combo, aes(reorder(combo, -count), count)) +
  geom_bar(stat="identity", col = "white", fill = "steelblue") +
scale_x_discrete(labels = function(x) str_wrap(x, width = 12)) +
  # geom_histogram(bins = 9, col = "white", fill = "steelblue") +
  labs(title= "Most Common Combinations", x="", y="Count") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  #theme(plot.margin = unit(c(0.35, 0.2, 0.3, 0.35), "cm")) +
  theme(axis.title.y=element_text(margin=margin(0,15,0,0))) +
  theme(axis.title.x=element_text(margin=margin(10,0,0,0))) +
  theme(plot.title=element_text(margin=margin(0,0,20,0)))

#by number of clicks ===========
by_clicks =
  as.data.frame(
    expedia_US %>%
      select(srch_id, click_bool, booking_bool) %>%
      group_by(srch_id) %>%
      summarize(clicks = sum(click_bool), booking = sum(booking_bool)) %>%
      ungroup() %>%
      group_by(clicks) %>%
      summarize(amount = n(), avg_booking = mean(booking)) %>%
      arrange(desc(clicks))
  )

ggplot(by_clicks, mapping = aes(clicks, amount)) + 
  geom_bar(stat="identity", col = "white", fill = "steelblue") +
  scale_x_continuous(breaks = seq(1,4), limits = c(0.5,4.5)) + 
  labs(title="Number of Results Clicked In Search Results", x="Clicks", y="Count")+
  theme(axis.title.y=element_text(margin=margin(0,15,0,0))) +
  theme(axis.title.x=element_text(margin=margin(10,0,0,0))) +
  theme(plot.title=element_text(margin=margin(0,0,20,0)))

ggplot(by_clicks, mapping = aes(clicks, avg_booking)) + 
  geom_point(stat = "Identity", color="steelblue") +
  geom_line(stat = "Identity", color="steelblue") +
  scale_x_continuous(breaks = seq(0,4), limits = c(0,4)) + 
  labs(title="Booking Rate by Number of Results Clicked", x="Clicks", y="Average Booking Rate") +
  theme(axis.title.y=element_text(margin=margin(0,15,0,0))) +
  theme(axis.title.x=element_text(margin=margin(10,0,0,0))) +
  theme(plot.title=element_text(margin=margin(0,0,20,0)))


#by number of search results
by_search_number =
  as.data.frame(
    expedia_US %>%
      select(srch_id, booking_bool, click_bool) %>%
      group_by(srch_id) %>%
      summarize(count = n(), booking = sum(booking_bool), clicks = sum(click_bool)) %>%
      ungroup() %>%
      group_by(count) %>%
      summarize(amount = n(), avg_booking = mean(booking), avg_clicks = mean(clicks)) %>%
      arrange(desc(count))
  )
ggplot(by_search_number, mapping = aes(count)) + 
  geom_line(aes(y = avg_booking, colour = "Avg. Booking")) +
  geom_line(aes(y = avg_clicks, colour = "Click Rate")) +
  xlim(6,35)+
  labs(title= "Average Clicking and Booking Rates\n By Number of Results", x="Number of Results", y="Rate") +
  # theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  #theme(plot.margin = unit(c(0.35, 0.2, 0.3, 0.35), "cm")) +
  theme(axis.title.y=element_text(margin=margin(0,15,0,0))) +
  theme(axis.title.x=element_text(margin=margin(10,0,0,0))) +
  theme(plot.title=element_text(margin=margin(0,0,20,0)))


#booking rate by search window ========
booking_rate_by_srch_window =
  expedia_US %>%
  select(srch_id, booking_bool, srch_booking_window) %>%
  group_by(srch_booking_window) %>%
  summarize(count = n(), avg_booking_rate = mean(booking_bool)) %>%
  arrange(desc(count))

ggplot(booking_rate_by_srch_window, mapping = aes(srch_booking_window, count)) + 
  geom_bar(stat="identity", fill = "steelblue") +
  scale_x_continuous(breaks = seq(0,100, 10), limits = c(0,100)) + 
  labs(title="Search In Days Ahead of Stay", x="Days", y="Count")+
  theme(axis.title.y=element_text(margin=margin(0,15,0,0))) +
  theme(axis.title.x=element_text(margin=margin(10,0,0,0))) +
  theme(plot.title=element_text(margin=margin(0,0,20,0)))

ggplot(booking_rate_by_srch_window, mapping = aes(srch_booking_window, avg_booking_rate)) +
geom_line(color="steelblue") +
  geom_smooth() +
  scale_x_continuous(breaks = seq(0,250, 50), limits = c(0,250)) + 
  ylim(0,0.05) +
  labs(title="Booking Rate vs. Days Ahead of Stay", x="Days Ahead of Stay", y="Booking Rate")+
  theme(axis.title.y=element_text(margin=margin(0,15,0,0))) +
  theme(axis.title.x=element_text(margin=margin(10,0,0,0))) +
  theme(plot.title=element_text(margin=margin(0,0,20,0)))


# by promo flag
by_promo =
as.data.frame(
  expedia_US %>%
    select(srch_id, promotion_flag, click_bool, booking_bool) %>%
    group_by(promotion_flag) %>%
    summarize(click_rate = mean(click_bool), 
              clicks = sum(click_bool), 
              booking_rate = mean(booking_bool), 
              bookings = sum(booking_bool))
)
by_promo$promotion_flag = as.numeric(as.character(by_promo$promotion_flag))

ggplot(by_promo, mapping = aes(promotion_flag)) + 
  geom_point(aes(y = booking_rate), color="red") +
  geom_line(aes(y = booking_rate, colour = "Avg. Booking")) +
  geom_point(aes(y = click_rate), color="steelblue") +
  geom_line(aes(y = click_rate, colour = "Click Rate")) +
  ylim(0,.065) + 
  scale_x_continuous(breaks = seq(0,1), limits = c(0,1)) + 
  labs(title="Interaction When Promo Flag", x="Promotion Flag Present Boolean", y="Rates") +
  theme(axis.title.y=element_text(margin=margin(0,15,0,0))) +
  theme(axis.title.x=element_text(margin=margin(10,0,0,0))) +
  theme(plot.title=element_text(margin=margin(0,0,20,0))) +
  abline

ggplot(by_promo, mapping = aes(promotion_flag, booking_rate)) + geom_bar(stat = "identity") + ylim(0,.065) + labs(title="Booking Rate When Promo Flag", x="Promotion Flag Present", y="Booking Rate")
