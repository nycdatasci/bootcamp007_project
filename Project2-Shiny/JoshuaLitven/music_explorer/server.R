# Global variables
artists = NULL
edges = NULL
nodes = NULL
tracks = NULL
playlist_name = NULL

# Load data for the selected playlist
# This requires loading artists, tracks and edges
# These will be global variables
load_playlist = function(playlist_id){
  
  PLAYLIST_PATH = file.path(DATA_PATH, playlist_id)
  
  # Load network data
  # Network consists of artists and their edges
  artist_file = file.path(PLAYLIST_PATH, 'artists.csv')
  artists <<- read.csv(artist_file, stringsAsFactors = FALSE)

  # Nodes
  nodes = artists
  nodes$shape = "circularImage"
  nodes$label = nodes$name
  nodes$value = pmin(nodes$n_edges, 5)
  nodes <<- nodes
  
  # Edges
  edges_file = file.path(PLAYLIST_PATH, 'edges.csv')
  edges <<- read.csv(edges_file, stringsAsFactors = FALSE)
  
  # Load track data
  track_file = file.path(PLAYLIST_PATH, 'tracks.csv')
  tracks = read.csv(track_file, stringsAsFactors = FALSE)
  tracks$full_name = paste0(tracks$artist, ' - ', tracks$name)
  tracks <<- tracks[which(complete.cases(tracks)), ] # Clean

}



shinyServer(function(input, output, session){
  
  output$menu = renderMenu({
    
    if(length(input$clickimg) > 0){
      sidebarMenu(id="tabs",
                  menuItem("Playlist Summary", tabName="summary", icon=icon("list"), selected=TRUE),
                  menuItem("Artist Network", tabName="artist_network", icon=icon("link")),
                  menuItem("Track Features", tabName="track_features", icon=icon("music")),
                  tags$hr()
                  #menuItem("Powered by Spotify", icon=icon("spotify"))
                  
      )
    }else{
      sidebarMenu(id="tabs",
                  menuItem("Select a Playlist", tabName="playlist", selected=TRUE))
    }
  })
  isolate({updateTabItems(session, "tabs", "playlist")})
  
  output$sidebar_panel = renderUI({
    if(is.null(input$clickimg)){
    }else{
      hidden(tags$div(id="filter_panel",
               tags$br(),
            
               fluidRow(
                 column(6, actionButton('addFilter', 'Add filter'))
               ),
               tags$div(id = 'placeholderAddRemFilt'),
               tags$div(id = 'placeholderFilter')
      ))
    }
  })
  
  output$network_sidebar = renderUI({
    selectInput("Focus", "Select Artist:", nodes$name)
  })
  
  
  output$imageGrid <- renderUI({
    
    if(is.null(input$clickimg)){
        fluidRow(
          apply(playlists, 1, function(playlist) {
            column(4, 
                   tags$input(type="image", src=playlist['image_url'], class="clickimg", 
                              'data-value'=playlist['id']),
                   tags$br(),
                   tags$br()
            )
          })
        
      )
    }else{
      playlist_name <<- playlists[playlists$id==input$clickimg, 'name']
      genre <<- playlists[playlists$id==input$clickimg, 'category_id']
      load_playlist(input$clickimg)
      isolate({updateTabItems(session, "tabs", "summary")})
    }
  })
  
  
  output$network <- renderVisNetwork({

    network = 
      visNetwork(nodes, edges) %>%
      visInteraction(hover = TRUE) %>%
      visEvents(selectNode = "function(nodes) {
                Shiny.onInputChange('current_node_id', nodes);
                ;}") %>% 
      visOptions(selectedBy = "group", height="600")
    return(network)
  })
  
  observe({
    updateSelectInput(session, "Focus", selected=nodes[nodes$id==input$current_node_id[[1]], ][['name']])
  })

  

  output$summary_header = renderUI({
    h1(playlist_name)
  })
  
  get_audio_tag = function(src){
    return(as.character(tags$audio(src=src, 
                                   type = "audio/mp3", 
                                   controls = NA)))
  }
  
  output$artist_details = renderUI({
    if(input$Focus != "" ){
      id = nodes[nodes['name']==input$Focus, 'id']
      tags$div(
        tags$img(src=nodes[nodes$id==id, ]['image']),
        tags$h5(HTML(nodes[nodes$id == id, ][['bio']])),
        tags$h3(nodes[nodes$id == id, ][['genres']]),
        HTML(get_audio_tag(nodes[nodes$id == id, ][['top_track_preview_url']]))
      )
    }
  })
  
  observeEvent(input$filters, {
    insertUI(
      selector = "#filters",
      where = "afterEnd",
      ui = sliderInput(tail(input$filters, n=1), label = tail(input$filters, n=1), min = 0, 
                       max = 100, value = c(0, 100))
    )
  
  })
  
  filter <- character(0)
  
  makeReactiveBinding("aggregFilterObserver")
  aggregFilterObserver <- list()
  
  observeEvent(input$addFilter, {
          add <- input$addFilter
          filterId <- paste0('Filter_', add)
          colfilterId <- paste0('Col_Filter_', add)
          rowfilterId <- paste0('Row_Filter_', add)
          removeFilterId <- paste0('Remove_Filter_', add)
          headers <- names(tracks)
          insertUI(
            selector = '#placeholderFilter',
            ui = tags$div(id = filterId,
                          tags$hr(),
                          actionButton(removeFilterId, label = "Remove filter"),
                          selectInput(colfilterId, label = NULL, choices = num_cols, selected = add + 1),
                          sliderInput(rowfilterId, label = "Select values", min=0, max=1, value=c(0, 1))
            )
          )
          
          observeEvent(input[[colfilterId]], {
            col <- input[[colfilterId]]
            values <- as.list(unique(tracks[col]))[[1]]
            
            min_val = min(values)
            max_val = max(values)
            
            updateSliderInput(session, rowfilterId, min=min_val, max=max_val, value=c(min_val, max_val))
            
            aggregFilterObserver[[filterId]]$col <<- col
            aggregFilterObserver[[filterId]]$rows <<- NULL
          })
          
          
          observeEvent(input[[rowfilterId]], {
            rows <- input[[rowfilterId]]
            aggregFilterObserver[[filterId]]$rows <<- rows
          })
          
          observeEvent(input[[removeFilterId]], {
            removeUI(selector = paste0('#', filterId))
            
            aggregFilterObserver[[filterId]] <<- NULL
            
          })
    
  })
  
  observeEvent(input$tabs, {
    useShinyjs()
    if(input$tabs=='track_features'){
      shinyjs::show(id = "filter_panel", anim=TRUE)
    }else{
      shinyjs::hide(id="filter_panel", anim=TRUE)
    }
    if(input$tabs=='artist_network'){
      updateSelectInput(session, "Focus", label="Select Artist:", choices=sort(nodes$name))
      shinyjs::show(id ="artist_details", anim=TRUE)
    }else{
      shinyjs::hide(id="artist_details", anim=FALSE)
    }
  })
  
  observe({
    if(input$Focus[1]!=""){
      visNetworkProxy("network") %>%
        visFocus(id = nodes[nodes['name']==input$Focus, 'id'], scale = 4)
    }
  })
  
  output$data <- renderDataTable({
    feature_cols = unique(as.character(lapply(aggregFilterObserver, function(filter) filter$col)))

    dataSet <- tracks
    invisible(lapply(aggregFilterObserver, function(filter){
      
      min = filter$rows[1]
      max = filter$rows[2]
      dataSet <<- dataSet[which(dataSet[[filter$col]] >= min & dataSet[[filter$col]] <= max), ]
    }))
    
    # Columns to select
    # Create preview column
    get_audio_tag = function(src){
      return(as.character(tags$audio(src=src, 
                 type = "audio/mp3", 
                 controls = NA)))
    }
    dataSet['audio'] = unlist(lapply(dataSet$preview_url, get_audio_tag))
    dataSet = dataSet[, c('artist', 'name', 'audio', feature_cols)]

    colnames(dataSet) = c("Artist", "Track", "Preview", plot_labels[feature_cols])
    return(dataSet)
  }, escape=FALSE, options=list(width="800", pageLength=10, searching=FALSE))
  
  histogram_js = "if(chart.getSelection().length > 0){
                    var row_index = chart.getSelection()[0].row;
                    var tooltip = data.getValue(row_index, 0);
                    Shiny.onInputChange('tooltip',tooltip);
                  }else{Shiny.onInputChange('tooltip', '');}"
  # Duration
  output$duration = renderGvis({
    minutes = tracks['duration_ms'] / (60 * 1000)
    names(minutes) = "minutes"
    gvisHistogram(data.frame(name=tracks$full_name, minutes=minutes),
                  options=list(title="Track Duration",
                               titleTextStyle="{fontName:'Courier', fontSize:24}",
                               legend="none",
                               hAxis="{title: 'Minutes', titleTextStyle:{fontSize:20}}",
                               tooltip="{isHtml:'True'}",
                               gvis.listener.jscode = histogram_js))
  })
  output$duration_box = renderUI({
    total_runtime = paste0(round(sum(tracks$duration_ms) / (60 * 1000)), " Minutes")
    valueBox(total_runtime, "Total Runtime", icon = icon("clock-o"))
  })
  
  # Energy
  output$energy = renderGvis({
    gvisHistogram(data.frame(name=tracks$full_name, energy=tracks$energy * 100),
                  options=list(title="Energy",
                               titleTextStyle="{fontName:'Courier', fontSize:24}",
                               hAxis="{title: 'Percentage', titleTextStyle:{fontSize:20}}",
                               legend="none",
                               gvis.listener.jscode = histogram_js))
  })
  
  output$energy_box = renderUI({
    median_energy = median(tracks$energy)
    energy_level = cut(median_energy, breaks=c(0, 0.33, 0.66, 1), labels=c("Low", "Medium", "High"))
    valueBox(energy_level, "Energy", icon = icon("battery-full"))
  })
  
  # Tempo
  output$tempo = renderGvis({
    gvisHistogram(tracks[, c('full_name', 'tempo'), drop=FALSE],
                  options=list(title="Tempo",
                               titleTextStyle="{fontName:'Courier', fontSize:24}",
                               hAxis="{title: 'Beats per Minute', titleTextStyle:{fontSize:20}}",
                               legend="none",
                               gvis.listener.jscode = histogram_js))
  })
  output$tempo_box = renderUI({
    median_tempo = median(tracks$tempo)
    tempo_level = cut(median_tempo, breaks=c(60, 80, 100, 120, 140), labels=c("Very Slow", "Slow", "Fast", "Very Fast"))
    valueBox(tempo_level, "Tempo", icon = icon("fighter-jet"))
  })
  
  # Volume
  output$volume = renderGvis({
    gvisHistogram(tracks[, c('full_name', 'loudness'), drop=FALSE],
                  options=list(title="Volume",
                               titleTextStyle="{fontName:'Courier', fontSize:24}",
                               hAxis="{title: 'Decibals', titleTextStyle:{fontSize:20}}",
                               legend="none",
                               gvis.listener.jscode = histogram_js))
  })
  output$volume_box = renderUI({
    median_volume = median(tracks$loudness)
    volume_level = cut(median_volume, breaks=c(-20, -15, -10, -5, 0), labels=c("Very Quiet", "Quiet", "Loud", "Very Loud"))
    valueBox(volume_level, "Volume", icon = icon("volume-up"))
  })
  
  # Valence
  output$valence = renderGvis({
    gvisHistogram(data.frame(tracks$full_name, valence=tracks$valence * 100),
                  options=list(title="Mood",
                               titleTextStyle="{fontName:'Courier', fontSize:24}",
                               hAxis="{title: 'Percentage', titleTextStyle:{fontSize:20}}",
                               legend="none",
                               gvis.listener.jscode = histogram_js))
  })
  output$valence_box = renderUI({
    median_valence = median(tracks$valence)
    valence_level = cut(median_valence, breaks=c(0, 0.33, 0.66, 1), labels=c("Negative", "Neutral", "Positive"))
    valueBox(valence_level, "Positiveness", icon = icon("smile-o"))
  })
  
  # Popularity
  output$popularity = renderGvis({
    gvisHistogram(tracks[, c('full_name', 'popularity'), drop=FALSE],
                  options=list(title="Popularity",
                               titleTextStyle="{fontName:'Courier', fontSize:24}",
                               hAxis="{title: 'Percentage', titleTextStyle:{fontSize:20}}",
                               legend="none",
                               gvis.listener.jscode = histogram_js))
  })
  output$popularity_box = renderUI({
    median_popularity = median(tracks$popularity)
    popularity_level = cut(median_popularity, breaks=c(0, 25, 50, 75, 100), include.lowest=TRUE, 
                           labels=c("Music Snob", "Uknown", "Popular", "Very Popular"))
    valueBox(popularity_level, "Popularity", icon = icon("users"))
  })
  
  
  output$features_plot = renderGvis({
    
    if (input$plotScatter == 0)
      return()
    
    isolate({
    # Create interactive scatter plot using googleVis
    dataSet <- tracks
    
    invisible(lapply(aggregFilterObserver, function(filter){
      
      min = filter$rows[1]
      max = filter$rows[2]
      dataSet <<- dataSet[which(dataSet[[filter$col]] >= min & dataSet[[filter$col]] <= max), ]
    }))
    dataSet
    
    scatter = dataSet[, c(input$scatter_xcol, input$scatter_ycol)]
    scatter$pop.html.tooltip=paste0(dataSet$artist, ' - ', dataSet$name, '<br>',
                                    '(', dataSet[[input$scatter_xcol]], ', ', dataSet[[input$scatter_ycol]], ')')
    Scatter1 <- gvisScatterChart(scatter,                                                           
                                 options=list(tooltip="{isHtml:'True'}",
                                              legend="none", lineWidth=0, pointSize=5,  
                                              title="Track Features",
                                              vAxis=paste0("{title:'", plot_labels[input$scatter_ycol], "'}"),                
                                              hAxis=paste0("{title:'", plot_labels[input$scatter_xcol], "'}"),                  
                                              width=1000, height=500,
                                              gvis.listener.jscode = "
                                              if(chart.getSelection().length > 0){
                                                var row_index = chart.getSelection()[0].row;
                                                var tooltip = data.getValue(row_index, 2);
                                                Shiny.onInputChange('tooltip',tooltip);
                                              }else{Shiny.onInputChange('tooltip', '');}")) 
    Scatter1
    })
  })

  Values<-reactiveValues(old="Start")
  
  observe({
    if(length(input$tooltip)==0){
      return()
    }
    
    if(input$tooltip != ""){
      full_name = unlist(strsplit(input$tooltip,split = "<br>"))[1]
      if(isolate({input$tooltip == Values$old})){
        js$playAudio()
      }else{
        preview_url = tracks[tracks$full_name==full_name, 'preview_url']
        js$pageCol(preview_url)
        isolate({ Values$old<-input$tooltip })
      }
    }else{
      js$pauseAudio()
    }
  })
  
  
  
  
  
  output$tags_plot = renderGvis({
    # Top tags
    genres = artists$genres
    genre_lists = sapply(genres, function(x) strsplit(x, ", "))
    genre_counts = data.frame(genre=unlist(genre_lists), stringsAsFactors = FALSE)  %>% count(genre)  %>% arrange(desc(n))
    genre_counts
    top_genres = genre_counts[1:10,]
    top_genres$genre.annotation = top_genres$genre
    
    gvisColumnChart(top_genres, xvar="genre", yvar=c("n", "genre.annotation"),
                    options=list(tooltip="{isHtml:'True'}",
                                 title="Top Tags",
                                 vAxis="{title: 'Number of Artists'}",
                                 width="100%", height="800",
                                 legend="none"))
  })
  

})