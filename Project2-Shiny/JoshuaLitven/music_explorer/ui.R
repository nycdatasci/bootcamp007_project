shinyUI(dashboardPage(skin="black",
                      
  # Header       
  dashboardHeader(title="Music Explorer"),
  
  # Sidebar
  dashboardSidebar(width = 300, useShinyjs(),
    
    sidebarMenu(id="tabs",
                sidebarMenuOutput("menu")
    ),
    htmlOutput("sidebar_panel"),
    hidden(htmlOutput("artist_details"))
    
    
  ),
  
  # Body
  dashboardBody(
    
    tabItems(
      
      tabItem(tabName="artist_network",
              
              fluidRow(

                box(width=12,
                  selectInput("Focus", "Focus on node :", ""),
                  visNetworkOutput("network", height="800")
                )
                
                )
              
      ), # end tab
      

      tabItem(tabName="summary",
              
              fluidRow(
                htmlOutput("summary_header"),

                box(width=12, collapsible = TRUE,
                  htmlOutput('tags_plot')
                ),
                
                # Duration
                box(width=12,
                    htmlOutput("duration_box"),
                    
                    box(width=8,
                      htmlOutput("duration")
                    )
                    ),
                # Energy
                box(width=12,
                    
                    htmlOutput("energy_box"),
                    
                    box(width=8,
                        htmlOutput("energy")
                    )
                ),
                # Tempo
                box(width=12,
                    htmlOutput("tempo_box"),
                    
                    box(width=8,
                        htmlOutput("tempo")
                    )
                ),
                # Volume
                box(width=12,
                    htmlOutput("volume_box"),
                    
                    box(width=8,
                        htmlOutput("volume")
                    )
                ),
                # Valence
                box(width=12,
                    htmlOutput("valence_box"),
                    
                    box(width=8,
                        htmlOutput("valence")
                    )
                ),
                # Popularity
                box(width=12,
                    htmlOutput("popularity_box"),
                    
                    box(width=8,
                        htmlOutput("popularity")
                    )
                )
                
              )
      ), # end tab
      
      tabItem(tabName="playlist",
              
              uiOutput("imageGrid"),
              
              tags$script(HTML(
                "$(document).on('click', '.clickimg', function() {",
                "  Shiny.onInputChange('clickimg', $(this).data('value'));",
                "});"
              ))
      ), # end tab
      
      tabItem(tabName="track_features",
              
              useShinyjs(),
              extendShinyjs(text=jsCode),
              extendShinyjs(text=jsCode2),
              extendShinyjs(text=js_play_audio),
              fluidRow(
                box(width = 12, collapsible = TRUE,
                    div(style="display: inline-block;vertical-align:top; width: 30%;",
                        selectInput(inputId='scatter_ycol', 
                                    label="Select Y:", 
                                    choices=num_cols,
                                    selected=num_cols[1])),
                    div(style="display: inline-block;vertical-align:top; width: 30%;",
                        selectInput(inputId='scatter_xcol', 
                                    label="Select X:", 
                                    choices=num_cols,
                                    selected=num_cols[2])),
                    div(style="margin-top: 0.65cm; display: inline-block; width: 10%",
                        actionButton("plotScatter", "Create Plot")),
                    htmlOutput("features_plot"),
                    tags$audio(id="audio_player", src = NULL, type = "audio/wav", autoplay = NA, controls = NA)
                    )
    
              ),
              
              fluidRow(
                dataTableOutput('data')
#                 box(
#                   title = "Filtered Playlist", status = "primary", solidHeader = TRUE,
#                   collapsible = TRUE, width = 12,
#                   tableOutput('data')
#                 )
              )
              
       ) # end tab
    ) # end tabItems
  ) # end body
))