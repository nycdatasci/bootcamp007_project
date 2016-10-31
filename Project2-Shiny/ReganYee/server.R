library(DT)
library(shiny)
library(googleVis)
library(scales)
library(rpivotTable)
library(dplyr)

# convert matrix to dataframe
pledged = readRDS("./data/pledged.RDS")

# select certain fields to display
data = pledged %>% select(Name, Goal, Pledged, Backers, Category, City, State, Status)

# total of US
summary_of_Loc = pledged %>% filter(Country=='US', nchar(State) == 2) %>% summarize(count=n())

# summarize by category (for percentage by category)
summary_of_cat = pledged %>% filter(Country=='US', nchar(State) == 2) %>% 
  group_by(Category) %>%
  summarize(Count=n()) %>% 
  mutate(Percentage = percent(Count/summary_of_Loc$count)) %>% 
  arrange(desc(Count/summary_of_Loc$count))

shinyServer(function(input, output){
  
  ## SUMMARY: High level overview of data
  output$sumTable <- DT::renderDataTable({
    datatable(summary_of_cat, rownames=FALSE, options = list(pageLength = 15))
  })
  
  ## BUBBLES: GoogleVis Bubble Chart  
  output$bubbles = renderGvis({
    gvisBubbleChart(
      data %>% filter(State == input$f_location, Status %in% input$f_status),
      idvar = "Name",
      xvar = "Goal",
      yvar = "Pledged",
      colorvar = "Category",
      sizevar = "Backers",
      options = list(
        title = paste0("Kickstarter Projects from ", input$f_location),
        titleTextStyle = "{fontName:'DejaVu Sans Mono for Powerline',
                           fontSize:25}",
        width = 800,
        height = 600,
        bubble = "{textStyle:{color: 'none'}}",
        vAxes = "[{title:'Pledged',
                   format:'#,###',
                   textPosition: 'out'}]",
        hAxes = "[{title:'Goal',textPosition: 'out'}]",
        explorer.actions = 'dragToZoom',
        animation.duration = 1
      )
    )
  })
  
  # DATA: show data using DataTable
  output$table <- DT::renderDataTable({
    datatable(data, rownames=FALSE)
  })
  
  
  ## CROSSTAB: Show data in crosstab of categories
  output$pivotSum = renderRpivotTable(
    rpivotTable(
      data %>% filter(State == input$f_location, Status %in% input$f_status),
      rows = "State",
      col = "Category",
      aggregatorName = "Count as Fraction of Rows",
      vals = "name",
      rendererName = "Table Barchart",
      width = "10%",
      height = "10px"
    )
  )

})
