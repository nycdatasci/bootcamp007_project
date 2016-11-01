library(dplyr)
library(shiny)
library(ggplot2)
library(plotly)
library(ggthemes)
library(googleCharts)

shinyServer(function(input, output, session) {
  
  xlim <- reactive({
                  list(
                    min = min(data[, input$indicator]) - min(data[, input$indicator])*0.5,
                    max = max(data[, input$indicator]) + max(data[, input$indicator])*0.5)
            })
  
  
  ylim <- list(min = min(data$Life.Span),
               max = max(data$Life.Span) + 20)
  
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
    df <- data %>%
      filter(Year == input$year) %>%
      select_('CountryName',
             input$indicator,
             'Life.Span',
             'Region',
             'Population') %>%
      arrange(Region)
  })
  
  output$chart <- reactive({
                              # Return the data and options
                              list(data = googleDataTable(yearData()),
                                   options = list(
                                     title = sprintf( paste(input$indicator," vs. Life Span"),
                                                     input$year),
                                     series = series,
                                     fontName = "Source Sans Pro",
                                     fontSize = 13,
                                     # Set axis labels and ranges
                                     hAxis = list(title = input$indicator,
                                                  viewWindow = xlim()),
                                     vAxis = list(title = "Life Span (years)",
                                                  viewWindow = ylim),
                                     colorAxis.legend.position ="bottom",
                                     # The default padding is a little too spaced out
                                     chartArea = list(top = 50, left = 75, height = "80%", width = "75%"),
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
  
  ### plot chart in Trends
 
      output$trend_plot <- renderPlotly({
        plotdata <- data_long%>%filter(CountryName==input$country,
                                       IndicatorName==input$indicator1)
        trend_plot <- ggplot(plotdata, aes(x=Year,y=Value))+
          geom_point(color="#8da0cb")+
          xlab("Year") + 
          ylab(input$indicator1) + 
          geom_smooth(colour ="#fc8d62",size = 0.5, se = F)+
          theme_minimal()+
          ggtitle(paste(input$indicator1,"vs.Year"))
       # print(input$indicator1)
        ggplotly(trend_plot)
      })

      output$hist <- renderPlotly({
        histdata <- data_long%>%filter(Year==input$year1,
                                       IndicatorName==input$indicator1)
        hist <- ggplot(histdata, aes(x=Value)) +
          geom_histogram(fill="#8da0cb")+
          ylab("Count")+
          xlab(input$indicator1) + 
          theme_minimal()+
          ggtitle(paste(input$indicator1,"vs.",input$year1))
        ggplotly(hist)
        
      })
      
    
    output$table <- DT::renderDataTable({
      DT::datatable(data_long)
    })

    })