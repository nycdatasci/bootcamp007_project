ui <- fluidPage(
  p("The checkbox group controls the select input"),
  checkboxGroupInput("inCheckboxGroup", "Input checkbox",
                     c("Item A", "Item B", "Item C")),
  selectInput("inSelect", label = "Select input",
              choices = c("Item A", "Item B", "Item C"))
)

server <- function(input, output, session) {
  observe({
    x <- input$inCheckboxGroup
    
    # Can use character(0) to remove all choices
    if (is.null(x))
      x <- character(0)
    
    # Can also set the label and select items
    updateSelectInput(session, "inSelect",
                      label = paste("Select input label", length(x)),
                      choices = x)
  })
}

shinyApp(ui, server)