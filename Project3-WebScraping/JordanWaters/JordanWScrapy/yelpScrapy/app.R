#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(tm)
library(wordcloud)
library(dplyr)

# Define UI for application that draws a histogram
ui <- shinyUI(fluidPage(
   
   # Application title
   titlePanel("Yelp Reviewer Analysis"),
   
   # Sidebar with a slider input for number of bins 
   sidebarLayout(
      sidebarPanel( 
        textInput("restaurant", "Restaurant", "a-and-a-bake-and-doubles-shop-brooklyn"),
        textInput("yourID", "Your User ID", "Ja9gBg4CYOne-MXqHUrcYA"),
        textOutput("Number of 5 Star Reviews: 26",container = span)
        ),
         
      
      # Show a plot of the generated distribution
      mainPanel(
        tabsetPanel(
         tabPanel("5 Stars" , plotOutput("dist5Plot")),
         tabPanel("4 Stars" ,plotOutput("dist4Plot")),
         tabPanel("3 Stars" ,plotOutput("dist3Plot")),
         tabPanel("2 Stars" ,plotOutput("dist2Plot"))
        )
          )
        )
      )
)


# Define server logic required to draw a histogram
server <- shinyServer(function(input, output) {
  reviews <- read.csv('../yelpScrape/reviews.csv')
  userReviews <- read.csv('../userScrap/userReviews.csv')
  
  restaurant = "A&A Bake & Doubles Shop"
  
  #subset restuarant by stars
  stars5 = reviews[reviews$stars ==5 & reviews$restaurant == restaurant,]
  stars4 = reviews[reviews$stars ==4 & reviews$restaurant == restaurant,]
  stars3 = reviews[reviews$stars ==3 & reviews$restaurant == restaurant,]
  stars2 = reviews[reviews$stars ==2 & reviews$restaurant == restaurant,]
  stars1 = reviews[reviews$stars ==1 & reviews$restaurant == restaurant,]
  
  #create text for transformation for tm
  corpus5 = Corpus(VectorSource(stars5$text))
  corpus4 = Corpus(VectorSource(stars4$text))
  corpus3 = Corpus(VectorSource(stars3$text))
  corpus2 = Corpus(VectorSource(stars2$text))
  corpus1 = Corpus(VectorSource(stars1$text))
  
  #transform text
  corpus5 = tm_map(corpus5, content_transformer(tolower))
  corpus5 = tm_map(corpus5, removePunctuation)
  corpus5 = tm_map(corpus5, removeNumbers)
  corpus5 = tm_map(corpus5, removeWords, stopwords("english"))
  corpus5 = tm_map(corpus5, stripWhitespace)
  
  corpus4 = tm_map(corpus4, content_transformer(tolower))
  corpus4 = tm_map(corpus4, removePunctuation)
  corpus4 = tm_map(corpus4, removeNumbers)
  corpus4 = tm_map(corpus4, removeWords, stopwords("english"))
  corpus4 = tm_map(corpus4, stripWhitespace)
  
  corpus3 = tm_map(corpus3, content_transformer(tolower))
  corpus3 = tm_map(corpus3, removePunctuation)
  corpus3 = tm_map(corpus3, removeNumbers)
  corpus3 = tm_map(corpus3, removeWords, stopwords("english"))
  corpus3 = tm_map(corpus3, stripWhitespace)
  
  corpus2 = tm_map(corpus2, content_transformer(tolower))
  corpus2 = tm_map(corpus2, removePunctuation)
  corpus2 = tm_map(corpus2, removeNumbers)
  corpus2 = tm_map(corpus2, removeWords, stopwords("english"))
  corpus2 = tm_map(corpus2, stripWhitespace)
  
  # corpus1 = tm_map(corpus1, content_transformer(tolower))
  # corpus1 = tm_map(corpus1, removePunctuation)
  # corpus1 = tm_map(corpus1, removeNumbers)
  # corpus1 = tm_map(corpus1, removeWords, stopwords("english"))
  # corpus1 = tm_map(corpus1, stripWhitespace)
  
  #create termmatrix of word counts
  DTM5 = TermDocumentMatrix(corpus5, control = list(minWordLength = 1))
  DTM4 = TermDocumentMatrix(corpus4, control = list(minWordLength = 1))
  DTM3 = TermDocumentMatrix(corpus3, control = list(minWordLength = 1))
  DTM2 = TermDocumentMatrix(corpus2, control = list(minWordLength = 1))
  #DTM1 = TermDocumentMatrix(corpus1, control = list(minWordLength = 1))
  
  #convert to matrix
  mat5 = as.matrix(DTM5)
  mat4 = as.matrix(DTM4)
  mat3 = as.matrix(DTM3)
  mat2 = as.matrix(DTM2)
  #mat1 = as.matrix(DTM1)
  
  #add of count counts and sort by decreasing
  v5 = sort(rowSums(mat5), decreasing = T)
  v4 = sort(rowSums(mat4), decreasing = T)
  v3 = sort(rowSums(mat3), decreasing = T)
  v2 = sort(rowSums(mat2), decreasing = T)
  #v1 = sort(rowSums(mat1), decreasing = T)
  
  #convert to dataframe with headers for wordcloud
  d5 = data.frame(word = names(v5), freq =v5)
  d4 = data.frame(word = names(v4), freq =v4)
  d3 = data.frame(word = names(v3), freq =v3)
  d2 = data.frame(word = names(v2), freq =v2)
  #d1 = data.frame(word = names(v1), freq =v1)
  
  #create wordclouds from dataframes
  # wordcloud5 = wordcloud(words = d5$word, freq = d5$freq, min.freq = 1,
  #                        max.words=200, random.order=FALSE, rot.per=0.35,
  #                        colors=brewer.pal(8, "Dark2"))
  # wordcloud4 = wordcloud(words = d4$word, freq = d4$freq, min.freq = 1,
  #                        max.words=200, random.order=FALSE, rot.per=0.35,
  #                        colors=brewer.pal(8, "Dark2"))
  # wordcloud3 = wordcloud(words = d3$word, freq = d3$freq, min.freq = 1,
  #                        max.words=200, random.order=FALSE, rot.per=0.35,
  #                        colors=brewer.pal(8, "Dark2"))
  # wordcloud2 = wordcloud(words = d2$word, freq = d2$freq, min.freq = 1,
  #                        max.words=200, random.order=FALSE, rot.per=0.35,
  #                        colors=brewer.pal(8, "Dark2"))
  # wordlouc1 = wordcloud(words = d1$word, freq = d1$freq, min.freq = 1,
  #                       max.words=200, random.order=FALSE, rot.per=0.35,
  #                       colors=brewer.pal(8, "Dark2"))
  # 
   # output$nrow5 <- renderText(paste('Number of 5 Star Reviews:',nrow(reviews[reviews$stars ==5 & reviews$restaurant == restaurant,])))
   # output$nrow4 <- nrow(reviews[reviews$stars ==4 & reviews$restaurant == restaurant,])
   # output$nrow3 <- nrow(reviews[reviews$stars ==3 & reviews$restaurant == restaurant,])
   # output$nrow2 <- nrow(reviews[reviews$stars ==2 & reviews$restaurant == restaurant,])

   
   wordcloud_rep <- repeatable(wordcloud)
   output$dist5Plot <- renderPlot({wordcloud_rep(words = d5$word, freq = d5$freq, min.freq = 1, max.words=200, random.order=FALSE, rot.per=0.35, colors=brewer.pal(8, "Dark2")) })
   
   output$dist4Plot <- renderPlot({wordcloud_rep(words = d4$word, freq = d4$freq, min.freq = 1, max.words=200, random.order=FALSE, rot.per=0.35, colors=brewer.pal(8, "Dark2")) })
   
   output$dist3Plot <- renderPlot({wordcloud_rep(words = d3$word, freq = d3$freq, min.freq = 1, max.words=200, random.order=FALSE, rot.per=0.35, colors=brewer.pal(8, "Dark2"))})
   
   output$dist2Plot <- renderPlot({wordcloud_rep(words = d2$word, freq = d2$freq, min.freq = 1, max.words=200, random.order=FALSE, rot.per=0.35, colors=brewer.pal(8, "Dark2"))})
   
   #output$dist1Plot <- renderPlot({wordcloud_rep(words = d1$word, freq = d1$freq, min.freq = 1, max.words=200, random.order=FALSE, rot.per=0.35, colors=brewer.pal(8, "Dark2"))})
  

})
# Run the application 
shinyApp(ui = ui, server = server)


