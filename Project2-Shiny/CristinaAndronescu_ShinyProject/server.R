library(ggplot2)
library(ggmap)
shinyServer(function(input, output){
          df <- reactive({
            #print(input$Hour)
            df=switch(as.character( input$Hour),
                                 "0"= data.0,
                                 "1"= data.1,
                                 "2"= data.2,
                                 "3"= data.3,
                                 "4"= data.4,
                                 "5"= data.5,
                                 "6"= data.6,
                                 "7"= data.7,
                                 "8"= data.8,
                                 "9"= data.9,
                                 "10"= data.10,
                                 "11"= data.11,
                                 "12"= data.12,
                                 "13"= data.13,
                                 "14"= data.14,
                                 "15"= data.15,
                                 "16"= data.16,
                                 "17"= data.17,
                                 "18"= data.18,
                                 "19"= data.19,
                                 "20"= data.20,
                                 "21"= data.21,
                                 "22"= data.22,
                                 "23"= data.23
                                               )
            #print(df)
            #df            
            
                                            })
          
          output$plot_hour <- renderPlot({
            #print(df())
             ggplot(df()) + geom_polygon(aes(
               x = long, y = lat, group = group,
               fill = cnt),
               col="black",
               alpha = 0.8,
               size = 0.4) + labs(x="", y="") +
               scale_fill_gradient(low = "white", high = "#0000FF") + theme_minimal()
                       
         #args$min <- input$range[1]
         #args$max <- input$range[2]
           
         
          })         
       }
    )