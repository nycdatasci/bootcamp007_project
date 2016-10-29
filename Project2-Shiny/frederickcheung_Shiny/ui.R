#This is my data processing of my healthdf file

setwd("~/github/bootcamp007_project/Project2-Shiny/frederickcheung_Shiny")
library(dplyr)
library(ggplot2)
library(shinydashboard)
library(googleVis)
library(dplyr)

healthdf <- readRDS("healthdf")

healthdfcountry <- unique(healthdf$Country.Name)
healthdfcat <- unique(healthdf$Topic)
healthdfcatindic <- unique(healthdf$Indicator.Name.x)


dashboardPage(
  dashboardHeader(title = "World Health Data"),
  dashboardSidebar(
    sidebarMenu(
          menuItem("Chart", tabName = "Chart", icon = icon("bar-chart-o"))
        ) #end sidebarMenu
    ), #end dashboardSidebar
  dashboardBody(
    # Boxes need to be put in a row (or column)
    tabItems(
      # First tab content
      tabItem(tabName = "Chart",
        h2("Health Graph by Topic"),
              fluidRow(
              box(
            title = "Controls",
            selectizeInput("Country", "Select Countries", healthdfcountry , multiple=TRUE, selected = 'United States'),
            selectInput("inSelect", "Category",
                               healthdfcat),
            selectInput("inSelect2", label = "Category Indicator",
                        choices = character(0))
            ) #end box
         ) #end fluidRow
        ) #end tabItem1
      ) #end tabItems
    ) #end dashboardBody
  ) #end dashboardPage
