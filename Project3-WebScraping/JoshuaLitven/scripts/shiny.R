library(shiny)
library(dplyr)
library(leaflet)
#library(htmltools)

# Load in the data
LOAD_DATA = TRUE
if(LOAD_DATA){
  setwd('~/Courses/nyc_data_science_academy/projects/web_scraping/data/cleaned_data')
  pantheon = read.csv('pantheon.csv', stringsAsFactors=FALSE)
  quotes = read.csv('quotes.csv', stringsAsFactors=FALSE)
  load('similarity_matrix.RData') # loads similarity_matrix
}

# Get the top n most similar authors
# author_name - string
# n - number of similar authors
# returns - names of authors
get_similar_authors = function(author_name, n=10){
  most_similar = sort(similarity_matrix[author_name, ], decreasing=TRUE)
  most_similar = most_similar[-1] # exclude top element
  return(names(most_similar[1:n]))
}

# Only load complete data for now
points = pantheon %>% filter(name %in% quotes$author)
points = points[complete.cases(points$LAT), ]

# Jitter the lon and lat as many points are the same
points$LON = jitter(points$LON, 5)
points$LAT = jitter(points$LAT, 5)

# Set the domain to a factor for coloring
points$domain = as.factor(points$domain)
domain_palette = colorFactor("RdYlBu", points$domain)

# Get the birth year
years = points$birthyear

# The ui page
ui <- bootstrapPage(
  
  # Set style of page to full screen
  tags$style(type="text/css", "html, body {width:100%;height:100%}"),
  
  # Leaflet map
  leafletOutput("map", width="100%", height="100%"),
  
  # Year
  absolutePanel(top=10, right=10,
    sliderInput("year", "Year", 
                min=min(years), max=max(years), 
                value=1, step=1, sep="")
  ),
  
  # Quotes and search
  absolutePanel(fixed=TRUE, top = 0, left = 0, right = 0, bottom = 0, width = '50%', height = '175px',
                style = "margin: auto; margin-bottom: 58px; left='50%'; text-align: center;",
                tags$div(style="margin-left: 25%; margin-right: 25%;",
                  selectizeInput("search", label=NULL, width="100%", selected = NULL,
                                 choices=c("", points$name), options=list(placeholder = "Author Name"))),
                htmlOutput("quote_text", width="100%"),
                tags$head(tags$style("#search{margin: auto}")),
                tags$head(tags$style("#quote_text{font-style: italic; overflow:scroll; height:100%;
                                    border: 2px solid; border-radius: 5px; background-color: white}"))
                ),
  
  # Similar authors
  absolutePanel(fixed=TRUE, top = 0, right = 0, bottom = 0, width = '20%', height = '100%',
                style = "margin: auto; margin-top: 100px; text-align: center;",
                htmlOutput("similar_authors", width="100%"),
                tags$head(tags$style("#similar_authors{font-style: italic; overflow:scroll; height:100%;
                                    border: 2px solid; border-radius: 5px; background-color: white}"))
                )

)


# The server side
server <- function(input, output, session){
  
  # Render an empty leaflet map
  output$map <- renderLeaflet({
    # leaflet() %>% addProviderTiles("Stamen.Watercolor")
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

shinyApp(ui, server)
