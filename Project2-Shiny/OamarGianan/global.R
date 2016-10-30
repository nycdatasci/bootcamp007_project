library(readr)
library(dplyr)
library(circlize)

#load dataset
all_data <- read_csv('all_data.csv')
all_categorized <- read_csv('all_categorized.csv')
From <- unique(all_data$From)
To <- unique(all_data$To)
Countries <- sort(c(From, To))
Countries <- as.data.frame(unique(Countries))

Colored <- Countries
Colored$Col <- rand_color(nrow(Colored))
