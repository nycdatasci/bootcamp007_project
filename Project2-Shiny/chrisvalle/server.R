library(dplyr)
library(ggplot2)
library(ggthemes)
library(shiny)
library(RColorBrewer)
library(gdata)
library(scales)
library(reshape2)

server <- function(input, output) {
  #set.seed(122)
  #histdata <- rnorm(500)
  
  #sample placeholder
 #output$sales <- renderPlot({
  #data <- histdata[seq_len(input$slider)]
  #hist(data)
  
  #})
  
  
  # Sales Revenues Annual 
 output$sales <- renderPlot({
    ggplot(sbuxRevFY, aes(x = Date, y = Revenue))+
      geom_bar(stat = "identity", aes(fill = "Revenue")) +
      xlab("Fiscal Year") +
      ylab("Revenues ($)")
    
  })
  
  # Business Model plot US vs non-US
  output$bizmod_plot = renderPlot({
    ggplot(location, aes(x=reorder(LocationCategory, Ownership.Type))) + 
      geom_bar(aes(fill = Ownership.Type)) + 
      ylab("number of stores")
  
    })
  
  # Transactions plot by region
  output$trxn_plot1 = renderPlot({
  ggplot(storeTxn, aes(x = Date, y = ChangeTrx)) +
      geom_bar(stat = "identity", aes(fill = Region)) + 
      facet_wrap(~Region) + 
      theme_bw() + xlab("Year") + ylab("Change in Store Transactions (%)")
  
    })
  
  # Ticket plot by region 
  output$trxn_plot2 = renderPlot({
  ggplot(storeTxn, aes(x = Date, y = ChangeTicket)) +
  geom_bar(stat = "identity", aes(fill = Region)) + 
  facet_wrap(~Region) + 
  theme_bw() + xlab("Year") + ylab("Change in Store Tickets (%)")
  
  })
  
 # Stock Market performance 
 #output$stockmarket = renderPlot({
 
 
 #})
  
  
  
}