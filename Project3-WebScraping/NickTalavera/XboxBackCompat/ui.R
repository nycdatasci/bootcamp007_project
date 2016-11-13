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
                menuItem("Game Search", tabName = "Games", icon = icon("dashboard")),
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
                tags$head(tags$style(HTML('
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
                                          padding: 10px;
                                          padding-top:10px;
                                          padding-right: 10px;
                                          padding-bottom: 10px;
                                          padding-left: 10px;
                                          margin-right: 10px;
                                          margin-left: 10px;
                                          }
                                          '))),
                fluidRow(
                  box(
                    title = "Search",
                    status = "primary",
                    width = 12,
                    # solidHeader = TRUE,
                    collapsible = TRUE,
                    helpText("Note: Leave a field empty to select all."),
                    checkboxGroupInput("Is_Backwards_Compatible", label = h3("Is Backwards Compatible:"), 
                                       choices = list("Yes" = TRUE, "No" = FALSE),
                                       selected = 1),
                    checkboxGroupInput("Predicted_to_become_Backwards_Compatible", label = h3("Predicted to become Backwards Compatible:"), 
                                       choices = list("Yes" = TRUE, "No" = FALSE),
                                       selected = 1),
                    sliderInput("bcProb",
                                label = h3("Backwards Compatability Probability Percent:"),
                                min = 0, max = 100, value = 1, step = 1,
                                post = "%", sep = ",", animate=FALSE),
                    dateRangeInput('dataAccessedDate',
                                   label = h3("Release Date:"),
                                   start = range(xboxData$releaseDate)[1], end = range(xboxData$releaseDate)[2],
                                   min = range(xboxData$releaseDate)[1], max = range(xboxData$releaseDate)[2],
                                   separator = " - ", format = "mm/dd/yy",
                                   startview = 'month', weekstart = 1
                    ),
                    checkboxGroupInput("Is_Backwards_Compatible", label = h3("Is Listed on Xbox.com:"), 
                                       choices = list("Yes" = TRUE, "No" = FALSE),
                                       selected = 1),
                    checkboxGroupInput("Is_Backwards_Compatible", label = h3("Is Exclusive:"), 
                                       choices = list("Only on Xbox 360" = "Only on Xbox 360", "Also Available on PC" = "PC", "No" = "No"),
                                       selected = 1),
                    checkboxGroupInput("Is_Backwards_Compatible", label = h3("Xbox One Version Available:"), 
                                       choices = list("Yes" = TRUE, "No" = FALSE),
                                       selected = 1),
                    checkboxGroupInput("Is_Backwards_Compatible", label = h3("Is on Uservoice"), 
                                       choices = list("Yes" = TRUE, "No" = FALSE),
                                       selected = 1),
                    sliderInput("bcProb",
                                label = h3("Uservoice Votes:"),
                                min = 0, max = max(xboxData$votes, na.rm = TRUE), value = 1, step = 1,
                                post = " votes", sep = ",", animate=FALSE),
                    sliderInput("bcProb",
                                label = h3("Uservoice Comments:"),
                                min = 0, max = max(xboxData$comments, na.rm = TRUE), value = 1, step = 1,
                                post = " comments", sep = ",", animate=FALSE),
                    checkboxGroupInput("Is_Backwards_Compatible", label = h3("Is Kinect Supported:"), 
                                       choices = list("Yes" = TRUE, "No" = FALSE),
                                       selected = 1),
                    checkboxGroupInput("Is_Backwards_Compatible", label = h3("Is Kinect Required:"), 
                                       choices = list("Yes" = TRUE, "No" = FALSE),
                                       selected = 1),  
                    checkboxGroupInput("Is_Backwards_Compatible", label = h3("Does it Need Special Peripherals:"), 
                                       choices = list("Yes" = TRUE, "No" = FALSE),
                                       selected = 1),
                    checkboxGroupInput("Is_Backwards_Compatible", label = h3("Is it Retail Only:"), 
                                       choices = list("Yes" = TRUE, "No" = FALSE),
                                       selected = 1),
                    checkboxGroupInput("Is_Backwards_Compatible", label = h3("Available to Purchase a Digital Copy on Xbox.com:"), 
                                       choices = list("Yes" = TRUE, "No" = FALSE),
                                       selected = 1),
                    checkboxGroupInput("Is_Backwards_Compatible", label = h3("Has a Demo Available:"), 
                                       choices = list("Yes" = TRUE, "No" = FALSE),
                                       selected = 1),
                    sliderInput("bcProb",
                                label = h3("Xbox User Review Score:"),
                                min = 0, max = max(xboxData$votes, na.rm = TRUE), value = 1, step = 1,
                                post = " votes", sep = ",", animate=FALSE),
                    sliderInput("bcProb",
                                label = h3("Xbox User Review Counts:"),
                                min = 0, max = max(xboxData$votes, na.rm = TRUE), value = 1, step = 1,
                                post = " votes", sep = ",", animate=FALSE),
                    sliderInput("bcProb",
                                label = h3("Metacritic Review Score:"),
                                min = 0, max = max(xboxData$votes, na.rm = TRUE), value = 1, step = 1,
                                post = " votes", sep = ",", animate=FALSE),
                    sliderInput("bcProb",
                                label = h3("Metacritic User Review Score:"),
                                min = 0, max = max(xboxData$votes, na.rm = TRUE), value = 1, step = 1,
                                post = " votes", sep = ",", animate=FALSE),
                    sliderInput("bcProb",
                                label = h3("Price on Xbox.com:"),
                                min = 0, max = max(xboxData$votes, na.rm = TRUE), value = 1, step = 1,
                                post = " votes", sep = ",", animate=FALSE),
                    selectInput("shippedFrom",
                                label = h3("Publisher:"),
                                choices = str_title_case(sort(c(as.character(unique(xboxData$publisher))))),
                                multiple = TRUE),
                    selectInput("shippedFrom",
                                label = h3("Developer:"),
                                choices = str_title_case(sort(c(as.character(unique(xboxData$developer))))),
                                multiple = TRUE),
                    selectInput("shippedFrom",
                                label = h3("Genre:"),
                                choices = str_title_case(sort(c(as.character(unique(xboxData$genre))))),
                                multiple = TRUE),
                    selectInput("shippedFrom",
                                label = h3("ESRB Rating:"),
                                choices = str_title_case(sort(c(as.character(unique(xboxData$ESRBRating))))),
                                multiple = TRUE),
                    selectInput("shippedFrom",
                                label = h3("Features:"),
                                choices = str_title_case(sort(c(as.character(unique(xboxData$features))))),
                                multiple = TRUE),
                    checkboxGroupInput("bcProb",
                                label = h3("Smartglass Compatable:"),
                                choices = list("Yes" = TRUE, "No" = FALSE),
                                selected = 1),
                    sliderInput("bcProb",
                                label = h3("Number of Game Add-Ons:"),
                                min = 0, max = max(xboxData$DLgameAddons, na.rm = TRUE), value = 1, step = 1,
                                post = " Add-Ons", sep = ",", animate=FALSE),
                    sliderInput("bcProb",
                                label = h3("Number of Avatar Items:"),
                                min = 0, max = max(xboxData$DLavatarItems, na.rm = TRUE), value = 1, step = 1,
                                post = " Avatar Items", sep = ",", animate=FALSE),
                    sliderInput("bcProb",
                                label = h3("Number of GamerPics:"),
                                min = 0, max = max(xboxData$DLgamerPictures, na.rm = TRUE), value = 1, step = 1,
                                post = " GamerPics", sep = ",", animate=FALSE),
                    sliderInput("bcProb",
                                label = h3("Number of Themes:"),
                                min = 0, max = max(xboxData$DLthemes, na.rm = TRUE), value = 1, step = 1,
                                post = " Themes", sep = ",", animate=FALSE),
                    sliderInput("bcProb",
                                label = h3("Number of Game Videos:"),
                                min = 0, max = max(xboxData$DLgameVideos, na.rm = TRUE), value = 1, step = 1,
                                post = " Game Videos", sep = ",", animate=FALSE),
                    actionButton("query", label = "Search")
                  ),
                  # conditionalPanel(
                  #   condition = "input.query",
                  box(
                    title = "Results",
                    # status = "primary",
                    width = 12,
                    # solidHeader = TRUE,
                    collapsible = FALSE,
                    DT::dataTableOutput('List_SearchResults')
                  )
              # )
                )# end of fluidrow
              ) # End of fluidPage
      ), # End of tabItem
      tabItem(tabName = "Lists",
              navbarPage(
                title = 'Interesting Lists',
                # position = "static-top",
                tabPanel('All Games',      DT::dataTableOutput('List_AllGames')),
                tabPanel('Backwards Compatible Now',     DT::dataTableOutput('List_BackwardsCompatibleGames')),
                tabPanel('Predicted Backwards Compatible',       DT::dataTableOutput('List_PredictedBackwardsCompatible')),
                navbarMenu("Publishers",
                           tabPanel('Most Likely 25',
                                    helpText('Not including Games that Require Kinect or Peripherals'),
                                    shiny::tableOutput('PublisherTop')),
                           tabPanel('Least Likely',
                                    helpText('Not including Games that Require Kinect or Peripherals'),
                                    shiny::tableOutput('PublisherBottom'))
                ),
                tabPanel('Exclusives',  DT::dataTableOutput('List_Exclusives')),
                tabPanel('Has Xbox One Version',  DT::dataTableOutput('List_HasXboxOneVersion')),
                tabPanel('Kinect Games',      DT::dataTableOutput('List_KinectGames'))
              )
      ), # End of tabItem
      tabItem(tabName = "Processing",
              fluidPage(
                tags$head(tags$style(HTML('
                                          .skin-blue .content-wrapper, .right-side{
                                          background-color: #f1f1f1;
                                          }
                                          .box.box-solid.box-primary>.box-header{
                                          background-color: #f1f1f1;
                                          }
                                          .box.box-solid.box-primary {
                                          border: 0.5px solid #f1f1f1;
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
                uiOutput("Explanation")
              ) # End of fluidPage
      ) # End of tabItem
    ) # end of tabITems
  )# end of dashboard body
)# end of dashboard page