# Darknet Market Analyzer
# Darknet Market Analysis
# Nick Talavera
# Date: Octber 25, 2016


library(shiny)
library(ggplot2)
programName = "Darknet Market Analyzer"
dashboardPage(skin = "green",
              dashboardHeader(title = programName),
              dashboardSidebar(
                sidebarMenu(id = "sbm",
                            menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
                            menuItem("Market Explorer", tabName = "explorer", icon = icon("search"))
                )# end of sidebarMenu
              ),#end of dashboardSidebar
              dashboardBody(
                includeCSS("www/custom.css"),
                tabItems(
                  tabItem(tabName = "dashboard",
                          fluidPage(
                            title = "Dashboard",
                            fluidRow(
                              column(width = 12,
                                     valueBoxOutput("usViBox", width = 3),
                                     valueBoxOutput("highestViBox", width = 3),
                                     valueBoxOutput("usAnnualBox", width = 3),
                                     valueBoxOutput("highestAnnualBox", width = 3)
                              )#end of column
                            ),# end of row
                            fluidRow(
                              column(width = 4,
                                     box(
                                       title = "Analytics for the Darknet Market",
                                       width = 12,
                                       height = 530,
                                       background = "orange",
                                       solidHeader = FALSE,
                                       collapsible = FALSE,
                                       collapsed = FALSE,
                                       h3(paste("Welcome to", programName)),
                                       p(
                                         paste("On this website, you can visualize data from across the darknet Market. The data was collected by Gwern. More info on the data can be seen at http://www.gwern.net/Black-market%20archives.")
                                       ),
                                       p(
                                         paste("The left menu will guide you through exploring the markets. The dashboard is an overview of interesting facts. The Market Explorer allows you to limit the scope of the data.")
                                       ),
                                       p(
                                         paste("This website was created by Nick Talavera to allow others to explore this dataset so that others can build their own insights.")
                                       ),
                                       p("Enjoy!")
                                     )# end of box
                              ),# end of column
                              column(width = 8,
                                     box(
                                       title = "Average Prices of All Drugs Time Series for Various Markets",
                                       status = "primary",
                                       width = 12,
                                       height = 530,
                                       solidHeader = FALSE,
                                       collapsible = TRUE,
                                       plotOutput("top10CitiesBar")
                                     ) #End of Box
                              ) # End of column
                            ), # End of Fluid Row
                            fluidRow(
                              column(width = 6,
                                     box(
                                       title = "Price of Drugs Time Series",
                                       status = "primary",
                                       width = 12,
                                       solidHeader = FALSE,
                                       collapsible = TRUE,
                                       plotOutput("topTenDrugPriceChangeTimeSeries")
                                     ) #End of Box
                              ),# end of column
                              column(width = 6,
                                     box(
                                       title = "Number of Posts in Each Darknet Market Time Series Compared to Bitcoin Prices (USD)",
                                       status = "primary",
                                       width = 12,
                                       solidHeader = FALSE,
                                       collapsible = TRUE,
                                       plotOutput("drugPricesVSBitcoinVSPharma")
                                     ) #End of Box
                              )# end of column
                            ),#end of fluidrow
                            fluidRow(
                              column(width = 12,
                                     valueBoxOutput("numStatesBox", width = 3),
                                     valueBoxOutput("mostPostedDruginXCountry", width = 3),
                                     valueBoxOutput("bitcoinHighLow", width = 3),
                                     valueBoxOutput("mostPopularMarketForDrugX", width = 3)
                              )# end of column
                            )# end of fluidrow
                          ) # End of fluidPage
                  ), # End of tabItem
                  tabItem(tabName = "explorer",
                          fluidPage(
                            title = "Market Explorer",
                            column(width = 4,
                                   box(
                                     title = "Query Builder",
                                     status = "primary",
                                     width = 12,
                                     solidHeader = TRUE,
                                     background = "navy",
                                     selectInput("marketName",
                                                 "Choose your markets:",
                                                 choices = str_title_case(sort(c(as.character(unique(dnmData$Market_Name))))),
                                                 multiple = TRUE),
                                     
                                     selectInput("drugName",
                                                 "Choose your drugs:",
                                                 choices = str_title_case(sort(c(as.character(unique(dnmData$Drug_Type))))),
                                                 multiple = TRUE),
                                     selectInput("shippedFrom",
                                                 "Choose where the drugs are shipped from:",
                                                 choices = str_title_case(sort(c(as.character(unique(dnmData$Shipped_From))))),
                                                 multiple = TRUE),
                                     
                                     selectInput("weightUnits",
                                                 "Choose your units of weight:",
                                                 choices = c("milligrams","grams", "kilograms", "ounces", "pounds","tons"),
                                                 selected = "grams"
                                     ),
                                     
                                     sliderInput("weightValue",
                                                 paste("Choose the the total weight of the drug in ", "grams", ":"),
                                                 min = 0, max = 1000, value = 1, step = 0.5,
                                                 post = " grams", sep = ",", animate=FALSE),
                                     
                                     sliderInput("pricePerWeight",
                                                 paste("Choose the range of price per ", "grams", ":"),
                                                 min = 0, max = maxPricePerWeight, value = c(0,maxPricePerWeight), step = maxPricePerWeight/5,
                                                 pre = "$", sep = ",", animate=FALSE),
                                     
                                     
                                     
                                     dateRangeInput('dataPostedDate',
                                                    label = paste('Choose the date range for when the item was posted:'),
                                                    start = timeAddedRange[1], end = timeAddedRange[2],
                                                    min = timeAddedRange[1], max = timeAddedRange[2],
                                                    separator = " - ", format = "mm/dd/yy",
                                                    startview = 'month', weekstart = 1
                                     ),
                                     
                                     
                                     dateRangeInput('dataAccessedDate',
                                                    label = paste('Choose the date range for when the item was accessed:'),
                                                    start = sheetDateRange[1], end = sheetDateRange[2],
                                                    min = sheetDateRange[1], max = sheetDateRange[2],
                                                    separator = " - ", format = "mm/dd/yy",
                                                    startview = 'month', weekstart = 1
                                     ),
                                     
                                     helpText("Note: Leave a field empty to select all."),
                                     actionButton("query", label = "Go")
                                   )
                            ),
                            
                            
                            conditionalPanel(
                              condition = "input.query",
                              column(width = 10,
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
                                       ),# end of fluidrow
                                       fluidRow(
                                         column(width = 12,
                                                box(
                                                  title = "Most Common Drug Listing by Count",
                                                  status = "primary",
                                                  width = 6,
                                                  solidHeader = FALSE,
                                                  collapsible = TRUE,
                                                  plotOutput("mostCommonDrugsHist")
                                                ),# end of box
                                                box(
                                                  title = "Most Active Market For Selected Drugs",
                                                  status = "primary",
                                                  width = 6,
                                                  solidHeader = FALSE,
                                                  collapsible = TRUE,
                                                  plotOutput("mostPopularMarkets")
                                                )# end of box
                                         )# end of column
                                       ),# end of fluidRow
                                       fluidRow(
                                         box(
                                           title = "Number of postings per day over time for each darknet",
                                           status = "primary",
                                           width = 12,
                                           height = 700,
                                           solidHeader = FALSE,
                                           collapsible = TRUE,
                                           plotOutput("postsPerDayWithDrugColor")
                                         ) #End of Box
                                       ),# end of fluidRow
                                       fluidRow(
                                         box(
                                           title = "Number of Drugs Available Per Market",
                                           status = "primary",
                                           width = 12,
                                           height = 700,
                                           solidHeader = FALSE,
                                           collapsible = TRUE,
                                           plotOutput("numberOfDrugsAvailablePerMarket")
                                         ) #End of Box
                                       ),# end of fluidRow
                                       fluidRow(
                                         box(
                                           title = "Price per gram for each drug over time",
                                           status = "primary",
                                           width = 12,
                                           height = 700,
                                           solidHeader = FALSE,
                                           collapsible = TRUE,
                                           plotOutput("pricePerDrug")
                                         ) #End of Box
                                       ),# end of fluidRow
                                       fluidRow(
                                         box(
                                           title = "Average prices of drugs for each market",
                                           status = "primary",
                                           width = 12,
                                           height = 700,
                                           solidHeader = FALSE,
                                           collapsible = TRUE,
                                           plotOutput("drugPrices")
                                         ) #End of Box
                                       ),# end of fluidRow
                                       fluidRow(
                                         box(
                                           title = "Average prices of drugs against price of bitcoins",
                                           status = "primary",
                                           width = 12,
                                           height = 700,
                                           solidHeader = FALSE,
                                           collapsible = TRUE,
                                           plotOutput("pricesComparedToBicoinPrice")
                                         ) #End of Box
                                       )# end of fluidRow
                                     )# end of box
                              )#end of column
                            ) # end of conditionalpanel
                          ) # End of fluidPage
                  ) # End of tabItem
                ) # end of tabITems
              )# end of dashboard body
)# end of dashboard page