#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  

 queryData <- eventReactive( input$search.button,{
   query.df <- queryAPI(input$search.player, input$year)
   
 }) 
 
 # does it have to be separate?
 queryData2 <- eventReactive( input$search.button2,{
   query.df2 <- queryAPI(input$search.player2, input$year)
   
 }) 
  
 
 # default stat by position. is it running query Data twice?
 stats <- reactiveValues(stat = 'RushYards')  
 observeEvent(input$search.button, { stats$stat <- queryData()$player$default.stat})
 # then go by stat dropdown menu
 observeEvent( input$stats.input, { stats$stat <- input$stats.input})

 
  # use observeEvent and reactive value to change type of plot 
 plot.compare <- reactiveValues(compare = data.frame(), title = 'DEFAULT')
 observeEvent(input$search.button, {
   plot.compare$compare <- queryData()$stats.frame
   plot.compare$title <- stats$stat
   
 })
 observeEvent(input$search.button2, { 
   plot.compare$compare <- inner_join(queryData()$stats.frame, queryData2()$stats.frame, 
                                      by = 'Week', suffix = c('.p1', '.p2'))
   stats$stat <- c(compare.stat.list[[1]][input$stats.input],
                   compare.stat.list[[2]][input$stats.input])
   plot.compare$title <- paste0(paste0(stats$stat[1], ' vs. '), stats$stat[2])
   
   
 })
 observeEvent(input$search.button, {
   output$test.plot <- renderGvis({
   
     gvisBarChart(plot.compare$compare, xvar ='Week', yvar=stats$stat,
                  options = list(title = plot.compare$title))
                      
     
    
   })
 })
  # cat to get only string and no index, quotes
  output$print.name <- renderPrint({cat(queryData()$player$name)})
  output$print.team <- renderPrint({cat(queryData()$player$team)})
  output$print.position <- renderPrint({cat(queryData()$player$position)})
  
  output$print.name2 <- renderPrint({cat(queryData2()$player$name)})
  output$print.team2 <- renderPrint({cat(queryData2()$player$team)})
  output$print.position2 <- renderPrint({cat(queryData2()$player$position)})
  
  
# rip  
#  observeEvent(input$team.name,{
    
    
#    updateSelectInput(inputId = "player.name", "Player Name", input$team.name)
#  })
 
  
  
  # ask for team
  
  # ask for player
  
  
  
  # to get stats from team_logs
  # avg or sum
  
  # look at feats and try to compare players that part should be easy, double everything
  
  
})
