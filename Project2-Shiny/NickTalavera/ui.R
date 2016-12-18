# Darknet Market Analyzer
# Darknet Market Analysis
# Nick Talavera
# Date: October 25, 2016


programName = "Darknet Market Analyzer"
sidebarWidth = 250
dashboardPage(dashboardHeader(title = programName,
                              titleWidth = sidebarWidth),
              dashboardSidebar(
                width = sidebarWidth,
                sidebarMenu(id = "sideBarMenu",
                            # menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
                            # menuItem("Maps", tabName = "maps", icon = icon("search")), 
                            menuItem("Market Explorer", tabName = "explorer", icon = icon("search")), 
                            conditionalPanel("input.sideBarMenu == 'explorer'",
                                        tabName = "explorer",
                                        icon = NULL,
                                     title = "Query Builder",
                                     status = "primary",
                                     solidHeader = TRUE,
                                     selectInput("marketName",
                                                 "Choose your markets:",
                                                 choices = AvailableMarkets,
                                                 multiple = TRUE,
                                                 selected = c("Agora","Silk Road 2", "Evolution")),

                                     selectInput("drugName",
                                                 "Choose your drugs:",
                                                 choices = AvailableDrugs,
                                                 multiple = TRUE,
                                                 selected = c("Ecstasy (Mdma)","Marijuana","Cocaine","Speed (Amphetamine)","Lsd (Lysergic Acid)","Heroin","Ghb")),
                                     selectInput("shippedFrom",
                                                 "Choose where the drugs are shipped from:",
                                                 choices = AvailableCountries,
                                                 multiple = TRUE,
                                                 selected = c("United States","China","Mexico","United Kingdom","South Africa","France","Chile","Venezuela")),

                                     # selectInput("weightUnits",
                                     #             "Choose your units of weight:",
                                     #             choices = c("milligrams","grams", "kilograms", "ounces", "pounds","tons"),
                                     #             selected = "grams"
                                     # ),

                                     # sliderInput("weightValue",
                                     #             paste("Choose the the total weight of the drug in ", "grams", ":"),
                                     #             min = 0, max = 1000, value = 1, step = 0.5,
                                     #             post = " grams", sep = ",", animate=FALSE),

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
                            # menuItem("Popular Words", tabName = "popularWords", icon = icon("search"))
                )# end of sidebarMenu
              ),#end of dashboardSidebar
              dashboardBody(
                theme = shinythemes::shinytheme("superhero"),
                includeCSS("www/custom.css"),
                tabItems(
                  tabItem(tabName = "dashboard",
                          fluidPage(
                            title = "Dashboard",
                            fluidRow(
                              column(width = 12,
                                     valueBoxOutput("usViBox", width = 3),
                                     valueBoxOutput("XThanAveragePricesForXAtXBox", width = 3),
                                     valueBoxOutput("averagePricePerOunceForXInXonXBox", width = 3),
                                     valueBoxOutput("DayOfTheMostXPostsOnXBox", width = 3)
                              )#end of column
                            ),# end of row
                            fluidRow(
                              column(width = 4,
                                     box(
                                       title = "Analytics for the Darknet Market",
                                       width = 12,
                                       height = 530,
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
                                       collapsible = FALSE,
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
                                       collapsible = FALSE,
                                       plotOutput("topTenDrugPriceChangeTimeSeries")
                                     ) #End of Box
                              ),# end of column
                              column(width = 6,
                                     box(
                                       title = "Number of Posts in Each Darknet Market Time Series Compared to Bitcoin Prices (USD)",
                                       status = "primary",
                                       width = 12,
                                       solidHeader = FALSE,
                                       collapsible = FALSE,
                                       plotOutput("drugPricesVSBitcoinVSPharma")
                                     ) #End of Box
                              )# end of column
                            ),#end of fluidrow
                            fluidRow(
                              column(width = 12,
                                     valueBoxOutput("MostActiveCountryBox", width = 3),
                                     valueBoxOutput("mostPostedDruginXCountryBox", width = 3),
                                     valueBoxOutput("bitcoinHighLowBox", width = 3),
                                     valueBoxOutput("mostPopularMarketForDrugXBox", width = 3)
                              )# end of column
                            )# end of fluidrow
                          ) # End of fluidPage
                  ), # End of tabItem
                  tabItem(tabName = "explorer",
                          fluidPage(
                            title = "Market Explorer",

                            conditionalPanel(
                              condition = "input.query | input.sideBarMenu == 'explorer'",
                              # column(width = 10,
                                       fluidRow(
                                         box(
                                           title = str_title_case("Number of postings per day over time for each darknet"),
                                           status = "primary",
                                           width = 12,
                                           solidHeader = FALSE,
                                           collapsible = FALSE,
                                           plotOutput("postsPerDayWithDrugColor")
                                         ) #End of Box
                                       ),# end of fluidRow
                                       fluidRow(
                                                box(
                                                  title = str_title_case("Most Common Drug Listing by Count"),
                                                  status = "primary",
                                                  width = 12,
                                                  solidHeader = FALSE,
                                                  collapsible = FALSE,
                                                  plotOutput("mostCommonDrugsHist")
                                                )# end of box
                                       ),# end of fluidRow
                                       fluidRow(
                                                box(
                                                  title = str_title_case("Most Active For Selected Drugs"),
                                                  status = "primary",
                                                  width = 12,
                                                  solidHeader = FALSE,
                                                  collapsible = FALSE,
                                                  plotOutput("mostPopularMarkets"),
                                                  radioButtons("radialMostActive", 
                                                               label = h3("Options:"),
                                                               choices = list("Most Active Market" = "Most Active Market", "Most Active Country" = "Most Active Country"), 
                                                               selected = "Most Active Market",
                                                               inline = TRUE)
                                                )# end of box
                                       ),# end of fluidRow

                                       fluidRow(
                                         box(
                                           title = str_title_case("Most Common Country and Market for Each Drug"),
                                           status = "primary",
                                           width = 12,
                                           solidHeader = FALSE,
                                           collapsible = FALSE,
                                           dataTableOutput("mostCommonCountryAndMarketForEachDrug")
                                         ) #End of Box
                                       ),# end of fluidRow
                                       fluidRow(
                                         box(
                                           title = str_title_case("Number of Drugs"),
                                           status = "primary",
                                           width = 12,
                                           solidHeader = FALSE,
                                           collapsible = FALSE,
                                           plotOutput("numberOfDrugsAvailablePerMarket"),
                                           radioButtons("numberOfDrugsRadial", 
                                                        label = h3("Options:"),
                                                        choices = list("Per Market" = "Per Market", "Per Country" = "Per Country"), 
                                                        selected = "Per Country",
                                                        inline = TRUE)
                                         ) #End of Box
                                       ),# end of fluidRow
                                       fluidRow(
                                         box(
                                           title = str_title_case("Price per gram for each drug over time"),
                                           status = "primary",
                                           width = 12,
                                           solidHeader = FALSE,
                                           collapsible = FALSE,
                                           plotOutput("pricePerDrug")
                                         ) #End of Box
                                       ),# end of fluidRow
                                       fluidRow(
                                         box(
                                           title = str_title_case("Average prices of drugs for each market"),
                                           status = "primary",
                                           width = 12,
                                           solidHeader = FALSE,
                                           collapsible = FALSE,
                                           plotOutput("drugPrices")
                                         ) #End of Box
                                       ),# end of fluidRow
                                       fluidRow(
                                         box(
                                           title = str_title_case("Average prices of drugs against price of bitcoins"),
                                           status = "primary",
                                           width = 12,
                                           solidHeader = FALSE,
                                           collapsible = FALSE,
                                           plotOutput("pricesComparedToBicoinPrice")
                                         ) #End of Box
                                       # ),# end of fluidRow
                                       # fluidRow(
                                       #   box(
                                       #     title = "Data Table",
                                       #     status = "primary",
                                       #     width = 12,
                                       #     solidHeader = FALSE,
                                       #     collapsible = FALSE,
                                       #     DT::dataTableOutput('dataTableViewOfDrugs')
                                       #   )# end of box
                                       )# end of fluidrow
                              # )#end of column
                            ) # end of conditionalpanel
                          ) # End of fluidPage
                  ), # End of tabItem
                  tabItem(tabName = "popularWords",
                          fluidPage(
                            title = str_title_case("Word Frequency in Descriptions"),
                            box(
                              title = "Word Cloud of the Silk Road",
                              width = 12,
                            plotOutput("wordCloud")
                            )
                          )
                  ),
                  tabItem(tabName = "maps",
                          fluidPage(
                            title = str_title_case("Maps"),
                            # leafletOutput("mymap"),
                            p(),
                            actionButton("recalc", "New points")
                          )
                  )
                ) # end of tabITems
              )# end of dashboard body
)# end of dashboard page