library(dplyr)
library(ggplot2)
library(ggthemes)
library(shiny)
library(DT)

shinyServer(function(input, output){

  # -- Adult data set
  
  output$table <- DT::renderDataTable({
    datatable(adult1, 
      rownames=FALSE) %>% formatStyle(input$selectCol, background="skyblue", fontWeight='bold')
  })
  
  # -- warning
  
  output$tabEd_warning <- renderInfoBox({
    infoBox(img(src="high.ed.small.jpg"), "Reminder : Each plot has different data size (see counters at top)!", 
      icon=icon("exclamation-triangle"), color="yellow", fill=TRUE)
  })
  output$tabHour_warning <- renderInfoBox({
    infoBox(img(src="work.hard.small.jpg"), "Reminder : Each plot has different data size (see counters at top)!", 
            icon=icon("exclamation-triangle"), color="yellow", fill=TRUE)
  })
  output$tabMarriage_warning <- renderInfoBox({
    infoBox(img(src="marriage.small.jpg"), "Reminder : Each plot has different data size (see counters at top)!", 
            icon=icon("exclamation-triangle"), color="yellow", fill=TRUE)
  })  
  
  # -- Higher Education

  output$tabEd_box1 <- renderValueBox({
    valueBox(count(adult1),
      "[Race=All,Work=All]", icon=icon("info"), color="green")
  })
  output$tabEd_box2 <- renderValueBox({
    valueBox(count(adult1[adult1$race==input$selectRace,]),
      "[Race=Selected,Work=All]", icon=icon("info"), color="green")
  })
  output$tabEd_box3 <- renderValueBox({
    valueBox(count(adult1[adult1$workclass==input$selectWorkClass,]),
      "[Race=All,Work=Selected]", icon=icon("info"), color="green")
  })
  output$tabEd_box4 <- renderValueBox({
    valueBox(count(adult1[adult1$race==input$selectRace & adult1$workclass==input$selectWorkClass,]),
      "[Race=Selected,Work=Selected]", icon=icon("info"), color="green")
  })
  
  output$tabEd_plot1 <- renderPlot({
    ggplot(adult1, 
      aes(x=class, y=education_num)) + geom_boxplot() + facet_wrap(~sex) +
      labs(x = "", y = "# education years", title = "[Race=All,Work=All]") 
    # + theme_economist() + scale_fill_economist()
  })
  output$tabEd_plot2 <- renderPlot({
    
    validate(
      need(TRUE,
        # sum(as.character(adult1$race)==input$selectRace & 
        #          as.character(adult1$workclass)==input$selectWorkClass) > 0,
      "Sorry cannot plot [Race=Selected,Work=Selected] since no data.  Please check counters above.")
    )
    
    # validate(
    #   need(count(adult1[adult1$race==input$selectRace & 
    #                       adult1$workclass==input$selectWorkClass,]) > 0, 
    #   "Sorry cannot plot [Race=Selected,Work=Selected] since no data.  Please check counters above.")
    # )
    
    ggplot(adult1[adult1$race==input$selectRace & adult1$workclass==input$selectWorkClass,], 
      aes(x=class, y=education_num)) + geom_boxplot() + facet_wrap(~sex) +
      labs(x = "", y = "# education years", title = "[Race=Selected,Work=Selected]") 
    # + theme_economist() + scale_fill_economist() 
  })
  output$tabEd_plot3 <- renderPlot({
    ggplot(adult1[adult1$race==input$selectRace,], 
      aes(x=class, y=education_num)) + geom_boxplot() + facet_wrap(~sex) +
      labs(x = "", y = "# education years", title = "[Race=Selected,Work=All]") 
    # + theme_economist() + scale_fill_economist() 
  })
  output$tabEd_plot4 <- renderPlot({
    validate(need(count(adult1[adult1$workclass==input$selectWorkClass,]) > 0, 
      "Sorry cannot plot [Race=All,Work=Selected] since no data.  Please check counters above.")
    )
    ggplot(adult1[adult1$workclass==input$selectWorkClass,], 
      aes(x=class, y=education_num)) + geom_boxplot() + facet_wrap(~sex) +
      labs(x = "", y = "# education years", title = "[Race=All,Work=Selected]") 
    # + theme_economist() + scale_fill_economist() 
  })
  
  # -- Work Hard
  
  output$tabHour_box1 <- renderValueBox({
    valueBox(count(adult1),
      "[Race=All,Work=All]", icon=icon("info"), color="green")
  })
  output$tabHour_box2 <- renderValueBox({
    valueBox(count(adult1[adult1$race==input$selectRace,]),
      "[Race=Selected,Work=All]", icon=icon("info"), color="green")
  })
  output$tabHour_box3 <- renderValueBox({
    valueBox(count(adult1[adult1$workclass==input$selectWorkClass,]),
      "[Race=All,Work=Selected]", icon=icon("info"), color="green")
  })
  output$tabHour_box4 <- renderValueBox({
    valueBox(count(adult1[adult1$race==input$selectRace & adult1$workclass==input$selectWorkClass,]),
      "[Race=Selected,Work=Selected]", icon=icon("info"), color="green")
  })

  output$tabHour_plot1 <- renderPlot({
    ggplot(adult1, 
      aes(x=class, y=hours_per_week)) + geom_boxplot() + facet_wrap(~sex) +
      labs(x = "", y = "work hours / week", title = "[Race=All,Work=All]") 
    + theme_economist() + scale_fill_economist() 
  })
  output$tabHour_plot2 <- renderPlot({
     validate(need(count(adult1[adult1$race==input$selectRace & adult1$workclass==input$selectWorkClass,]) > 0, 
      "Sorry cannot plot [Race=Selected,Work=Selected] since no data.  Please check counters above.")
    )
   ggplot(adult1[adult1$race==input$selectRace & adult1$workclass==input$selectWorkClass,], 
      aes(x=class, y=hours_per_week)) + geom_boxplot() + facet_wrap(~sex) +
      labs(x = "", y = "work hours / week", title = "[Race=Selected,Work=Selected]") 
   # + theme_economist() + scale_fill_economist() 
  })
  output$tabHour_plot3 <- renderPlot({
    ggplot(adult1[adult1$race==input$selectRace,], 
      aes(x=class, y=hours_per_week)) + geom_boxplot() + facet_wrap(~sex) +
      labs(x = "", y = "work hours / week", title = "[Race=Selected,Work=All]")
    # + theme_economist() + scale_fill_economist() 
  })
  output$tabHour_plot4 <- renderPlot({
    validate(need(count(adult1[adult1$workclass==input$selectWorkClass,]) > 0, 
      "Sorry cannot plot [Race=All,Work=Selected] since no data.  Please check counters above.")
    )
    ggplot(adult1[adult1$workclass==input$selectWorkClass,], 
      aes(x=class, y=hours_per_week)) + geom_boxplot() + facet_wrap(~sex) +
      labs(x = "", y = "work hours / week", title = "[Race=All,Work=Selected]")
    # + theme_economist() + scale_fill_economist() 
  })

  # -- Happy Marriage
  
  output$tabMarriage_box1 <- renderValueBox({
    valueBox(count(adult1),
      "[Race=All,Work=All]", icon=icon("info"), color="green")
  })
  output$tabMarriage_box2 <- renderValueBox({
    valueBox(count(adult1[adult1$race==input$selectRace,]),
      "[Race=Selected,Work=All]", icon=icon("info"), color="green")
  })
  output$tabMarriage_box3 <- renderValueBox({
    valueBox(count(adult1[adult1$workclass==input$selectWorkClass,]),
      "[Race=All,Work=Selected]", icon=icon("info"), color="green")
  })
  output$tabMarriage_box4 <- renderValueBox({
    valueBox(count(adult1[adult1$race==input$selectRace & adult1$workclass==input$selectWorkClass,]),
      "[Race=Selected,Work=Selected]", icon=icon("info"), color="green")
  })
    
  output$tabMarriage_plot1 <- renderPlot({
    ggplot(adult1, 
      aes(x=marital_status)) + 
      geom_bar(aes(fill=marital_status)) + facet_grid(class ~ sex) +
      xlab("marital status") + theme_economist() + scale_fill_economist() + ggtitle("[Race=All,Work=All]")
  })
  output$tabMarriage_plot2 <- renderPlot({
    validate(need(count(adult1[adult1$race==input$selectRace & adult1$workclass==input$selectWorkClass,]) > 0, 
      "Sorry cannot plot [Race=Selected,Work=Selected] since no data.  Please check counters above.")
    )
    ggplot(adult1[adult1$race==input$selectRace & adult1$workclass==input$selectWorkClass,], 
      aes(x=marital_status)) + 
      geom_bar(aes(fill=marital_status)) + facet_grid(class ~ sex) +
      xlab("marital status") + 
      # theme_economist() + scale_fill_economist() + 
      ggtitle("[Race=Selected,Work=Selected]")
  })
  output$tabMarriage_plot3 <- renderPlot({
    ggplot(adult1[adult1$race==input$selectRace,], 
      aes(x=marital_status)) + 
      geom_bar(aes(fill=marital_status)) + facet_grid(class ~ sex) +
      xlab("marital status") + 
      # theme_economist() + scale_fill_economist() + 
      ggtitle("[Race=Selected,Work=All]")
  })
  output$tabMarriage_plot4 <- renderPlot({
    validate(need(count(adult1[adult1$workclass==input$selectWorkClass,]) > 0, 
      "Sorry cannot plot [Race=All,Work=Selected] since no data.  Please check counters above.")
    )
    ggplot(adult1[adult1$workclass==input$selectWorkClass,], 
      aes(x=marital_status)) + 
      geom_bar(aes(fill=marital_status)) + facet_grid(class ~ sex) +
      xlab("marital status") + 
      # theme_economist() + scale_fill_economist() + 
      ggtitle("[Race=All,Work=Selected]")
  })
  
})