library(dplyr)
library(sp)

sd <- readRDS("data/school_district_shp.RDS")
hs_SAT_survey <- readRDS("data/hs_SAT_survey.RDS")
hs_SAT_survey$lon <- jitter(hs_SAT_survey$lon)
hs_SAT_survey$lat <- jitter(hs_SAT_survey$lat)
hs_info_disp <- readRDS("data/hs_info_disp.RDS")
df_1 <- data.frame(SAT = hs_SAT_survey$SAT_2010, Year = rep("2010", 437))
df_2 <- data.frame(SAT = hs_SAT_survey$SAT_2012, Year = rep("2012", 437))
df <- rbind(df_1, df_2)
gifted <- c(47, 75, 97, 188, 194, 233, 244, 397, 430) ##IDs for "Gifted & Talented" schools

