# Xbox One Backwards Compatiablity Predictor

library(shiny)

programName = "Xbox One Backwards Compatibility Predictor"
sideBarWidth = 450
dashboardPage(
  
  dashboardHeader(
    title = programName,
    titleWidth = sideBarWidth
  ),
  dashboardSidebar(
    width = sideBarWidth,
    sidebarMenu(id = "sbm",
                menuItem("Lists", tabName = "Lists", icon = icon("search")),
                menuItem("Games", tabName = "Games", icon = icon("dashboard")),
                menuItem("Processing", tabName = "Processing", icon = icon("dashboard"))
    )# end of sidebarMenu
  ),#end of dashboardSidebar
  dashboardBody(
    # includeCSS("www/custom.css"),
    tags$head(tags$style(HTML('
                                          /* logo */
                                          .skin-blue .main-header .logo {
                                          background-color: #107c10;
                                          }
                                          
                                          /* logo when hovered */
                                          .skin-blue .main-header .logo:hover {
                                          background-color: #107c10;
                                          }
                                          
                                          /* navbar (rest of the header) */
                                          .skin-blue .main-header .navbar {
                                          background-color: #107c10;
                                          }        
                                          
                                          /* main sidebar */
                                          .skin-blue .main-sidebar {
                                          background-color: #3a3a3a;
                                          }
                                          
                                          /* active selected tab in the sidebarmenu */
                                          .skin-blue .main-sidebar .sidebar .sidebar-menu .active a{
                                          background-color: #f1f1f1;
color: #000000;
border-left-color: #c2c2c2
                                          }
                                          
                                          /* other links in the sidebarmenu */
                                          .skin-blue .main-sidebar .sidebar .sidebar-menu a{
                                          background-color: #3a3a3a;
                                          color: #f1f1f1;
                                          }
                                          
                                          /* other links in the sidebarmenu when hovered */
                                          .skin-blue .main-sidebar .sidebar .sidebar-menu a:hover{
                                          background-color: #f1f1f1;
color: #000000;
border-left-color: #c2c2c2
                                          }
                                          /* toggle button when hovered  */                    
                                          .skin-blue .main-header .navbar .sidebar-toggle:hover{
                                          background-color: #ff69b4;
                                          }
/* toggle button when hovered  */                    
.skin-blue .main-header .navbar .sidebar-toggle:hover{
  background-color: #f1f1f1;
color: #000000;
}
.skin-blue .content-wrapper, .right-side{
  background-color: #c2c2c2;
}
.box.box-solid.box-primary>.box-header{
  background-color: #107c10;
}
.box.box-solid.box-primary {
    border: 0.5px solid #3a3a3a;
}
.box-body {
    border-radius: 0 0 3px 3px;
padding: 10px;
background-color: #f1f1f1;
}
.content {
    min-height: 250px;
padding: 0px;
padding-top:0px;
padding-right: 0px;
padding-bottom: 0px;
padding-left: 0px;
margin-right: 0px;
margin-left: 0px;
}
                                          '))),
    
    
    tabItems(
      tabItem(tabName = "Games",
              fluidPage(
                title = "Games",
                fluidRow(
                  box(
                    title = "Query Builder",
                    status = "primary",
                    width = 12,
                    solidHeader = TRUE,
                    # selectInput("marketName",
                    #             "Choose your markets:",
                    #             choices = str_title_case(sort(c(as.character(unique(xboxData$Market_Name))))),
                    #             multiple = TRUE),
                    # 
                    # selectInput("drugName",
                    #             "Choose your drugs:",
                    #             choices = str_title_case(sort(c(as.character(unique(xboxData$Drug_Type))))),
                    #             multiple = TRUE),
                    # selectInput("shippedFrom",
                    #             "Choose where the drugs are shipped from:",
                    #             choices = str_title_case(sort(c(as.character(unique(xboxData$Shipped_From))))),
                    #             multiple = TRUE),
                    # 
                    # selectInput("weightUnits",
                    #             "Choose your units of weight:",
                    #             choices = c("milligrams","grams", "kilograms", "ounces", "pounds","tons"),
                    #             selected = "grams"
                    # ),
                    # 
                    # sliderInput("weightValue",
                    #             paste("Choose the the total weight of the drug in ", "grams", ":"),
                    #             min = 0, max = 1000, value = 1, step = 0.5,
                    #             post = " grams", sep = ",", animate=FALSE),
                    
                    # sliderInput("pricePerWeight",
                    #             paste("Choose the range of price per ", "grams", ":"),
                    #             min = 0, max = maxPricePerWeight, value = c(0,maxPricePerWeight), step = maxPricePerWeight/5,
                    #             pre = "$", sep = ",", animate=FALSE),
                    
                    
                    
                    # dateRangeInput('dataPostedDate',
                    #                label = paste('Choose the date range for when the item was posted:'),
                    #                start = timeAddedRange[1], end = timeAddedRange[2],
                    #                min = timeAddedRange[1], max = timeAddedRange[2],
                    #                separator = " - ", format = "mm/dd/yy",
                    #                startview = 'month', weekstart = 1
                    # ),
                    # 
                    # 
                    # dateRangeInput('dataAccessedDate',
                    #                label = paste('Choose the date range for when the item was accessed:'),
                    #                start = sheetDateRange[1], end = sheetDateRange[2],
                    #                min = sheetDateRange[1], max = sheetDateRange[2],
                    #                separator = " - ", format = "mm/dd/yy",
                    #                startview = 'month', weekstart = 1
                    # ),
                    
                    # helpText("Note: Leave a field empty to select all."),
                    actionButton("query", label = "Search")
                  )
                )# end of fluidrow
              ) # End of fluidPage
      ), # End of tabItem
      tabItem(tabName = "Lists",
              navbarPage(
                title = 'Interesting Lists',
                position = "static-top",
                tabPanel('Backwards Compatible Now',     DT::dataTableOutput('List_BackwardsCompatibleGames')),
                navbarMenu("Publishers",
                           tabPanel('Top 10',        DT::dataTableOutput('ex5')),
                           tabPanel('Bottom 10',      DT::dataTableOutput('ex6'))),
                tabPanel('Predicted Backwards Compatible',       DT::dataTableOutput('List_PredictedBackwardsCompatible')),
                tabPanel('Exclusives',  DT::dataTableOutput('ex3')),
                # tabPanel('Has Xbox One Version',  DT::dataTableOutput('ex3')),
                tabPanel('Kinect Supported on Xbox 360',      DT::dataTableOutput('ex4'))
              )
      ) # End of tabItem
    ) # end of tabITems
  )# end of dashboard body
)# end of dashboard page