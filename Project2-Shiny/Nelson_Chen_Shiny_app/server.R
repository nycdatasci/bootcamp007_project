###################################################
# Nelson Chen
# nchen9191@gmail.com
# NYC Data Science Academy
# Shiny Project
# Server code
###################################################

# Packages
library(shiny)
library(shinydashboard)
library(DT)
library(leaflet)
library(maps)
library(geosphere)
library(ggplot2)
library(ggthemes)
library(dplyr)
library(reshape2)

# Server function
shinyServer(function(input, output){
  
  ### Reactive Functions ###
  
  # Subset data by month 
  delay_time_filter = reactive({
    # filter by input months and airport
    delays_by_routes = delay_flights %>% filter(Month >= input$months[1] & 
                                                Month <= input$months[2] & 
                                                Origin == input$airport)
    # group delays and add column of total flights by routes
    delays_by_routes = delays_by_routes %>% group_by(Origin, Dest) %>% 
      inner_join(total_byroutes, c('Origin','Dest')) %>% 
      summarise(total_delays = n()) %>% inner_join(total_byroutes, by = c('Origin','Dest'))
    
    # define a percentage column
    delays_by_routes['Percent'] = round(100*delays_by_routes$total_delays/delays_by_routes$total_flights, 2)
    
    # output of reactive function
    delays_by_routes
  })
  
  # Further subset by top 10 choices of either delays or percentage of delays
  delay_gen = reactive({
    delays_by_routes = delay_time_filter()
    
    # Translate input string to column name string
    sort_choice = switch(input$sort_choice,
           "Total Delays" = "-total_delays",
           "Percentage" = "-Percent")
    
    # Arrange routes in descending order
    delays = delays_by_routes %>% arrange_(sort_choice)
    
    #subset to top 10 or total number of routes
    end_ind = min(nrow(delays), 10)
    delays_sub = delays[1:end_ind,] %>% 
            inner_join(airports, by = c('Dest' = 'iata'))
    delays_sub$Percent = round(delays_sub$Percent,2)
    delays_sub
  })
  
  # generate weekly dataframe filtered by inputs
  weekday_gen = reactive({
    temp = delay_flights # delayed flights
    temp_total = weekly_total_flights # total flights
    
    # Filter if there is input (did not choose none)
    if (input$airport_start != 'All'){
      temp = temp %>% filter(Origin == input$airport_start)
      temp_total = temp_total %>% filter(Origin == input$airport_start)
    }
    if (input$airport_end != 'All'){
      temp = temp %>% filter(Dest == input$airport_end)
      temp_total = temp_total %>% filter(Dest == input$airport_end)
    }
    if (input$AirLine != 'All'){
      temp = temp %>% filter(UniqueCarrier == Airlines[input$AirLine])
      temp_total = temp_total %>% filter(UniqueCarrier == Airlines[input$AirLine])
    }
    
    # Count delays by which day of the week
    temp = temp %>% group_by(DayOfWeek) %>% summarise(total = n())
    
    # Count total flights by which day of the week
    temp_total = temp_total %>% group_by(DayOfWeek) %>% summarise(weekday_total = sum(total_flights))
    temp_total$DayOfWeek = as.factor(temp_total$DayOfWeek)    # Convert to factors
    temp = temp %>% inner_join(temp_total, by = 'DayOfWeek') # join by the total
    temp['Percent'] = 100*temp$total/temp$weekday_total
    temp
    
  })
  
  # generate monthly dataframe filtered by inputs
  month_gen = reactive({
    temp = delay_flights
    temp_total = monthly_total_flights
    
    # Filter if there is input (not equal to none)
    if (input$airport_start != 'All'){
      temp = temp %>% filter(Origin == input$airport_start)
      temp_total = temp_total %>% filter(Origin == input$airport_start)
    }
    if (input$airport_end != 'All'){
      temp = temp %>% filter(Dest == input$airport_end)
      temp_total = temp_total %>% filter(Dest == input$airport_end)
    }
    if (input$AirLine != 'All'){
      temp = temp %>% filter(UniqueCarrier == Airlines[input$AirLine])
      temp_total = temp_total %>% filter(UniqueCarrier == Airlines[input$AirLine])
    }
    
    # Count total delayed flights by month
    temp = temp %>% group_by(Month) %>% summarise(total = n())
    
    # add up total flights
    temp_total = temp_total %>% group_by(Month) %>% summarise(Month_total = sum(total_flights))
    
    # combine to find percentage of flights that were delayed in that month
    temp = temp %>% inner_join(temp_total, by = 'Month')
    temp['Percent'] = 100*temp$total/temp$Month_total
    temp
  })
  
  delay_causes = reactive({
    temp = delay_flights
    
    # Filter if there is input (not equal to none)
    if (input$airport_start2 != 'All'){
      temp = temp %>% filter(Origin == input$airport_start2)
    }
    if (input$airport_end2 != 'All'){
      temp = temp %>% filter(Dest == input$airport_end2)
    }
    if (input$AirLine2 != 'All'){
      temp = temp %>% filter(UniqueCarrier == Airlines[input$AirLine2])
    }
    
    # filter by cause
    carrier_df = temp %>% filter(CarrierDelay != 0)
    carrier_total = (carrier_df %>% summarise(total = n()))[1,1]
    carrier_median = median(carrier_df$CarrierDelay)

    weather_df = temp %>% filter(WeatherDelay != 0)
    weather_total = (weather_df %>% summarise(total = n()))[1,1]
    weather_median = median(weather_df$WeatherDelay)

    NAS_df = temp %>% filter(NASDelay != 0)
    NAS_total = (NAS_df %>% summarise(total = n()))[1,1]
    NAS_median = median(NAS_df$NASDelay)

    LateAC_df = temp %>% filter(LateAircraftDelay != 0)
    LateAC_total = (LateAC_df %>% summarise(total = n()))[1,1]
    LateAC_median = median(LateAC_df$LateAircraftDelay)

    Security_df = temp %>% filter(SecurityDelay != 0)
    security_total = (Security_df %>% summarise(total = n()))[1,1]
    security_median = median(Security_df$SecurityDelay)
    
    # combine to find percentage of flights that were delayed in that month
    temp2 = data.frame(Delay.Causes = c("Carrier", "Weather", "NAS", "Late Aircraft", "Security"),
                       X1 = c(carrier_median, weather_median, NAS_median, LateAC_median, security_median),
                       total = c(carrier_total, weather_total, NAS_total, LateAC_total, security_total))
    temp2
  })
  
  delay_dist = reactive({
    temp = delay_flights
    
    # Filter if there is input (not equal to none)
    if (input$airport_start2 != 'All'){
      temp = temp %>% filter(Origin == input$airport_start2)
    }
    if (input$airport_end2 != 'All'){
      temp = temp %>% filter(Dest == input$airport_end2)
    }
    if (input$AirLine2 != 'All'){
      temp = temp %>% filter(UniqueCarrier == Airlines[input$AirLine2])
    }
    
    data = melt(temp[c('CarrierDelay', "WeatherDelay", "NASDelay", 'LateAircraftDelay', "SecurityDelay")])
    data = data[data$value != 0,]
  })
  
  ### Output Functions ###
  
  # Output datatable of all delays for different routes (input starting airport)
  output$table <- DT::renderDataTable({
      cols = c('Origin', 'Dest', 'total_delays', 'total_flights', 'Percent')
      delays_sub = delay_time_filter()
      datatable(delays_sub[cols], rownames=FALSE) %>% 
        formatStyle(cols, fontWeight='bold')
    })
  
  # Output US Map with 10 or max flight lines from origin airport
  output$mymap = renderLeaflet({
      delays_sub = delay_gen()
      
      # starting coordinates
      lat_start = airports$lat[airports$iata == input$airport]
      lon_start = airports$long[airports$iata == input$airport]
      
      # vectors of ending coordinates
      lat_end = delays_sub$lat
      lon_end = delays_sub$long
      
      # pull map from global code
      temp_map = USmap
    
      # Add great circle lines 
      for (i in 1:length(delays_sub$Dest)){
        
          # String to print out when user clicks on line
          detail = paste('Destination: ', airports[airports$iata == delays_sub$Dest[i],'airport'], "<br>" ,
                         'Total Delays = ', delays_sub$total_delays[i], '<br>',
                         'Total Flights = ', total_byroutes$total_flights[total_byroutes$Origin == input$airport &
                                                                            total_byroutes$Dest == delays_sub$Dest[i]],'<br>',
                         'Percentage = ', delays_sub$Percent[i], '%',
                         
                         sep = '')
          
          # create great circle lines
          inter <- gcIntermediate(c(lon_start, lat_start), c(lon_end[i], lat_end[i]), n=200, addStartEnd=TRUE)
          
          # add lines with leaflet
          temp_map = temp_map %>% addPolylines(data = inter, weight = 2, color = "red", opacity = 0.9 ,popup = detail)
      }
      
      # output final map
      temp_map
  })
  
  # Output bar chart of delays aggregated by days of the week
  output$barchart = renderPlot({
    data = weekday_gen()
    title_ = paste('Weekday Chart - ', input$airport_start, " to ",
                   input$airport_end, " on ", input$AirLine, sep='')
    ggplot(data, aes(x = DayOfWeek, y = Percent, fill = DayOfWeek)) +
      geom_bar(stat = 'identity') + scale_fill_pander("Weekday") + 
      ggtitle(title_) + theme_pander(base_size = 22)
  })
  
  # Output line chart of delays aggregated by month of the year
  output$lineGraph = renderPlot({
    data = month_gen()
    title_ = paste('Monthly Graph - ', input$airport_start, " to ",
                   input$airport_end, " on ", input$AirLine, sep='')
    ggplot(data, aes(x = Month, y = Percent)) + 
      geom_line(color = 'blue') + scale_x_continuous(breaks=1:12) +
      ggtitle(title_) + theme_economist(base_size = 18) +
      xlab('Months') + ylab('Percent (%)')
  })
  
  # Delay reason chart
  output$delayChart = renderPlot({
    data = delay_causes()
    title_ = paste('Delay Causes - ', input$airport_start, " to ",
                   input$airport_end, " on ", input$AirLine, sep='')
    g = ggplot(data, aes(x = Delay.Causes, y = X1, fill = Delay.Causes)) +
      geom_bar(stat = 'identity') + scale_fill_pander("") +
      ggtitle(title_) + xlab('Delay Causes') + ylab('Median Delays in Min') +
      theme_pander(base_size = 20) + coord_flip()
    g
  })
  
  # Total Delays
  output$delayTotal = renderPlot({
    data = delay_causes()
    g = ggplot(data, aes(x = Delay.Causes, y = total, fill = Delay.Causes)) +
      geom_bar(stat = 'identity') + scale_fill_pander("") +
      ggtitle('Flight Total by Delay Causes') + xlab('Delay Causes') + ylab('Total Flights') +
      theme_pander(base_size = 20) + coord_flip()
    g
  })
  
  # Delay Distributions
  output$delayDist = renderPlot({
    data = delay_dist()
    ggplot(data, aes(x=variable,y=value, fill = variable)) + geom_violin() + theme_pander(base_size = 22) + 
      xlab('Delay Causes') + ylab('Delay in Min') + scale_fill_discrete("Delay Causes") +
      theme(axis.text.x = element_text(size = 14, angle = 30, hjust = 1), 
            legend.text = element_text(size = 12),
            legend.title = element_text(size = 14)) + ggtitle('Delay Causes Violin Plot')
  })
})