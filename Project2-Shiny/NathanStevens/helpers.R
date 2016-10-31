# return the average rating by the state 
getAvgRatingByState = function(infection) {
  gbDF = data.frame()
  
  if(infection == 'ALL') {
    gbDF = group_by(infectionsDF, State)
  } else {
    df = filter(infectionsDF, Normalized.Measure.ID == infection)
    gbDF = group_by(df, State)
  }
  
  # multiply the returned avg rating by 100 to make this numbers integers
  avgRatingDF = summarise(gbDF, Avg.Rating = mean(Normalized.Rating)*100)
  avgRatingDF$Avg.Rating = as.integer(avgRatingDF$Avg.Rating)
  avgRatingDF  = arrange(avgRatingDF, Avg.Rating)
  
  return(avgRatingDF)
}

# return the average rating by hospital and state
getHospitalRatingByState = function(stateAbbr, infection) {
  # prefilter by state
  df = filter(infectionsDF, State == stateAbbr)
  
  if(nrow(df) == 0) {
    return(data.frame())
  }
  
  # now group by infection
  gbDF = data.frame()
  if(infection == 'ALL') {
    gbDF = group_by(df, Provider.ID)
  } else {
    df = filter(df, Normalized.Measure.ID == infection)
    gbDF = group_by(df, Provider.ID)
  }
  
  ratingDF = summarise(gbDF, Rating = sum(Normalized.Rating))
  ratingDF = arrange(ratingDF, Rating)
  
  if(nrow(ratingDF) != 0) {
    # add column we can use for the axis #3
    ratingDF$Hospital = seq(1:nrow(ratingDF))
    
    # now add colum which holds value that controls the sizing #4
    ratingDF = mutate(ratingDF, 
                      Standing = ifelse(Rating < 0, 'Better',
                                        ifelse(Rating == 0, 'No Difference', 'Worst')),
                      Relative.Rating = abs(Rating) + 1) 
    
    # now rearange the columns so they plotted corrected
    ratingDF = ratingDF[, c(1,3,2,4,5)]
    return(ratingDF)
  } else {
    return(data.frame())
  }
}

# function to return all the raw data filtered by the state
getDataByState = function(stateAbbr) {
  # prefilter by state
  df = filter(infectionsDF, State == stateAbbr)
  df = df[, c(1:7)]
  
  return(df)
}

# function to convert abreviation to fullname for states, districts,
# territories. Original code from the gitgub below
# orginal code lifted from github
abb2state <- function(name, convert = F, strict = F){
  data(state)
  
  # state data doesn't include DC, PR, or Guam
  state = list()
  state[['name']] = c(state.name,"District Of Columbia", "Puerto Rico", "Guam")
  state[['abb']] = c(state.abb,"DC", "PR", "Gu")
  
  if(convert) state[c(1,2)] = state[c(2,1)]
  
  single.a2s <- function(s){
    if(strict){
      is.in = tolower(state[['abb']]) %in% tolower(s)
      ifelse(any(is.in), state[['name']][is.in], NA)
    }else{
      # To check if input is in state full name or abb
      is.in = rapply(state, function(x) tolower(x) %in% tolower(s), how="list")
      state[['name']][is.in[[ifelse(any(is.in[['name']]), 'name', 'abb')]]]
    }
  }
  sapply(name, single.a2s)
}