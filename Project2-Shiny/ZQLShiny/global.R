
#use wide dataframe
data <- read.csv('shiny_wide.csv', stringsAsFactors = F)
data_long <- read.csv('shiny_long.csv', stringsAsFactors = F)

trend_data <- subset(data_long,CountryName%in%c("United States","United Kingdom",
                                                "United Arab Emirates", "Spain",
                                                "Sweden","New Zealand",
                                                "Ireland","Israel","Italy",
                                                "Japan", "Mexico","Netherlands",
                                                "India","France", "Germany",
                                                "Canada","Chile","China",
                                                "Colombia", "Australia", "Brazil") )
trend_cn <- c("United States","United Kingdom",
              "United Arab Emirates", "Spain",
              "Sweden","New Zealand",
              "Ireland","Israel","Italy",
              "Japan", "Mexico","Netherlands",
              "India","France", "Germany",
              "Canada","Chile","China",
              "Colombia", "Australia", "Brazil")



