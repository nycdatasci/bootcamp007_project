#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinydashboard)
library(googleVis)
library(dplyr)
library(tidyr)
library(ggplot2)


shinyServer(function(input, output) {
  output$barPlot = renderGvis({
    #filter data based on selection

    FilterTable = NewASum3
    if (input$race != 9) {
      FilterTable1 = filter(FilterTable, PTDTRACE == input$race)
      n= nrow(FilterTable)}
    else {
      FilterTable1 = FilterTable}
    if (input$region != 3) {
      FilterTable2 = filter(FilterTable1, GEMETSTA == input$region)
      n= nrow(FilterTable)}
    else {
      FilterTable2 = FilterTable1}
    if (input$sex != 3) {
      FilterTable3 = filter(FilterTable2, TESEX == input$sex)
      n= nrow(FilterTable)}
    else {
      FilterTable3 = FilterTable2}
    
    
    if (input$incomeg != 6) {
      FilterTable4 = filter(FilterTable3, IncomeGroup == input$incomeg)
      n= nrow(FilterTable)}
    else {
      FilterTable4 = FilterTable3
    }
    
    melted = FilterTable4 %>% gather(Activity, values,HouseHold:Sleeping)
    Table1 = melted %>% group_by(TUYEAR, Activity) %>% summarise(Time=mean(values))
    YTable1 = filter(Table1, TUYEAR == input$slider1)
    
    
    Bar = gvisColumnChart(data = YTable1, xvar = "Activity", yvar = "Time")
    return (Bar)
    })
  output$barPlot2 = renderGvis({
    #filter data based on selection
    
    FilterTable = NewASum3
    if (input$race != 9) {
      FilterTable1 = filter(FilterTable, PTDTRACE == input$race)
      n= nrow(FilterTable)}
    else {
      FilterTable1 = FilterTable}
    if (input$region != 3) {
      FilterTable2 = filter(FilterTable1, GEMETSTA == input$region)
      n= nrow(FilterTable)}
    else {
      FilterTable2 = FilterTable1}
    if (input$sex != 3) {
      FilterTable3 = filter(FilterTable2, TESEX == input$sex)
      n= nrow(FilterTable)}
    else {
      FilterTable3 = FilterTable2}
    
    
    if (input$incomeg != 6) {
      FilterTable4 = filter(FilterTable3, IncomeGroup == input$incomeg)
      n= nrow(FilterTable)}
    else {
      FilterTable4 = FilterTable3
    }
    
    melted = FilterTable4 %>% gather(Activity, values,HouseHold:Sleeping)
    Table3 = melted %>% group_by(TUYEAR, Activity) %>% summarise(Time=log(mean(values)))
    YTable3 = filter(Table3, TUYEAR == input$slider2)
    
    
    Bar2 = gvisColumnChart(data = YTable3, xvar = "Activity", yvar = "Time")
    return (Bar2)
  })
  
  output$DataFrame = DT::renderDataTable(DT::datatable({
    
    FilterTable = NewASum3
    if (input$race != 9) {
      FilterTable1 = filter(FilterTable, PTDTRACE == input$race)
      n= nrow(FilterTable)}
    else {
      FilterTable1 = FilterTable}
    if (input$region != 3) {
      FilterTable2 = filter(FilterTable1, GEMETSTA == input$region)
      n= nrow(FilterTable)}
    else {
      FilterTable2 = FilterTable1}
    if (input$sex != 3) {
      FilterTable3 = filter(FilterTable2, TESEX == input$sex)
      n= nrow(FilterTable)}
    else {
      FilterTable3 = FilterTable2}
    
    
    if (input$incomeg != 6) {
      FilterTable4 = filter(FilterTable3, IncomeGroup == input$incomeg)
      n= nrow(FilterTable)}
    else {
      FilterTable4 = FilterTable3
    }
    
    melted = FilterTable4 %>% gather(Activity, values,HouseHold:Sleeping)
    Table1 = melted %>% group_by(TUYEAR, Activity) %>% summarise(Time=mean(values))
    Table1 = Table1 %>% 
      arrange(TUYEAR,desc(Time))
      
    return (Table1)
    

    
}))
})
