#This is the UI to my project


library(shinydashboard)

dashboardPage(
  dashboardHeader(title = "World Health Data"),
  dashboardSidebar(
    sidebarMenu(
          menuItem("Chart", tabName = "Chart", icon = icon("bar-chart-o"))
        ) #end sidebarMenu
    ), #end dashboardSidebar
  dashboardBody(
    # Boxes need to be put in a row (or column)
    tabItems(
      # First tab content
      tabItem(tabName = "Chart",
        h2("Life Expectancy by Gender"),
              
        fluidRow(
            
          htmlOutput("LifeExpect")
          
            
          )#end fluidRow1
        ) #end tabItem1
      ) #end tabItems
    ) #end dashboardBody
  ) #end dashboardPage
