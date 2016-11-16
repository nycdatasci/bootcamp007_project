bootstrapPage(
  
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