library(shiny)
library(shinydashboard)

shinyUI(dashboardPage(
                      skin ="yellow",
    dashboardHeader(title = "Healthcare", titleWidth = 280),
    
    dashboardSidebar(
      width = 280,
      
        sidebarUserPanel("Timely and Effective Study",
                         image = "http://vignette1.wikia.nocookie.net/zombie/images/1/18/Hospital.jpg/revision/latest?cb=20160329114824"),
        sidebarMenu(
           menuItem("map", tabName = "map", icon = icon("picture-o")),
           menuItem("Data", tabName = "data", icon = icon("hospital-o"))
        ),
        selectizeInput("ConditionChoice",
                       "Select Condition:",
                       width = 280,
                       choices,selected = "Colonoscopy Care"),
      
         selectizeInput("RegionChoice",
                     "Select region:",
                     width = 280,
                     regionChoice, selected = "NationWide")
    ),
    dashboardBody(
        tags$head(
            tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
        ),

        tabItems(
            tabItem(tabName = "map",
                    fluidRow(infoBoxOutput("maxBox"),
                             infoBoxOutput("minBox"),
                             infoBoxOutput("avgBox")),
                    fluidRow(box(htmlOutput("map"), height = 300),
                             box(htmlOutput("hist"), height = 300))),
            tabItem(tabName = "data",
                    fluidRow(box(DT::dataTableOutput("table"), width = 12)))
        )
    )
))# End of DashboardPage
# End of shinyUI