#helper 

rm(list = ls())

library(dplyr)
library(readr)
library(tidyr)
library(reshape2)



df = read.csv("~/Documents/Rworkfiles/world-development-indicators/Indicators.csv",
              header = T, stringsAsFactors = F)

####reshape make IndicatorCode into columns
### use reshape have correct result

data_wide <-
  dcast(df,
        CountryName + CountryCode + Year ~ IndicatorCode ,
        value.var = "Value")
head(data_wide)

####select columns for shiny
###define column names in c
names <- c("CountryName","CountryCode","Year",
           "SH.H2O.SAFE.ZS", "SH.STA.ACSN", 
           "SH.XPD.PCAP","SH.MED.PHYS.ZS",
           "SP.DYN.LE00.IN", "SH.TBS.CURE.ZS",
           "SH.TBS.DTEC.ZS","SH.TBS.INCD",
           "SP.POP.TOTL")
###select columns
df_shiny <- data_wide[, names]

###change column names
names(df_shiny)[4:12] <- c(  "Improved.Water", 
                             "Sanitation.Facilities", 
                             "Health.Expenditure",
                             "Physicians",
                             "Life.Expectancy", 
                             "Tuberculosis.Success",
                             "Tuberculosis.Detection",
                             "Tuberculosis.Incidence",
                             "Population")

###add region name, find region name at healthexp.Rds
healthexp <- readRDS("~/Downloads/healthexp.Rds")

###change the mismatch column names
colnames(healthexp)[1] <- "CountryName"

######match the region use healthexp.Rds
######healthexp.Rds has different column names with df_health

df_shiny <- merge(df_shiny, distinct(select(healthexp,c(CountryName, Region))), 
                  by="CountryName",all.x=TRUE)

#### save data_wide as data_health.csv
### write.csv(df_shiny, file = "shiny_wide.csv")

###after that when wants to read it
##df_shiny <- read.csv('df_shiny.csv', header = T, stringsAsFactors = F)

### filter year before 1990
df_shiny95 <- filter(df_shiny, Year >= 1995)  ###wow
df_shiny95 <- filter(df_shiny95, Year <= 2012)  ###wow 1995--2010

### remove region with NA
cc=is.na(df_shiny95$Region)
m=which(cc==c("TRUE"))
df_shiny95_r=df_shiny95[-m,]

####select countries

### from wide to long again  cry 
data_long <- melt(df_shiny95_r,
                  # ID variables - all the variables to keep but not split apart on
                  id.vars=c("CountryName", "CountryCode","Year"),
                  # The source columns
                  measure.vars=c( "Improved.Water", 
                                  "Sanitation.Facilities", 
                                  "Health.Expenditure",
                                  "Physicians",
                                  "Life.Expectancy", 
                                  "Tuberculosis.Success",
                                  "Tuberculosis.Detection",
                                  "Tuberculosis.Incidence",
                                  "Population"),
                  # Name of the destination column that will identify the original
                  # column that the measurement came from
                  variable.name="IndicatorName",
                  value.name="Value"
)

## write.csv(data_long, file = "~/Downloads/shiny_long95.csv")
## write.csv(df_shiny95_r, file = "~/Downloads/shiny_wide95.csv")
