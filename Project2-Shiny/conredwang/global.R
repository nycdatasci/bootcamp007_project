# load adult dataset
adult1 <- readRDS(file = "data/adult1.rds")
choiceRace <- levels(adult1$race)
choiceWorkClass <- levels(adult1$workclass)
