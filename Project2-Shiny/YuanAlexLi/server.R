library(shiny)
library(shinydashboard)
library(leaflet)
library(dplyr)
library(caret)
library(RSQLite)
library(sp)
library(KernSmooth)
library(ggplot2)

r_colors <- rgb(t(col2rgb(colors()) / 255))
names(r_colors) <- colors()

function(input, output, session) {

  pokedb = dbConnect(RSQLite::SQLite(), "./data/poke.db.sqlite")
  
  # map data subsetting
  points <- eventReactive(input$go, {
    if (input$id!="All"){
      inp_dat = dbGetQuery(pokedb, paste0("SELECT pokemonId, longitude, latitude FROM ", dbSel(input$region))) %>%
        filter(., pokemonId==pokeID[pokeID$Pokemon %in% input$id, 1]) %>% head(input$freq) #%>% 
        #select(., latitude, longitude)
    }else if(input$id=="All"){
      inp_dat = dbGetQuery(pokedb, paste0("SELECT pokemonId, longitude, latitude FROM ", dbSel(input$region))) %>%
        head(input$freq) #%>% select(., latitude, longitude)
    }
  }, ignoreNULL=FALSE)

  # Render map
  output$map <- renderLeaflet({
    
    pokeIcon = iconList(
      Bulbasaur=makeIcon("1.png"), Ivysaur=makeIcon("2.png"), Venusaur=makeIcon("3.png"), Charmander=makeIcon("4.png"), 
      Charmeleon=makeIcon("5.png"), Charizard=makeIcon("6.png"), Squirtle=makeIcon("7.png"), Wartortle=makeIcon("8.png"),
      Blastoise=makeIcon("9.png"), Caterpie=makeIcon("10.png"), Metapod=makeIcon("11.png"), Butterfree=makeIcon("12.png"),
      Weedle=makeIcon("13.png"), Kakuna=makeIcon("14.png"), Beedrill=makeIcon("15.png"), Pidgey=makeIcon("16.png"),
      Pidgeotto=makeIcon("17.png"), Pidgeot=makeIcon("18.png"), Rattata=makeIcon("19.png"), Raticate=makeIcon("20.png"),
      Spearow=makeIcon("21.png"), Fearow=makeIcon("22.png"), Ekans=makeIcon("23.png"), Arbok=makeIcon("24.png"),
      Pikachu=makeIcon("25.png"), Raichu=makeIcon("26.png"), Sandshrew=makeIcon("27.png"), Sandslash=makeIcon("28.png"),
      Nidoran.F=makeIcon("29.png"), Nidorina=makeIcon("30.png"), Nidoqueen=makeIcon("31.png"), Nidoran.M=makeIcon("32.png"),
      Nidorino=makeIcon("33.png"), Nidoking=makeIcon("34.png"), Clefairy=makeIcon("35.png"), Clefable=makeIcon("36.png"),
      Vulpix=makeIcon("37.png"), Ninetales=makeIcon("38.png"), Jigglypuff=makeIcon("39.png"), Wigglytuff=makeIcon("40.png"),
      Zubat=makeIcon("41.png"), Golbat=makeIcon("42.png"), Oddish=makeIcon("43.png"), Gloom=makeIcon("44.png"),
      Vileplume=makeIcon("45.png"), Paras=makeIcon("46.png"), Parasect=makeIcon("47.png"), Venonat=makeIcon("48.png"),
      Venomoth=makeIcon("49.png"), Diglett=makeIcon("50.png"), Dugtrio=makeIcon("51.png"), Meowth=makeIcon("52.png"),
      Persian=makeIcon("53.png"), Psyduck=makeIcon("54.png"), Golduck=makeIcon("55.png"), Mankey=makeIcon("56.png"),
      Primeape=makeIcon("57.png"), Growlithe=makeIcon("58.png"), Arcanine=makeIcon("59.png"), Poliwag=makeIcon("60.png"),
      Poliwhirl=makeIcon("61.png"), Poliwrath=makeIcon("62.png"), Abra=makeIcon("63.png"), Kadabra=makeIcon("64.png"),
      Alakazam=makeIcon("65.png"), Machop=makeIcon("66.png"), Machoke=makeIcon("67.png"), Machamp=makeIcon("68.png"),
      Bellsprout=makeIcon("69.png"), Weepinbell=makeIcon("70.png"), Victreebel=makeIcon("71.png"), Tentacool=makeIcon("72.png"),
      Tentacruel=makeIcon("73.png"), Geodude=makeIcon("74.png"), Graveler=makeIcon("75.png"), Golem=makeIcon("76.png"),
      Ponyta=makeIcon("77.png"), Rapidash=makeIcon("78.png"), Slowpoke=makeIcon("79.png"), Slowbro=makeIcon("80.png"),
      Magnemite=makeIcon("81.png"), Magneton=makeIcon("82.png"), Farfetchd=makeIcon("83.png"), Doduo=makeIcon("84.png"), 
      Dodrio=makeIcon("85.png"),Seel=makeIcon("86.png"), Dewgong=makeIcon("87.png"), Grimer=makeIcon("88.png"), 
      Muk=makeIcon("89.png"), Shellder=makeIcon("90.png"), Cloyster=makeIcon("91.png"), Gastly=makeIcon("92.png"),
      Haunter=makeIcon("93.png"), Gengar=makeIcon("94.png"), Onix=makeIcon("95.png"), Drowzee=makeIcon("96.png"),
      Hypno=makeIcon("97.png"), Krabby=makeIcon("98.png"), Kingler=makeIcon("99.png"), Voltorb=makeIcon("100.png"),
      Electrode=makeIcon("101.png"), Exeggcute=makeIcon("102.png"), Exeggutor=makeIcon("103.png"), Cubone=makeIcon("104.png"),
      Marowak=makeIcon("105.png"), Hitmonlee=makeIcon("106.png"), Hitmonchan=makeIcon("107.png"), Lickitung=makeIcon("108.png"),
      Koffing=makeIcon("109.png"), Weezing=makeIcon("110.png"), Rhyhorn=makeIcon("111.png"), Rhydon=makeIcon("112.png"),
      Chansey=makeIcon("113.png"), Tangela=makeIcon("114.png"), Kangaskhan=makeIcon("115.png"), Horsea=makeIcon("116.png"),
      Seadra=makeIcon("117.png"), Goldeen=makeIcon("118.png"), Seaking=makeIcon("119.png"), Staryu=makeIcon("120.png"),
      Starmie=makeIcon("121.png"), Mr.Mime=makeIcon("122.png"), Scyther=makeIcon("123.png"), Jynx=makeIcon("124.png"),
      Electabuzz=makeIcon("125.png"), Magmar=makeIcon("126.png"), Pinsir=makeIcon("127.png"), Tauros=makeIcon("128.png"),
      Magikarp=makeIcon("129.png"), Gyarados=makeIcon("130.png"), Lapras=makeIcon("131.png"), Ditto=makeIcon("132.png"),
      Eevee=makeIcon("133.png"), Vaporeon=makeIcon("134.png"), Jolteon=makeIcon("135.png"), Flareon=makeIcon("136.png"),
      Porygon=makeIcon("137.png"), Omanyte=makeIcon("138.png"), Omastar=makeIcon("139.png"), Kabuto=makeIcon("140.png"),
      Kabutops=makeIcon("141.png"), Aerodactyl=makeIcon("142.png"), Snorlax=makeIcon("143.png"), Articuno=makeIcon("144.png"),
      Zapdos=makeIcon("145.png"), Moltres=makeIcon("146.png"), Dratini=makeIcon("147.png"), Dragonair=makeIcon("148.png"),
      Dragonite=makeIcon("149.png"), Mewtwo=makeIcon("150.png"), Mew=makeIcon("151.png")
      
    )
    
    
    icon_list = points() %>% left_join(., pokeID, by="pokemonId") %>% select(., Pokemon)

    poke_df = sp::SpatialPointsDataFrame(
      cbind(points()[,2], points()[,3]), data.frame(icons=icon_list)
        )

    leaflet(poke_df) %>% addTiles(options = providerTileOptions(noWrap = TRUE)) %>%
      addMarkers(icon=~pokeIcon[Pokemon], group="pokemon") 

  })
  

  # Render Infobox  
  output$position <- renderInfoBox({
    shiny::validate(shiny::need(input$map_click, FALSE))
    
    infoBox("Position", value=paste0("Longitude: ", round(input$map_click$lng, digit=2), "\n", 
                              "Latitude: ", round(input$map_click$lat, digit=2)), icon=icon("globe"))
  })
  
  output$prediction <- renderInfoBox({
    shiny::validate(shiny::need(input$map_click, FALSE))
    
    target = data.frame(longitude=as.numeric(input$map_click$lng), latitude=as.numeric(input$map_click$lat))
    target = cbind(target, coords2region(target))
    colnames(target)[3] = "region"
    modelName = paste0(target[1,3], ".RData")
    
    obs = target[, names(target)!="region"]
    obs = obs %>% select(., latitude, longitude)
    
    res_df = data.frame(matrix(0, ncol=5, nrow=1))
    
    knnFit = modelSel(modelName)
    
    res_df = predict(knnFit, newdata=obs, type="prob")*100
    res_df[, 4] = ifelse(length(res_df==3), 0, res[,4])
    res_df[, 5] = ifelse(length(res_df==4), 0, res[,5])
    colnames(res_df) = c("Common", "Uncommon", "Rare", "Very Rare", "Super Rare")
    infoBox("Prediction", value=paste0("C: ", round(res_df[1,1], digit=2), "|",
                                       "U: ", round(res_df[1,2], digit=2), "|",
                                       "R: ", round(res_df[1,3], digit=2), "|",
                                       "VR: ", round(res_df[1,4], digit=2), "|",
                                       "SR: ", round(res_df[1,5], digit=2), "|"),
            icon=icon("calculator"))

  })
  
  # Adding additional marker
  observe({
    shiny::validate(shiny::need(input$map_click, FALSE))
    leafletProxy("map") %>% 
      addMarkers(input$map_click$lng, input$map_click$lat)
  })
  
  # Subsetting contour points
  cityPts = eventReactive(input$gen, {
    dbGetQuery(pokedb, paste0("SELECT pokemonId, longitude, latitude, rarity FROM ", dbCity(input$city)))
  })
  
  # Render kde map
  output$kdeMap <- renderLeaflet({

    kde <- bkde2D(select(cityPts(), longitude, latitude),
                  bandwidth=c(.0045, .0045), gridsize = c(1000,1000))
    CL <- contourLines(kde$x1 , kde$x2 , kde$fhat)
    
    ## EXTRACT CONTOUR LINE LEVELS
    LEVS <- as.factor(sapply(CL, `[[`, "level"))
    NLEV <- length(levels(LEVS))
    
    ## CONVERT CONTOUR LINES TO POLYGONS
    pgons <- lapply(1:length(CL), function(i)
      Polygons(list(Polygon(cbind(CL[[i]]$x, CL[[i]]$y))), ID=i))
    spgons = SpatialPolygons(pgons)
    
    leaflet(spgons) %>% addTiles() %>% addPolygons(color = heat.colors(NLEV, NULL)[LEVS])
    
  })
  
  # Render barplot
  output$rareDist <- renderPlot(ggplot(data=cityPts(), aes(x=as.factor(rarity))) + 
                                  geom_bar(fill="gold2", color="dodgerblue3", size=3) + 
                                  theme_bw() + ylab("Frequency") + xlab("Rarity") + 
                                  ggtitle("Rarity Distribution") + 
                                  scale_x_discrete(labels=c("1"="Common", "2"="Uncommon", "3"="Rare",
                                                            "4"="Very Rare", "5"="Supe Rare"))
                                  )
  
}

