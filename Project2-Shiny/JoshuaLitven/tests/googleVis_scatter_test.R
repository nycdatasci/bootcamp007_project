library(googleVis)
#demo(googleVis)

Departments = c('Art' , 'Music', 'Theatre', 'Anthropology', 'Economics',
                'History', 'Political Science', 'Sociology', 'Chinese',  'Classics',
                'English', 'French', 'German', 'Russian', 'Spanish',
                'Biology', 'Chemistry', 'Mathematics', 'Physics', 'Linguistics',
                'Philosophy', 'Psychology', 'Religion')

Majors = c(58, 21, 16, 52, 56,
           57, 68, 28, 6, 20, 
           150, 5, 2, 7, 3, 
           153.5, 74, 72.5, 125, 45,
           75, 98, 25)

FTE = c(7.8, 4, 6.25, 5, 5.6, 
        8.7, 5.5, 3, 3, 4, 
        12, 5, 3, 3, 5, 
        9, 6.8, 8, 6, 4, 
        5.7, 7.7, 4)

data <- data.frame(Departments, Majors, FTE)


if( !is.element("googleVis", installed.packages()[,1]) )
  install.packages("googleVis")

suppressPackageStartupMessages(library(googleVis))

# make a new data frame with only two columns to scatter plot 
keep <- c('Majors', 'FTE')
data2 <- data[keep]

# add names to new data frame as factor 
data2$pop.html.tooltip=data$Departments

# create interactive scatter plot using googleVis
Scatter1 <- gvisScatterChart(data2,                                                           
                             options=list(tooltip="{isHtml:'True'}",              # Define tooltip                            
                                          legend="none", lineWidth=0, pointSize=5,                                                     
                                          vAxis="{title:'Faculty (Total FTE)'}",             # y-axis label                
                                          hAxis="{title:'Majors (delared and intended)'}",   # x-axis label                     
                                          width=750, height=500))                            # plot dimensions 

# plot interactive scatter (use 'plot(Scatter1)' to view in RStudio)
plot(Scatter1)

table = gvisTable(data2)
plot(table)
