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
      #capture waypoints
      conUrl <- "https://api.mapbox.com/directions/v5/mapbox/cycling/-73.98,40.73;-73.97,40.75?geometries=geojson&continue_straight=true&access_token=pk.eyJ1IjoiamhvbmFzdHRhbiIsImEiOiJFLTAzeVVZIn0.mwAAfKtGwv3rs3L61jz87A"
      
      con <- url(conUrl)  
      data.json <- fromJSON(paste(readLines(con), collapse=""))
      close(con)
      
      poly_points <- data.frame(matrix((unlist(data.json$routes[[1]]$geometry$coordinates)),length(unlist(data.json$routes[[1]]$geometry$coordinates)),2,2))
      names(poly_points) <- c("lng","lat")
      
      #capture avg ride time from dataset
      oneRow <- cb_df_avg_trip_duration[1,c("start.station.name","start.station.latitude","start.station.longitude","end.station.name","end.station.latitude","end.station.longitude")]
      tempMatrix <- oneRow %>% matrix(2,3,2)
      exmapLeaflet <- as.data.frame(tempMatrix)
      names(exmapLeaflet)  <- c("station.name","lat","lng")
      exmapLeaflet$lat <- as.numeric(exmapLeaflet$lat)
      exmapLeaflet$lng <- as.numeric(exmapLeaflet$lng)
      
      #complete coordinates
      poly_points <- rbind(poly_points, exmapLeaflet[2,c('lng','lat')])
      
      #generate map
      leaflet(data = exmapLeaflet) %>% 
        addTiles(urlTemplate = tile_layer) %>% 
        addPopups(exmapLeaflet, lat = exmapLeaflet$lat,lng = exmapLeaflet$lng, popup = as.character(exmapLeaflet$station.name)) %>%
        addPolylines(lng = poly_points$lng,lat = poly_points$lat,color="green", popup = paste0("Avg Time: ",round(data.json$routes[[1]]$duration/60,,integer = 2))) %>% 
        fitBounds(lng1 = exmapLeaflet$lng[1],lat1 = exmapLeaflet$lat[1], 
                  lng2 = exmapLeaflet$lng[2], lat2 = exmapLeaflet$lat[2] )
          

    })
    
    # show histogram using googleVis
    output$hist <- renderGvis(
      gvisHistogram(cb_df[,input$selected, drop=FALSE]))
    
    output$table <- DT::renderDataTable({
      datatable(cb_df, rownames=FALSE) %>% 
        formatStyle(input$selected,  
                    background="skyblue", fontWeight='bold')
      # Highlight selected column using formatStyle
    })
    
    #top output boxes
    output$maxBox <- renderInfoBox({
      max_value <- max(cb_df_avg_trip_duration[,input$selected])
      max_state <- 
        cb_df_avg_trip_duration$start.station.name[cb_df_avg_trip_duration[,input$selected]==max_value]
      infoBox(max_state, max_value, icon = icon("hand-o-up"))
    })
    output$minBox <- renderInfoBox({
      min_value <- min(cb_df_avg_trip_duration[,input$selected])
      min_state <- 
        cb_df_avg_trip_duration$start.station.id[cb_df_avg_trip_duration[,input$selected]==min_value]
      infoBox(min_state, min_value, icon = icon("hand-o-down"))
    })
    output$avgBox <- renderInfoBox(
      infoBox(paste("AVG.", input$selected),
              mean(cb_df_avg_trip_duration[,input$selected],rm.na=TRUE), 
              icon = icon("calculator"), fill = TRUE))
})