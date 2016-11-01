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
library(googleVis)
library(vembedr)
library(htmltools)
library(ggmap)
library(ggplot2)

shinyServer(function(input, output){

    output$map <- renderLeaflet({
      
      if (length(input$selected) == 2) {
      
        leaflet_info <- get_coordinates(input$selected)
        popup_maneuver_info <- get_maneuver_info(leaflet_info$Data.json$routes[[1]]$legs[[1]]$steps)
        popup_message <- HTML(paste0("Avg Time: ",round(leaflet_info$Data.json$routes[[1]]$duration/60,,integer = 2), " mins<br>"),
                                  #   "<ul>", paste0("<li>", popup_maneuver_info, "</li>"), "<ul>")
                              "<ul><li>",
                              paste(popup_maneuver_info,sep = "",collapse = "<li>"),
                              "<ul>")
                              
        
    #print(leaflet_info$Poly_points) << helped trouble shoot the polygon issue
        leaflet(data = leaflet_info$ExmapLeaflet) %>% 
          addTiles(urlTemplate = tile_layer) %>% 
          addMarkers(popup = paste0(c("Station","Destination"), ": ", leaflet_info$ExmapLeaflet$station.name)) %>% 
          #addGeoJSON(leaflet_info$Poly_points,stroke = TRUE,
          #           color = "blue",fill = TRUE,fillColor = "blue", weight = 1,opacity = 1, fillOpacity = 1) %>%
          #addTopoJSON(leaflet_info$Data.json$routes[[1]]$geometry$coordinates) %>% 
          addPolygons(leaflet_info$Poly_points, noClip=FALSE,lng = leaflet_info$Poly_points$longitude,lat= leaflet_info$Poly_points$latitude,color="blue", 
                       popup = popup_message,
                      fill = FALSE) %>%
           fitBounds(lng1 = leaflet_info$ExmapLeaflet$longitude[1],lat1 = leaflet_info$ExmapLeaflet$latitude[1], 
                    lng2 = leaflet_info$ExmapLeaflet$longitude[2], lat2 = leaflet_info$ExmapLeaflet$latitude[2] )
        
      } else {
        
        
        leaflet_info <- get_markers(list(input$selected,input$bikesAvailable,input$docksAvailable))
      
        #print (nrow(leaflet_info))
        if (length(input$manualAddress > 0)) {
          manualCoordinates <- geocode(paste0(input$manualAddress, " Manhattan, NY"))
        leaflet(data = leaflet_info) %>% 
          addTiles(urlTemplate = tile_layer) %>% 
          addMarkers(popup = paste0("Station: ", leaflet_info$stationName,
                                    "<br>Bikes: ", leaflet_info$availableBikes, " / Docks: ",
                                    leaflet_info$availableDocks, " / Total Docks: ", leaflet_info$totalDocks)) %>%
          addCircles(lat = leaflet_info[1:length(input$selected),'latitude'], 
                     lng = leaflet_info[1:length(input$selected),'longitude'],
                     weight = leaflet_info$availableBikes, radius = leaflet_info$availableDocks / input$docksAvailable, 
                     color =  ifelse(leaflet_info$availableBikes >= input$bikesAvailable,"green","red"),
                     #weight = 1, radius = ((leaflet_info$availableBikes + leaflet_info$availableDocks) * 5 ), color =  "black",
                     fillColor = "orange", fillOpacity=0.5, opacity=1) %>%
          #addPolylines(lat = as.numeric(leaflet_info[1:length(input$selected),'latitude']), 
          #           lng = as.numeric(leaflet_info[1:length(input$selected),'longitude'])) %>% 
          #setView(lng = leaflet_info$longitude[1],lat = leaflet_info$latitude[1], zoom = 13)
            setView(lng = manualCoordinates$lon, lat = manualCoordinates$lat, zoom = input$zoom)
          } else {
            leaflet(data = leaflet_info) %>% 
              addTiles(urlTemplate = tile_layer) %>% 
              addMarkers(popup = paste0("Station: ", leaflet_info$stationName,
                                        "<br>Bikes: ", leaflet_info$availableBikes, " / Docks: ",
                                        leaflet_info$availableDocks, " / Total Docks: ", leaflet_info$totalDocks)) %>%
              addCircles(lat = leaflet_info[1:length(input$selected),'latitude'], 
                         lng = leaflet_info[1:length(input$selected),'longitude'],
                         weight = leaflet_info$availableBikes, radius = leaflet_info$availableDocks / input$docksAvailable, 
                         color =  ifelse(leaflet_info$availableBikes >= input$bikesAvailable,"green","red"),
                         #weight = 1, radius = ((leaflet_info$availableBikes + leaflet_info$availableDocks) * 5 ), color =  "black",
                         fillColor = "orange", fillOpacity=0.5, opacity=1) %>%
          setView(lng = -73.976522, lat = 40.7528, zoom = input$zoom)
          
          }
      }

    }) # End of renderleaflet
    
    
    output$gaugeBikes <-  renderGvis(
      
                        gvisGauge(filter(cb_station_bike_gauge, availableBikes >= as.integer(input$bikesAvailable)) %>%  
                                        arrange(desc(availableBikes)), 
                        options=list(min=0, max= max(as.integer(cb_station_df$totalDocks)), greenFrom=15,
                                     greenTo=max(as.integer(cb_station_df$totalDocks)), yellowFrom=5, yellowTo=15,
                                     redFrom=0, redTo=5, width=500, 
                                     height= 30000))# ifelse(input$docksAvailable <=25, 30000, 30000/input$bikesAvailable * 2)))
    
                        
                        ) # End of gaugeBikes
    
    output$gaugeDocks <-  renderGvis(
      gvisGauge(filter(cb_station_dock_gauge, availableDocks >= as.integer(input$docksAvailable)) %>% 
                  arrange(desc(availableDocks)), 
                options=list(min=0, max=max(as.integer(cb_station_df$totalDocks)), greenFrom=15,
                             greenTo=max(as.integer(cb_station_df$totalDocks)), yellowFrom=5, yellowTo=15,
                             redFrom=0, redTo=5, width=500, 
                             height= 30000))#ifelse(input$docksAvailable <=25, 30000, 30000/input$bikesAvailable * 2)))
    ) # End of gaugeDocks
    
    output$table <- DT::renderDataTable({
      datatable(cb_station_df[,c(1,2,3,9,4,5,6,17)], rownames=FALSE) %>% 
        formatStyle("id",#input$selected,  
                    background="skyblue", fontWeight='bold')
      # Highlight selected column using formatStyle
    })
    
    #top output boxes
    output$station <- renderInfoBox({
      validate(
        need(length(input$selected) > 0, "")
      )
      #get available bikes / docks, status value 
      station_info <- filter(cb_station_df,stationName == input$selected[1]) %>% select(id, stationName, availableBikes, availableDocks, totalDocks)
      bike_station <- paste0("Start Station: ",station_info$stationName)
 
      station_values <- HTML(paste0("<hr>Bikes: ", ifelse(as.integer(station_info$availableBikes) < input$bikesAvailable,
                                                     html_font_color(station_info$availableBikes,"red"), #do red font if lower than threshold
                                                     html_font_color(station_info$availableBikes,"green")),
                               " / Docks: ", ifelse(as.integer(station_info$availableDocks) < input$docksAvailable,
                                                    html_font_color(station_info$availableDocks,"red"),
                                                    html_font_color(station_info$availableDocks,"green")),
                               " / Total Docks: ", station_info$totalDocks
      ))
      max_state <- input$selected
      infoBox(bike_station, station_values, icon = icon("arrow-right"))
    })
    output$destination <- renderInfoBox({
      validate(
        need(length(input$selected) == 2, "")
      )

      station_info <- filter(cb_station_df,stationName == input$selected[2]) %>% select(id, stationName, availableBikes, availableDocks, totalDocks)
      bike_station <- paste0("Destination Station: ",station_info$stationName)
      
      station_values <- HTML(paste0("<hr>Bikes: ", ifelse(as.integer(station_info$availableBikes) < input$bikesAvailable,
                                                          html_font_color(station_info$availableBikes,"red"), #do red font if lower than threshold
                                                          html_font_color(station_info$availableBikes,"green")),
                                    " / Docks: ", ifelse(as.integer(station_info$availableDocks) < input$docksAvailable,
                                                         html_font_color(station_info$availableDocks,"red"),
                                                         html_font_color(station_info$availableDocks,"green")),
                                    " / Total Docks: ", station_info$totalDocks
      ))
      infoBox(bike_station, station_values, icon = icon("hand-paper-o"))
    })
    
      
      output$avgBox <- renderInfoBox({
        validate(
          need(length(input$selected) == 2, "")
        )
        
        leaflet_info <- get_coordinates(input$selected)
        travel_duration <- round(leaflet_info$Data.json$routes[[1]]$duration/60,,integer = 2)
        station_values <- HTML(paste("AVG. Travel Time in Minutes<hr>   "))
        
        infoBox(station_values, travel_duration, icon = icon("clock-o")) #, fill = TRUE
        
        })
      
      #output$video <- renderUI({
      #  h2("          Intro Video", br(), tags$video(src="ShinyCitibikeAnalysis.mp4", type="video/mp4", width = "350px", height = "350px", controls="controls"))
      #})
      
      #observeEvent(input$refresh, {
      #  
      #  session$sendCustomMessage(type = 'refreshmessage',
      #                            message = 'NYC Citibike Data has been refreshed')
      #})
        
    
})