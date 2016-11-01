library(shiny)
library(shinydashboard)

shinyUI(dashboardPage(skin = "green",
  dashboardHeader(title = img(src="see.for.yourself.logo.jpg")),
  dashboardSidebar(
    sidebarUserPanel("Conred Wang",image = "author.jpg"),
    sidebarMenu(
      menuItem("See for Yourself", tabName = "tabInfo", icon = icon("eye")),
      menuItem("Data", tabName = "tabData", icon = icon("database")),
      menuItem("Higher Education", tabName = "tabEd", icon = icon("graduation-cap")),
      menuItem("Work Hard", tabName = "tabHour", icon = icon("clock-o")),
      menuItem("Happy Marriage", tabName = "tabMarriage", icon = icon("venus-mars"))
    ),
    selectizeInput("selectRace","select Race :",choiceRace),
    selectizeInput("selectWorkClass","select Work Class",choiceWorkClass)
  ), # dashboardSidebar
  dashboardBody(
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
    ),
    tabItems(

      
# -- [tabName = "tabInfo"] BEGIN ***
      tabItem(tabName = "tabInfo", 
        fluidPage(
          tabBox(title = "Information", id="infoPages", width = 12,
            tabPanel("See for Yourself",
              img(src="see.jpg")
            ),              
            tabPanel("Page 1",
              tags$div(
                HTML('
<!-- Page 1 -->
<h2>Most asian parents tell their children :</h2>
<h4><img src="high.ed.small.jpg"> Higher Education +</h4>
<h4><img src="work.hard.small.jpg"> Work Hard +</h4>
<h4><img src="marriage.small.jpg"> Happy Marriage =</h4>
<h4><img src="Money.small.jpg"> <img src="Money.small.jpg"> <img src="Money.small.jpg"> <strong>Good Life</strong></h4>
<h3>?</h3>
<h3>? Myth or Fact ?</h3>
<h3>?</h3>
                ') #HTML
              ) # tags$div
            ), # page 1
            tabPanel("Page 2",
              tags$div(
                HTML('
<!-- Page 2 -->
<h3> </h3>
<br>
<h3> </h3>
<br>
<h3>I know, I know, a <strong>Good Life</strong> is <strong>NOT</strong> identical to <img src="Money.small.jpg">…</h3>
<h3>But, be honest, you know and I know, we need some <img src="Money.small.jpg"> to have a <strong>Good Life</strong>.</h3>
<h3>With <strong>R</strong> and <strong>ggplot2</strong>, and visually exploring the <em>Adult</em> dataset from 
<em>UC Irvine Machine Learning Repository</em>, I investigated if the telling is a myth or a fact :</h3>
<h3><img src="high.ed.small.jpg"> + <img src="work.hard.small.jpg"> + <img src="marriage.small.jpg"> = 
<img src="Money.small.jpg"> <img src="Money.small.jpg"> <img src="Money.small.jpg"></h3> 
<h3>You can find my first investigation <strong>I Told You So</strong> at <a href="http://blog.nycdatascience.com/author/Conred/">my NYC Data Science Academy blog</a></h3>
<br>
<h3> </h3>
<br>
                ') #HTML
              ) # tags$div
            ), # page 2
            tabPanel("Page 3",
              tags$div(
                HTML('
<!-- Page 3 -->
<h3> </h3>
<br>
<h3> </h3>
<br>
<h3>In <strong>I Told You So</strong>, I focused only on asian adults who working in private sector.</h3>
<br>
<h3>In this study, <strong>See For Yourself</strong>, using <strong>Shinny</strong>, 
I invite you to join my investigation about the myth/fact 
against different races, working classes/sectors, and the combination of both.  
We can click <strong>"Higher Education" / "Work Hard" / "Happy Marriage"</strong>, 
and select<strong>"Race" / "Work Class"</strong> from drop-down list.</h3>
<br>
<h3>You can examine the data for this study, by clicking the <strong>Data</strong>.</h3>
<br>
<h3>Soon, I will post the discovery we found at <a href="http://blog.nycdatascience.com/author/Conred/">my NYC Data Science Academy blog</a></h3>
<br>
<h3> </h3>
<br>
                ') #HTML
              ) # tags$div
            ), # page 3
            tabPanel("Page 4",
              h1("TRY NOW &"),
              img(src="see.jpg")
            ) # page 4              
          ) #tabBox
        ) # fluidPage
      ), # tabInfo
# -- [tabName = "tabInfo"] END ***/Users/blessed/NYCDSA/project/PrjShiny/WRK/conredwang
      tabItem(tabName = "tabData", 
        fluidRow(box(DT::dataTableOutput("table"), width = 12)) 
      ),
      tabItem(tabName = "tabEd", 
        fluidRow(
          valueBoxOutput("tabEd_box1", width = 3), valueBoxOutput("tabEd_box2", width = 3),
          valueBoxOutput("tabEd_box3", width = 3), valueBoxOutput("tabEd_box4", width = 3)
        ),
        fluidRow(
          fluidRow(
            box(plotOutput("tabEd_plot1"), width = 6), box(plotOutput("tabEd_plot2"), width = 6)
          ),
          fluidRow(
            box(plotOutput("tabEd_plot3"), width = 6), box(plotOutput("tabEd_plot4"), width = 6)
          ), width = 12
        ), 
        fluidRow(
          infoBoxOutput("tabEd_warning", width = 12)
        )
      ), # tabEd
      tabItem(tabName = "tabHour", 
        fluidRow(
          valueBoxOutput("tabHour_box1", width = 3), valueBoxOutput("tabHour_box2", width = 3),
          valueBoxOutput("tabHour_box3", width = 3), valueBoxOutput("tabHour_box4", width = 3)
        ),
        fluidRow(
          fluidRow(
            box(plotOutput("tabHour_plot1"), width = 6), box(plotOutput("tabHour_plot2"), width = 6)
          ),
          fluidRow(
            box(plotOutput("tabHour_plot3"), width = 6), box(plotOutput("tabHour_plot4"), width = 6)
          ), width = 12
        ), 
        fluidRow(
          infoBoxOutput("tabHour_warning", width = 12)
        )
      ), # tabHour
      tabItem(tabName = "tabMarriage", 
        fluidRow(
          valueBoxOutput("tabMarriage_box1", width = 3), valueBoxOutput("tabMarriage_box2", width = 3),
          valueBoxOutput("tabMarriage_box3", width = 3), valueBoxOutput("tabMarriage_box4", width = 3)
        ),
        fluidRow(
          fluidRow(
            box(plotOutput("tabMarriage_plot1"), width = 6), box(plotOutput("tabMarriage_plot2"), width = 6)
          ),
          fluidRow(
            box(plotOutput("tabMarriage_plot3"), width = 6), box(plotOutput("tabMarriage_plot4"), width = 6)
          ), width = 12
        ), 
        fluidRow(
          infoBoxOutput("tabMarriage_warning", width = 12)
        )
      ) # tabMarriage
    ) # tabItems
  ) # dashboardBody
))