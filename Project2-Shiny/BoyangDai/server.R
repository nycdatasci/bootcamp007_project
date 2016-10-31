# server.R
library(shiny)
library(dplyr)




shinyServer(function(input, output, session) {
  
  # - - - - - - - - - - - - # - - - - - - - - - - - - #
  #                                                   #
  #             Standard Data Upload Setup            #
  #                                                   #
  # - - - - - - - - - - - - # - - - - - - - - - - - - #
  
  # - - - - - #
  #    In     #
  # - - - - - #
  # get the uploaded dataset
  
  core_data <- reactive({
    file_upload <- input$datafile
    if (is.null(file_upload)) {
      return(NULL)
    }
    read.csv(file_upload$datapath, na.strings = c("NA", "."))
  })
  
  # - - - - - - - - - - - - #
  #     Data Description    #
  # - - - - - - - - - - - - #
  output$data_dim <- renderText({
    paste('This dataset has:', dim(core_data())[1],
          'observations over ', dim(core_data())[2],
          'variables.')
  })
  
  output$data_structure <- renderPrint({
    str(core_data())
  })
  
  output$data_summary <- renderPrint({
    dataset <- core_data()
    summary(dataset)
  })
  
  # - - - - - - - - - - - - # - - - - - - - - - - - - #  # - - - - - - - - - - - - # - - - - - - - - - - - - #
  
  # - - - - - - - - - - - - # - - - - - - - - - - - - #
  #                                                   #
  #                 excel_table setups                #
  #                                                   #
  # - - - - - - - - - - - - # - - - - - - - - - - - - #
  
  # - - - - - - - - #
  #    slide_bar1   #
  # - - - - - - - - #
  output$slide_bar1 <- renderUI({
    df <- core_data()
    x_var <- input$x
    if (is.null(df)) return(NULL)
    if (!is.numeric(df[, x_var])) return(NULL)
    sliderInput("bar1", 
                label = paste(x_var, "Range"),
                min = min(df[, x_var], na.rm = TRUE),
                max = max(df[, x_var], na.rm = TRUE),
                value = c(min(df[, x_var], na.rm = TRUE), max(df[, x_var], na.rm = TRUE)) 
    )
  })
  
  # - - - - - - - - #
  #    slide_bar2   #
  # - - - - - - - - #
  output$slide_bar2 <- renderUI({
    df <- core_data()
    y_var <- input$y
    if (is.null(df)) return(NULL)
    if (!is.numeric(df[, y_var])) return(NULL)
    sliderInput("bar2", 
                label = paste(y_var, "Range"),
                min = min(df[, y_var], na.rm = TRUE),
                max = max(df[, y_var], na.rm = TRUE),
                value = c(min(df[, y_var], na.rm = TRUE), max(df[, y_var], na.rm = TRUE)) 
    )
  })
  
  # - - - - - - - - #
  #     max_lvls    #
  # - - - - - - - - #
  output$max_lvls <- renderUI({
    df <- core_data()
    if (is.null(df)) return(NULL)
    numericInput(inputId = "in_max_lvls",
                 label = "Max number of unique values for filtered variables:",
                 value = 10,
                 min = 1,
                 max = NA
    )
  })
  
  # - - - - - - - - - - - #
  #      strained_var1    #
  # - - - - - - - - - - - #
  output$strained_var1 <- renderUI({
    df <- core_data()
    if (is.null(df)) return(NULL)
    uniq_obs <- sapply(df, function(x) length(unique(x)))
    names_kept <- names(df)[uniq_obs < input$in_max_lvls]
    selectInput("in_strained_var1" , 
                label = "Variable 1:",
                c('None', names_kept))
  })
  
  # - - - - - - - - - - - - - - #
  #      strained_var1_value    #
  # - - - - - - - - - - - - - - #
  output$strained_var1_value <- renderUI({
    df <- core_data()
    if (is.null(df)) return(NULL)
    if (input$in_strained_var1 == "None") {
      return(NULL)  
    }
    if (input$in_strained_var1 != "None") {
      choices <- levels(as.factor(df[, input$in_strained_var1]))
      selectInput('in_strained_var1_not_null',
                  label = paste("Select values", input$in_strained_var1),
                  choices = c(choices),
                  selected = choices,
                  multiple = TRUE, selectize = FALSE)   
    }
  })  
  
  # - - - - - - - - - - #
  #      main_subset    #
  # - - - - - - - - - - #
  main_subset  <- reactive({
    df <- core_data()
    if (is.null(df)) return(NULL)
    if (!is.numeric(input$bar1[1])) {
      df 
    }
    if (!is.numeric(input$bar2[1])) {
      df 
    }
    if (is.numeric(input$bar1[1]) & is.numeric(df[, input$x])) {
      df<- df[!is.na(df[, input$x]),]
      df <- df[df[, input$x] >= input$bar1[1]&df[, input$x] <= input$bar1[2],]
    }
    if (is.numeric(input$bar2[1]) & is.numeric(df[, input$y])) {
      df<- df[!is.na(df[, input$y]),]
      df <- df[df[, input$y] >= input$bar2[1]&df[, input$y] <= input$bar2[2],]
    }  
    if (is.null(input$in_strained_var1)) {
      df <- df 
    }
    if (!is.null(input$in_strained_var1)&input$in_strained_var1!="None") {
      df <- df[is.element(df[, input$in_strained_var1], input$in_strained_var1_not_null), ]
    }
    df
  })
  
  # - - - - - - - - - - - #
  #      strained_var2    #
  # - - - - - - - - - - - #
  output$strained_var2 <- renderUI({
    df <- core_data()
    if (is.null(df)) return(NULL)
    uniq_obs <- sapply(df, function(x){length(unique(x))})
    names_kept <- names(df)[uniq_obs < input$in_max_lvls]
    names_kept <- names_kept[names_kept != input$in_strained_var1]
    selectInput("in_strained_var2" , 
                label = "Variable 2:", 
                c('None', names_kept))
  })
  
  # - - - - - - - - - - - - - - #
  #      strained_var2_value    #
  # - - - - - - - - - - - - - - #
  output$strained_var2_value <- renderUI({
    df <- main_subset()
    if (is.null(df)) return(NULL)
    if(input$in_strained_var2 == "None") {
      selectInput('in_strained_var2_null',
                  label ='No filter variable 2 specified', 
                  choices = list(""),
                  multiple = TRUE, selectize = FALSE)   
    }
    if(input$in_strained_var2 != "None"&!is.null(input$in_strained_var2))  {
      choices <- levels(as.factor(as.character(df[, input$in_strained_var2])))
      selectInput('in_strained_var2_not_null',
                  label = paste("Select values", input$in_strained_var2),
                  choices = c(choices),
                  selected = choices,
                  multiple = TRUE, selectize = TRUE)   
    }
  })   
  
  # - - - - - - - - - - #
  #      subset_data    #
  # - - - - - - - - - - #
  subset_data  <- reactive({
    df <- main_subset()
    if (is.null(df)) return(NULL)
    if(!is.null(input$in_strained_var2)&input$in_strained_var2!="None") {
      df <- df[is.element(df[, input$in_strained_var2], input$in_strained_var2_not_null), ]
    }
    if(input$in_strained_var2 == "None") {
      df 
    }
    df
  })
  
  # - - - - - - - #
  #    cat_var1   #
  # - - - - - - - #
  output$cat_var1 <- renderUI({
    df <- core_data()
    if (is.null(df)) return(NULL)
    items = names(df)
    names(items) = items
    numer <- sapply(df, function(x) is.numeric(x))
    names_kept2 <- names(df)[numer]
    selectInput('cat_var1_in', 
                label = 'Recode into Binned Categories:',
                choices = names_kept2,
                multiple = TRUE)
  })
  
  # - - - - - - - #
  #     n_cut     #
  # - - - - - - - # 
  output$n_cut <- renderUI({
    if (length(input$cat_var1_in) < 1)  return(NULL)
    sliderInput('ncut_in',
                label = 'N of Cut Breaks:', 
                min=2, 
                max=10, 
                value=c(3),
                step=1)
  })
  
  # - - - - - - - - #
  #     cat_var2    #
  # - - - - - - - - #
  output$cat_var2 <- renderUI({
    df <- core_data()
    if (is.null(df)) return(NULL)
    items = names(df)
    names(items) = items
    numer <- sapply(df, function(x) is.numeric(x))
    names_kept2 <- names(df)[numer]
    if (length(input$cat_var1_in) >= 1) {
      names_kept2 <- names_kept2[!is.element(names_kept2, input$cat_var1_in)]
    }
    selectInput('cat_var2_in',
                label = 'Treat as Categories:',
                choices = names_kept2,
                multiple = TRUE)
  })
  
  # - - - - - - - - - - #
  #     data_recoder1   #
  # - - - - - - - - - - #
  data_recoder1  <- reactive({
    df <- subset_data()
    if (is.null(df)) return(NULL)
    if(length(input$cat_var1_in) >= 1) {
      for (i in 1:length(input$cat_var1_in)) {
        var_nam <- input$cat_var1_in[i]
        df[, var_nam] <- cut(df[, var_nam], input$ncut_in)
        df[, var_nam] <- as.factor(df[, var_nam])
      }
    }
    df
  })
  
  # - - - - - - - - - - - #
  #     data_recoder_2    #
  # - - - - - - - - - - - #
  data_recoder2  <- reactive({
    df <- data_recoder1()
    if (is.null(df)) return(NULL)
    if(length(input$cat_var2_in) >= 1) {
      for (i in 1:length(input$cat_var2_in)) {
        var_nam <- input$cat_var2_in[i]
        df[, var_nam] <- as.factor(df[, var_nam])
      }
    }
    df
  })
  
  # - - - - - - - - - #
  #    excel_table    #
  # - - - - - - - - - #
  output$excel_table = renderDataTable({
    datatable(data_recoder2() ,
              extensions = c('ColReorder','TableTools'),
              options = list(dom = 'RMD<"cvclear"C><"clear"T>lfrtip',
                             searchHighlight = TRUE,
                             pageLength=10 ,
                             lengthMenu = list(c(5, 10, 15, -1), c('5','10', '15', 'All')),
                             colReorder = list(realtime = TRUE),
                             tableTools = list(
                               "sSwfPath" = "//cdnjs.cloudflare.com/ajax/libs/datatables-tabletools/2.1.5/swf/copy_csv_xls.swf"
                             )
              ), 
              filter = 'bottom',
              style = "bootstrap")
  })
  
  # - - - - - - - - - - - - # - - - - - - - - - - - - #  # - - - - - - - - - - - - # - - - - - - - - - - - - #
  
  
  # - - - - - - - - - - - - # - - - - - - - - - - - - #
  #                                                   #
  #                   EDA Plot setups                 #
  #                                                   #
  # - - - - - - - - - - - - # - - - - - - - - - - - - #
  
  # - - - - - - - - - - - #
  #      general setup    #
  # - - - - - - - - - - - #
  
  # - - - scatter - - - #
  output$colour <- renderUI({
    df <- core_data()
    if (is.null(df)) return(NULL)
    items = names(df)
    names(items) = items
    selectInput("colorin", 
                label = "Colour By:",
                c("None", items))
  })
  
  # - - - scatter - - - #
  output$group <- renderUI({
    df <- core_data()
    if (is.null(df)) return(NULL)
    items = names(df)
    names(items) = items
    selectInput("groupin", 
                label = "Group By:",
                c("None", items))
  })
  
  # - - - scatter - - - #
  output$pointsize <- renderUI({
    df <- core_data()
    if (is.null(df)) return(NULL)
    items = names(df)
    names(items) = items
    selectInput("pointsizein", 
                label = "Size By:",
                c("None", items))
  })
  
  
  # - - - scatter - - - #
  output$fill <- renderUI({
    df <- core_data()
    if (is.null(df)) return(NULL)
    items = names(df)
    names(items) = items
    selectInput("fillin", 
                label = "Fill By:", 
                c("None", items))
  })
  
  
  # - - - - - - - - - - #
  #                     #
  #     scatter_plot    #
  #                     #
  # - - - - - - - - - - #
  
  output$x_col <- renderUI({
    df <- core_data()
    if (is.null(df)) return(NULL)
    items = names(df)
    names(items) = items
    selectInput("x", 
                label = "x variable:", 
                items)
  })
  
  output$y_col <- renderUI({
    df <- core_data()
    if (is.null(df)) return(NULL)
    items = names(df)
    names(items) = items
    selectInput("y", 
                label = "y variable:",
                items)
  })
  
  output$clickheader <-  renderUI({
    df <- data_recoder2()
    if (is.null(df)) return(NULL)
    h4("Clicked points")
  })
  
  output$brushheader <-  renderUI({
    df <- data_recoder2()
    if (is.null(df)) return(NULL)
    h4("Brushed points")
    
  })
  
  output$plot_clickedpoints <- renderTable({
    df <- data_recoder2()  
    if (is.null(df)) return(NULL)
    res <- nearPoints(data_recoder2(), input$plot_click, input$x, input$y)
    if (nrow(res) == 0|is.null(res))
      return(NULL)
    res
  })
  
  output$plot_brushedpoints <- renderTable({
    df <- data_recoder2()  
    if (is.null(df)) return(NULL)
    res <- brushedPoints(data_recoder2(), input$plot_brush, input$x, input$y)
    if (nrow(res) == 0|is.null(res))
      return(NULL)
    res
  })
  
  output$plotinfo <- renderPrint({
    df<- data_recoder2()  
    if (is.null(df)) return(NULL)
    nearPoints(data_recoder2(), input$plot_click, 
               threshold = 5, maxpoints = 5,
               addDist = TRUE, xvar = input$x, yvar = input$y)
  })
  
  output$optionsmenu_scatter <-  renderUI({
    df <- core_data()
    if (is.null(df)) return(NULL) 
    fluidRow(
      hr(),      
      column(4, checkboxInput('showplottypes', 'Check to customize plot components:', value = TRUE)),
      column(4, checkboxInput('showfacets', 'Check to customize aggregation options', value = TRUE))
    )
  })
  
  
  # - - - - - - - - - - #
  #     Scatter Plot    #
  # - - - - - - - - - - #
  
  plot_scat <- reactive({
    plot_data <- data_recoder2()
    
    if(!is.null(plot_data)) {
      
      p <- ggplot(plot_data, aes_string(x = input$x, y = input$y)) 
      
      if (input$Points == "Points" & input$pointsizein == 'None')
        p <- p + geom_point(, alpha = input$pointstransparency, 
                            shape = input$pointtypes,
                            size = input$pointsizes)  
      if (input$Points == "Points" & input$pointsizein != 'None')
        p <- p + geom_point(, alpha = input$pointstransparency,
                            shape = input$pointtypes)  
      if (input$line == "Lines" & input$pointsizein == 'None')
        p <- p + geom_line(, size = input$linesize,
                           alpha = input$linestransparency,
                           linetype = input$linetypes)
      if (input$line == "Lines" & input$pointsizein != 'None')
        p <- p + geom_line(, alpha = input$linestransparency,
                           linetype = input$linetypes)
      if (input$pointsizein != 'None')
        p <- p + aes_string(size = input$pointsizein)
      if (input$Points == "Jitter")
        p <- p + geom_jitter()
      if (input$colorin != 'None')
        p <- p + aes_string(color = input$colorin)
      if (input$fillin != 'None')
        p <- p + aes_string(fill = input$fillin)
      if (input$groupin != 'None' & !is.factor(plot_data[, input$x]))
        p <- p + aes_string(group = input$groupin)
      if (input$groupin != 'None' & is.factor(plot_data[, input$x]))
        p <- p + aes(group = 1)
      
      p
    }
  })
  
  output$plot_scatter <- renderPlot({
    plot_scat()
  })
  
  
  
  
  
  
  # - - - - - - - - - - - - # - - - - - - - - - - - - #  # - - - - - - - - - - - - # - - - - - - - - - - - - #
  
  
  # - - - - - - - - - - - - # - - - - - - - - - - - - #
  #                                                   #
  #                    BarPlot setups                 #
  #                                                   #
  # - - - - - - - - - - - - # - - - - - - - - - - - - #
  
  # - - - - - - - - - - #
  #    categorical X.   #
  # - - - - - - - - - - #
  
  output$x_col_cat <- renderUI({
    df <- core_data()
    if (is.null(df)) return(NULL)
    items = names(df)
    cat_name = items[sapply(df[, items], is.factor)]
    names(cat_name) = cat_name
    selectInput("x_br_cat", 
                label = "Categorical variable:", 
                cat_name)
  })
  
  
  # - - - - - - - - - - #
  #     Options Menu    #
  # - - - - - - - - - - # 
  
  output$optionsmenu_bar <-  renderUI({
    df <- core_data()
    if (is.null(df)) return(NULL) 
    fluidRow(
      hr(),      
      column(4, checkboxInput('showplottypes_br', 'Check to customize plot components:', value = TRUE)),
      column(4, checkboxInput('showfacets_br', 'Check to customize aggregation options', value = TRUE))
    )
  })
  
  # - - - - - - - - - - - #
  #      general setup    #
  # - - - - - - - - - - - #
  
  # - - - bar - - - #
  output$colour_br <- renderUI({
    df <- core_data()
    if (is.null(df)) return(NULL)
    items = names(df)
    cat_name = items[sapply(df[, items], is.factor)]
    names(cat_name) = cat_name
    selectInput("colorin_br", 
                label = "Colour By:",
                c("None", cat_name))
  })
  
  # - - - bar - - - #
  output$fill_br <- renderUI({
    df <- core_data()
    if (is.null(df)) return(NULL)
    items = names(df)
    cat_name = items[sapply(df[, items], is.factor)]
    names(cat_name) = cat_name
    selectInput("fillin_br", 
                label = "Fill By:", 
                c("None", cat_name))
  })
  
  
  
  # - - - - - - - - - - #
  #       Bar Plot      #
  # - - - - - - - - - - #
  plot_br <- reactive({
    
    plot_brr <- core_data()
    
    if(!is.null(plot_brr)){
      p <- ggplot(plot_brr, aes_string(x = input$x_br_cat)) 
      
      if (input$Bar == 'bar')
        p <- p + geom_bar(, stat = 'count', 
                          alpha = input$barstransparency)        
      if (input$colour_br != 'None')
        p <- p + aes_string(color = input$colourin_br)  
      if (input$fillin_br != 'None')
        p <- p + aes_string(fill = input$fillin_br)  
    }
    p    
  })
  
  output$plot_bar <- renderPlot({
    plot_br()
  })
  
  # - - - - - - - - - - - - # - - - - - - - - - - - - #  # - - - - - - - - - - - - # - - - - - - - - - - - - #
  
  
  # - - - - - - - - - - - - # - - - - - - - - - - - - #
  #                                                   #
  #                    BoxPlot setups                 #
  #                                                   #
  # - - - - - - - - - - - - # - - - - - - - - - - - - #
  
  # - - - - - - - - - - #
  #    categorical X.   #
  # - - - - - - - - - - #
  
  output$x_col_bx <- renderUI({
    df <- core_data()
    if (is.null(df)) return(NULL)
    items = names(df)
    cat_name = items[sapply(df[, items], is.factor)]
    names(cat_name) = cat_name
    selectInput("x_bx_cat", 
                label = "X variable (categorical):", 
                cat_name)
  })
  
  
  # - - - - - - - - #
  #    numeric Y.   #
  # - - - - - - - - #
  output$y_col_bx <- renderUI({
    df <- core_data()
    if (is.null(df)) return(NULL)
    items = names(df)
    num_name = items[sapply(df[, items], is.numeric)]
    names(num_name) = num_name
    selectInput("y_bx_num", 
                label = "Y variable (numeric):", 
                num_name)
  })
  
  # - - - - - - - - - - #
  #     Options Menu    #
  # - - - - - - - - - - # 
  
  output$optionsmenu_bar <-  renderUI({
    df <- core_data()
    if (is.null(df)) return(NULL) 
    fluidRow(
      hr(),      
      column(4, checkboxInput('showplottypes_bx', 'Check to customize plot components:', value = TRUE)),
      column(4, checkboxInput('showfacets_bx', 'Check to customize aggregation options', value = TRUE))
    )
  })
  
  
  # - - - - - - - - - - #
  #       Box Plot      #
  # - - - - - - - - - - #
  plot_bx <- reactive({
    
    plot_bxx <- core_data()
    
    if(!is.null(plot_bxx)){
      p <- ggplot(plot_bxx, aes_string(x = input$x_bx_cat, y = input$y_bx_num)) + 
        geom_boxplot(, alpha = input$bxstransparency)      
      
    }
    p    
  })
  
  
  output$plot_box <- renderPlot({
    plot_bx()
  })
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
})