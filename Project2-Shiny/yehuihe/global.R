country <- read.csv("Q1.csv", stringsAsFactors = FALSE)
personal <- read.csv("Q4.csv", stringsAsFactors = FALSE)


country_stat <- data.frame(country.name = country$X, country)
rownames(country_stat) <- NULL
choice <- colnames(country_stat)[-1]

personal_stat <- data.frame(personal.name = personal$X, personal)
rownames(personal_stat) <- NULL
choice_1 <- colnames(personal_stat)[-1]
