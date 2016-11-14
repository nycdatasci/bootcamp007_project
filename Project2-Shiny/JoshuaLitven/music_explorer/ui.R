# User Interface for Music Explorer

shinyUI(dashboardPage(skin="black",
                      
                      
                      dashboardHeader(title="Explorify"),
                      
                      # Sidebar
                      dashboardSidebar(width = 300, useShinyjs(),
                                       
                                       sidebarMenu(id="tabs",
                                                   sidebarMenuOutput("menu")
                                       ),
                                       
                                       htmlOutput("sidebar_panel"),
                                       
                                       hidden(htmlOutput("artist_details"))
                                       
                      ), # end sidebar
                      
                      # Body
                      dashboardBody(
                        
                        # Set the background color
                        tags$head(tags$style(HTML('.skin-black .content{
                              background-color: black;
                              }
                              .skin-black .main-header .logo:hover {
                              background-color: black;
                              }'))
                        ),
                        
                        
                        tabItems(
                          
                          tabItem(tabName="overview",
                                  
                                  fluidRow(
                                    box(width=12,
                                        tags$h3(tags$b("Explorify"), "allows you to explore Spotify playlists
                                            by viewing relationships between artists and plotting track features."),
                                        tags$h3("Track features, track previews, artist images, and artist tags are pulled from the Spotify Web API and artist biographies are pulled from the Last.fm API. All plots are made using Googlevis, an R package for creating Google Charts."),
                                        tags$h3("The source code is available on",  tags$a("Github.", 
                                                                                           href="https://github.com/nycdatasci/bootcamp007_project/tree/master/Project2-Shiny/JoshuaLitven/music_explorer")),
                                        tags$h3("Click 'Select a Playlist' on the left to begin!"),
                                        tags$p("Powered by ", tags$a("Spotify", href="http://www.spotify.com/"), icon("spotify"),
                                                "and ", tags$a("Last.fm", href="http://www.last.fm/"), icon("lastfm")),
                                        tags$p("Created by", tags$a("Joshua Litven", href="http://joshualitven.com/"))
                                    ),
                                    box(title="Track Features?", width=12, collapsible=TRUE, collapsed=TRUE,
                                        tags$li(tags$i("acousticness"),
                                                "- A confidence measure from 0.0 to 1.0 of whether the track is acoustic. 1.0 represents high confidence the track is acoustic."),
                                        tags$br(),
                                        tags$li(tags$i("danceability"), 
                                                "- Danceability describes how suitable a track is for dancing based on a combination of musical elements including tempo, rhythm stability, beat strength, and overall regularity. A value of 0.0 is least danceable and 1.0 is most danceable."),
                                        tags$br(),
                                        tags$li(tags$i("duration_ms"),
                                                "- The duration of the track in milliseconds."),
                                        tags$br(),
                                        tags$li(tags$i("energy"),
                                                "- Energy is a measure from 0.0 to 1.0 and represents a perceptual measure of intensity and activity. Typically, energetic tracks feel fast, loud, and noisy. For example, death metal has high energy, while a Bach prelude scores low on the scale. Perceptual features contributing to this attribute include dynamic range, perceived loudness, timbre, onset rate, and general entropy."),
                                        tags$br(),
                                        tags$li(tags$i("liveness"),
                                                "- Detects the presence of an audience in the recording. Higher liveness values represent an increased probability that the track was performed live. A value above 0.8 provides strong likelihood that the track is live."),
                                        tags$br(),
                                        tags$li(tags$i("loudness"),
                                                "- The overall loudness of a track in decibels (dB). Loudness values are averaged across the entire track and are useful for comparing relative loudness of tracks. Loudness is the quality of a sound that is the primary psychological correlate of physical strength (amplitude). Values typical range between -60 and 0 db."),
                                        tags$br(),
                                        tags$li(tags$i("speechiness"),
                                                "- Speechiness detects the presence of spoken words in a track. The more exclusively speech-like the recording (e.g. talk show, audio book, poetry), the closer to 1.0 the attribute value. Values above 0.66 describe tracks that are probably made entirely of spoken words. Values between 0.33 and 0.66 describe tracks that may contain both music and speech, either in sections or layered, including such cases as rap music. Values below 0.33 most likely represent music and other non-speech-like tracks."),
                                        tags$br(),
                                        tags$li(tags$i("tempo"),
                                                "- The overall estimated tempo of a track in beats per minute (BPM). In musical terminology, tempo is the speed or pace of a given piece and derives directly from the average beat duration."),
                                        tags$br(),
                                        tags$li(tags$i("valence"),
                                                "- A measure from 0.0 to 1.0 describing the musical positiveness conveyed by a track. Tracks with high valence sound more positive (e.g. happy, cheerful, euphoric), while tracks with low valence sound more negative (e.g. sad, depressed, angry).")
                                    )
                                  ) # end fluid row
                                  
                          ), # end overview tab
                          
                          tabItem(tabName="artist_network",
                                  
                                  fluidRow(
                                    box(width=12,
                                        #selectInput("Focus", "Focus on node :", ""),
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
                                  div(style="display:inline-block",
                                      textInput("playlist_url", label=NULL, value = "", width = NULL, 
                                                placeholder = "Enter Playlist URL")),
                                  div(style="display:inline-block; color: red; font-style: italic;",
                                      textOutput("playlist_msg")),
                                  tags$br(),
                                  #tags$head(tags$style("#playlist_msg{color: red; font-style: italic;}")),
                                  actionButton("playlist_button", "Load Playlist"),
                                  h2("Or select a Spotify playlist:"),
                                  uiOutput("imageGrid"),
                                  
                                  tags$script(HTML(
                                    "$(document).on('click', '.clickimg', function() {",
                                    "  Shiny.onInputChange('clickimg', $(this).data('value'));",
                                    "});"
                                  ))
                          ), # end tab
                          
                          tabItem(tabName="track_features",
                                  
                                  # Javascript audio functions
                                  useShinyjs(),
                                  extendShinyjs(text=js_set_audio_src),
                                  extendShinyjs(text=js_pause_audio),
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
                                  )
                                  
                          ) # end tab
                        ) # end tabItems
                      ) # end body
                      
                      
))