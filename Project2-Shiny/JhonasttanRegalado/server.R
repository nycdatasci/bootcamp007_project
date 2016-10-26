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


shinyServer(function(input, output){

    output$map <- renderLeaflet({
      # get leaflet coordinates
      #validate(
      #  need(length(input$selected) > 0, "Select a minimum of two addresses to render map...")
      #)
      
      if (length(input$selected) == 2) {
      
        leaflet_info <- get_coordinates(input$selected)
  
        leaflet(data = leaflet_info$ExmapLeaflet) %>% 
          addTiles(urlTemplate = tile_layer) %>% 
          addPopups(leaflet_info$ExmapLeaflet, lat = leaflet_info$ExmapLeaflet$lat,
                    lng = leaflet_info$ExmapLeaflet$lng, popup = as.character(leaflet_info$ExmapLeaflet$station.name)) %>%
          addPolylines(.,noClip=TRUE,lng = leaflet_info$Poly_points$lng,lat = leaflet_info$Poly_points$lat,color="blue", 
                       popup = paste0("Avg Time: ",round(leaflet_info$Data.json$routes[[1]]$duration/60,,integer = 2))) %>%
           fitBounds(lng1 = leaflet_info$ExmapLeaflet$lng[1],lat1 = leaflet_info$ExmapLeaflet$lat[1], 
                    lng2 = leaflet_info$ExmapLeaflet$lng[2], lat2 = leaflet_info$ExmapLeaflet$lat[2] )
      } else if (length(input$selected) < 1 ) {
        
        leaflet_info <- get_all_markers()
        
        #popup_info <- HTML(paste0(leaflet_info$stationName,
        #                     "<br>Bikes: ", leaflet_info$availableBikes, " / Docks: ", 
        #                     leaflet_info$availableDocks, " / Total Docks: ", leaflet_info$totalDocks))
        
        leaflet(data = leaflet_info) %>% 
          addTiles(urlTemplate = tile_layer) %>% 
          addMarkers(popup = paste0("Station: ", leaflet_info$stationName,
                                         "<br>Bikes: ", leaflet_info$availableBikes, " / Docks: ", 
                                         leaflet_info$availableDocks, " / Total Docks: ", leaflet_info$totalDocks)) %>% 
          setView(lng = leaflet_info$lng[1],lat = leaflet_info$lat[1], zoom = 12)#, 
        
      } else {
        
        leaflet_info <- get_markers(input$selected)
        
        leaflet(data = leaflet_info) %>% 
          addTiles(urlTemplate = tile_layer) %>% 
          addMarkers(popup = paste0("Station: ", leaflet_info$stationName,
                                    "<br>Bikes: ", leaflet_info$availableBikes, " / Docks: ", 
                                    leaflet_info$availableDocks, " / Total Docks: ", leaflet_info$totalDocks)) %>% 
          setView(lng = leaflet_info$lng[1],lat = leaflet_info$lat[1], zoom = 15)
        
      }

    })
    

    output$gauge <-  renderGvis(
                        gvisGauge(cb_station_gauge, 
                        options=list(min=0, max=70, greenFrom=20,
                                     greenTo=70, yellowFrom=10, yellowTo=20,
                                     redFrom=0, redTo=10, width=1000, height=30000))
                        )
    
    output$table <- DT::renderDataTable({
      datatable(cb_station_df[,c(1,2,3,9,4,5,6,17)], rownames=FALSE) %>% 
        formatStyle("id",#input$selected,  
                    background="skyblue", fontWeight='bold')
      # Highlight selected column using formatStyle
    })
    
    #top output boxes
    output$station <- renderInfoBox({
      validate(
        need(length(input$selected) > 0, "Select a minimum of two addresses to show counts...")
      )
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
      validate(
        need(length(input$selected) == 2, "Select two addresses to show Destination details...")
      )
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
              (travel_duration / 60),
              icon = icon("calculator"), fill = TRUE))
})