library(shiny)

ui <- fluidPage(
  sidebarLayout(
    sidebarPanel(
      fluidRow(
        column(6, actionButton('addFilter', 'Add filter')),
        offset = 6
      ),
      tags$hr(),
      tags$div(id = 'placeholderAddRemFilt'),
      tags$div(id = 'placeholderFilter'),
      width = 4 # sidebar
    ),
    mainPanel(
      htmlOutput('table')
      #tableOutput('data')
    )
  )
)

server <- function(input, output,session) {
  filter <- character(0)
  
  makeReactiveBinding("aggregFilterObserver")
  aggregFilterObserver <- list()
  
  observeEvent(input$addFilter, {
    add <- input$addFilter
    filterId <- paste0('Filter_', add)
    colfilterId <- paste0('Col_Filter_', add)
    rowfilterId <- paste0('Row_Filter_', add)
    removeFilterId <- paste0('Remove_Filter_', add)
    headers <- names(mtcars)
    insertUI(
      selector = '#placeholderFilter',
      ui = tags$div(id = filterId,
                    actionButton(removeFilterId, label = "Remove filter", style = "float: right;"),
                    selectInput(colfilterId, label = NULL, choices = as.list(headers), selected = 1),
                    sliderInput(rowfilterId, label = "Select values", min=0, max=100, value=c(0, 100))
      )
    )
    
    observeEvent(input[[colfilterId]], {

      col <- input[[colfilterId]]
      values <- as.list(unique(mtcars[col]))[[1]]
      
      min_val = min(values)
      max_val = max(values)
      
      updateSliderInput(session, rowfilterId, min=min_val, max=max_val, value=c(min_val, max_val))
      
      aggregFilterObserver[[filterId]]$col <<- col
      aggregFilterObserver[[filterId]]$rows <<- NULL
    })
    
    observeEvent(input[[rowfilterId]], {
      rows <- input[[rowfilterId]]
      aggregFilterObserver[[filterId]]$rows <<- rows
    })
    
    observeEvent(input[[removeFilterId]], {
      removeUI(selector = paste0('#', filterId))
      
      aggregFilterObserver[[filterId]] <<- NULL
      
    })
  })
  
  output$data <- renderTable({
    
    dataSet <- mtcars
    
    invisible(lapply(aggregFilterObserver, function(filter){
      
      min = filter$rows[1]
      max = filter$rows[2]
      dataSet <<- dataSet[which(dataSet[[filter$col]] >= min & dataSet[[filter$col]] <= max), ]
    }))
    dataSet
  })
  
  output$table = renderGvis({
    dataSet <- mtcars
    print("re-rendering")
    invisible(lapply(aggregFilterObserver, function(filter){
      
      min = filter$rows[1]
      max = filter$rows[2]
      dataSet <<- dataSet[which(dataSet[[filter$col]] >= min & dataSet[[filter$col]] <= max), ]
    }))
    
    table = gvisTable(dataSet,
              options=list(title="Filtered Playlist"))
    return(table)
  })
}

shinyApp(ui = ui, server = server)
