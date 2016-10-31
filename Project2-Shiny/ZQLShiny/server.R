library(dplyr)
library(shiny)

shinyServer(function(input, output, session) {
  
  xlim <- reactive({
                  list(
                    min = min(data[, input$indicator]) - min(data[, input$indicator])*0.5,
                    max = max(data[, input$indicator]) + max(data[, input$indicator])*0.5)
            })
  
  
  ylim <- list(min = min(data$Life.Expectancy),
               max = max(data$Life.Expectancy) + 20)
  
  # Provide explicit colors for regions, so they don't get recoded when the
  # different series happen to be ordered differently from year to year.
  # http://andrewgelman.com/2014/09/11/mysterious-shiny-things/
  defaultColors <-
    c("#3366cc",
      "#dc3912",
      "#ff9900",
      "#109618",
      "#990099",
      "#0099c6",
      "#dd4477")
  series <- structure(lapply(defaultColors, function(color) {
    list(color = color)
  }),
  names = levels(data$Region))
  
  yearData <- reactive({
    # Filter to the desired year, and put the columns
    # in the order that Google's Bubble Chart expects
    # them (name, x, y, color, size). Also sort by region
    # so that Google Charts orders and colors the regions
    # consistently.
    df <- data %>%
      filter(Year == input$year) %>%
      select_('CountryName',
             input$indicator,
             'Life.Expectancy',
             'Region',
             'Population') %>%
      arrange(Region)
  })
  
  output$chart <- reactive({
                              # Return the data and options
                              list(data = googleDataTable(yearData()),
                                   options = list(
                                     title = sprintf("Sanitation.Facilities vs. life expectancy, %s",
                                                     input$year),
                                     series = series,
                                     fontName = "Source Sans Pro",
                                     fontSize = 13,
                                     # Set axis labels and ranges
                                     hAxis = list(title = "Improved sanitation facilities (% of population with access)",
                                                  viewWindow = xlim()),
                                     vAxis = list(title = "Life expectancy (years)",
                                                  viewWindow = ylim),
                                     # The default padding is a little too spaced out
                                     chartArea = list(top = 50, left = 75, height = "75%", width = "75%"),
                                     # Allow pan/zoom
                                     explorer = list(),
                                     # Set bubble visual props
                                     bubble = list(opacity = 0.4, stroke = "none",
                                       # Hide bubble label
                                       textStyle = list(color = "none")
                                     ),
                                     # Set fonts
                                     titleTextStyle = list(fontSize = 16),
                                     tooltip = list(textStyle = list(fontSize = 12))
                                   ))
                            }) # End of reactive chart
})