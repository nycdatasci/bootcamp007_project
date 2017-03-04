# Xbox 360 Backwards Compatability Predictor
# Nick Talavera
# Date: November 1, 2016

# server.R

#===============================================================================
#                               SHINYSERVER                                    #
#===============================================================================
shinyServer(function(input, output, session) {
  observe({
    # Re-execute this reactive expression after 1000 milliseconds
    invalidateLater(1000*60*5, session)
  })
  #=============================================================================
  #                              DATA PREPERATION                              #
  #=============================================================================
  getDataSetToUse <- eventReactive(input$query, {
    dataToDisplay = getDataPresentable()
    if (!is.null(input$SEARCH_Is_Backwards_Compatible)) {
      dataToDisplay = dataToDisplay[dataToDisplay$isBCCompatible == input$SEARCH_Is_Backwards_Compatible[1] | dataToDisplay$isBCCompatible == input$SEARCH_Is_Backwards_Compatible[2],]
    }

    # if (!is.null(input$SEARCH_Uservoice_Votes)) {
    #   dataToDisplay = dataToDisplay[dataToDisplay$votes >= input$SEARCH_Uservoice_Votes[1] & dataToDisplay$votes <= input$SEARCH_Uservoice_Votes[2],]
    # }
    # if (!is.null(input$SEARCH_Uservoice_Comments)) {
    #   dataToDisplay = dataToDisplay[(dataToDisplay$comments >= input$SEARCH_Uservoice_Comments[1] | is.na(dataToDisplay$comments)) & dataToDisplay$comments <= input$SEARCH_Uservoice_Comments[2],]
    # }
    # print(paste("SEARCH_Is_Exclusive", input$SEARCH_Is_Exclusive))
    # print(paste("SEARCH_Xbox_One_Version_Available", input$SEARCH_Xbox_One_Version_Available))
    # print(paste("SEARCH_Is_On_Uservoice", input$SEARCH_Is_On_Uservoice))
    # print(paste("SEARCH_Is_Kinect_Supported", input$SEARCH_Is_Kinect_Supported))
    # print(paste("SEARCH_Is_Kinect_Required", input$SEARCH_Is_Kinect_Required))
    # print(paste("SEARCH_Does_The_Game_Need_Special_Peripherals", input$SEARCH_Does_The_Game_Need_Special_Peripherals))
    # print(paste("SEARCH_Is_The_Game_Retail_Only", input$SEARCH_Is_The_Game_Retail_Only))
    # print(paste("SEARCH_Available_to_Purchase_a_Digital_Copy_on_Xbox.com", input$SEARCH_Available_to_Purchase_a_Digital_Copy_on_Xbox.com))
    # print(paste("SEARCH_Has_a_Demo_Available", input$SEARCH_Has_a_Demo_Available))
    # print(paste("SEARCH_Smartglass_Compatible", input$SEARCH_Smartglass_Compatible))
    
    if (!is.null(input$SEARCH_Predicted_to_become_Backwards_Compatible)) {
      print(input$SEARCH_Predicted_to_become_Backwards_Compatible)
      dataToDisplay = dataToDisplay[which((dataToDisplay$predicted_isBCCompatible%in%input$SEARCH_Predicted_to_become_Backwards_Compatible)),]
    }
    
    print(colnames(dataToDisplay))
    # if (!is.null(input$SEARCH_Is_Listed_on_XboxCom)) {
    #   dataToDisplay = dataToDisplay[which(dataToDisplay$isListedOnMSSite$%in%input$SEARCH_Is_Listed_on_XboxCom),]
    # }
    # if (!is.null(input$SEARCH_Is_Exclusive)) {
    #   dataToDisplay = dataToDisplay[which((dataToDisplay$isExclusive%in%input$SEARCH_Is_Exclusive)),]
    # }
    if (!is.null(input$SEARCH_Features)) {
      dataToDisplay = dataToDisplay[which((dataToDisplay$features%in%input$SEARCH_Features)),]
    }
    if (!is.null(input$SEARCH_Features)) {
      dataToDisplay = dataToDisplay[which((dataToDisplay$features%in%input$SEARCH_Features)),]
    }
    if (!is.null(input$SEARCH_Features)) {
      dataToDisplay = dataToDisplay[which((dataToDisplay$features%in%input$SEARCH_Features)),]
    }
    if (!is.null(input$SEARCH_Features)) {
      dataToDisplay = dataToDisplay[which((dataToDisplay$features%in%input$SEARCH_Features)),]
    }
    if (!is.null(input$SEARCH_Features)) {
      dataToDisplay = dataToDisplay[which((dataToDisplay$features%in%input$SEARCH_Features)),]
    }
    if (!is.null(input$SEARCH_Features)) {
      dataToDisplay = dataToDisplay[which((dataToDisplay$features%in%input$SEARCH_Features)),]
    }
    
    
    
    
    
    
    
    
    
    if (!is.null(input$SEARCH_Xbox_User_Review_Score)) {
      dataToDisplay = dataToDisplay[(is.na(dataToDisplay$xbox360Rating) & input$SEARCH_Xbox_User_Review_Score[1] == 0) | (dataToDisplay$xbox360Rating >= input$SEARCH_Xbox_User_Review_Score[1] & dataToDisplay$xbox360Rating <= input$SEARCH_Xbox_User_Review_Score[2]),]
    }
    if (!is.null(input$SEARCH_Xbox_User_Review_Counts)) {
      dataToDisplay = dataToDisplay[(is.na(dataToDisplay$numberOfReviews) & input$SEARCH_Xbox_User_Review_Counts[1] == 0) | (dataToDisplay$numberOfReviews >= input$SEARCH_Xbox_User_Review_Counts[1] & dataToDisplay$numberOfReviews <= input$SEARCH_Xbox_User_Review_Counts[2]),]
    }
    if (!is.null(input$SEARCH_Uservoice_Votes)) {
      dataToDisplay = dataToDisplay[(is.na(dataToDisplay$reviewScorePro) & input$SEARCH_Uservoice_Votes[1] == 0) | (dataToDisplay$reviewScorePro >= input$SEARCH_Metacritic_Review_Score[1] & dataToDisplay$reviewScorePro <= input$SEARCH_Metacritic_Review_Score[2]),]
    }
    if (!is.null(input$SEARCH_Metacritic_User_Review_Score)) {
      dataToDisplay = dataToDisplay[(is.na(dataToDisplay$reviewScoreUser) & input$SEARCH_Metacritic_User_Review_Score[1] == 0) | (dataToDisplay$reviewScoreUser >= input$SEARCH_Metacritic_User_Review_Score[1] & dataToDisplay$reviewScoreUser <= input$SEARCH_Metacritic_User_Review_Score[2]),]
    }
    if (!is.null(input$SEARCH_Price_on_Xbox.com)) {
      dataToDisplay = dataToDisplay[(is.na(dataToDisplay$price) & input$SEARCH_Price_on_Xbox.com[1] == 0) | (dataToDisplay$price >= input$SEARCH_Price_on_Xbox.com[1] & dataToDisplay$price <= input$SEARCH_Price_on_Xbox.com[2]),]
    }
    if (!is.null(input$SEARCH_Publisher)) {
      dataToDisplay = dataToDisplay[which((dataToDisplay$publisher%in%input$SEARCH_Publisher)),]
    }
    if (!is.null(input$SEARCH_Developer)) {
      dataToDisplay = dataToDisplay[which((dataToDisplay$developer%in%input$SEARCH_Developer)),]
    }
    if (!is.null(input$SEARCH_Genre)) {
      dataToDisplay = dataToDisplay[which((dataToDisplay$genre%in%input$SEARCH_Genre)),]
    }
    if (!is.null(input$SEARCH_ESRB_Rating)) {
      dataToDisplay = dataToDisplay[which((dataToDisplay$ESRBRating%in%input$SEARCH_ESRB_Rating)),]
    }
    if (!is.null(input$SEARCH_Features)) {
      dataToDisplay = dataToDisplay[which((dataToDisplay$features%in%input$SEARCH_Features)),]
    }
    if (!is.null(input$SEARCH_Number_of_Game_Add_Ons)) {
      dataToDisplay = dataToDisplay[dataToDisplay$DLgameAddons >= input$SEARCH_Number_of_Game_Add_Ons[1] & dataToDisplay$DLgameAddons <= input$SEARCH_Number_of_Game_Add_Ons[2],]
    }
    if (!is.null(input$SEARCH_Number_of_Avatar_Items)) {
      dataToDisplay = dataToDisplay[dataToDisplay$DLavatarItems >= input$SEARCH_Number_of_Avatar_Items[1] & dataToDisplay$DLavatarItems <= input$SEARCH_Number_of_Avatar_Items[2],]
    }
    if (!is.null(input$SEARCH_Number_of_GamerPics)) {
      dataToDisplay = dataToDisplay[dataToDisplay$DLgamerPictures >= input$SEARCH_Number_of_GamerPics[1] & dataToDisplay$DLgamerPictures <= input$SEARCH_Number_of_GamerPics[2],]
    }
    if (!is.null(input$SEARCH_Number_of_Themes)) {
      dataToDisplay = dataToDisplay[dataToDisplay$DLthemes >= input$SEARCH_Number_of_Themes[1] & dataToDisplay$DLthemes <= input$SEARCH_Number_of_Themes[2],]
    }
    if (!is.null(input$SEARCH_Number_of_Game_Videos)) {
      dataToDisplay = dataToDisplay[dataToDisplay$DLgameVideos >= input$SEARCH_Number_of_Game_Videos[1] & dataToDisplay$DLgameVideos <= input$SEARCH_Number_of_Game_Videos[2],]
    }
    return(dataToDisplay)
  }, ignoreNULL = FALSE)
  
  
  getDataPresentable = function(){
    dataToPresent = xboxData
    dataToPresent = dataToPresent[dataToPresent$gameName != "TRUE",]
    dataToPresent = dataToPresent[!is.na(dataToPresent$gameName),]
    # dataToPresent$percentProb[dataToPresent$isBCCompatible == TRUE] = 100 #  ADD BACK IF MY MODEL PRODUCES PERCENT PROBABILITIES
    dataToPresent$predicted_isBCCompatible = as.logical(dataToPresent$predicted_isBCCompatible)
    return(dataToPresent)
  }
  
  #=============================================================================
  #                                 DATA TABLES                                #
  #=============================================================================
  output$List_SearchResults <- DT::renderDataTable(
    DT::datatable(
      {
        dataToPresent = getDataSetToUse()
        dataToPresent = dplyr::select(dataToPresent, Name = gameName, 'Predicted Backwards Compatible' = predicted_isBCCompatible, "Uservoice Votes" = as.numeric(votes), "Available for Digital Download" = isAvailableToPurchaseDigitally, 
                                      "On Microsoft's Site" = isListedOnMSSite, "Kinect Supported" = isKinectSupported,
                                      "Kinect Required" = isKinectRequired, "Exclusive" = isExclusive, "Is Console Exclusive" = isConsoleExclusive, "Metacritic Rating" = reviewScorePro, 
                                      "Metacritic User Rating" = reviewScoreUser, "Xbox User Rating" = xbox360Rating, 'Price' = price, 'Game Addons' = DLgameAddons, "Genre" = genre,
                                      'Publisher'= publisher, 'Developer' = developer, "Xbox One Version Available" = isOnXboxOne)
        dataToPresent = dataToPresent[!is.na(dataToPresent$Name),]
        dataToPresent = yesNo(dataToPresent)
      }, 
      selection = "none",
      options = list(scrollX = TRUE,
                     lengthMenu = list(c(15, 30, 50, -1), c('15', '30', '50', 'All')),
                     pageLength = 15
      ),
      escape = FALSE
    )
  )
  
  yesNo <- function(dataToPresent) {
    logicals = is.logical(dataToPresent)
    dataToPresent[logicals] = as.character(dataToPresent[logicals])
    dataToPresent[dataToPresent == 'FALSE'] = "No"
    dataToPresent[dataToPresent == 'TRUE'] = "Yes"
    return(dataToPresent)
  }
  
  output$List_BackwardsCompatibleGames <- DT::renderDataTable(
    DT::datatable(
      {
        dataToPresent = getDataPresentable()
        dataToPresent = dataToPresent[dataToPresent$isBCCompatible == TRUE,]
        dataToPresent = dplyr::select(dataToPresent, Name = gameName, "Available for Digital Download" = isAvailableToPurchaseDigitally, 
                                      "On Microsoft's Site" = isListedOnMSSite, "Kinect Supported" = isKinectSupported,
                                      "Kinect Required" = isKinectRequired, "Exclusive" = isExclusive, "Is Console Exclusive" = isConsoleExclusive, "Metacritic Rating" = reviewScorePro, 
                                      "Metacritic User Rating" = reviewScoreUser, "Xbox User Rating" = xbox360Rating, 'Price' = price, 'Game Addons' = DLgameAddons, "Genre" = genre,
                                      'Publisher'= publisher, 'Developer' = developer, "Xbox One Version Available" = isOnXboxOne)
        dataToPresent = yesNo(dataToPresent)
        dataToPresent
      }, selection = "none",
      options = list(scrollX = TRUE,
                     lengthMenu = list(c(15, 30, -1), c('15', '30', 'All')),
                     pageLength = 15
      ),
      escape = FALSE
    )
  )
  
  output$List_AllGames <- DT::renderDataTable(
    DT::datatable(
      {
        dataToPresent = getDataPresentable()
        dataToPresent = dplyr::select(dataToPresent, Name = gameName, 'Predicted Backwards Compatible' = predicted_isBCCompatible, "Uservoice Votes" = as.numeric(votes), "Available for Digital Download" = isAvailableToPurchaseDigitally, 
                                      "On Microsoft's Site" = isListedOnMSSite, "Kinect Supported" = isKinectSupported,
                                      "Kinect Required" = isKinectRequired, "Exclusive" = isExclusive, "Is Console Exclusive" = isConsoleExclusive, "Metacritic Rating" = reviewScorePro, 
                                      "Metacritic User Rating" = reviewScoreUser, "Xbox User Rating" = xbox360Rating, 'Price' = price, 'Game Addons' = DLgameAddons, "Genre" = genre,
                                      'Publisher'= publisher, 'Developer' = developer, "Xbox One Version Available" = isOnXboxOne)
        dataToPresent = yesNo(dataToPresent)
        dataToPresent
      }, selection = "none",
      options = list(scrollX = TRUE,
                     lengthMenu = list(c(15, 30, -1), c('15', '30', 'All')),
                     pageLength = 15
      ),
      escape = FALSE,
      fillContainer = FALSE,
      autoHideNavigation = FALSE
    )
  )
  
  output$List_PredictedBackwardsCompatible <- DT::renderDataTable(
    DT::datatable(
      {
        dataToPresent = getDataPresentable()
        dataToPresent = dataToPresent[dataToPresent$predicted_isBCCompatible == TRUE & dataToPresent$isBCCompatible == FALSE,]
        dataToPresent = dplyr::select(dataToPresent, Name = gameName, "Uservoice Votes" = as.numeric(votes), "Available for Digital Download" = isAvailableToPurchaseDigitally, 
                                      "On Microsoft's Site" = isListedOnMSSite, "Kinect Supported" = isKinectSupported,
                                      "Kinect Required" = isKinectRequired, "Exclusive" = isExclusive, "Is Console Exclusive" = isConsoleExclusive, "Metacritic Rating" = reviewScorePro, 
                                      "Metacritic User Rating" = reviewScoreUser, "Xbox User Rating" = xbox360Rating, 'Price' = as.numeric(price), 'Game Addons' = DLgameAddons, "Genre" = genre,
                                      'Publisher'= publisher, 'Developer' = developer, "Xbox One Version Available" = isOnXboxOne)
        dataToPresent[is.logical(dataToPresent) & dataToPresent == TRUE] = "Yes"
        dataToPresent[is.logical(dataToPresent) & dataToPresent == FALSE] = "No"
        dataToPresent
      }, selection = "none",
      options = list(scrollX = TRUE,
                     lengthMenu = list(c(15, 30, -1), c('15', '30', 'All')),
                     pageLength = 15
      ),
      escape = FALSE,
      fillContainer = FALSE,
      autoHideNavigation = FALSE
    )
  )
  
  output$List_KinectGames <- DT::renderDataTable(
    DT::datatable(
      {
        dataToPresent = getDataPresentable()
        dataToPresent = dataToPresent[dataToPresent$isKinectSupported == TRUE | dataToPresent$isKinectRequired == TRUE,]
        dataToPresent = dplyr::select(dataToPresent, Name = gameName, 'Predicted Backwards Compatible' = predicted_isBCCompatible, "Kinect Required" = isKinectRequired, "Uservoice Votes" = votes, 
                                      "Available for Digital Download" = isAvailableToPurchaseDigitally, "On Microsoft's Site" = isListedOnMSSite, 
                                      "Exclusive" = isExclusive, "Is Console Exclusive" = isConsoleExclusive, "Metacritic Rating" = reviewScorePro, 
                                      "Metacritic User Rating" = reviewScoreUser, "Xbox User Rating" = xbox360Rating, 'Price' = price, 'Game Addons' = DLgameAddons, "Genre" = genre,
                                      'Publisher'= publisher, 'Developer' = developer, "Xbox One Version Available" = isOnXboxOne)
        dataToPresent = yesNo(dataToPresent)
        dataToPresent
      }, selection = "none",
      options = list(scrollX = TRUE,
                     lengthMenu = list(c(15, 30, -1), c('15', '30', 'All')),
                     pageLength = 15
      ),
      escape = FALSE
    )
  )
  
  output$List_HasXboxOneVersion <- DT::renderDataTable(
    DT::datatable(
      {
        dataToPresent = getDataPresentable()
        dataToPresent = dataToPresent[dataToPresent$isOnXboxOne == TRUE | dataToPresent$isKinectRequired == TRUE,]
        dataToPresent = dplyr::select(dataToPresent, Name = gameName,'Predicted Backwards Compatible' = predicted_isBCCompatible, "Uservoice Votes" = votes, "Available for Digital Download" = isAvailableToPurchaseDigitally, 
                                      "On Microsoft's Site" = isListedOnMSSite, "Kinect Supported" = isKinectSupported,
                                      "Kinect Required" = isKinectRequired, "Exclusive" = isExclusive, "Is Console Exclusive" = isConsoleExclusive, "Metacritic Rating" = reviewScorePro, 
                                      "Metacritic User Rating" = reviewScoreUser, "Xbox User Rating" = xbox360Rating, 'Price' = price, 'Game Addons' = DLgameAddons, "Genre" = genre,
                                      'Publisher'= publisher, 'Developer' = developer)
        dataToPresent = yesNo(dataToPresent)
        dataToPresent
      }, selection = "none",
      options = list(scrollX = TRUE,
                     lengthMenu = list(c(15, 30, -1), c('15', '30', 'All')),
                     pageLength = 15
      )
    )
  )
  output$List_Exclusives <- DT::renderDataTable(
    DT::datatable(
      {
        dataToPresent = getDataPresentable()        
        dataToPresent = dataToPresent[dataToPresent$isExclusive == TRUE,]
        dataToPresent = dplyr::select(dataToPresent, Name = gameName, 'Predicted Backwards Compatible' = predicted_isBCCompatible, "Is Console Exclusive" = isConsoleExclusive, "Uservoice Votes" = votes, "Available for Digital Download" = isAvailableToPurchaseDigitally, 
                                      "On Microsoft's Site" = isListedOnMSSite, "Kinect Supported" = isKinectSupported,
                                      "Kinect Required" = isKinectRequired, "Metacritic Rating" = reviewScorePro, 
                                      "Metacritic User Rating" = reviewScoreUser, "Xbox User Rating" = xbox360Rating, 'Price' = price, 'Game Addons' = DLgameAddons, "Genre" = genre,
                                      'Publisher'= publisher, 'Developer' = developer, "Xbox One Version Available" = isOnXboxOne)
        dataToPresent = yesNo(dataToPresent)
        dataToPresent
      }, selection = "none",
      height = NULL,
      options = list(scrollX = TRUE,
                     lengthMenu = list(c(15, 30, -1), c('15', '30', 'All')),
                     pageLength = 15
      ),
      escape = FALSE,
      fillContainer = FALSE,
      autoHideNavigation = FALSE
    )
  )
  
  #=============================================================================
  #                               NORMAL TABLES                                #
  #=============================================================================
  output$PublisherBottom <- shiny::renderTable(
    head({
      dataToPresent = getDataPresentable()
      dataToPresent = dataToPresent[dataToPresent$isKinectRequired == FALSE & dataToPresent$usesRequiredPeripheral == FALSE,]
      dataToPresent = dplyr::summarise(dplyr::group_by(dataToPresent, "Publisher" = publisher), "Games Made Backwards Compatible" = length(isBCCompatible[isBCCompatible==TRUE]), "Games Published" = length(gameName), "Percent" = as.integer(round(length(isBCCompatible[isBCCompatible==TRUE])/length(gameName)*100,0)))
      dataToPresent = dplyr::arrange(dataToPresent, Percent, desc(dataToPresent$"Games Published"))
      dataToPresent = yesNo(dataToPresent)
      dataToPresent
    }, 
    n = max(length(dataToPresent$"Percent"[dataToPresent$"Percent" == 0]),25))
  )
  
  
  output$PublisherTop <- shiny::renderTable(
    head({
      dataToPresent = getDataPresentable()
      dataToPresent = dataToPresent[dataToPresent$isKinectRequired == FALSE & dataToPresent$usesRequiredPeripheral == FALSE,]
      dataToPresent = dplyr::summarise(dplyr::group_by(dataToPresent, "Publisher" = publisher), "Games Made Backwards Compatible" = length(isBCCompatible[isBCCompatible==TRUE]), "Games Published" = length(gameName), "Percent" = as.integer(round(length(isBCCompatible[isBCCompatible==TRUE])/length(gameName)*100,0)))
      dataToPresent = dplyr::arrange(dataToPresent, desc(Percent), desc(dataToPresent$"Games Published"))
      dataToPresent = yesNo(dataToPresent)
      dataToPresent
    }, 
    n = 25)
  )
  
  #=============================================================================
  #                                 HTML ELEMENTS                              #
  #=============================================================================
  output$Explanation <- renderUI({
    if (file.exists("Markdowns/Explanation.Rmd")) {
      file = "Markdowns/Explanation.Rmd"
    } else  if (file.exists("/Volumes/SDExpansion/Data Files/bootcamp007_project/Project3-WebScraping/NickTalavera/Markdowns/Explanation.Rmd")) {
      file = "/Volumes/SDExpansion/Data Files/bootcamp007_project/Project3-WebScraping/NickTalavera/Markdowns/Explanation.Rmd"
    } else if (file.exists("/srv/shiny-server/bootcamp007_project/Project3-WebScraping/NickTalavera/Markdowns/Explanation.Rmd")) {
      file = "/srv/shiny-server/bootcamp007_project/Project3-WebScraping/NickTalavera/Markdowns/Explanation.Rmd"
    }
    knittedFile = knit(file, quiet = TRUE)
    rmarkdown::render(file)
    HTML(markdown::markdownToHTML(knittedFile, stylesheet = 'www/custom.css'))
  })
  
  output$AboutMe <- renderUI({
    if (file.exists("Markdowns/AboutMe.Rmd")) {
      file = "Markdowns/AboutMe.Rmd"
    } else  if (file.exists("/Volumes/SDExpansion/Data Files/bootcamp007_project/Project3-WebScraping/NickTalavera/Markdowns/AboutMe.Rmd")) {
      file = "/Volumes/SDExpansion/Data Files/bootcamp007_project/Project3-WebScraping/NickTalavera/Markdowns/AboutMe.Rmd"
    } else if (file.exists("/srv/shiny-server/bootcamp007_project/Project3-WebScraping/NickTalavera/Markdowns/AboutMe.Rmd")) {
      file = "/srv/shiny-server/bootcamp007_project/Project3-WebScraping/NickTalavera/Markdowns/AboutMe.Rmd"
    }
    knittedFile = knit(file, quiet = TRUE)
    rmarkdown::render(file)
    HTML(markdown::markdownToHTML(knittedFile, stylesheet = 'www/custom.css'))
  })
})