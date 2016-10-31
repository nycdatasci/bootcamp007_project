library(dplyr)

hiDF = read.csv("C:/Users/nathan/Google Drive/Data Science Boot Camp/data/Healthcare_Associated_Infections_-_Hospital.csv")

# first filter out the data so that it doesn't contain
# hospitals for which measurements were not done
hiDF = filter(hiDF, Compared.to.National != 'Not Available')

# next remove the columns we dont need
hiDF = hiDF[, c(1,2,5,9,11,12,16)]

# function to normalize the rating. 
# return 0 if no different than benchmark
# -1 if better than benchmark
# +1 if worst than benchmark
normalizeRating = function(rating) {
  ifelse(grepl('No Different', rating, fixed = TRUE), 0, 
         ifelse(grepl('Better', rating, fixed = TRUE), -1, 1)) 
}

# function to normalize the measurement type id aggreggate
# all measurements associated with an infection
normalizeMeasureID = function(measureName) {
  ifelse(grepl('CLABSI', measureName, ignore.case = T), 'CLABSI', 
    ifelse(grepl('CAUTI', measureName, ignore.case = T), 'CAUTI', 
      ifelse(grepl('C.diff', measureName, ignore.case = T), 'C.diff', 
        ifelse(grepl('MRSA', measureName, ignore.case = T), 'MRSA',
          ifelse(grepl('Abdominal', measureName, ignore.case = T), 'SSI: Abdominal', 
            ifelse(grepl('Colon', measureName, ignore.case = T), 'SSI: Colon', 'Unknown'))))))   
}

# this is our final data matrix which we should save as rds
infectionsDF = mutate(hiDF, 
                      Normalized.Rating = normalizeRating(Compared.to.National),
                      Normalized.Measure.ID = normalizeMeasureID(Measure.Name))

# now change the normalize measire ID to a factor
infectionsDF$Normalized.Measure.ID = as.factor(infectionsDF$Normalized.Measure.ID)

# finally save to file
filename = "C:/Users/nathan/Google Drive/Data Science Boot Camp/RShiny/HospiView/data/infections.rda"
save(infectionsDF, file = filename)
