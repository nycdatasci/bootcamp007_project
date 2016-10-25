library(httr)
library(rjson)
library(RJSONIO)
library(shiny)
library(shinydashboard)
library(leaflet)
library(dplyr)
library(curl) # make the jsonlite suggested dependency explicit
library(googleVis)
library(data.table)


shinyServer(function(input, output){

    output$map <- renderLeaflet({
      
      #capture avg ride time from dataset
      #oneRow <- cb_df_avg_trip_duration[1,c("start.station.name","start.station.latitude","start.station.longitude","end.station.name","end.station.latitude","end.station.longitude")]
      #oneRow <- filter(cb_df_avg_trip_duration, start.station.name == input$selected)[1,]
      
      #if only one location is entered, final destination will be Grand Central
      #if (input$selected == ' ') {
      #  bike_start_station = "W 38 St & 8 Ave"
      #  bike_end_station = "Pershing Square South"
      #}
      #oneRow <- filter(cb_df_avg_trip_duration, start.station.name == input$selected) %>% 
      #  select(start.station.name,start.station.latitude,start.station.longitude,
      #         end.station.name,end.station.latitude,end.station.longitude)
      
      oneRow <- filter(cb_station_df, stationName == input$selected[1]) %>% 
        select(stationName,latitude,longitude)
      oneRow <- rbind(oneRow, filter(cb_station_df, stationName == input$selected[2]) %>% 
                        select(stationName,latitude,longitude))
      
      #tempMatrix <- oneRow[1,c("start.station.name","start.station.latitude","start.station.longitude","end.station.name","end.station.latitude","end.station.longitude")] %>% matrix(2,3,2)
      #exmapLeaflet <- as.data.frame(tempMatrix)
      exmapLeaflet <- oneRow
      names(exmapLeaflet)  <- c("station.name","lat","lng")
      exmapLeaflet$lat <- as.numeric(exmapLeaflet$lat)
      exmapLeaflet$lng <- as.numeric(exmapLeaflet$lng)

      #capture waypoints
      
      conUrl_start <- "https://api.mapbox.com/directions/v5/mapbox/cycling/"
      conUrl_mid <- paste0(exmapLeaflet$lng[1],",",exmapLeaflet$lat[1],";",exmapLeaflet$lng[2],",",exmapLeaflet$lat[2]) # ex: -73.98,40.73;-73.97,40.75
      conUrl_end <- "?geometries=geojson&continue_straight=true&access_token=pk.eyJ1IjoiamhvbmFzdHRhbiIsImEiOiJFLTAzeVVZIn0.mwAAfKtGwv3rs3L61jz87A"
      conUrl <- paste0(conUrl_start,conUrl_mid,conUrl_end)
    
      con <- url(conUrl)  
      data.json <- fromJSON(paste(readLines(con), collapse=""))
      close(con)
      
      poly_points <- data.frame(matrix((unlist(data.json$routes[[1]]$geometry$coordinates)),length(unlist(data.json$routes[[1]]$geometry$coordinates)),2,2))
      names(poly_points) <- c("lng","lat")
      
          
      #complete coordinates
      poly_points <- rbind(poly_points, exmapLeaflet[2,c('lng','lat')])
      poly_points <- rbind(poly_points,poly_points[rev(rownames(poly_points)),])
      rownames(poly_points) <- 1:nrow(poly_points)

      #generate map
      leaflet(data = exmapLeaflet) %>% 
        addTiles(urlTemplate = tile_layer) %>% 
        addPopups(exmapLeaflet, lat = exmapLeaflet$lat,lng = exmapLeaflet$lng, popup = as.character(exmapLeaflet$station.name)) %>%
        #addPolylines(.,lng = poly_points$lng,lat = poly_points$lat,color="blue", popup = paste0("Avg Time: ",round(data.json$routes[[1]]$duration/60,,integer = 2))) %>% 
        addPolylines(.,noClip=TRUE,lng = poly_points$lng,lat = poly_points$lat,color="blue", popup = paste0("Avg Time: ",round(data.json$routes[[1]]$duration/60,,integer = 2))) %>% 
        fitBounds(lng1 = exmapLeaflet$lng[1],lat1 = exmapLeaflet$lat[1], 
                  lng2 = exmapLeaflet$lng[2], lat2 = exmapLeaflet$lat[2] ) #%>% 
        #setView(exmapLeaflet$lng[1], exmapLeaflet$lat[1], zoom = 13)
      
          

    })
    
    # show histogram using googleVis
    output$hist <- renderGvis(
      gvisHistogram(cb_df[,input$selected, drop=FALSE]))
    
    output$table <- DT::renderDataTable({
      datatable(cb_station_df[,c(1,2,3,9,4,5,6,17)], rownames=FALSE) %>% 
        formatStyle("id",#input$selected,  
                    background="skyblue", fontWeight='bold')
      # Highlight selected column using formatStyle
    })
    
    #top output boxes
    output$station <- renderInfoBox({
      #get available bikes / docks, status value 
      station_info <- filter(cb_station_df,stationName == input$selected[1]) %>% select(id, stationName, availableBikes, availableDocks, totalDocks)
      bike_station <- paste0("Bike Station: ",station_info$stationName)
 
      station_values <- HTML(paste0("<hr>Bikes: ", ifelse(as.integer(station_info$availableBikes) < 5,
                                                     html_font_color(station_info$availableBikes,"red"), #do red font if lower than threshold
                                                     html_font_color(station_info$availableBikes,"green")),
                               " / Docks: ", ifelse(as.integer(station_info$availableDocks) < 5,
                                                    html_font_color(station_info$availableDocks,"red"),
                                                    html_font_color(station_info$availableDocks,"green")),
                               " / Total Docks: ", station_info$totalDocks
      ))
      max_state <- input$selected
      infoBox(bike_station, station_values, icon = icon("fa-map-marker"))
    })
    output$destination <- renderInfoBox({
      #min_value <- filter(cb_station_df,stationName == input$selected) %>% select(Bikes = availableBikes) #place holder
      #min_state <- input$selected
      station_info <- filter(cb_station_df,stationName == input$selected[2]) %>% select(id, stationName, availableBikes, availableDocks, totalDocks)
      bike_station <- paste0("Bike Destination: ",station_info$stationName)
      
      station_values <- HTML(paste0("<hr>Bikes: ", ifelse(as.integer(station_info$availableBikes) < 5,
                                                          html_font_color(station_info$availableBikes,"red"), #do red font if lower than threshold
                                                          html_font_color(station_info$availableBikes,"green")),
                                    " / Docks: ", ifelse(as.integer(station_info$availableDocks) < 5,
                                                         html_font_color(station_info$availableDocks,"red"),
                                                         html_font_color(station_info$availableDocks,"green")),
                                    " / Total Docks: ", station_info$totalDocks
      ))
      infoBox(bike_station, station_values, icon = icon("fa-compass"))
    })
    output$avgBox <- renderInfoBox(
      infoBox(paste("AVG. Duration in Minutes:", "Btwn 2 Locations"),
              #filter(cb_station_df,stationName == input$selected) %>% select(Bikes = availableBikes),
              (data.json$routes[[1]]$duration / 60),
              icon = icon("calculator"), fill = TRUE))
})