#install.packages("googleVis")
#install.packages("DT")
library(DT)
library(shiny)
library(googleVis)


shinyServer(function(input, output){
  # show map using googleVis

  
  output$map <- renderGvis({
    gvisGeoChart(country_stat, "country.name", input$selected,
                 options=list(region="world", displayMode="regions", 
                              resolution="countries",
                              width="auto", height="auto",
                              projection="kavrayskiy-vii"))
    # using width="auto" and height="auto" to
    # automatically adjust the map size
  })
  
  # plot(gvisMotionChart(country_stat, "Satisfied", "Dissatisfied", options = list(width = 500, height = 350)))
  
  df = select(country_stat, country.name, Satisfied, Dissatisfied)
  output$bar <- renderGvis({
    gvisBarChart(df, xvar = "country.name", yvar = c("Satisfied", "Dissatisfied"),
                 options = list(title = "National Economy Optimism", height="1600px"))
  })
  
  
  # show histogram using googleVis
  output$hist <- renderGvis(
    gvisHistogram(country_stat[,input$selected, drop=FALSE]))
  
  # show data using DataTable
  output$table <- DT::renderDataTable({
    datatable(
      caption = htmltools::tags$caption(
        style = 'caption-side: bottom; text-align: center;',
        "Table 1: ", htmltools::em("National and Economic Conditions.")),
      country_stat, rownames=FALSE) %>%
      formatStyle(input$selected,  
                  background="skyblue", fontWeight='bold')
    # Highlight selected column using formatStyle
  })
  
  
  
  # show statistics using infoBox
  output$maxBox <- renderInfoBox({
    max_value <- max(country_stat[,input$selected])
    max_country <- 
      country_stat$country.name[country_stat[,input$selected]==max_value]
    infoBox(max_country, max_value, icon = icon("thumbs-up"), color = "green", fill = TRUE)
  })
  output$minBox <- renderInfoBox({
    min_value <- min(country_stat[,input$selected])
    min_country <- 
      country_stat$country.name[country_stat[,input$selected]==min_value]
    infoBox(min_country, min_value, icon = icon("thumbs-down"), color = "red", fill = TRUE)
  })
  output$avgBox <- renderInfoBox(
    infoBox(paste("AVG.", input$selected),
            mean(country_stat[,input$selected]), 
            icon = icon("fa fa-key"), fill = TRUE)) 
  
  
  
})
