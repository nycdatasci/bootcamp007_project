## server.R ##
library(googleVis)

TOP_N <- 100
## load general data
qa_cnt <- readRDS("./data/qa_cnt.rds")

## load python data
p_tags <- readRDS("./data/python/Tags.rds")
p_pkgs <- readRDS("./data/python/python_pkgs.rds")
p_tag_cnt <- readRDS("./data/python/Tags_count.rds")

## load r data
r_tags <- readRDS("./data/r/Tags.rds")
r_pkgs <- readRDS("./data/r/r_pkgs.rds")
r_tag_cnt <- readRDS("./data/r/Tags_count.rds")

count_tag_mon <- function(data) {
  data %>% mutate(Date = format(as.Date(CreationDate), "%Y-%m")) %>% 
    filter(Date > "2008-12" & Date < "2016-10") %>%
    group_by(Date, Tag) %>% 
    summarise(count_item = n(),
              count_user = n_distinct(OwnerUserId))
}

function(input, output, session) {
  
  output$cateInput <- renderUI({
    if(!is.null(input$lan) & input$lan != "All") {
      selectizeInput("cat", "Choose Category", 
                     choices = c("Packages", "Topics"),
                     width = 200)
    }
  })
  
  output$pkgsInput <- renderUI({
    if(length(input$cat) > 0 && input$cat == "Packages") {
      if(input$lan == "Python") {
        selectizeInput("pkg", "Choose Packages", 
                       choices = as.character(top_pkgs()$package),
                       selected = top_pkgs()$package[1:5],
                       multiple = TRUE,
                       options = list(maxItems = 20),
                       width = 400)
      } else if(input$lan == "R") {
        selectizeInput("pkg", "Choose Packages", 
                       choices = as.character(top_pkgs()$package),
                       selected = top_pkgs()$package[1:5],
                       multiple = TRUE,
                       options = list(maxItems = 20),
                       width = 400)
      }
    } else if(length(input$cat) > 0 && input$cat == "Topics") {
      if(input$lan == "Python") {
        selectizeInput("pkg", "Choose Topics", 
                       choices = top_pkgs()$package,
                       selected = top_pkgs()$package[1:5],
                       multiple = TRUE,
                       options = list(maxItems = 10),
                       width = 400)
      } else if(input$lan == "R") {
        selectizeInput("pkg", "Choose Topics", 
                       choices = top_pkgs()$package,
                       selected = top_pkgs()$package[1:5],
                       multiple = TRUE,
                       options = list(maxItems = 10),
                       width = 400)
      }
    }
  })
  
  qa_tag_cnt <- reactive({
    tag_cnt <- qa_cnt
    if(input$lan != "All") {
      tag_cnt <- ifelse(input$lan == "Python", p_tag_cnt, r_tag_cnt)
      tag_cnt <- p_tag_cnt %>% filter(Tag %in% input$pkg)
      
      date <- data.frame(Date = seq.Date(min(tag_cnt$Date), max(tag_cnt$Date),
                                         by = "month"))
      tags <- data.frame(Tag = input$pkg)
      holder <- merge(x = date, y = tags, by = NULL)
      tag_cnt <- holder %>% left_join(tag_cnt, by = c("Date", "Tag")) %>%
        rename(Language = Tag)
      tag_cnt[is.na(tag_cnt)] <- 0
    }
    return(tag_cnt)
  })

  output$gvisMotion <- renderGvis({
    input$go
    isolate(
      gvisMotionChart(qa_tag_cnt(), idvar = "Language", timevar = "Date")
    )
    
  })
  
  top_pkgs <- reactive({
    if(input$lan == "Python") {
      top_pkgs <- data.frame(count = table(p_tags$Tag)) %>% 
        rename(package = count.Var1,
               `Tag count` = count.Freq)
      if(input$cat == "Packages") {
        top_pkgs <- top_pkgs %>%
          filter(package %in% p_pkgs)
      } else {
        top_pkgs <- top_pkgs %>%
          filter(!(package %in% c("python", p_pkgs)))
      }
      top_pkgs <- top_pkgs %>%
        top_n(TOP_N, `Tag count`) %>%
        arrange(desc(`Tag count`))
    } else if(input$lan == "R") {
      top_pkgs <- data.frame(count = table(r_tags$Tag)) %>% 
        rename(package = count.Var1,
               `Tag count` = count.Freq)
      if(input$cat == "Packages") {
        top_pkgs <- top_pkgs %>%
          filter(package %in% r_pkgs)
      } else {
        top_pkgs <- top_pkgs %>%
          filter(!(package %in% r_pkgs))
      }
      top_pkgs <- top_pkgs %>%
        top_n(TOP_N, `Tag count`) %>%
        arrange(desc(`Tag count`))
    } else {
      top_pkgs <- subset(qa_cnt, select = -Date) %>%
        group_by(Language) %>%
        summarise_each(funs(sum))
    }
  })
  
  output$gvisBar <- renderGvis({
    validate(
      need(is.data.frame(top_pkgs()), "Select a language to see")
    )
    isolate(
      if(input$lan == "All") {
        gvisColumnChart(top_pkgs(), 
                        options=list(height="600px"))
      } else {
        gvisBarChart(top_pkgs()[1:20,], 
                     options=list(height="600px"))
      }
    )
    
    
  })

  
}