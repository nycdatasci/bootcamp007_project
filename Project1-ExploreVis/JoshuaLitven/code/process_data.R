# Script to process user listening data scraped from last.fm


# Libraries ---------------------------------------------------------------


library(dplyr)


# Parameters --------------------------------------------------------------

# Set the working directory to where the files are stored
setwd('~/Courses/nyc_data_science_academy/bootcamp007_project/Project1-ExploreVis/JoshuaLitven/')

RAW_PATH = file.path('data', 'raw_data')
PROCESSED_PATH = file.path('data', 'processed_data')
SUBSET_FLAG = TRUE
SUBSET_SIZE = 1000000 # number of rows to import for testing


# Helper Functions --------------------------------------------------------

# Create the data frame from a tsv file
create_df_from_tsv = function(in.file, col.names, subset = FALSE){
  nrows = ifelse(subset, SUBSET_SIZE, -1) # subset the data
  df =  read.csv(in.file,sep='\t', nrows=nrows, stringsAsFactors=FALSE, quote="", na.strings="")
  colnames(df) = col.names
  return(tbl_df(df))
}

# Create the data frame from a user demographics file
create_df_from_user = function(in.file, col.names){
  df = read.csv(in.file, sep = '\t', head = TRUE, quote = "", stringsAsFactors = FALSE, na.strings="")
  colnames(df) = col.names
  return(tbl_df(df))
}


# Process the 360K data set -----------------------------------------------


# 360K data set contains user - artist - plays for the user's top artists
in.file = file.path(RAW_PATH, 'lastfm-dataset-360K/usersha1-artmbid-artname-plays.tsv')
col.names = c('user_id', 'artist_id', 'artist_name', 'plays')
user_artist_plays = create_df_from_tsv(in.file, col.names, subset = SUBSET_FLAG)

# Save processed data
out.file = file.path(PROCESSED_PATH, 'user_artist_plays.rds')
saveRDS(user_artist_plays, out.file)

# User demographics for the 360k data set
in.file = file.path(RAW_PATH, 'lastfm-dataset-360K/usersha1-profile.tsv')
col.names = c('user_id', 'sex', 'age', 'country', 'signup')
user_artist_plays_demographics = create_df_from_user(in.file, col.names)

# Clean
user_artist_plays_demographics$sex = as.factor(user_artist_plays_demographics$sex)
user_artist_plays_demographics$age = as.numeric(user_artist_plays_demographics$age)
user_artist_plays_demographics$country = as.factor(user_artist_plays_demographics$country)
user_artist_plays_demographics$signup = NULL # don't need signup info

# Save processed data
out.file = file.path(PROCESSED_PATH, 'user_artist_plays_demographics.rds')
saveRDS(user_artist_plays_demographics, out.file)


# Process the 1k data set -------------------------------------------------


# 1k data set contains user - artist - track - time stamp for a user's last.fm history
in.file = file.path(RAW_PATH, 'lastfm-dataset-1k/userid-timestamp-artid-artname-traid-traname.tsv')
col.names = c('user_id', 'time', 'artist_id', 'artist_name', 'track_id', 'track_name')
user_listening_history = create_df_from_tsv(in.file, col.names, subset = SUBSET_FLAG)

# Convert date-time chars to POSIXlt
user_listening_history$time.stamp = as.POSIXct(user_listening_history$time, format="%Y-%m-%dT%H:%M:%SZ")

# Create columns for year, month, day, hour, DofW, date
user_listening_history = 
  user_listening_history %>%
  mutate(year = format(time.stamp,"%y"),
         month = as.integer(format(time.stamp,"%m")),
         day = as.integer(format(time.stamp,"%d")),
         hour = as.integer(format(time.stamp,"%H")),
         DofW = weekdays(time.stamp),
         date = as.Date(format(time.stamp,"%y-%m-%d")))

# Convert to factors
day.names = c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")
user_listening_history$DofW = factor(user_listening_history$DofW, levels=day.names)

month.names = c("January", "February", "March", "April", "May", "June", "July",
                "August", "September", "October", "November", "December")
user_listening_history$month = factor(user_listening_history$month, levels = 1:12, labels = month.names)

user_listening_history$hour = factor(user_listening_history$hour) 

# Save processed data
out.file = file.path(PROCESSED_PATH, 'user_listening_history.rds')
saveRDS(user_listening_history, out.file)

# User demographics for the 1k data set
in.file = file.path(RAW_PATH, 'lastfm-dataset-1k/userid-profile.tsv')
col.names = c('user_id', 'sex', 'age', 'country', 'signup')
user_listening_history_demographics = create_df_from_user(in.file, col.names)

# Clean
user_listening_history_demographics$signup = NULL # don't need signup info

# Convert to correct column types
user_listening_history_demographics$sex = as.factor(user_listening_history_demographics$sex)
user_listening_history_demographics$age = as.numeric(user_listening_history_demographics$age)
user_listening_history_demographics$country = as.factor(user_listening_history_demographics$country)

out.file = file.path(PROCESSED_PATH, 'user_listening_history_demographics.rds')
saveRDS(user_listening_history_demographics, out.file)


# Create Artist Location Data ------------------------------------------------------

# Load in the list of unique artists to get the mapping from artist id to mbid
# Source: http://labrosa.ee.columbia.edu/millionsong/
unique_artists = read.csv(file.path(RAW_PATH, 'unique_artists.txt'), 
                          header = FALSE, stringsAsFactors = FALSE, na.strings = "")
unique_artists = tbl_df(unique_artists)

artist_mapping =
  unique_artists %>%
  select(id = V1, mbid = V2)
  
# Get country of origin
# Load in the list of coordinates for each artist
# Source: http://labrosa.ee.columbia.edu/millionsong/
artist_locations = read.csv(file.path(RAW_PATH, 'artist_location.txt'), header=FALSE,
                            stringsAsFactors=FALSE, na.strings="")
artist_locations = tbl_df(artist_locations)

artist_coords =
  artist_locations %>%
  select(long = V3, lat = V2, id = V1) %>%
  mutate_each(funs(as.numeric), long, lat) %>%
  na.omit()
artist_coords

# Convert artist coordinates to countries
source(file.path('code', 'find_countries.R'))
countries = coords2country(artist_coords[, c("long", "lat")])
artist_coords$country = countries

# Join artist coordinates and the mapping from id to mbid
location_and_mapping = inner_join(artist_coords, artist_mapping, by = "id")
location_and_mapping = location_and_mapping %>% na.omit()

# Join the artist location data with the artists from user_artist_plays data set
# to get the artist names
user_artist_plays_artists = 
  user_artist_plays %>%
  select(artist_id, artist_name) %>%
  unique()

artist_locations_names = inner_join(location_and_mapping, 
                                        user_artist_plays_artists, 
                                        by = c("mbid" = "artist_id"))

artist_locations_names$id = NULL # no longer needed

out.file = file.path(PROCESSED_PATH, 'artist_locations.rds')
saveRDS(artist_locations_names, out.file)
