#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinydashboard)

# Define UI for application that draws a histogram
dashboardPage(

  dashboardHeader(
    title= ('NFL Search!')
  ),
  
  dashboardSidebar(
    
    # Menu to select which group of stats to access
    sidebarMenu(
      menuItem("Players", tabName = 'players'),
      menuItem("Teams", tabName = 'teams')
    )
    
    # ???
    # sidebarPanel(
    #   
    #   
    # )
    
    
  ),
  
  dashboardBody(
    # tabItems (   tabItem(  ), ) and link with Sidebarmenu for tab selection
    tabItems(
      tabItem(tabName = 'players',
              fluidRow(
              #column and width and stuffif you really wanted to  
                box(width = 4,
                  #title, width (each row is 12, so 1-12), $solidHeader=T/F
                  # height can be too but height must be in pixels(200, 300 etc.)
                  selectInput(inputId="year", "Year", years.available),
                  
                  
                 # search box for player search, ideally with autocomplete
                 # insert lookup table for autocomplete
                 
                  sidebarSearchForm(textId = "search.player", buttonId = "search.button",
                                    label = "Search Player"),
                 
                 sidebarSearchForm(textId = "search.player2", buttonId = "search.button2",
                                   label = "Compare"),
                 
                 selectInput(inputId = 'stats.input', "Select Stat:", stat.list),
                 
                 selectInput(inputId = 'chart.input', "Select Chart Type:", chart.type)
                 
                 
                 
                ),
                
                
                # status goes by color
                box(title = "StatChart", status = "primary",
                  width = 8, height = 500,
                  
                  htmlOutput("test.plot")
                )
              ),
              
              fluidRow(
                

                
                box(
                  
                  # text box with basic stats
                  # Name, Number, Team, Years, Position, 
                  # And then maybe basic total stats, imitate online?
                  # Number, Years of Experience missing for football
                  textOutput(outputId = 'print.name'),
                  textOutput(outputId = 'print.team'),
                  textOutput(outputId = 'print.position')
                  
                  
                ),
                
                box(
                  
                  # text box with basic stats
                  # Name, Number, Team, Years, Position, 
                  # And then maybe basic total stats, imitate online?
                  # Number, Years of Experience missing for football
                  textOutput(outputId = 'print.name2'),
                  textOutput(outputId = 'print.team2'),
                  textOutput(outputId = 'print.position2')
                  
                  
                )
              )
              
              
              ),
      
      tabItem(tabName = 'teams', h2('Coming Soon')
              
              
              )
    )
    # another fluidRow for next Row
    
  )

  
  
  
)
