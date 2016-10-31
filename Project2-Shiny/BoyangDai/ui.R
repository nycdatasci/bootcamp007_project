# ui.R

suppressMessages(library(shinydashboard))
suppressMessages(library(shinythemes))
suppressMessages(library(rmarkdown))
suppressMessages(library(scales))
suppressMessages(library(DT))
suppressMessages(library(Hmisc))
suppressMessages(library(quantreg))
suppressMessages(library(ggplot2))
suppressMessages(library(dplyr))
#source('global.R')

shinyUI(
  fluidPage(
    theme = shinytheme("spacelab"),
    navbarPage("EDA Plot Generator",
               # - - - - - - - - - - - - # - - - - - - - - - - - - #  # - - - - - - - - - - - - # - - - - - - - - - - - - #
               tabPanel('Overview',
                        navlistPanel(widths = c(3, 9),
                                     # - - - - - - - - - - - - # - - - - - - - - - - - - #
                                     tabPanel('Introduction', 
                                              column(12, 
                                                     h3('Introduction'),
                                                     h5('This project is initialized by the author aiming to provide a quicker EDA analysis for people without
                                                        extensive coding experience in data analytic field. ')
                                                     )
                                              ),
                                     # - - - - - - - - - - - - # - - - - - - - - - - - - #
                                     tabPanel('Author',
                                              column(12, 
                                                     h3('Boyang Dai')
                                              )
                                     )
                                     )
               ),
               # - - - - - - - - - - - - # - - - - - - - - - - - - #  # - - - - - - - - - - - - # - - - - - - - - - - - - #
               navbarMenu('Data Options',
                          tabPanel("Uploading Files",
                                   sidebarLayout(
                                     sidebarPanel(
                                       tabsetPanel(
                                         tabPanel("Inputs", 
                                                  tagList(
                                                    singleton(tags$head(tags$script(src='//cdn.datatables.net/1.10.7/js/jquery.dataTables.min.js', type='text/javascript'))),
                                                    singleton(tags$head(tags$script(src='//cdn.datatables.net/tabletools/2.2.4/js/dataTables.tableTools.min.js', type='text/javascript'))),
                                                    singleton(tags$head(tags$script(src='//cdn.datatables.net/colreorder/1.1.3/js/dataTables.colReorder.min.js', type='text/javascript'))),
                                                    singleton(tags$head(tags$script(src='colvis.js',type='text/javascript'))),
                                                    singleton(tags$head(tags$script(src='//cdn.datatables.net/tabletools/2.2.4/js/ZeroClipboard.min.js', type='text/javascript'))),
                                                    singleton(tags$head(tags$link(href='//cdn.datatables.net/tabletools/2.2.4/css/dataTables.tableTools.css', rel='stylesheet', type='text/css'))),
                                                    singleton(tags$script(HTML("if (window.innerHeight < 400) alert('Screen too small');"))),
                                                    tags$head(tags$style(HTML(".cvclear{text-align:right}"))) 
                                                  ),
                                                  fileInput("datafile", "Choose *.csv file to upload", multiple = FALSE, accept = c("csv")),
                                                  uiOutput("max_lvls"),
                                                  tabsetPanel(
                                                    tabPanel("Filter", 
                                                             uiOutput("strained_var1"),
                                                             uiOutput("strained_var1_value"),
                                                             uiOutput("strained_var2"),
                                                             uiOutput("strained_var2_value")
                                                    ),
                                                    tabPanel("Encoder", 
                                                             uiOutput("cat_var1"),
                                                             uiOutput("n_cut"),
                                                             uiOutput("cat_var2"))
                                                  ),
                                                  hr()
                                         ) 
                                       )
                                     ), 
                                     mainPanel(
                                       tabsetPanel(
                                         tabPanel('Data', dataTableOutput("excel_table")),
                                         tabPanel('Structure', verbatimTextOutput('data_structure'),
                                                  p(textOutput('data_dim'))),
                                         tabPanel('Summary', verbatimTextOutput('data_summary'))
                                       )
                                     )
                                   )
                          ),
                          tabPanel("Data Manipulation...")
               ),
               # - - - - - - - - - - - - # - - - - - - - - - - - - #  # - - - - - - - - - - - - # - - - - - - - - - - - - #
               tabPanel("Plotting - EDA",
                        sidebarPanel(
                          conditionalPanel(condition = "input.conditionedPanels == 1",
                                           uiOutput("x_col"),
                                           uiOutput("slide_bar1"),
                                           uiOutput('y_col'),
                                           uiOutput("slide_bar2")
                          ),
                          conditionalPanel(condition = "input.conditionedPanels == 2",
                                           uiOutput('x_col_cat')
                          ),
                          conditionalPanel(condition = "input.conditionedPanels == 3",
                                           uiOutput('x_col_bx'),
                                           uiOutput('y_col_bx')
                          ),
                          conditionalPanel(condition = "input.conditionedPanels == 4"),
                          conditionalPanel(condition = "input.conditionedPanels == 5")
                        ),
                        
                        mainPanel(
                          tabsetPanel(
                            # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
                            tabPanel('ScatterPlot', value = 1,
                                     plotOutput('plot_scatter',  width = "100%" ,click = "plot_click",
                                                hover = hoverOpts(id = "plot_hover", delayType = "throttle"),
                                                brush = brushOpts(id = "plot_brush")),
                                     uiOutput('optionsmenu_scatter'),
                                     # * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
                                     conditionalPanel(
                                       condition = "input.showplottypes", 
                                       fluidRow(
                                         column(12, 
                                                hr()),
                                         # - - - - - - - - - - - - - - - - - - -
                                         column(5, 
                                                radioButtons("Points", "Points/Jitter:",
                                                             c("Points" = "Points",
                                                               "Jitter" = "Jitter",
                                                               "None" = "None")),
                                                conditionalPanel("input.Points== 'Points' ",
                                                                 sliderInput("pointstransparency", 
                                                                             "Points Transparency:", 
                                                                             min = 0, max=1,
                                                                             value = c(0.5),
                                                                             step = 0.01)
                                                )
                                         ),
                                         # - - - - - - - - - - - - - - - - - - -
                                         column(5,
                                                conditionalPanel("input.Points == 'Points' ",
                                                                 sliderInput("pointsizes", 
                                                                             "Points Size:", 
                                                                             min = 0, max = 10, 
                                                                             value = c(1), step = 0.2),
                                                                 numericInput('pointtypes',
                                                                              'Points Type:',
                                                                              10, 
                                                                              min = 1, max = 25)
                                                )
                                         ),
                                         # - - - - - - - - - - - - - - - - - - -
                                         column (5,
                                                 radioButtons("line", "Lines:",
                                                              c("Lines" = "Lines", "None" = "None"),
                                                              selected="None"),
                                                 conditionalPanel("input.line== 'Lines' ",
                                                                  sliderInput("linestransparency", 
                                                                              "Lines Transparency:", 
                                                                              min = 0, max = 1, 
                                                                              value = c(0.5), step = 0.01)
                                                 )
                                         ),
                                         # - - - - - - - - - - - - - - - - - - -
                                         column(5, 
                                                conditionalPanel("input.line == 'Lines' ",
                                                                 sliderInput("linesize", "Lines Size:", 
                                                                             min = 0, max = 10, 
                                                                             value = c(1), step = 0.1),
                                                                 selectInput('linetypes', 
                                                                             'Lines Type:',
                                                                             c("solid","dotted"))
                                                )),
                                         column (12, 
                                                 h5("NOTES:"),
                                                 h6("Points --> Full customization version."),
                                                 h6("Jitter --> Jitter the points."),
                                                 h6('None --> No scatters.'))
                                       )#fluidrow
                                     ),
                                     # * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
                                     conditionalPanel(
                                       condition = "input.showfacets", 
                                       fluidRow(
                                         column (12, hr()),
                                         column (4, uiOutput("colour"), uiOutput("group")),
                                         column (4, uiOutput("pointsize"), uiOutput("fill"))
                                       )
                                     ),
                                     hr(),
                                     uiOutput("clickheader"),
                                     tableOutput("plot_clickedpoints"),
                                     uiOutput("brushheader"),
                                     tableOutput("plot_brushedpoints")
                            ),
                            # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
                            tabPanel('BarPlot', value = 2,
                                     plotOutput('plot_bar'),
                                     uiOutput('optionsmenu_bar'),
                                     # * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
                                     conditionalPanel(
                                       condition = "input.showplottypes_br", 
                                       fluidRow(
                                         column(12, 
                                                hr()),
                                         # - - - - - - - - - - - - - - - - - - -
                                         column(5, 
                                                radioButtons('Bar', 'Bars:',
                                                             c('Count Bar' = 'bar',
                                                               'None' = 'None')),
                                                conditionalPanel("input.Bar== 'bar'",
                                                                 sliderInput("barstransparency", 
                                                                             "Bars Transparency:", 
                                                                             min = 0, max = 1,
                                                                             value = c(0.5),
                                                                             step = 0.01)
                                                )
                                         )
                                         # - - - - - - - - - - - - - - - - - - -
                                         
                                       )#fluidrow
                                     ),
                                     # * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
                                     conditionalPanel(
                                       condition = "input.showfacets_br", 
                                       fluidRow(
                                         column(12, hr()),
                                         column(4, uiOutput("colour_br")),
                                         column(4, uiOutput('fill_br'))
                                       )
                                     )
                            ),
                            # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
                            tabPanel('BoxPlot', value = 3,
                                     plotOutput('plot_box'),
                                     # * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
                                     sliderInput('bxtransparency',
                                                 'Boxes Transparency:',
                                                 min = 0, max = 1, 
                                                 value = c(0.5),
                                                 step = 0.01)
                                     # - - - - - - - - - - - - - - - - - - -
                                     
                                     # - - - - - - - - - - - - - - - - - - -
                                     
                                     # - - - - - - - - - - - - - - - - - - -
                                     
                                     # - - - - - - - - - - - - - - - - - - -
                                     
                                     # * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
                                     
                            ),
                            # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
                            tabPanel('Histogram', value = 4),
                            tabPanel('Density', value = 5),
                            id = 'conditionedPanels'
                          )
                        )
               ),
               # - - - - - - - - - - - - # - - - - - - - - - - - - #  # - - - - - - - - - - - - # - - - - - - - - - - - - #
               tabPanel("Statistical Analysis..."),
               # - - - - - - - - - - - - # - - - - - - - - - - - - #  # - - - - - - - - - - - - # - - - - - - - - - - - - #
               tabPanel("Code Generator..."),
               # - - - - - - - - - - - - # - - - - - - - - - - - - #  # - - - - - - - - - - - - # - - - - - - - - - - - - #
               tabPanel("...")    
  )
  # - - - - - - - - - - - - # - - - - - - - - - - - - #  # - - - - - - - - - - - - # - - - - - - - - - - - - #
)
)












