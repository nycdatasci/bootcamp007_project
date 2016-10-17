
bar_plot <- function(data, xvar, group, 
                     position = "stack", 
                     color = "black",
                     palette = "Spectral") {
  g <- ggplot(data, aes_string(xvar, fill = group)) +
    geom_bar(position = position, color = color) + 
    scale_fill_brewer(palette = palette)
  if(position == "fill") {
    g <- g + ylab("Percentage")
  }
  return(g)
}


heat_map <- function(data, xvar, yvar, colvar, 
                     low = "white",
                     high = "black") {
  ggplot(data, aes_string(xvar, yvar)) + 
    geom_tile(aes_string(fill = colvar)) +
    scale_fill_gradient(low = low, high = high) +
    theme_classic()
}

toDay <- function(x) {
  sapply(x, function(x){
    age <- unlist(strsplit(x, split = " "))
    if(grepl("day", age[2])) 
      return(as.numeric(age[1]))
    else 
      return(NA)
  })
}

toWeek <- function(x) {
  sapply(x, function(x){
    age <- unlist(strsplit(x, split = " "))
    if(grepl("day", age[2])) 
      return(0)
    else if(grepl("week", age[2])) 
      return(as.numeric(age[1]))
    else 
      return(NA)
  })
}

toMonth <- function(x) {
  sapply(x, function(x){
    age <- unlist(strsplit(x, split = " "))
    if(grepl("day", age[2]) | grepl("week", age[2])) 
      return(0)
    else if(grepl("month", age[2])) 
      return(as.numeric(age[1]))
    else return(NA)
  })
}

toYear <- function(x) {
  sapply(x, function(x){
    age <- unlist(strsplit(x, split = " "))
    if(grepl("day", age[2]) | grepl("week", age[2]) | grepl("month", age[2])) 
      return(0)
    else if(grepl("year", age[2])) 
      return(as.numeric(age[1]))
    else return(NA)
  })
}

