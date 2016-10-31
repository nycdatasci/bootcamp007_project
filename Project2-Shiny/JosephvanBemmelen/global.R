library(dplyr)

nursinghomes = read.csv("nursinghomes.csv")
names(nursinghomes)

nursinghomes2 =
  nursinghomes %>%
  select(Location, Overall.Rating, Size = Number.of.Residents.in.Certified.Beds)

#by State
nursinghomes3 =
  nursing %>%
  select(state.name = Provider.State,
         Overall.Rating,
         Number.of.Residents.in.Certified.Beds,
         Total.Amount.of.Fines.in.Dollars,
         Adjusted.LPN.Staffing.Hours.per.Resident.per.Day,
         Adjusted.RN.Staffing.Hours.per.Resident.per.Day,              
         Adjusted.Total.Nurse.Staffing.Hours.per.Resident.per.Day) %>%
  group_by(state.name) %>%
  summarise("Number of nursing homes" = n(),
            "Average nursing home rating" = round(mean(Overall.Rating, na.rm = TRUE),2),
            "Total Residents" = sum(Number.of.Residents.in.Certified.Beds, na.rm = T),
            "Average Number of Residents Per Home" = mean(Number.of.Residents.in.Certified.Beds, na.rm = T),
            "Total Fines ($)" = sum(Total.Amount.of.Fines.in.Dollars, na.rm = T),
            "Average Fine Per Home" = mean(Total.Amount.of.Fines.in.Dollars, na.rm = T),
            "Average LPN Hrs Per Resident Per Day" = mean(Adjusted.LPN.Staffing.Hours.per.Resident.per.Day, na.rm = T),
            "Average RN Hrs Per Resident Per Day" = mean(Adjusted.RN.Staffing.Hours.per.Resident.per.Day, na.rm = T),
            "Average Total Nurse Hrs Per Resident Per Day" = mean(Adjusted.Total.Nurse.Staffing.Hours.per.Resident.per.Day, na.rm = T)
            )

#by County
nursinghomesbycounty =
  nursing %>%
  select(Provider.County.Name,
         state.name = Provider.State,
         Overall.Rating,
         Number.of.Residents.in.Certified.Beds,
         Total.Amount.of.Fines.in.Dollars,
         Adjusted.LPN.Staffing.Hours.per.Resident.per.Day,
         Adjusted.RN.Staffing.Hours.per.Resident.per.Day,              
         Adjusted.Total.Nurse.Staffing.Hours.per.Resident.per.Day) %>%
  group_by(Provider.County.Name, state.name) %>%
  summarise("Number of nursing homes" = n(),
            "Average nursing home rating" = round(mean(Overall.Rating, na.rm = TRUE),2),
            "Total Residents" = sum(Number.of.Residents.in.Certified.Beds, na.rm = T),
            "Average Number of Residents Per Home" = mean(Number.of.Residents.in.Certified.Beds, na.rm = T),
            "Total Fines ($)" = sum(Total.Amount.of.Fines.in.Dollars, na.rm = T),
            "Average Fine Per Home" = mean(Total.Amount.of.Fines.in.Dollars, na.rm = T),
            "Average LPN Hrs Per Resident Per Day" = mean(Adjusted.LPN.Staffing.Hours.per.Resident.per.Day, na.rm = T),
            "Average RN Hrs Per Resident Per Day" = mean(Adjusted.RN.Staffing.Hours.per.Resident.per.Day, na.rm = T),
            "Average Total Nurse Hrs Per Resident Per Day" = mean(Adjusted.Total.Nurse.Staffing.Hours.per.Resident.per.Day, na.rm = T)
  )

str(nursinghomes3)
str(nursing)
nursing$Total.Amount.of.Fines.in.Dollars

#convert fines to number from dollar denominated factor
nursing$Total.Amount.of.Fines.in.Dollars = sapply(nursing$Total.Amount.of.Fines.in.Dollars, function(x)
  as.numeric(gsub("[,$]", "", x)))


nursinghomes4 =
  nursinghomes %>%
  select(state.name = Provider.State, Overall.Rating, Total.Amount.of.Fines.in.Dollars) %>%
  group_by(state.name) %>%
  summarise("Number of nursing homes" = n(),
            "Average nursing home rating" = round(mean(Overall.Rating, na.rm = TRUE),2)) %>%
  top_n(5)


names(nursing)

choice <- colnames(nursinghomes3)[-1]
choice2 <- colnames(nursinghomes3)[-1]

###################
