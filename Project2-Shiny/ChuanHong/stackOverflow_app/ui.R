## ui.R ##
library(googleVis)
library(shinydashboard)

dashboardPage(
  header = dashboardHeader(
    title = img(src = "http://www.fogcreek.com/images/logos/so-logo.png", width = "100%")
    ),
  
  sidebar = dashboardSidebar(
    sidebarUserPanel("Chuan Hong",
                     subtitle = a(href = "#", icon("circle", class = "text-success"), "Online"),
                     # Image file should be in www/ subdir
                     image = "https://avatars1.githubusercontent.com/u/9791149?v=3&s=400"
    ),
    
    sidebarMenu(
      # Setting id makes input$tabs give the tabName of currently-selected tab
      id = "tabs",
      menuItem(HTML("stack<strong>overflow</strong>"), 
               tabName = "about", 
               icon = icon("stack-overflow")),
      menuItem("Analysis", 
               tabName = "analysis", 
               icon = icon("line-chart")),
      menuItem("Find Answers", 
               icon = icon("stack-overflow"),
               menuSubItem("R", tabName = "subitem1"),
               menuSubItem("Python", tabName = "subitem2")
      )
    ),
    sidebarSearchForm(textId = "searchText", 
                      buttonId = "searchButton", 
                      label = "Search not available yet...")
  ),
  
  body = dashboardBody(
    tabItems(
      tabItem("about",
              img(src="http://cdn.sstatic.net/Sites/stackoverflow/company/Img/bg-so-header.png?v=6207408854fe", 
                  width = "100%"),
              h4("Developers trust Stack Overflow to help solve coding problems and use Stack Overflow Jobs to find job opportunities. 
                We’re committed to making the internet a better place, and our products aim to enrich the lives of developers as they grow and mature in their careers."),
              h4("Founded in 2008, Stack Overflow sees 40 million visitors each month and is the flagship site of the Stack Exchange network, 
                home to 150+ Q&A sites dedicated to niche topics.")),
      
      tabItem("analysis",
              box(width = 12,
                fluidRow(
                  column(width = 3,
                         selectizeInput("lan", "Choose Language", 
                                        choices = c("All", "Python", "R"),
                                        width = 200)
                         ),
                  column(width = 3,
                         uiOutput("cateInput")
                         ),
                  column(width = 4,
                         uiOutput("pkgsInput")
                         ),
                  column(width = 2,
                         br(),
                         actionButton("go", "Go")
                  )
                )),
              box(width = 12,
                  fluidRow(
                    column(6,h3("Summary of R & Python (01/2009 - 09/2016)", align = "center"),
                           htmlOutput("gvisBar")),
                    column(6,h3("Time Series Analysis", align = "center"),
                           htmlOutput("gvisMotion"))
                  ))
      ),
      tabItem("subitem1",
              "Python coming soon :)"
      ),
      tabItem("subitem2",
              "R comming soon :)"
      )
    )
  ),
  
  skin = "black"
)
