#
library(shiny)
library(leaflet)
library(RColorBrewer)
library(scales)
library(lattice)
library(dplyr)
site <- readRDS('site')
working <- readRDS('working')
filteredData <- site
r_colors <- rgb(t(col2rgb(colors()) / 255))
names(r_colors) <- colors()


ui <- bootstrapPage(
  tags$head(tags$style(HTML("body {width:100%;height:100%}; 
#controls {
  background-color:rgba(255,255,255,0.5);
  padding: 0 20px 20px 20px;
  cursor: move;
  zoom: 0.9;
}
"))),
  uiOutput("leaf"),
  absolutePanel(draggable = FALSE, 
                top = 10, 
                right = "20%",
                titlePanel("Superfund Sites"),
                absolutePanel( id = 'controls', 
                               draggable = TRUE,
                               sliderInput('dateRange', 
                                           width = "100%",
                                           min = range(site$Listed)[1], 
                                           max = range(site$Listed)[2],value = c(as.Date("1983-07-20", format = '%Y-%m-%d'),as.Date("2000-07-20", format = '%Y-%m-%d')),
                                           dragRange = TRUE, label = "Range of Date Listed"),
                               checkboxInput('active','Active Sites', FALSE),
                               actionButton("reset_button", "Reset view"))
  )
  #tableOutput('table')

)



server <- shinyServer(function(input, output, session) {
  output$leaf=renderUI({
    leafletOutput('mymap',height = 1000)
  })
  output$mymap <- renderLeaflet({
    if(input$active == TRUE){filteredData <- filter(site, is.na(site$Completed))}
    filteredData <- filter(filteredData, filteredData$Listed > input$dateRange[1], filteredData$Listed < input$dateRange[2] )
    leaflet() %>%
      addTiles(
        urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
        attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>'
      ) %>%
      setView(lng = -93.85, lat = 37.45, zoom = 4) %>%
      addMarkers(data = filteredData, 
                 lng = ~Longitude, 
                 lat = ~Latitude, 
                 layerId = filteredData$ID,
                 popup = paste0(filteredData$Name,'<br/>',filteredData$Reason),
                 clusterOptions = markerClusterOptions())
  })
  observe({
    input$reset_button
    leafletProxy("mymap") %>% setView(lat = 37.45, lng = -93.85, zoom = 4)
  })
  
  observe({
    click <<- input$mymap_marker_click
    print(click$id)
    #contams <- filter(select(working, c( Contaminant , Environment , Chem_type )),working$ID == click$id )
    #output$table <- renderDataTable(contams)
                                      

              })
})
shinyApp(ui, server)