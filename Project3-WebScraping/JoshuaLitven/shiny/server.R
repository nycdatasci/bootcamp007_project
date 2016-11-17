# The server side
server <- function(input, output, session){
  
  # Render an empty leaflet map
  output$map <- renderLeaflet({
    leaflet(data=points) %>% 
      addProviderTiles("Thunderforest.Pioneer") %>% 
      addLegend("bottomleft", pal = domain_palette, values=~domain,
                title = "Domain", opacity=1)
  })
  
  # Get the authors for the current year
  filtered_authors <- reactive({ 
    points[which(years>=input$year - 100 & years<=input$year), ] 
  })
  
  # Add points based on filtered authors
  observe({
    if(nrow(filtered_authors())==0){
      leafletProxy("map") %>% clearShapes()
    }else{
      leafletProxy("map", data = filtered_authors()) %>% 
        clearMarkers() %>%
        addCircleMarkers(radius = 5,
                         label=~name,
                         layerId=~name,
                         labelOptions=labelOptions(),
                         stroke=FALSE,
                         fill=TRUE,
                         fillColor=~domain_palette(domain),
                         fillOpacity=1)
    }
  })
  
  # On author click, update the search value
  observeEvent(input$map_marker_click, {
    p <- input$map_marker_click
    author_name = p$id
    updateSelectInput(session, "search", selected=author_name)
  })
  
  # On similar author click, update the search value
  
  # observe the marker click info and get author id
  data <- reactiveValues(author_name=NULL)
  
  observeEvent(input$map_marker_click, {
    data$author_name <- input$map_marker_click$id
  }
  )
  observeEvent(input$map_click,{
    data$author_name <- NULL
    updateSelectInput(session, "search", selected="")
  })
  
  # Update map markers and view on search changes
  observeEvent(input$search, {
    if(input$search!=""){
      author = subset(points, name==input$search)
      updateSliderInput(session, "year", value=author$birthyear)
      data$author_name = author$name
      leafletProxy("map") %>% 
        setView(lng=author$LON, lat=author$LAT, input$map_zoom) %>% 
        addPopups(lng=author$LON,lat=author$LAT, 
                  paste0(author$name, " (", author$birthyear, ")<br>",
                         author$occupation,
                         "<br><img src=", author$image_url, " style='width:100px'>", 
                         collapse="<br>"))
    }
  })
  
  # Display quotes
  output$quote_text = renderText({
    if(is.null(data$author_name)){
      return("")
    }else{
      author_name = data$author_name
      author_quotes = quotes %>% filter(author==author_name)
      author_quotes = author_quotes$body
      similar_authors = get_similar_authors(author_name)
      return(paste0('"', author_quotes, '"', collapse="<br><br>"))
      #return(paste(similar_authors, collapse="<br>"))
    }
  })
  
  # Display similar authors
  output$similar_authors = renderText({
    if(is.null(data$author_name)){
      return("")
    }else{
      author_name = data$author_name
      similar_authors = subset(points, name %in% get_similar_authors(author_name))
      thinkers_html = paste0(similar_authors$name, " (", similar_authors$birthyear, ")<br>",
                             similar_authors$occupation,
                             "<br><a id='similar_", 1:nrow(similar_authors), "' href='#'><img src=", 
                             similar_authors$image_url, " style='width:50%'></a>", 
                             collapse="<br>")
      return(paste("<h3>Similar Thinkers</h3>", thinkers_html))
    }
  })
  
}