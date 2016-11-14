



routingParser <- function(routing.string){
  
  # more cleaning, removing city names in parantheses.
  # was left in for readability in data frame, future better to clean
  # from scrapy
  routing <- gsub(' \\(\\w*\\)', '', routing.string)
  airports <- character()
  routing.vector <- strsplit(routing, ' - ')[[1]]
  for(r in routing.vector){
    airports <- c(airports, filter(airport.codes, Code == r)['Location'] )
  }


  origin <- airports[1]
  destination <- airports[(length(airports) + 1) / 2]
  
  return(airports)
                  
}

routingParser('LAX - NRT (Tokyo) - TPE (Taipei) - NRT - LAX')



dateParser <- function(date.string){
  # complicated, deal via cases.
  
  dates.raw <- strsplit(date.string, '/')

  # replace early mid and late with arbitrary dates
  dates.raw <- lapply(dates.raw, function(x){gsub('early', '|10|', x)})
  dates.raw <- lapply(dates.raw, function(x){gsub('mid', '|15|', x)})
  dates.raw <- lapply(dates.raw, function(x){gsub('late', '|20|', x)})
  
  # handle no dates somehow. add 1 or 30 eventually. Watch out for February?
  
  # swap month and day to preserve order
  # while(regexpr('|', dates.raw)[1] != -1){
  #   idx <- regexpr('|')[1]
  #   dates.raw <- paste0(substr(dates.raw, 1, idx - 1), 
  #                       
  #                       substr(dates.raw, idx + 1, idx + 2)
  # }
  
  dates.parsed <- dates.raw
  
  return(dates.parsed)                                  
  # use regematches with m as gregrexp to do the above swpa
    
}

dateParser('early Feburary, 2017 - late December, 2017')
