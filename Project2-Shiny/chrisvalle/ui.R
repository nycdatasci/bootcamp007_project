library(shiny)
library(shinydashboard)
library(ggplot2)
library(dplyr)

ui <- dashboardPage(skin = "green",
                    
                    dashboardHeader(title = "Starbucks Executive Dashboard"),
                    
                    
                    dashboardSidebar(
                      sidebarMenu(
                        menuItem("Sales Revenues", tabName = "sales", icon = icon("dollar",lib = "font-awesome")),
                        menuItem("Business Model", tabName = "bizmod", icon = icon("bank",lib = "font-awesome")),
                        menuItem("Transactions", tabName = "trxn", icon = icon("credit-card",lib = "font-awesome")),
                        # menuItem("Stores", tabName = "stores", icon = icon("map-marker",lib = "font-awesome")),
                        menuItem("Stock Market", tabName = "stockmarket", icon = icon("line-chart",lib = "font-awesome")),
                        
                        checkboxGroupInput("checkGroup",
                                           label = h5("Add:"),
                                           choices = list("CAGR" = 1,
                                                          "Index" = 2),selected = 1)
                        
                      )
                    ),
                    
                    
                    # add dashboardBody
                    # add widget - dropdown
                    
                    dashboardBody(
                      tabItems(
                        tabItem(tabName = "sales",
                                fluidRow(
                                  box(plotOutput("sales", height = 400, width = 600)),
                                  box(title = "Annual",
                                      radioButtons("typeInput", "Time",
                                                   choices = c("Fiscal Year", "Quarterly"),
                                                   selected = "Fiscal Year")
                                  ))
                                
                                ### old end dashboardBody      
                        ),
                        
                        # business model tab
                        tabItem(tabName = "bizmod",
                                fluidRow(
                                  box(plotOutput("bizmod_plot", height = 400)),
                                  box(title = "Annual",
                                      sliderInput("slider", "year:", 2010, 2016, 2014))
                                  
                                )),
                        
                        
                        # # Transactions & Tickets tab
                        # tabItem(tabName = "stores",
                        #         fluidRow(
                        #           box(plotOutput("    ", height = 400)),
                        #           box(plotOutput("    ", height = 400)),
                        #           box(title = "Annual",
                        #               sliderInput("slider", "year:", 2010, 2016, 2014))
                        #           
                        #         )), 
                        
                        # Stores
                        tabItem(tabName = "trxn",
                                fluidRow(
                                  box(plotOutput("trxn_plot1", height = 400)),
                                  box(plotOutput("trxn_plot2", height = 400)),
                                  box(title = "Annual",
                                      sliderInput("slider", "year:", 2010, 2016, 2014))
                                  
                                )),
                      
                        # Stock Market tab
                        tabItem(tabName = "stockmarket",
                                fluidRow(
                                  box(plotOutput("stockmarket_plot", height = 400)),
                                  box(title = "Annual",
                                      sliderInput("slider", "year:", 2010, 2016, 2014))
                                ))
                  
                      ) # tabItems end
                      
                    ) #dashboardBody end
) #UI end