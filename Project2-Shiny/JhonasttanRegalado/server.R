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
      
      if (length(input$selected) == 2) {
      
        leaflet_info <- get_coordinates(input$selected)
  
        leaflet(data = leaflet_info$ExmapLeaflet) %>% 
          addTiles(urlTemplate = tile_layer) %>% 
          addMarkers(popup = paste0(c("Station","Destination"), ": ", leaflet_info$ExmapLeaflet$station.name)) %>% 
          addPolylines(.,noClip=TRUE,lng = leaflet_info$Poly_points$lng,lat = leaflet_info$Poly_points$lat,color="blue", 
                       popup = paste0("Avg Time: ",round(leaflet_info$Data.json$routes[[1]]$duration/60,,integer = 2), " mins")) %>%
           fitBounds(lng1 = leaflet_info$ExmapLeaflet$lng[1],lat1 = leaflet_info$ExmapLeaflet$lat[1], 
                    lng2 = leaflet_info$ExmapLeaflet$lng[2], lat2 = leaflet_info$ExmapLeaflet$lat[2] )
        
      } else {
        
        
        leaflet_info <- get_markers(list(input$selected,input$bikesAvailable,input$docksAvailable))
      
        #print (nrow(leaflet_info))
        
        leaflet(data = leaflet_info) %>% 
          addTiles(urlTemplate = tile_layer) %>% 
          addMarkers(popup = paste0("Station: ", leaflet_info$stationName,
                                    "<br>Bikes: ", leaflet_info$availableBikes, " / Docks: ",
                                    leaflet_info$availableDocks, " / Total Docks: ", leaflet_info$totalDocks)) %>%
          addCircles(lat = leaflet_info[1:length(input$selected),'lat'], 
                     lng = leaflet_info[1:length(input$selected),'lng'],
                     #weight = (leaflet_info$availableBikes/leaflet_info$availableDocks), radius = ((leaflet_info$availableBikes + leaflet_info$availableDocks) * 5 ), color =  "black",
                     weight = 1, radius = ((leaflet_info$availableBikes + leaflet_info$availableDocks) * 5 ), color =  "black",
                     fillColor = "orange", fillOpacity=0.5, opacity=1) %>%
          #addPolylines(lat = as.numeric(leaflet_info[1:length(input$selected),'lat']), 
          #           lng = as.numeric(leaflet_info[1:length(input$selected),'lng'])) %>% 
          setView(lng = leaflet_info$lng[1],lat = leaflet_info$lat[1], zoom = 13)
        
      }

    }) # End of renderleaflet
    
    

    output$gaugeBikes <-  renderGvis(
                        gvisGauge(filter(cb_station_bike_gauge, availableBikes >= as.integer(input$bikesAvailable)) %>%  
                                        arrange(desc(availableBikes)), 
                        options=list(min=0, max= max(as.integer(cb_station_df$totalDocks)), greenFrom=15,
                                     greenTo=max(as.integer(cb_station_df$totalDocks)), yellowFrom=5, yellowTo=15,
                                     redFrom=0, redTo=5, width=1000, 
                                     height= ifelse(input$bikesAvailable <=25, 30000, 30000/input$bikesAvailable)))
                        ) # End of renderGivs
    
    output$gaugeDocks <-  renderGvis(
      gvisGauge(filter(cb_station_dock_gauge, availableDocks >= as.integer(input$docksAvailable)) %>% 
                  arrange(desc(availableDocks)), 
                options=list(min=0, max=max(as.integer(cb_station_df$totalDocks)), greenFrom=15,
                             greenTo=max(as.integer(cb_station_df$totalDocks)), yellowFrom=5, yellowTo=15,
                             redFrom=0, redTo=5, width=1000, 
                             height= ifelse(input$docksAvailable <=25, 30000, 30000/input$bikesAvailable)))
    ) # End of renderWrite
    
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
      bike_station <- paste0("Start Station: ",station_info$stationName)
 
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

      station_info <- filter(cb_station_df,stationName == input$selected[2]) %>% select(id, stationName, availableBikes, availableDocks, totalDocks)
      bike_station <- paste0("Destination Station: ",station_info$stationName)
      
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