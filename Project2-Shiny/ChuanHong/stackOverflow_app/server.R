## server.R ##
library(dplyr)
library(googleVis)


count_tag_mon <- function(data) {
  data %>% mutate(Date = format(as.Date(CreationDate), "%Y-%m")) %>% 
    filter(Date > "2008-12" & Date < "2016-10") %>%
    group_by(Date, Tag) %>% 
    summarise(count_item = n(),
              count_user = n_distinct(OwnerUserId))
}

function(input, output, session) {
  
  observe({
    if(input$lan == "Python") {
      if(input$cat == "Packages") {
        choices <- p_pkg_top[[1]]
        updateSelectizeInput(session, "tag", "Select Python Packages", 
                             choices, choices[1:5])
      } else {
        choices <- p_tpc_top[[1]]
        updateSelectizeInput(session, "tag", "Select Python Topics", 
                             choices, choices[1:5])
      }
    } else if(input$lan == "R") {
      if(input$cat == "Packages") {
        choices <- r_pkg_top[[1]]
        updateSelectizeInput(session, "tag", "Select R Packages", 
                             choices, choices[1:5])
      } else {
        choices <- r_tpc_top[[1]]
        updateSelectizeInput(session, "tag", "Select R Topics", 
                             choices, choices[1:5])
      }
    }

  })
  
  qa_tag_cnt <- reactive({
    input$go
    if(input$lan == "Python") {
      tag_cnt <- p_tag_cnt
    } else if(input$lan == "R") {
      tag_cnt <- r_tag_cnt
    } else {
      return(qa_cnt)
    }
    date <- data.frame(Date = seq.Date(min(tag_cnt$Date), max(tag_cnt$Date),
                                       by = "month"))
    tags <- data.frame(Tag = isolate(input$tag))
    holder <- merge(x = date, y = tags, by = NULL)
    tag_cnt <- holder %>% left_join(tag_cnt, by = c("Date", "Tag")) %>%
      rename(Language = Tag)
    tag_cnt[is.na(tag_cnt)] <- 0
    return(tag_cnt)
  })

  output$gvisMotion <- renderGvis({
    gvisMotionChart(qa_tag_cnt(), idvar = "Language", timevar = "Date")
  })

  
  output$gvisBar <- renderGvis({
    
    if(input$lan == "Python") {
      if(input$cat == "Packages") {
        g <- gvisBarChart(p_pkg_top[1:20,], 
                          options=list(height="600px"))
      } else {
        g <- gvisBarChart(p_tpc_top[1:20,], 
                          options=list(height="600px"))
      }
    } else if(input$lan == "R") {
      if(input$cat == "Packages") {
        g <- gvisBarChart(r_pkg_top[1:20,], 
                          options=list(height="600px"))
      } else {
        g <- gvisBarChart(r_tpc_top[1:20,], 
                          options=list(height="600px"))
      }
    } else {
      tag_top <- subset(qa_cnt, select = -Date) %>%
        group_by(Language) %>%
        summarise_each(funs(sum))
      g <- gvisColumnChart(tag_top, 
                           options=list(height="600px"))
    }
    g
  })

  
}