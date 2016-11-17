# Xbox 360 Backwards Compatability Predictor
# Nick Talavera
# Date: November 1, 2016

# server.R

#===============================================================================
#                               SHINYSERVER                                    #
#===============================================================================
str_Currency <- function(value, currency.sym="$", digits=2, sep=",", decimal=".") {
  paste(
    currency.sym,
    formatC(value, format = "f", big.mark = sep, digits=digits, decimal.mark=decimal),
    sep=""
  )
}

reorder_size <- function(x) {
  factor(x, levels = names(sort(table(x))))
}

shinyServer(function(input, output, session) {
  
  ######################
  #Data sets
  ######################
  
  # Return the requested dataset
  getDataSetToUse <- eventReactive(input$query, {
    dataToDisplay = getDataPresentable()
    
    # input$SEARCH_Is_Backwards_Compatible
    # input$SEARCH_Predicted_to_become_Backwards_Compatible
    # input$SEARCH_Backwards_Compatibility_Probability_Percent
    # input$SEARCH_Release_date
    # input$SEARCH_Is_Listed_on_XboxCom
    # input$SEARCH_Is_Exclusive
    # input$SEARCH_Xbox_One_Version_Available
    # input$SEARCH_Is_On_Uservoice
    # input$SEARCH_Uservoice_Votes
    # input$SEARCH_Uservoice_Comments
    # input$SEARCH_Is_Kinect_Supported
    # input$SEARCH_Is_Kinect_Required
    # input$SEARCH_Does_The_Game_Need_Special_Peripherals
    # input$SEARCH_Is_The_Game_Retail_Only
    # input$SEARCH_Available_to_Purchase_a_Digital_Copy_on_Xbox.com
    # input$SEARCH_Has_a_Demo_Available
    # input$SEARCH_Xbox_User_Review_Score
    # input$SEARCH_Xbox_User_Review_Counts
    # input$SEARCH_Metacritic_Review_Score
    # input$SEARCH_Metacritic_User_Review_Score
    # input$SEARCH_Price_on_Xbox.com
    # input$SEARCH_Publisher
    # input$SEARCH_Developer
    # input$SEARCH_Genre
    # input$SEARCH_ESRB_Rating
    # input$SEARCH_Features
    # input$SEARCH_Smartglass_Compatible
    # input$SEARCH_Number_of_Game_Add-Ons
    # input$SEARCH_Number_of_Avatar_Items
    # input$SEARCH_Number_of_GamerPics
    # input$SEARCH_Number_of_Themes
    # input$SEARCH_Number_of_Game_Videos
    print("NEW SEARCH")
    print(paste("SEARCH_Is_Backwards_Compatible", input$SEARCH_Is_Backwards_Compatible))
    if (!is.null(input$SEARCH_Is_Backwards_Compatible)) {
      dataToDisplay = dataToDisplay[dataToDisplay$isBCCompatible == input$SEARCH_Is_Backwards_Compatible[1] | dataToDisplay$isBCCompatible == input$SEARCH_Is_Backwards_Compatible[2],]
    }
    print(paste("SEARCH_Predicted_to_become_Backwards_Compatible", input$SEARCH_Predicted_to_become_Backwards_Compatible))
    if (!is.null(input$SEARCH_Backwards_Compatibility_Probability_Percent)) {
      dataToDisplay = dataToDisplay[dataToDisplay$percentProb >= input$SEARCH_Backwards_Compatibility_Probability_Percent[1] & dataToDisplay$percentProb <= input$SEARCH_Backwards_Compatibility_Probability_Percent[2],]
    }
    print(paste("SEARCH_Is_Listed_on_XboxCom", input$SEARCH_Is_Listed_on_XboxCom))
    print(paste("SEARCH_Is_Exclusive", input$SEARCH_Is_Exclusive))
    print(paste("SEARCH_Xbox_One_Version_Available", input$SEARCH_Xbox_One_Version_Available))
    print(paste("SEARCH_Is_On_Uservoice", input$SEARCH_Is_On_Uservoice))
    if (!is.null(input$SEARCH_Uservoice_Votes)) {
      dataToDisplay = dataToDisplay[dataToDisplay$votes >= input$SEARCH_Uservoice_Votes[1] & dataToDisplay$votes <= input$SEARCH_Uservoice_Votes[2],]
    }
    if (!is.null(input$SEARCH_Uservoice_Comments)) {
      dataToDisplay = dataToDisplay[dataToDisplay$comments >= input$SEARCH_Uservoice_Comments[1] & dataToDisplay$comments <= input$SEARCH_Uservoice_Comments[2],]
    }
    print(paste("SEARCH_Is_Kinect_Supported", input$SEARCH_Is_Kinect_Supported))
    print(paste("SEARCH_Is_Kinect_Required", input$SEARCH_Is_Kinect_Required))
    print(paste("SEARCH_Does_The_Game_Need_Special_Peripherals", input$SEARCH_Does_The_Game_Need_Special_Peripherals))
    print(paste("SEARCH_Is_The_Game_Retail_Only", input$SEARCH_Is_The_Game_Retail_Only))
    print(paste("SEARCH_Available_to_Purchase_a_Digital_Copy_on_Xbox.com", input$SEARCH_Available_to_Purchase_a_Digital_Copy_on_Xbox.com))
    print(paste("SEARCH_Has_a_Demo_Available", input$SEARCH_Has_a_Demo_Available))
    if (!is.null(input$SEARCH_Xbox_User_Review_Score)) {
      dataToDisplay = dataToDisplay[dataToDisplay$xbox360Rating >= input$SEARCH_Xbox_User_Review_Score[1] & dataToDisplay$xbox360Rating <= input$SEARCH_Xbox_User_Review_Score[2],]
    }
    if (!is.null(input$SEARCH_Xbox_User_Review_Counts)) {
      dataToDisplay = dataToDisplay[dataToDisplay$numberOfReviews >= input$SEARCH_Xbox_User_Review_Counts[1] & dataToDisplay$numberOfReviews <= input$SEARCH_Xbox_User_Review_Counts[2],]
    }
    if (!is.null(input$SEARCH_Uservoice_Votes)) {
      dataToDisplay = dataToDisplay[dataToDisplay$reviewScorePro >= input$SEARCH_Metacritic_Review_Score[1] & dataToDisplay$reviewScorePro <= input$SEARCH_Metacritic_Review_Score[2],]
    }
    if (!is.null(input$SEARCH_Metacritic_User_Review_Score)) {
      dataToDisplay = dataToDisplay[dataToDisplay$reviewScoreUser >= input$SEARCH_Metacritic_User_Review_Score[1] & dataToDisplay$reviewScoreUser <= input$SEARCH_Metacritic_User_Review_Score[2],]
    }
    if (!is.null(input$SEARCH_Price_on_Xbox.com)) {
      dataToDisplay = dataToDisplay[dataToDisplay$price >= input$SEARCH_Price_on_Xbox.com[1] & dataToDisplay$price <= input$SEARCH_Price_on_Xbox.com[2],]
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
    print(paste("SEARCH_Smartglass_Compatible", input$SEARCH_Smartglass_Compatible))
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
    # dataToDisplay = dataToDisplay[!is.na(dataToDisplay$gameName),]
    return(dataToDisplay)
  }, ignoreNULL = FALSE)
  
  
  getDataPresentable = function(){
    dataToPresent = xboxData
    dataToPresent = dataToPresent[dataToPresent$gameName != "TRUE",]
    # dataToPresent$percentProb[dataToPresent$isBCCompatible == TRUE] = 100
    dataToPresent$bcGuess = as.logical(dataToPresent$bcGuess)
    # dataToPresent[dataToPresent == TRUE] = TRUE
    # dataToPresent[dataToPresent == FALSE] = FALSE
    return(dataToPresent)
  }
  
  output$List_SearchResults <- DT::renderDataTable(
    DT::datatable(
      {
        dataToPresent = getDataSetToUse()
        print(nrow(dataToPresent))
        dataToPresent = dplyr::select(dataToPresent, Name = gameName, 'Predicted Backwards Compatible' = bcGuess, "Percent Probability" = percentProb, "Uservoice Votes" = as.numeric(votes), "Available for Digital Download" = isAvailableToPurchaseDigitally, 
                                      "On Microsoft's Site" = isListedOnMSSite, "Kinect Supported" = isKinectSupported,
                                      "Kinect Required" = isKinectRequired, "Exclusive" = isExclusive, "Is Console Exclusive" = isConsoleExclusive, "Metacritic Rating" = reviewScorePro, 
                                      "Metacritic User Rating" = reviewScoreUser, "Xbox User Rating" = xbox360Rating, 'Price' = price, 'Game Addons' = DLgameAddons, "Genre" = genre,
                                      'Publisher'= publisher, 'Developer' = developer, "Xbox One Version Available" = isOnXboxOne)
        print(nrow(dataToPresent))
        dataToPresent
      }, selection = "none",
      options = list(scrollX = TRUE,
                     lengthMenu = list(c(15, 30, -1), c('15', '30', 'All')),
                     pageLength = 15
      ),
      escape = FALSE
    )
  )
  
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
        dataToPresent = dplyr::select(dataToPresent, Name = gameName, 'Predicted Backwards Compatible' = bcGuess, "Percent Probability" = percentProb, "Uservoice Votes" = as.numeric(votes), "Available for Digital Download" = isAvailableToPurchaseDigitally, 
                                      "On Microsoft's Site" = isListedOnMSSite, "Kinect Supported" = isKinectSupported,
                                      "Kinect Required" = isKinectRequired, "Exclusive" = isExclusive, "Is Console Exclusive" = isConsoleExclusive, "Metacritic Rating" = reviewScorePro, 
                                      "Metacritic User Rating" = reviewScoreUser, "Xbox User Rating" = xbox360Rating, 'Price' = price, 'Game Addons' = DLgameAddons, "Genre" = genre,
                                      'Publisher'= publisher, 'Developer' = developer, "Xbox One Version Available" = isOnXboxOne)
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
        dataToPresent = dataToPresent[dataToPresent$bcGuess == TRUE & dataToPresent$isBCCompatible == FALSE,]
        dataToPresent = dplyr::select(dataToPresent, Name = gameName, "Percent Probability" = percentProb, "Uservoice Votes" = as.numeric(votes), "Available for Digital Download" = isAvailableToPurchaseDigitally, 
                                      "On Microsoft's Site" = isListedOnMSSite, "Kinect Supported" = isKinectSupported,
                                      "Kinect Required" = isKinectRequired, "Exclusive" = isExclusive, "Is Console Exclusive" = isConsoleExclusive, "Metacritic Rating" = reviewScorePro, 
                                      "Metacritic User Rating" = reviewScoreUser, "Xbox User Rating" = xbox360Rating, 'Price' = as.numeric(price), 'Game Addons' = DLgameAddons, "Genre" = genre,
                                      'Publisher'= publisher, 'Developer' = developer, "Xbox One Version Available" = isOnXboxOne)
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
  
  # # you can also use paging = FALSE to disable pagination
  # output$ex3 <- DT::renderDataTable(
  #   DT::datatable(iris, options = list(paging = FALSE))
  # )
  
  output$List_KinectGames <- DT::renderDataTable(
    DT::datatable(
      {
        dataToPresent = getDataPresentable()
        dataToPresent = dataToPresent[dataToPresent$isKinectSupported == TRUE | dataToPresent$isKinectRequired == TRUE,]
        dataToPresent = dplyr::select(dataToPresent, Name = gameName, "Kinect Required" = isKinectRequired, "Percent Probability" = percentProb, "Uservoice Votes" = votes, 
                                      "Available for Digital Download" = isAvailableToPurchaseDigitally, "On Microsoft's Site" = isListedOnMSSite, 
                                      "Exclusive" = isExclusive, "Is Console Exclusive" = isConsoleExclusive, "Metacritic Rating" = reviewScorePro, 
                                      "Metacritic User Rating" = reviewScoreUser, "Xbox User Rating" = xbox360Rating, 'Price' = price, 'Game Addons' = DLgameAddons, "Genre" = genre,
                                      'Publisher'= publisher, 'Developer' = developer, "Xbox One Version Available" = isOnXboxOne)
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
        dataToPresent = dplyr::select(dataToPresent, Name = gameName, "Uservoice Votes" = votes, "Available for Digital Download" = isAvailableToPurchaseDigitally, 
                                      "On Microsoft's Site" = isListedOnMSSite, "Kinect Supported" = isKinectSupported,
                                      "Kinect Required" = isKinectRequired, "Exclusive" = isExclusive, "Is Console Exclusive" = isConsoleExclusive, "Metacritic Rating" = reviewScorePro, 
                                      "Metacritic User Rating" = reviewScoreUser, "Xbox User Rating" = xbox360Rating, 'Price' = price, 'Game Addons' = DLgameAddons, "Genre" = genre,
                                      'Publisher'= publisher, 'Developer' = developer)
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
        dataToPresent = dplyr::select(dataToPresent, Name = gameName, "Is Console Exclusive" = isConsoleExclusive, "Uservoice Votes" = votes, "Available for Digital Download" = isAvailableToPurchaseDigitally, 
                                      "On Microsoft's Site" = isListedOnMSSite, "Kinect Supported" = isKinectSupported,
                                      "Kinect Required" = isKinectRequired, "Metacritic Rating" = reviewScorePro, 
                                      "Metacritic User Rating" = reviewScoreUser, "Xbox User Rating" = xbox360Rating, 'Price' = price, 'Game Addons' = DLgameAddons, "Genre" = genre,
                                      'Publisher'= publisher, 'Developer' = developer, "Xbox One Version Available" = isOnXboxOne)
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
  
  
  output$PublisherBottom <- shiny::renderTable(
    head({
      dataToPresent = getDataPresentable()
      dataToPresent = dataToPresent[dataToPresent$isKinectRequired == FALSE & dataToPresent$usesRequiredPeripheral == FALSE,]
      dataToPresent = summarise(group_by(dataToPresent, "Publisher" = publisher), "Games Made Backwards Compatible" = length(isBCCompatible[isBCCompatible==TRUE]), "Games Published" = length(gameName), "Percent" = as.integer(round(length(isBCCompatible[isBCCompatible==TRUE])/length(gameName)*100,0)))
      dataToPresent = dplyr::arrange(dataToPresent, Percent, desc(dataToPresent$"Games Published"))
      dataToPresent
    }, 
    n = max(length(dataToPresent$"Percent"[dataToPresent$"Percent" == 0]),25))
  )
  
  
  output$PublisherTop <- shiny::renderTable(
    head({
      dataToPresent = getDataPresentable()
      dataToPresent = dataToPresent[dataToPresent$isKinectRequired == FALSE & dataToPresent$usesRequiredPeripheral == FALSE,]
      dataToPresent = summarise(group_by(dataToPresent, "Publisher" = publisher), "Games Made Backwards Compatible" = length(isBCCompatible[isBCCompatible==TRUE]), "Games Published" = length(gameName), "Percent" = as.integer(round(length(isBCCompatible[isBCCompatible==TRUE])/length(gameName)*100,0)))
      dataToPresent = arrange(dataToPresent, desc(Percent), desc(dataToPresent$"Games Published"))
      dataToPresent
    }, 
    n = 25)
  )
  
  output$Explanation <- renderUI({
    if (file.exists("Markdowns/Explanation.Rmd")) {
      file = "Markdowns/Explanation.Rmd"
    } else  if (file.exists("./Markdowns/Explanation.Rmd")) {
      file = "./Markdowns/Explanation.Rmd"
    } else if (file.exists("/srv/shiny-server/bootcamp007_project/Project3-WebScraping/NickTalavera/Markdowns/Explanation.Rmd")) {
      file = "/srv/shiny-server/bootcamp007_project/Project3-WebScraping/NickTalavera/Markdowns/Explanation.Rmd"
    }
    HTML(markdown::markdownToHTML(knit(file, quiet = TRUE), stylesheet = NA))
  })
  
  output$AboutMe <- renderUI({
    if (file.exists("Markdowns/AboutMe.Rmd")) {
      file = "Markdowns/AboutMe.Rmd"
    } else  if (file.exists("./Markdowns/AboutMe.Rmd")) {
      file = "./Markdowns/AboutMe.Rmd"
    } else if (file.exists("/srv/shiny-server/bootcamp007_project/Project3-WebScraping/NickTalavera/Markdowns/AboutMe.Rmd")) {
      file = "/srv/shiny-server/bootcamp007_project/Project3-WebScraping/NickTalavera/Markdowns/AboutMe.Rmd"
    }
    HTML(markdown::markdownToHTML(knit(file, quiet = TRUE), stylesheet = NA))
  })
})