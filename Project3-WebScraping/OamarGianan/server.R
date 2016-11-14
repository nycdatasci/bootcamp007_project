library(googleVis)
library(reshape2)
library(shiny)
library(DT)
library(dplyr)

getSankey_a <- function(select_artist){
  ##filter df based on input
  df.a <- df %>% filter(artist == select_artist)
  d1 <- df.a %>% select(C_1, C_2)
  names(d1) <- c("from", 'to')
  d1 <- d1 %>% group_by(from, to) %>% summarise(n=n())
  
  d2 <- df.a %>% select(C_2, C_3)
  names(d2) <- c("from", 'to')
  d2 <- d2 %>% group_by(from, to) %>% summarise(n=n())
  
  d3 <- df.a %>% select(C_3, C_4)
  names(d3) <- c("from", 'to')
  d3 <- d3 %>% group_by(from, to) %>% summarise(n=n())
  d.all <- rbind(d1, d2, d3)
  d.all <- as.data.frame(d.all)
  g <- gvisSankey(d.all, from="from", to="to", weight = "n",
             options=list(
               width=1000, height=500,
               sankey="{link: {color: { fill: '#d799ae' } },
                         node: { width: 10, 
                                color: { fill: '#a61d4c' },
                                label: { fontName: 'Garamond',
                                         fontSize: 20,
                                         bold: true} }}"))
}


getSankey_g <- function(select_genre){
  ##filter df based on input
  print(select_genre)
  print("sank")
  df.g <- df %>% filter(grepl(select_genre, genres))
  d1 <- df.g %>% select(C_1, C_2)
  names(d1) <- c("from", 'to')
  d1 <- d1 %>% group_by(from, to) %>% summarise(n=n())
  
  d2 <- df.g %>% select(C_2, C_3)
  names(d2) <- c("from", 'to')
  d2 <- d2 %>% group_by(from, to) %>% summarise(n=n())
  
  d3 <- df.g %>% select(C_3, C_4)
  names(d3) <- c("from", 'to')
  d3 <- d3 %>% group_by(from, to) %>% summarise(n=n())
  print(head(d3))
  d.all <- rbind(d1, d2, d3)
  d.all <- as.data.frame(d.all)
  print(head(d.all))
  print(str(d.all))
  g <- gvisSankey(d.all, from="from", to="to", weight = "n",
                  options=list(
                    width=1000, height=500,
                    sankey="{link: {color: { fill: '#d799ae' } },
                         node: { width: 10, 
                                color: { fill: '#a61d4c' },
                                label: { fontName: 'Garamond',
                                         fontSize: 20,
                                         bold: true} }}"))
}


shinyServer(function(input, output){
  getArtist <- reactive({return(input$select_artist)})
  getGenre <- reactive({return(input$select_genre)})

# show Sankey using googleVis
    output$sankey_a <- renderGvis({getSankey_a(getArtist())})
    
# show Sankey using googleVis
    output$sankey_g <- renderGvis({getSankey_g(getGenre())})
    
})