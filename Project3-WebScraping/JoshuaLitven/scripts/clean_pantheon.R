# Script to clean the pantheon data set and combine it with scraped death dates from wikipedia

library(dplyr)
library(ggplot2)
library(VIM)
library(mice)

# Loading Data ------------------------------------------------------------

# Load in the raw pantheon data
setwd('~/Courses/nyc_data_science_academy/projects/web_scraping/data')
pantheon = read.csv('raw_data/pantheon.tsv', sep="\t", na.strings="", stringsAsFactors = FALSE)

# Merge with wiki_pages.csv to add year of death
deaths = read.csv('raw_data/wiki_pages.csv', stringsAsFactors = FALSE, na.strings="")
deaths = deaths %>% select(en_curid, death_date)
deaths$deathyear = format(as.Date(deaths$death_date), '%Y')
deaths$death_date = NULL

pantheon = left_join(pantheon, deaths, by="en_curid")

# Select columns we care about
pantheon = 
  pantheon %>% 
  select(en_curid, name, countryName, countryCode, countryCode3, LAT, LON,
         birthyear, gender, occupation, industry, domain, deathyear)

# Investigate Missingness -------------------------------------------------

summary(pantheon)
# Missing 1047 LAT and LON values

summary(aggr(pantheon))
# Conclusion: Mostly missing death year, LAT and LON
# Only 38% compete cases
# Mostly missing LAT and LON
# Let's fill them in using countryCode
sum(is.na(pantheon$countryCode)) # Only missing 3 country codes!

# Load in country codes to get their lat/lon
countries = read.csv('raw_data/country_latlon.csv')

# Join with pantheon and impute missing values
pantheon = left_join(pantheon, countries, by="countryCode")
pantheon = transform(pantheon, LAT = ifelse(is.na(LAT), latitude, LAT))
pantheon = transform(pantheon, LON = ifelse(is.na(LON), longitude, LON))

# Remove columns no longer needed
pantheon$latitude = NULL
pantheon$longitude = NULL

# Feature Engineering -----------------------------------------------------

# Add image url
pantheon$image_url = paste0("http://pantheon.media.mit.edu/people/", pantheon$en_curid, ".jpg")

# Convert birth year to a date and a numeric
pantheon$birthdate = strptime(pantheon$birthyear, "%Y")
pantheon$birthyear = as.numeric(pantheon$birthyear)

# Create factors of different centuries
pantheon$century = cut(pantheon$birthyear, 
                       breaks=c(-5000, 1000, 1100, 1200, 1300, 1400, 1500, 1600, 1700, 1800, 1900, 2000),
                       labels=c("<1000", 
                                paste(c("11th", "12th", "13th", "14th", "15th", "16th", "17th", "18th", "19th",
                                        "20th"), "century")))
# Write cleaned to file
write.csv(pantheon, "cleaned_data/pantheon.csv")
