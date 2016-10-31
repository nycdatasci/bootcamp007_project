D# Darknet Market Analyzer
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
                                         paste("Here, we use statistical inference and forecast modeling techniques to 
                                               explore and forecast over 13,000 real estate markets in the United States.  
                                               This tool will enable you to:")),
                                       tags$ul(
                                         tags$li("get a snapshot and timeseries of the states and cities with the highest annual increase in median home values
                                                 on this", span("Dashboard page,", style = "color:white")),
                                         tags$li("explore home price indices and growth rates across various markets at several levels of granularity in 
                                                 the", span("Market Explorer,", style = "color:white")),
                                         tags$li("select a market and analyze and decompose price movements into their seasonal, trend and irregular components in the"
                                                 , span("Value Analyzer,", style = "color:white")),
                                         tags$li("train the most popular forecasting models and compare predictive accuracies in the", span("Forecast Modeler,", style = "color:white"), "and"),
                                         tags$li("use these models to forecast home prices in virtually every US real estate market in the", span("Market Forecaster.", 
                                                                                                                                                  style = "color:white"))
                                       ),
                                       p(
                                         paste("The menus to the left will walk you through the process of exploring markets, reviewing price trends, training 
                                               forecast models, evaluating model performance accuracy and predict home prices, 3, 5 or 10 years out.")),
                                       p(
                                         paste("To get started, click on the Market Explorer menu on the left.  For help, click on the help tab on 
                                               the sidebar panel.")),
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
                                                 choices = c(as.character(unique(dnmData$Market_Name))),
                                                 multiple = TRUE),
                                     
                                     selectInput("drugName",
                                                 "Choose your drugs:",
                                                 choices = c(as.character(unique(dnmData$Drug_Type))),
                                                 multiple = TRUE),
                                     selectInput("shippedFrom",
                                                 "Choose where the drugs are shipped from:",
                                                 choices = c(as.character(unique(dnmData$Shipped_From))),
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
                                           title = "Number of postings per day over time for each darknet (color fill of drug type)",
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
                                           title = "Most active country each day",
                                           status = "primary",
                                           width = 12,
                                           height = 700,
                                           solidHeader = FALSE,
                                           collapsible = TRUE,
                                           plotOutput("mostActiveCountryDaily")
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
                                       ),# end of fluidRow
                                       fluidRow(
                                         box(
                                           title = "Number of posts compared to bitcoin price (colored by country)",
                                           status = "primary",
                                           width = 12,
                                           height = 700,
                                           solidHeader = FALSE,
                                           collapsible = TRUE,
                                           plotOutput("postsComparedToBicoinPrice")
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