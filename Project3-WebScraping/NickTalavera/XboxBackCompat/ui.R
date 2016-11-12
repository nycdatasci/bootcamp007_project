# Xbox One Backwards Compatiablity Predictor

library(shiny)

programName = "Xbox One Backwards Compatability Predictor"
sideBarWidth = 350
dashboardPage(
              
              dashboardHeader(
                title = programName,
                titleWidth = sideBarWidth
              ),
              dashboardSidebar(
                width = sideBarWidth,
                sidebarMenu(id = "sbm",
                            menuItem("Games", tabName = "Games", icon = icon("dashboard")),
                            menuItem("Lists", tabName = "Lists", icon = icon("search"))
                )# end of sidebarMenu
              ),#end of dashboardSidebar
              dashboardBody(
                # includeCSS("www/custom.css"),
                tags$head(tags$style(HTML('
                                          /* logo */
                                          .skin-blue .main-header .logo {
                                          background-color: #f4b943;
                                          }
                                          
                                          /* logo when hovered */
                                          .skin-blue .main-header .logo:hover {
                                          background-color: #f4b943;
                                          }
                                          
                                          /* navbar (rest of the header) */
                                          .skin-blue .main-header .navbar {
                                          background-color: #f4b943;
                                          }        
                                          
                                          /* main sidebar */
                                          .skin-blue .main-sidebar {
                                          background-color: #f4b943;
                                          }
                                          
                                          /* active selected tab in the sidebarmenu */
                                          .skin-blue .main-sidebar .sidebar .sidebar-menu .active a{
                                          background-color: #ff0000;
                                          }
                                          
                                          /* other links in the sidebarmenu */
                                          .skin-blue .main-sidebar .sidebar .sidebar-menu a{
                                          background-color: #00ff00;
                                          color: #000000;
                                          }
                                          
                                          /* other links in the sidebarmenu when hovered */
                                          .skin-blue .main-sidebar .sidebar .sidebar-menu a:hover{
                                          background-color: #ff69b4;
                                          }
                                          /* toggle button when hovered  */                    
                                          .skin-blue .main-header .navbar .sidebar-toggle:hover{
                                          background-color: #ff69b4;
                                          }
/* toggle button when hovered  */                    
.skin-blue .main-header .navbar .sidebar-toggle:hover{
  background-color: #ff69b4;
}
                                          '))),
                
                
                tabItems(
                  tabItem(tabName = "Games",
                          fluidPage(
                            title = "Games",
                            fluidRow(
                              column(width = 4,
                                     box(
                                       title = "Query Builder",
                                       status = "primary",
                                       width = 12,
                                       solidHeader = TRUE,
                                       background = "navy",
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
                              )
                            )# end of fluidrow
                          ) # End of fluidPage
                  ), # End of tabItem
                  tabItem(tabName = "Lists",
                          fluidPage(
                            title = "Lists",
                            box(
                              title = "Market Data",
                              status = "primary",
                              width = 12,
                              solidHeader = TRUE,
                              collapsible = FALSE,
                              fluidRow(
                                box(
                                  title = "Data Table",
                                  status = "primary",
                                  width = 12,
                                  solidHeader = FALSE,
                                  collapsible = TRUE,
                                  DT::dataTableOutput('dataTableViewOfDrugs')
                                )# end of box
                              )# end of fluidrow
                            )# end of box
                          ) # End of fluidPage
                  ) # End of tabItem
                ) # end of tabITems
              )# end of dashboard body
)# end of dashboard page