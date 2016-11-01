library(leaflet)
library(RColorBrewer)
library(scales)
library(lattice)
library(dplyr)
library(googleVis)


# Leaflet bindings are a bit slow; for now we'll just sample to compensate
#set.seed(100)
#zipdata <- allzips[sample.int(nrow(allzips), 10000),]
# By ordering by centile, we ensure that the (comparatively rare) SuperZIPs
# will be drawn last and thus be easier to see
#zipdata <- zipdata[order(zipdata$centile),]

lat <- c(-36.852, -36.952)
lon <- c(174.768, 174.9)

function(input, output, session) {
  
## Interactive Map ##
  
  #sizeBy <- input$size  
  #radius <- nursing[[sizeBy]] / max(nursing[[sizeBy]]) * 15119
  
  # Precalculate the breaks we'll need for the two histograms
#  centileBreaks <- hist(plot = FALSE, allzips$centile, breaks = 20)$breaks
 
  homesInBounds <- reactive({
    if (is.null(input$map_bounds))
      return(nursing[FALSE,])
    bounds <- input$map_bounds
    latRng <- range(bounds$north, bounds$south)
    lngRng <- range(bounds$east, bounds$west)
    
    subset(nursing,
           lat >= latRng[1] & lat <= latRng[2] &
             lon >= lngRng[1] & lon <= lngRng[2])
  }) 
  output$histCentile <- renderPlot({
    # If no zipcodes are in view, don't plot
   if (nrow(homesInBounds()) == 0)
     return(NULL)
    
    hist(homesInBounds()$Overall.Rating,
     #   breaks = centileBreaks,
         main = "Overall grades (visible homes)",
         xlab = "Overall Grade",
    #     xlim = range(nursing$Overall.Rating, na.rm = T),
         col = 'steelblue',
         border = 'white')
  })
  
  output$map <- renderLeaflet({
    map <- leaflet() %>%
      addProviderTiles("CartoDB.Positron") %>%
      addTiles(urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
               attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>') %>%
      setView(lng = -93.85, lat = 37.45, zoom = 4) %>%
 #    addMarkers(lng=nursing$lon, lat=nursing$lat) %>%
      addCircleMarkers(
        lng = nursing$lon, 
        lat = nursing$lat,
        radius = nursing$Number.of.Residents.in.Certified.Beds / max(nursing$Number.of.Residents.in.Certified.Beds)*15,
      # color = ~pal(type), 
      # color = ~factpal(nursing$Overall.Rating),
        color = colorFactor("RdYlGn", levels = unique(nursing$Overall.Rating)),
    stroke = FALSE, fillOpacity = 0.2
      )
     # addCircles(~nursing$lon, ~nursing$lat, radius=radius, layerId=~zipcode,
      #           stroke=FALSE, fillOpacity=0.4, fillColor=pal(colorData)) %>%
  #    addLegend("bottomleft", pal=pal, values=colorData, title=colorBy,
   #             layerId="colorLegend")
    
#    previewColors(colorFactor("RdYlGn", domain = NULL), LETTERS[1:5])
    map
  })
  
   
  
  output$gmap <- renderGvis({
    gvisGeoChart(nursinghomes3, "state.name", input$selected,
                 options=list(region="US", displayMode="regions", 
                              resolution="provinces",
                              width="auto", height="auto"))
    # using width="auto" and height="auto" to
    # automatically adjust the map size
  })
  
 # Fines = "Total.Amount.of.Fines.in.Dollars" 
  
#  output$activelist<-renderGvis({
 #   if(input$listformat=="Count"){
  #    df<-table(listdata()$neighbourhood_group_cleansed,listdata()$room_type)
   #   df<-as.data.frame.matrix(df)
    #  df$neighbour<-rownames(df)}
#    if(input$listformat=="Fines") {
 #     df <- as.data.frame(with(listdata2(), tapply(pct, list(neighbour, room_type) , I)))
  #    df$neighbour<-rownames(df)
   # }
  
#  barInput <- reactive({
 #   switch(input$barchart,
  #         "rock" = "Average nursing home rating",
   #        "pressure" = "Number of nursing homes")
  #})
  

  output$bar <- renderGvis(
    gvisBarChart(nursinghomes3[,(input$selected), drop=F]))
  
  datasetInput <- reactive({
    gvisBarChart(nursinghomes3[,(input$selected), drop=F])
  })
  output$bar2 <- renderGvis({datasetInput()})
  
  datasetInput2 <- reactive({
    gvisBubbleChart(nursinghomes3, 
                    xvar="Average nursing home rating", yvar= input$selected)})
  output$view <- renderGvis({datasetInput2()})
  
  
  output$countybar <- renderGvis(
    gvisBubbleChart(nursinghomes3, xvar= "Average nursing home rating", yvar = input$selected,
                    options=list(width="auto", height="auto")
  ))

  bubbleInput <- reactive({
    gvisBubbleChart(nursinghomes3, 
                    xvar="Average nursing home rating", yvar= input$selected,
    options=list(width="auto", height="auto"))})
  output$bubble <- renderGvis({bubbleInput()})
  
  #data table output
  myOptions <- reactive({
    list(
      page=ifelse(input$pageable==TRUE,'enable','disable'),
      pageSize=input$pagesize
    )
  })
  output$myTable <- renderGvis({
    gvisTable(nursinghomesbycounty,options=myOptions())         
  })

  

  # show histogram using googleVis  
 output$hist <- renderGvis(
  gvisHistogram(nursinghomes3[,input$selected, drop=FALSE]))
  
##  output$bar <- renderGvis(
##    gvisBarChart(nursinghomes3))
  
  
  
  # (deleted the histogram and scatterplot overlay)
  
  # This observer is responsible for maintaining just the color
  # Size of bubble determined by number of residents in facility

 #     colorData <- nursinghomes2$Overall.Rating
#      pal <- colorBin("Spectral", colorData, 7, pretty = FALSE)
 #   
  #    radius <- nursinghomes2$Size / max(nursinghomes2$Size) * 15644
    
   # leafletProxy("map", data = nursinghomes2) %>%
    #  clearShapes() %>%
     # addCircles(~longitude, ~latitude, radius=radius, layerId=~zipcode,
    #             stroke=FALSE, fillOpacity=0.4, fillColor=pal(colorData)) %>%
  #    addLegend("bottomleft", pal=pal, values=colorData, title=colorBy,
#                layerId="colorLegend")
  }
