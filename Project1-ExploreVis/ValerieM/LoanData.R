## Load the Lending Club data, 2016_Q2
## install.packages("ggplot2")
library(ggplot2)
library(dplyr)

ldata = read.csv('~/project1/RejectStats_2016Q2.csv', stringsAsFactors = TRUE)


ggplot(ldata, aes(Amount.Requested)) +
  geom_point() +
  geom_smooth(method ="lm") +
  coord_cartesian() +
  scale_color_gradient() +
  theme_bw()

f = mutate(ldata, amt_cat = 
  ifelse(Amount.Requested < 3000, '<3000', 
    ifelse(Amount.Requested >=3000 & Amount.Requested < 6000, '3000-5999',
      ifelse(Amount.Requested >= 6000 & Amount.Requested < 9000, '6000-8999',
        ifelse(Amount.Requested >= 9000 & Amount.Requested < 12000, '9000-11999', '12000',
          ifelse(Amount.Requested >= 12000 & Amount.Requested < 15000, '12000-14999',
              ifelse(Amount.Requested >= 15000 & Amount.Requestd < 18000, '15000-17999',
                  ifelse(Amount.Request >= 18000 & Amount.Requested < 21000, '18000-21999'
                                                       ))))))))
##f = 
  mutate(ldata, amt_cat = ifelse(Amount.Requested < 3000, '<3000',
    ))
groupedByLoadAmt = group_by(f, amt_cat) %>% count(., amt_cat)

LoanPlot = ggplot(data =  
         groupedByLoadAmt,aes(x = reorder(amt_cat, n), y = n)) + geom_bar(aes(fill = amt_cat), stat="identity")
LoanPlot + 
  xlab("$ Amount of Loan") + ylab("Count") + 
  labs(title="What Are $$ Amounts of Rejected Loan Applications? (2016Q2)") + labs(fill="$ Amount")

##ff = group_by(ldata, State, Debt.To.Income.Ratio) %>% 
##  summarise(., avg = as.numeric(strsplit(Debt.To.Income.Ratio, '%'))  
ff = group_by(ldata, State) %>% 
      summarise(., avg = mean(as.numeric(strsplit(Debt.To.Income.Ratio, '%')), .1))
                        
