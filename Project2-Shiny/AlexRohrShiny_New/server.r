source('calcs.r')
shinyServer(function(input, output) {
  # a large table, reactive to input$show_vars
  output$mytable1 = renderDataTable({
    library(ggplot2)
    Reviews[, input$show_vars, drop = FALSE]
  })
  # sorted columns are colored now because CSS are attached to
  #them
  output$mytable2 = renderDataTable({
    mtcars
  }, options = list(bSortClasses = TRUE))
  # customize the length drop-down menu; display 5 rows per page
  #by default
  output$mytable3 = renderDataTable({
    iris
  }, options = list(aLengthMenu = c(5, 30, 50), iDisplayLength =
                      5))
})