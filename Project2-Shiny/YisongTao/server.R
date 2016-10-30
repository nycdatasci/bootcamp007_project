library(leaflet)
library(RColorBrewer)
library(scales)
library(ggplot2)
library(plotly)
library(dplyr)
library(sp)


function(input, output, session) {
  ## Interactive Map ###########################################
  colorData <- colorFactor(c('#377eb8','#4daf4a','#e41a1c'), domain = levels(hs_SAT_survey$Admission_Priority))
  # Create the map
  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles(
        urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
        attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>'
      ) %>% 
      setView(lng = -73.887141, lat = 40.701037, zoom = 11) %>%
    addPolygons(data = sd, stroke = T, smoothFactor = 0.5, 
    	fill = F, weight = 2, color = "orange", group = "School District", layerId= ~sd@data$school_dis) 

  })
  output$SAT_2012_hist <- renderPlot({
          
          ggplot(df) + 
              geom_histogram(aes(x=SAT, fill = Year), bins = 50, 
                             position = "dodge", na.rm = T) +
              theme_minimal() + theme(legend.position = c(0.9, 0.5) )+
              scale_fill_manual(values = c("blue", "orange")) +
              xlab("SAT Score \n (Student Avg.)") +
              ylab("Number of Schools") +
              ggtitle("NYC High School SAT Scores Distribution")
      })
  output$survey_2011_hist <- renderPlot({

    ggplot(hs_SAT_survey) + geom_histogram(aes(x=survey), bins = 50, 
                                           fill = "purple", na.rm = T, 
                                           alpha = 1) +
          theme_minimal() + 
          ggtitle("2011 High School Survey Rating ") +
          xlab("2011 High School Survey Rating") + ylab("Number of Schools")
  })
  output$student_number <- renderPlot({
      ggplot(hs_SAT_survey) + geom_histogram(aes(x=total_students), bins = 50,
                                             fill = "green", alpha = 1) +
          theme_minimal() + ggtitle("2016 Number of Students Distribution") +
          xlab("Number of Students") + ylab("Number of Schools")
  })

  # This observer is responsible for maintaining the markers,
  # according to the variables the user-chosen marker size. 
  # Decided not to use variable marker size in the end, this part could be moved to the main map renedering function.
  observe({
    #radius <- hs_SAT_survey$tot_radius 
     radius <- 6

    leafletProxy("map", data = hs_SAT_survey) %>%
      addCircleMarkers(~lng, ~lat, layerId=~ID, color=~colorData(Admission_Priority),
       stroke = FALSE, fillOpacity = 0.8, radius = radius, group = "School") %>%
      addLegend("bottomleft", pal=colorData, values=levels(hs_SAT_survey$Admission_Priority),
                title="Admission Priority", opacity = 0.5, layerId="colorLegend") %>%
      addLayersControl(
        overlayGroups = c("School District", "School"),
        options = layersControlOptions(collapsed = T), position = "topleft")
  })

  # Show a popup at the given location school pop up
  showHsPopup <- function(ID, lat, lng) {
    selectedHS <- hs_SAT_survey[hs_SAT_survey$ID == ID,]
    sname <- paste0("<a href='http://",selectedHS$Website, "'>", selectedHS$school_name,"</a>")
    content <- as.character(tagList(
      tags$h4(HTML(sname)),
      tags$strong(HTML(sprintf("%s", selectedHS$addr_1
      ))), tags$br(), 
      tags$strong(HTML(sprintf("%s", selectedHS$addr_2
      ))) 
    ))
    leafletProxy("map") %>% addPopups(lng, lat, content,
                                      layerId = ID, 
                                      popupOptions(keepInView = T))
  }
  ## update plots when a school is selected
  updatePlots <- function(ID) {
      output$SAT_2012_hist <- renderPlot({
          if (is.na(hs_SAT_survey$SAT_2012[hs_SAT_survey$ID == ID]) &
              is.na(hs_SAT_survey$SAT_2010[hs_SAT_survey$ID == ID])) {
              ggplot(df) + 
                  geom_histogram(aes(x=SAT, fill = Year), bins = 50, 
                                 position = "dodge", na.rm = T) +
                  theme_minimal() + theme(legend.position = c(0.9, 0.5) )+
                  scale_fill_manual(values = c("blue", "orange")) +
                  xlab("SAT Score \n (Student Avg.)") +
                  ylab("Number of Schools") +
                  ggtitle("NYC High School SAT Scores Distribution")
          }else if (!is.na(hs_SAT_survey$SAT_2012[hs_SAT_survey$ID == ID])){
              value1 <- hs_SAT_survey$SAT_2012[hs_SAT_survey$ID == ID]
              ggplot(hs_SAT_survey) + 
                  geom_histogram(aes(x=SAT_2012), bins = 50, 
                                 fill = "orange", na.rm = T, alpha = 0.2) +
                  theme_minimal() +
                  xlab("2012 SAT Score \n (Student Avg.)") + ylab("Number of Schools") +
                  ggtitle("2012 SAT Scores Distribution") +
                  geom_vline(xintercept = value1, color = 'red') 
          }else {
              value1 <- hs_SAT_survey$SAT_2010[hs_SAT_survey$ID == ID]
              ggplot(hs_SAT_survey) + 
                  geom_histogram(aes(x=SAT_2010), bins = 50, 
                                 fill = "blue", na.rm = T, alpha = 0.2) +
                  theme_minimal() +
                  xlab("2010 SAT Score \n (Student Avg.)") + ylab("Number of Schools") +
                  ggtitle("2010 SAT Scores Distribution") +
                  geom_vline(xintercept = value1, color = 'red') 
          }
          
      })
      value2 <- hs_SAT_survey$total_students[hs_SAT_survey$ID == ID]
      output$student_number <- renderPlot({
          ggplot(hs_SAT_survey) + geom_histogram(aes(x=total_students), bins = 50,
                                                 fill = "green", alpha = 0.2) +
              theme_minimal() + ggtitle("2016 Number of Students Distribution") +
              xlab("Number of Students") + ylab("Number of Schools") +
              geom_vline(xintercept = value2, color = 'red')
      })
      
      output$survey_2011_hist <- renderPlot({
          p2 <- ggplot(hs_SAT_survey) + geom_histogram(aes(x=survey), bins = 50, 
                                                       fill = "purple", na.rm = T, 
                                                       alpha = 0.2) +
              theme_minimal() + 
              ggtitle("2011 High School Survey Rating ") +
              xlab("2011 High School Survey Rating") + ylab("Number of Schools")
          
          value <- hs_SAT_survey$survey[hs_SAT_survey$ID == ID]
          if (is.na(value)) {
              ggplot(hs_SAT_survey) + 
                  geom_histogram(aes(x=survey), bins = 50, fill = "purple", na.rm = T) +
                  theme_minimal() + 
                  ggtitle("2011 High School Survey Rating Distribution") +
                  xlab("2011 High School Survey Rating") + ylab("Number of Schools")
          }else{
              p2 + geom_vline(xintercept = value, color = 'red')
          } 
      })
  }
  ## shows school info in panel when a school is selected
  updatehtml <- function(ID) {
      selectedHS <- hs_SAT_survey[hs_SAT_survey$ID == ID,]
      sname <- paste0("<a href='http://",selectedHS$Website, "'>", selectedHS$school_name,"</a>")
      email <- ifelse(!is.na(selectedHS$Email), 
                      paste0("<a href='mailto:",selectedHS$Email, "'>", selectedHS$Email,"</a>"), 
                      NA)
      
      output$School_Info <- renderUI(tagList(
          tags$h4(HTML(sname)),tags$br(),
          tags$strong(HTML(sprintf("%s", selectedHS$addr_1))),
          tags$br(), 
          tags$strong(HTML(sprintf("%s", selectedHS$addr_2))),
          tags$br(),tags$br(),
          if (!is.na(email)){
          tags$strong(HTML(sprintf("Email: %s", email)))},
          tags$br(),
          tags$strong(HTML(sprintf("Phone: %s", selectedHS$Phone_Number))),
          tags$br(),
          if (!is.na(selectedHS$Fax_Number)){
          tags$strong(HTML(sprintf("Fax: %s", selectedHS$Fax_Number)))},
          tags$br(), 
          if (!is.na(selectedHS$SAT_2012)) {
          tags$strong(HTML(sprintf("2012 SAT Score (Student Avg.): %s",
                                   selectedHS$SAT_2012)))
          },
          tags$br(),
          if (!is.na(selectedHS$SAT_2010)) {
          tags$strong(HTML(sprintf("2010 SAT Score (Student Avg.): %s",
                                   selectedHS$SAT_2010)))
          },
          tags$br(),
          if (!is.na(selectedHS$survey)){
          tags$strong(HTML(sprintf("2011 High School Survey Rating: %s",
                                   selectedHS$survey)))},
          tags$br(),
          tags$strong(HTML(sprintf("2016 Number of Students: %s",
                                   selectedHS$total_students)))
      ))
  }

  # When map is clicked, show a popup with school info, show school info in panel and update plots
  observe({
    leafletProxy("map") %>% clearPopups()
    event <- input$map_marker_click
    if (is.null(event))
      return()

    isolate({
      showHsPopup(event$id, event$lat, event$lng)
      updatePlots(event$id)
      updatehtml(event$id)
    })
  })

  ### clear school info, popup and reset plots on map click
  observe({
      if (is.null(input$map_click)) {
          return(NULL)
      } else{
          output$School_Info <- renderUI(tagList())
          leafletProxy("map") %>% clearPopups()
          output$survey_2011_hist <- renderPlot({
              
              ggplot(hs_SAT_survey) + geom_histogram(aes(x=survey), bins = 50, 
                                                     fill = "purple", na.rm = T, 
                                                     alpha = 1) +
                  theme_minimal() + 
                  ggtitle("2011 High School Survey Rating ") +
                  xlab("2011 High School Survey Rating") + ylab("Number of Schools")
          })
          output$SAT_2012_hist <- renderPlot({
              ggplot(df) + 
                  geom_histogram(aes(x=SAT, fill = Year), bins = 50, 
                                 position = "dodge", na.rm = T) +
                  theme_minimal() + theme(legend.position = c(0.9, 0.5) )+
                  scale_fill_manual(values = c("blue", "orange")) +
                  xlab("SAT Score \n (Student Avg.)") +
                  ylab("Number of Schools") +
                  ggtitle("NYC High School SAT Scores Distribution")
          })
          output$student_number <- renderPlot({
              ggplot(hs_SAT_survey) + geom_histogram(aes(x=total_students), bins = 50,
                                                     fill = "green", alpha = 1) +
                  theme_minimal() + ggtitle("2016 Number of Students Distribution") +
                  xlab("Number of Students") + ylab("Number of Schools")
          })
      }
  })
  ## Data Explorer ###################################################

  observe({
    neighborhoods <- if (is.null(input$boroughs)) character(0) else {
      filter(hs_info_disp, Borough %in% input$boroughs) %>%
        `$`('Neighborhood') %>%
        unique() %>%
        sort()
    }
    stillSelected <- isolate(input$neighborhoods[input$neighborhoods %in% neighborhoods])
    updateSelectInput(session, "neighborhoods", choices = neighborhoods,
      selected = stillSelected)
  })

  
########################################################################
  observe({
    if (is.null(input$goto))
      return()
    isolate({
      map <- leafletProxy("map")
      map %>% clearPopups()
      
      ID1 <- input$goto$ID
      lat <- input$goto$lat
      lng <- input$goto$lng
      showHsPopup(ID1, lat, lng)
      updatePlots(ID1)
      updatehtml(ID1)
    })
  })


  output$hs_info <- DT::renderDataTable({
    df2 <- hs_SAT_survey %>%
          filter(
              is.null(input$boroughs) | Borough %in% input$boroughs,
              is.null(input$neighborhoods) | Neighborhood %in% input$neighborhoods
          )
    df <- hs_info_disp %>%
      filter(
        is.null(input$boroughs) | Borough %in% input$boroughs,
        is.null(input$neighborhoods) | Neighborhood %in% input$neighborhoods
        ) %>%
      mutate(Go_to_Map = paste('<a class="go-map" href="" data-lat="', df2$lat, '" data-long="', df2$lng,
                            '" data-id="', df2$ID, '">', School_Name,'</a>', sep=""))
    df <- df %>% select(-School_Name) %>% 
        select(DBN, School_Name = Go_to_Map, Grades, Admission_Priority,
               School_District, Borough, Neighborhood)
    action <- DT::dataTableAjax(session, df)

    DT::datatable(df, options = list(ajax = list(url = action)), 
                  escape = FALSE, selection = 'single')
  })
 
  observe({
     
     if (is.null(input$hs_info_rows_selected)) {
         output$School_Info_dt <- renderUI(tagList())
         return()
         }
     output$School_Info_dt <- renderUI({
        selected<-input$hs_info_rows_selected
        selected_hs <- hs_SAT_survey[hs_SAT_survey$ID == selected,]
        selected_sd <- hs_info_disp$School_District[hs_SAT_survey$ID == selected]
        selected_grades <- hs_info_disp$Grades[hs_SAT_survey$ID == selected]
        sname <- paste0("<a href='http://",selected_hs$Website, "'>", selected_hs$school_name,"</a>")
        email <- paste0("<a href='mailto:",selected_hs$Email, "'>", selected_hs$Email,"</a>")
        tagList(
            tags$h4("School Name:", HTML(sname)), tags$br(), 
            tags$strong(sprintf("School District: %s", selected_sd)),
            tags$strong(sprintf("Grades: %s", selected_grades)), tags$br(),
            tags$strong(HTML(sprintf("Address: %s, %s", selected_hs$addr_1, selected_hs$addr_2))),
            tags$br(), 
            tags$br(),
            if(!is.na(selected_hs$Email)){
            tags$strong(HTML(sprintf("Email: %s", email)))},
            tags$br(),
            tags$strong(HTML(sprintf("Phone: %s", selected_hs$Phone_Number))),
            tags$br(),
            if (!is.na(selected_hs$Fax_Number)){
            tags$strong(HTML(sprintf("Fax: %s", selected_hs$Fax_Number)))},
            tags$br(), tags$br(), tags$br(),
            tags$strong(sprintf("Total Number of Students in 2016: %d", selected_hs$total_students)),
            tags$br(),tags$br(),
            tags$strong(HTML("Nearby public transit:")), tags$br(),
            if (!is.na(selected_hs$bus)){
                tags$strong(sprintf("Bus: %s", selected_hs$bus))
            }, tags$br(),
            if (!is.na(selected_hs$subway)){
                tags$strong(sprintf("Subway: %s", selected_hs$subway))
            },tags$br(),tags$br(),
            if (!is.na(selected_hs$school_sports)){
                tags$strong(sprintf("School sports: %s", selected_hs$school_sports))
            },tags$br(),tags$br(),
            if (!is.na(selected_hs$language_classes)){
                tags$strong(sprintf("Language classes: %s", selected_hs$language_classes))
            },tags$br(),tags$br(),
            tags$strong(sprintf("English language learner program: %s", selected_hs$ell_programs)),
            tags$br(),tags$br(),
            if (!is.na(selected_hs$advancedplacement_courses)){
                tags$strong(sprintf("Advanced placement courses: %s", selected_hs$advancedplacement_courses))
            },tags$br(),tags$br(),
            if (!is.na(selected_hs$extracurricular_activities)){
                tags$strong(sprintf("Extracurricular activities: %s", selected_hs$extracurricular_activities))
            },tags$br()
        )}
    )
  })  
  ####################set up filter menu on school district#####################
  observe({
      school_dist_1 <- if (is.null(input$selection1)) character(0) else {
          filter(hs_SAT_survey, !(School_District %in% input$selection1)) %>%
              `$`('School_District') %>%
              unique() %>%
              sort()
      }
      stillSelected <- isolate(input$selection2[input$selection2 %in% school_dist_1])
      updateSelectInput(session, "selection2", choices = school_dist_1,
                        selected = stillSelected)
  })
  #######################################################
  observe({
      school_gifted <- hs_SAT_survey[gifted,]
      if (is.null(input$selection1)) {
          school_selection1 <- hs_SAT_survey
      } else if ("Gifted & Talented" %in% input$selection1){
          selection1_temp <- input$selection1[!input$selection1 == "Gifted & Talented"]
          school_selection1 <- hs_SAT_survey %>%
              filter(Admission_Priority == "District" & School_District %in% selection1_temp)
          school_selection1 <- rbind(school_selection1, school_gifted)
      }else{
          school_selection1 <- hs_SAT_survey %>%
              filter(Admission_Priority == "District" & School_District %in% input$selection1)
      }
      school_selection1$selection <- "Selection 1"
      
      if (input$variable=="2012 SAT Score"){
          var1 <- "SAT_2012"
          var2 <- "reading_avg_2012"
          var3 <- "math_avg_2012"
          var4 <- "writing_avg_2012"
      }else if (input$variable=="2010 SAT Score"){
          var1 <- "SAT_2010"
          var2 <- "reading_avg_2010"
          var3 <- "math_avg_2010"
          var4 <- "writing_avg_2010"
      }else{
          var1 <- "saf_tot_11"
          var2 <- "com_tot_11"
          var3 <- "eng_tot_11"
          var4 <- "aca_tot_11"
      }
   
      
  output$selection_info <- renderUI({
      if (is.null(input$selection2)) return(NULL)
      if ("Gifted & Talented" %in% input$selection2){
          selection2_temp <- input$selection2[!input$selection2 == "Gifted & Talented"]
          school_selection2 <- hs_SAT_survey %>%
              filter(Admission_Priority == "District" & School_District %in% input$selection2_temp)
          school_selection2 <- rbind(school_selection2, school_gifted)
      }else{
          school_selection2 <- hs_SAT_survey %>%
              filter(Admission_Priority == "District" & School_District %in% input$selection2)
      }
      
      school_selection2$selection <- "Selection 2"
      neighborhood_1 <- unique(school_selection1$Neighborhood)
      neighborhood_1 <- paste(neighborhood_1, collapse = ', ')
      number_school_1 <- ifelse("Gifted & Talented" %in% input$selection1, nrow(school_selection1)-9, nrow(school_selection1))
      neighborhood_2 <- unique(school_selection2$Neighborhood)
      neighborhood_2 <- paste(neighborhood_2, collapse = ', ')
      number_school_2 <- ifelse("Gifted & Talented" %in% input$selection2, nrow(school_selection2)-9, nrow(school_selection2))
      tagList(
          tags$strong(sprintf("Selection 1 contains schools from these neighborhoods: %s", neighborhood_1)),
          tags$br(),tags$br(),
          tags$strong(sprintf("Selection 1 includs %s public high schools which prioritize the district in admission  process.", number_school_1)),
          tags$br(),tags$br(),tags$br(),tags$br(),
          tags$strong(sprintf("Selection 2 contains schools from these neighborhoods: %s", neighborhood_2)),
          tags$br(),tags$br(),
          tags$strong(sprintf("Selection 2 includs %s public high schools which prioritize the district in admission  process.", number_school_2)),
          tags$br()
      )
      
  })
  output$sd_comp_1 <- renderPlotly({
      if (is.null(input$selection2)) return(NULL)
      if ("Gifted & Talented" %in% input$selection2){
          selection2_temp <- input$selection2[!input$selection2 == "Gifted & Talented"]
          school_selection2 <- hs_SAT_survey %>%
              filter(Admission_Priority == "District" & School_District %in% input$selection2_temp)
          school_selection2 <- rbind(school_selection2, school_gifted)
      }else{
          school_selection2 <- hs_SAT_survey %>%
              filter(Admission_Priority == "District" & School_District %in% input$selection2)
      }
      school_selection2$selection <- "Selection 2"
      df_plot <- rbind(school_selection1, school_selection2)
      if (var1!= "saf_tot_11"){
          plot1 <- ggplot(df_plot, aes_string(x="selection", y = var1, color = "selection")) +
              geom_boxplot(na.rm = T) +
              ylab(paste(input$variable, "- Cumulative")) + theme_minimal() +
              xlab("Selected School Districts") +
              scale_color_manual(name = "Selected School Districts", values = c('#377eb8','#e41a1c')
                                , labels = c("Selection 1", "Selection 2")) +
              theme(legend.position="none")
      }else{
          plot1 <- ggplot(df_plot, aes_string(x="selection", y = var1, color = "selection")) +
              geom_boxplot(na.rm = T) +
              ylab(paste("2011 Survey - Safety and Respect")) + theme_minimal() +
              xlab("Selected School Districts") +
              scale_color_manual(name = "Selected School Districts", values = c('#377eb8','#e41a1c')
                                , labels = c("Selection 1", "Selection 2"))+
              theme(legend.position="none")
      }
      ggplotly(plot1)
  })
  output$sd_comp_2 <- renderPlotly({
      if (is.null(input$selection2)) return(NULL)
      if ("Gifted & Talented" %in% input$selection2){
          selection2_temp <- input$selection2[!input$selection2 == "Gifted & Talented"]
          school_selection2 <- hs_SAT_survey %>%
              filter(Admission_Priority == "District" & School_District %in% input$selection2_temp)
          school_selection2 <- rbind(school_selection2, school_gifted)
      }else{
          school_selection2 <- hs_SAT_survey %>%
              filter(Admission_Priority == "District" & School_District %in% input$selection2)
      }
      school_selection2$selection <- "Selection 2"
      df_plot <- rbind(school_selection1, school_selection2)
      if (var1!= "saf_tot_11"){
          plot2 <- ggplot(df_plot, aes_string(x="selection", y = var2, color = "selection")) +
              geom_boxplot(na.rm = T) +
              ylab(paste(input$variable, "- Reading")) + theme_minimal() +
              xlab("Selected School Districts") +
              scale_color_manual(name = "Selected School Districts", values = c('#377eb8','#e41a1c')
                                , labels = c("Selection 1", "Selection 2")) +
              theme(legend.position="none")
      }else{
          plot2 <- ggplot(df_plot, aes_string(x="selection", y = var2, color = "selection")) +
              geom_boxplot(na.rm = T) +
              ylab(paste("2011 Survey - Communication")) + theme_minimal() +
              xlab("Selected School Districts") +
              scale_color_manual(name = "Selected School Districts", values = c('#377eb8','#e41a1c')
                                , labels = c("Selection 1", "Selection 2")) +
              theme(legend.position="none")
      }
      ggplotly(plot2)
  })
  output$sd_comp_3 <- renderPlotly({
      if (is.null(input$selection2)) return(NULL)
      if ("Gifted & Talented" %in% input$selection2){
          selection2_temp <- input$selection2[!input$selection2 == "Gifted & Talented"]
          school_selection2 <- hs_SAT_survey %>%
              filter(Admission_Priority == "District" & School_District %in% input$selection2_temp)
          school_selection2 <- rbind(school_selection2, school_gifted)
      }else{
          school_selection2 <- hs_SAT_survey %>%
              filter(Admission_Priority == "District" & School_District %in% input$selection2)
      }
      school_selection2$selection <- "Selection 2"
      df_plot <- rbind(school_selection1, school_selection2)
      if (var1!= "saf_tot_11"){
          plot3 <- ggplot(df_plot, aes_string(x="selection", y = var3, color = "selection")) +
              geom_boxplot(na.rm = T) +
              ylab(paste(input$variable, "- Math")) + theme_minimal() +
              xlab("Selected School Districts") +
              scale_color_manual(name = "Selected School Districts", values = c('#377eb8','#e41a1c')
                                , labels = c("Selection 1", "Selection 2")) +
              theme(legend.position="none")
      }else{
          plot3 <- ggplot(df_plot, aes_string(x="selection", y = var3, color = "selection")) +
              geom_boxplot(na.rm = T) +
              ylab(paste("2011 Survey - Engagement")) + theme_minimal() +
              xlab("Selected School Districts") +
              scale_color_manual(name = "Selected School Districts", values = c('#377eb8','#e41a1c')
                                , labels = c("Selection 1", "Selection 2")) +
              theme(legend.position="none")
      }
      ggplotly(plot3)
  })
  output$sd_comp_4 <- renderPlotly({
      if (is.null(input$selection2)) return(NULL)
      if ("Gifted & Talented" %in% input$selection2){
          selection2_temp <- input$selection2[!input$selection2 == "Gifted & Talented"]
          school_selection2 <- hs_SAT_survey %>%
              filter(Admission_Priority == "District" & School_District %in% input$selection2_temp)
          school_selection2 <- rbind(school_selection2, school_gifted)
      }else{
          school_selection2 <- hs_SAT_survey %>%
              filter(Admission_Priority == "District" & School_District %in% input$selection2)
      }
      school_selection2$selection <- "Selection 2"
      df_plot <- rbind(school_selection1, school_selection2)
      if (var1!= "saf_tot_11"){
          plot4 <- ggplot(df_plot, aes_string(x="selection", y = var4, color = "selection")) +
              geom_boxplot(na.rm = T) +
              ylab(paste(input$variable,"- Writing")) + theme_minimal() +
              xlab("Selected School Districts") +
              scale_color_manual(name = "Selected School Districts", values = c('#377eb8','#e41a1c')
                                , labels = c("Selection 1", "Selection 2")) +
              theme(legend.position="none")
      }else{
          plot4 <- ggplot(df_plot, aes_string(x="selection", y = var4, color = "selection")) +
              geom_boxplot(na.rm = T) +
              ylab(paste("2011 Survey - Academic Expectation")) + theme_minimal() +
              xlab("Selected School Districts") +
              scale_color_manual(name = "Selected School Districts", values = c('#377eb8','#e41a1c')
                                , labels = c("Selection 1", "Selection 2")) +
              theme(legend.position="none")
      }
      ggplotly(plot4)
  })
})
output$note <- renderUI({
    tagList(
        tags$strong("Notes:"), tags$br(),
        tags$li("'Gifted and Talented' programs are one way that NYC Department of Education supports the needs of exceptional students. The 9 public high schools in the program are:", tags$em("The Bronx High School of Science, The Brooklyn Latin School, Brooklyn Technical High School, High School for Mathematics, Science and Engineering at the City College, High School of American Studies at Lehman College, Queens High School for the Sciences at York College, Staten Island Technical High School, Stuyvesant High School and Fiorello H. LaGuardia High School of Music & Art and Performing Arts."), "These school are open to city-wide, but requiring Specialized High School Admission Test or an audition for admission." ),
        tags$br(),
        tags$li("The participants of NYC School Surveys are students, their parents and teachers at each school. The survey rates a school on a 0-10 scale in four aspects: safety and respect, communication, engagement and academic expectation. This is not a standardized test for schools. However, it presents the satisfaction level whether the school meets the expectation of students, parents and teachers."), tags$br()
    )
})


}
