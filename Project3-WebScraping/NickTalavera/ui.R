# Xbox One Backwards Compatiablity Predictor

library(shiny)
roundUp <- function(x, nice=c(1,2,4,5,6,8,10)) {
  if(length(x) != 1) stop("'x' must be of length 1")
  10^floor(log10(x)) * nice[[which(x <= 10^floor(log10(x)) * nice)[[1]]]]
}

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
                menuItem("Lists", tabName = "Lists", icon = icon("gamepad")),
                menuItem("Game Search", tabName = "Games", icon = icon("search")),
                menuItem("Processing", tabName = "Processing", icon = icon("list-ol")),
                menuItem("About Me", tabName = "AboutMe", icon = icon("user"))
    )# end of sidebarMenu
  ),#end of dashboardSidebar
  dashboardBody(
    includeCSS("www/custom.css"),
    tags$head(tags$style(HTML('
                                          
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
.irs-bar {
    height: 8px;
                                          top: 25px;
                                          border-top: 0.5px solid #000000;
                                          border-bottom: 0.5px solid #000000;
                                          background: #5dc21e;
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
                    checkboxGroupInput("SEARCH_Is_Backwards_Compatible", label = h3("Is backwards compatible:"), 
                                       choices = list("Yes" = TRUE, "No" = FALSE),
                                       selected = 1),
                    checkboxGroupInput("SEARCH_Predicted_to_become_Backwards_Compatible", label = h3("Predicted to become backwards compatible:"), 
                                       choices = list("Yes" = TRUE, "No" = FALSE),
                                       selected = 1),
                    sliderInput("SEARCH_Backwards_Compatability_Probability_Percent",
                                label = h3("Backwards compatability probability percent:"),
                                min = 0, max = 100, value = 50, step = 1,
                                post = "%", sep = ",", animate=FALSE),
                    dateRangeInput('SEARCH_Release_date',
                                   label = h3("Release Date:"),
                                   start = range(xboxData$releaseDate)[1], end = range(xboxData$releaseDate)[2],
                                   min = range(xboxData$releaseDate)[1], max = range(xboxData$releaseDate)[2],
                                   separator = " - ", format = "mm/dd/yy",
                                   startview = 'month', weekstart = 1
                    ),
                    checkboxGroupInput("SEARCH_Is_Listed_on_XboxCom", label = h3("Is listed on Xbox.com:"), 
                                       choices = list("Yes" = TRUE, "No" = FALSE),
                                       selected = 1),
                    checkboxGroupInput("SEARCH_Is_Exclusive", label = h3("Is Exclusive:"), 
                                       choices = list("Only on Xbox 360" = "Only on Xbox 360", "Also Available on PC" = "PC", "No" = "No"),
                                       selected = 1),
                    checkboxGroupInput("SEARCH_Xbox_One_Version_Available", label = h3("Xbox One version available:"), 
                                       choices = list("Yes" = TRUE, "No" = FALSE),
                                       selected = 1),
                    checkboxGroupInput("SEARCH_Is_On_Uservoice", label = h3("Is on Uservoice"), 
                                       choices = list("Yes" = TRUE, "No" = FALSE),
                                       selected = 1),
                    sliderInput("SEARCH_Uservoice_Votes",
                                label = h3("Uservoice votes:"),
                                min = 0, max = roundUp(max(xboxData$votes, na.rm = TRUE)), value = 0, step = 1,
                                post = " votes", sep = ",", animate=FALSE),
                    sliderInput("SEARCH_Uservoice_Comments",
                                label = h3("Uservoice comments:"),
                                min = 0, max = roundUp(max(xboxData$comments, na.rm = TRUE)), value = 0, step = 1,
                                post = " comments", sep = ",", animate=FALSE),
                    checkboxGroupInput("SEARCH_Is_Kinect_Supported", label = h3("Is Kinect supported:"), 
                                       choices = list("Yes" = TRUE, "No" = FALSE),
                                       selected = 1),
                    checkboxGroupInput("SEARCH_Is_Kinect_Required", label = h3("Is Kinect required:"), 
                                       choices = list("Yes" = TRUE, "No" = FALSE),
                                       selected = 1),  
                    checkboxGroupInput("SEARCH_Does_The_Game_Need_Special_Peripherals", label = h3("Does the game need special peripherals:"), 
                                       choices = list("Yes" = TRUE, "No" = FALSE),
                                       selected = 1),
                    checkboxGroupInput("SEARCH_Is_The_Game_Retail_Only", label = h3("Is the game retail only:"), 
                                       choices = list("Yes" = TRUE, "No" = FALSE),
                                       selected = 1),
                    checkboxGroupInput("SEARCH_Available_to_Purchase_a_Digital_Copy_on_Xbox.com", label = h3("Available to purchase a digital copy on Xbox.com:"), 
                                       choices = list("Yes" = TRUE, "No" = FALSE),
                                       selected = 1),
                    checkboxGroupInput("SEARCH_Has_a_Demo_Available", label = h3("Has a demo available:"), 
                                       choices = list("Yes" = TRUE, "No" = FALSE),
                                       selected = 1),
                    sliderInput("SEARCH_Xbox_User_Review_Score",
                                label = h3("Xbox user review score:"),
                                min = 0, max = 5, value = 3, step = 0.5,
                                post = "", sep = ",", animate=FALSE),
                    sliderInput("SEARCH_Xbox_User_Review_Counts",
                                label = h3("Xbox user review counts:"),
                                min = 0, max = roundUp(max(xboxData$numberOfReviews, na.rm = TRUE)), value = 0, step = 1,
                                post = " reviews", sep = ",", animate=FALSE),
                    sliderInput("SEARCH_Metacritic_Review_Score",
                                label = h3("Metacritic review score:"),
                                min = 0, max = 100, value = 50, step = 1,
                                post = "", sep = ",", animate=FALSE),
                    sliderInput("SEARCH_Metacritic_User_Review_Score",
                                label = h3("Metacritic user review score:"),
                                min = 0, max = 10, value = 5, step = 0.1,
                                post = "", sep = ",", animate=FALSE),
                    sliderInput("SEARCH_Price_on_Xbox.com",
                                label = h3("Price on Xbox.com:"),
                                min = 0, max = roundUp(max(xboxData$price, na.rm = TRUE)), value = 10, step = 1, pre = "$",
                                post = "", sep = ",", animate=FALSE),
                    selectInput("SEARCH_Publisher",
                                label = h3("Publisher:"),
                                choices = str_title_case(sort(c(as.character(unique(xboxData$publisher))))),
                                multiple = TRUE),
                    selectInput("SEARCH_Developer",
                                label = h3("Developer:"),
                                choices = str_title_case(sort(c(as.character(unique(xboxData$developer))))),
                                multiple = TRUE),
                    selectInput("SEARCH_Genre",
                                label = h3("Genre:"),
                                choices = str_title_case(sort(c(as.character(unique(xboxData$genre))))),
                                multiple = TRUE),
                    selectInput("SEARCH_ESRB_Rating",
                                label = h3("ESRB Rating:"),
                                choices = str_title_case(sort(c(as.character(unique(xboxData$ESRBRating))))),
                                multiple = TRUE),
                    selectInput("SEARCH_Features",
                                label = h3("Features:"),
                                choices = str_title_case(sort(c(as.character(unique(xboxData$features))))),
                                multiple = TRUE),
                    checkboxGroupInput("SEARCH_Smartglass_Compatable",
                                       label = h3("Smartglass Compatable:"),
                                       choices = list("Yes" = TRUE, "No" = FALSE),
                                       selected = 1),
                    sliderInput("SEARCH_Number_of_Game_Add_Ons",
                                label = h3("Number of Game Add-Ons:"),
                                min = 0, max = roundUp(max(xboxData$DLgameAddons, na.rm = TRUE)), value = 0, step = 1,
                                post = " Add-Ons", sep = ",", animate=FALSE),
                    sliderInput("SEARCH_Number_of_Avatar_Items",
                                label = h3("Number of Avatar Items:"),
                                min = 0, max = roundUp(max(xboxData$DLavatarItems, na.rm = TRUE)), value = 0, step = 1,
                                post = " Avatar Items", sep = ",", animate=FALSE),
                    sliderInput("SEARCH_Number_of_GamerPics",
                                label = h3("Number of GamerPics:"),
                                min = 0, max = roundUp(max(xboxData$DLgamerPictures, na.rm = TRUE)), value = 0, step = 1,
                                post = " GamerPics", sep = ",", animate=FALSE),
                    sliderInput("SEARCH_Number_of_Themes",
                                label = h3("Number of Themes:"),
                                min = 0, max = roundUp(max(xboxData$DLthemes, na.rm = TRUE)), value = 0, step = 1,
                                post = " Themes", sep = ",", animate=FALSE),
                    sliderInput("SEARCH_Number_of_Game_Videos",
                                label = h3("Number of Game Videos:"),
                                min = 0, max = roundUp(max(xboxData$DLgameVideos, na.rm = TRUE)), value = 0, step = 1,
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
      ), # End of tabItem
      tabItem(tabName = "AboutMe",
              fluidPage(
                uiOutput("AboutMe")
              )
      ) # End of tabItem
    ) # end of tabITems
  )# end of dashboard body
)# end of dashboard page