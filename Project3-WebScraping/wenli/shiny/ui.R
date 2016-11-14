shinyUI(navbarPage('Shiny Ted Talks',
                   theme = shinythemes::shinytheme('united'),
                   
                   tabPanel('TEDx Events 2017',
                            div(class="outer",
                                tags$head(
                                  includeCSS("styles.css"),
                                  includeScript("gomap.js")),
                                leafletOutput('map', width = '100%', height = '100%')),
                            absolutePanel(id = 'logo', fixed = F, draggable = F,
                                          top = 50, left = 50, right ='auto', bottom = 'auto',
                                          width = 280, height = 'auto',
                                          cursor = 'inherit',
                                          h3(img(src = 'logo.png', height = 40, width = 280)))
                     
                   ),
                   
                   tabPanel('Graphic EDA of Views',
                            fluidRow(
                              column(4,
                                     h3('What brings more views?'),
                                     br(),
                                     selectInput('factors',
                                                 h4('Select a factor:'),
                                                 choices = factors,
                                                 selected = 'seconds'),
                                     br(),
                                     selectInput('topics1',
                                                 h4('Select a topic:'),
                                                 choices = topics,
                                                 selected = 'Psychology'),
                                     br(),
                                     checkboxInput('log10y', "Show y-axis in log10", T)),
                              column(8,
                                     h3(''),
                                     plotOutput('scatterplot'),
                                     hr(),
                                     plotOutput('barchart'),
                                     hr(),
                                     plotOutput('barchart2')))
                   ),
                   
                   
                   tabPanel('Topic Perspective',
                            fluidRow(
                              column(1),
                              column(10,
                                     h3('Topics vs. Time'),
                                     dygraphOutput('dygraphs'),
                                     hr(),
                                     h3('Topic "Network"'),
                                     forceNetworkOutput('force')),
                              column(1))
                   ),
                   
                   tabPanel('Modeling',
                            column(1),
                            column(10,
                                   withMathJax(includeMarkdown("RMarkdownFile.md"))),
                            column(1)
                   ),
                   
                   tabPanel('About',
                            fluidRow(
                              column(1),
                              column(9,
                                     h2('About This Shiny App'),
                                     hr(),
                                     h3('Dataset scrapy from:'),
                                     a('TED.com',href="http://www.ted.com", target = "_blank"),
                                     br(),
                                     h3('Codes:'),
                                     a('NYC Data Science Academy Blog',href="http://blog.nycdatascience.com/author/liwen/", target = "_blank"),
                                     br(),
                                     br()),
                              column(1)),
                            absolutePanel(id = 'ds', fixed = F, draggable = F,
                                          top = 300, left = 290, right = 'auto', bottom = 'auto',
                                          width = 600, height = 'auto', style = 'opacity: 0.8',
                                          cursor = 'inherit',
                                          img(src = "ds.png", width = 600))
                   )
                   
                   
))