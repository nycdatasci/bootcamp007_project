#############################################
# Nelson Chen
# nchen9191@gmail.com
# NYC Data Science Academy
# Exploratory Data Visualization Project
# College Scorecard Dataset
##############################################

# Visual analysis of Public vs Private for-profit vs Private non-profit Undergraduate schools
# https://www.kaggle.com/kaggle/college-scorecard

########### Use packages ############
library(ggplot2)
library(dplyr)

################### Read in data ########################
#college_data = read.csv('Scorecard.csv', na.strings = "NULL") #Read data from CSV file
#saveRDS(college_data,file='scorecard')  # Save data into RDS file for easy R readability
college_data = readRDS('scorecard')   # Read presaved RDS file

############ Subset of data being used ################
college_data_sub = select(college_data,
                          UNITID,         ## Institution ID
                          INSTNM,         ## Institution name
                          PREDDEG,        ## Predominate degree
                          CURROPER,       ## Currently operating flag
                          CONTROL,        ## Type of college
                          COSTT4_A,       ## Cost of attendence
                          NPT4_PUB,       ## Net Cost for Public Institutions
                          NPT4_PRIV,      ## Net Cost for Private Institutions
                          DEBT_MDN,       ## Median debt after graduation
                          md_earn_wne_p10,## Median earning 10 years after graduation
                          LATITUDE,       ## Latitude of location
                          LONGITUDE,      ## Longitude of location
                          Year,           ## Year of data point
                          CCBASIC,        ## Carnegie Classification of college
                          DISTANCEONLY)   ## Distance only flag 

college_data_sub = filter(college_data_sub,
                          PREDDEG=="Predominantly bachelor's-degree granting" &    ## Predominate degree is BS
                          CURROPER=="Currently certified as operating" &    ## Currently operating
                          DISTANCEONLY=="Not distance-education only"     ## Not distance
)

college_data_sub['CONTROL2'] = ifelse(college_data_sub$CONTROL == 'Public', 'Public', 'Private')

############# US Maps of public and private #################

## filter data
schools = filter(college_data_sub,
                   Year == 2013 &
                   is.na(LATITUDE)==FALSE &            ## Make sure that latitude is not missing
                   is.na(LONGITUDE)==FALSE &           ## Make sure that longitude is not missing
                   is.na(COSTT4_A) == FALSE &          ## Make sure that cost is not missing
                   CONTROL2 == "Public" &              ## Public Schools
                   LATITUDE>20 & LATITUDE<50 &         ## Location is in 48 states
                   LONGITUDE>(-130) & LONGITUDE<(-60))

## add a tuition factor for tuition range
cuts = c(0, 10000, 20000, 30000, 40000, 50000)
labs = c("$0-9.999K","$10K-19.999K", "$20K-29.999K", "$30K-39.999K", "$40K+")
schools$cost = cut(schools$COSTT4_A, 
                   cuts, right=FALSE, labels=labs) #Define new variables for cost as factors

## Plot public Map 

## define colors to use for each tuition range
costColors = c("dodgerblue", "green", "yellow", "orange", "red")
names(costColors) = levels(schools$cost) #Connect colors to cuts

# colored scatter plot on top of US map by latitude and longitude
public = ggplot(schools) 
public = public + borders("state", colour="white", fill="gray25")
public = public + geom_point(mapping=aes(x=LONGITUDE, y=LATITUDE, 
                                 colour=cost),  size=0.5)
public = public + ggtitle("Cost of Bachelor Degrees in Public Institutions" ) 
public = public + scale_colour_manual(name = "Cost",values = costColors)
public = public + theme(legend.position="top", legend.box="horizontal", 
                legend.text=element_text(size=20), 
                legend.title=element_text(size=20),
                axis.line=element_blank(),axis.text.x=element_blank(),
                axis.text.y=element_blank(),
                axis.ticks=element_blank(),
                axis.title.x=element_blank(),
                axis.title.y=element_blank(),
                plot.title = element_text(size=26))
public = public + guides(colour = guide_legend(override.aes = list(size=6)))

## Plot private school US Map
schools = filter(college_data_sub,
      Year == 2013 &               ## Looking at latest year of data
      is.na(LATITUDE)==FALSE &
      is.na(LONGITUDE)==FALSE &
      is.na(COSTT4_A) == FALSE &
      CONTROL2 == "Private" &
      LATITUDE>20 & LATITUDE<50 &         ## Location is public 48
      LONGITUDE>(-130) & LONGITUDE<(-60))

## add a tuition factor for tuition range with pre-defined cuts/labels
schools$cost = cut(schools$COSTT4_A, 
                   cuts, right=FALSE, labels=labs)

names(costColors) = levels(schools$cost)

## Plotting actual map
private = ggplot(schools) 
private = private + borders("state", colour="white", fill="gray25")
private = private + geom_point(mapping=aes(x=LONGITUDE, y=LATITUDE, 
                                         colour=cost),  size=0.5)
private = private + ggtitle("Cost of Bachelor Degrees in Private Institutions") 
private = private + scale_colour_manual(name = "Cost",values = costColors)
private = private + theme(legend.position="top", legend.box="horizontal", 
                        legend.text=element_text(size=20), 
                        legend.title=element_text(size=20),
                        axis.line=element_blank(),axis.text.x=element_blank(),
                        axis.text.y=element_blank(),
                        axis.ticks=element_blank(),
                        axis.title.x=element_blank(),
                        axis.title.y=element_blank(),
                        plot.title = element_text(size=26))
private = private + guides(colour = guide_legend(override.aes = list(size=6)))

############### Adjust for net cost ################

## Public Schools ##
schools = filter(college_data_sub,
      Year == 2013 &
      is.na(LATITUDE)==FALSE &
      is.na(LONGITUDE)==FALSE &
      is.na(NPT4_PUB) == FALSE &           ## Make sure net cost is not missing
      CONTROL2 == "Public" &
      LATITUDE>20 & LATITUDE<50 &         
      LONGITUDE>(-130) & LONGITUDE<(-60))

## add a tuition factor for tuition range
cuts = c(0, 10000, 20000, 30000, 40000, 50000)
labs = c("$0-9.999K","$10K-19.999K", "$20K-29.999K", "$30K-39.999K", "$40K+")
schools$cost = cut(schools$NPT4_PUB, 
                   cuts, right=FALSE, labels=labs)

## Plot public Map ##

## define colors to use for each tuition range
costColors = c("dodgerblue", "green", "yellow", "orange", "red")
names(costColors) = levels(schools$cost)

public_net = ggplot(schools) 
public_net = public_net + borders("state", colour="white", fill="gray25")
public_net = public_net + geom_point(mapping=aes(x=LONGITUDE, y=LATITUDE, 
                                         colour=cost),  size=0.5)
public_net = public_net + ggtitle("Adjusted Net Cost of Bachelor Degrees in Public Institutions") 
public_net = public_net + scale_colour_manual(name = "Cost",values = costColors)
public_net = public_net + theme(legend.position="top", legend.box="horizontal", 
                        legend.text=element_text(size=20), 
                        legend.title=element_text(size=20),
                        axis.line=element_blank(),axis.text.x=element_blank(),
                        axis.text.y=element_blank(),
                        axis.ticks=element_blank(),
                        axis.title.x=element_blank(),
                        axis.title.y=element_blank(),
                        plot.title = element_text(size=26))
public_net = public_net + guides(colour = guide_legend(override.aes = list(size=6)))


## Private Schools ##
schools = filter(college_data_sub,
      Year == 2013 &
      is.na(LATITUDE)==FALSE &
      is.na(LONGITUDE)==FALSE &
      is.na(NPT4_PRIV) == FALSE &             ## Making sure private net cost is not missing
      CONTROL2 == "Private"  &
      LATITUDE>20 & LATITUDE<50 &         ## Location is public 48
      LONGITUDE>(-130) & LONGITUDE<(-60))

## add a tuition factor for tuition range
schools$cost = cut(schools$NPT4_PRIV, 
                   cuts, right=FALSE, labels=labs)

## Plot Private Map ##
names(costColors) = levels(schools$cost)

private_net = ggplot(schools) 
private_net = private_net + borders("state", colour="white", fill="gray25")
private_net = private_net + geom_point(mapping=aes(x=LONGITUDE, y=LATITUDE, 
                                           colour=cost),  size=0.5)
private_net = private_net + ggtitle("Adjusted Net Cost of Bachelor Degrees in Private Institutions") 
private_net = private_net + scale_colour_manual(name = "Cost",values = costColors)
private_net = private_net + theme(legend.position="top", legend.box="horizontal", 
                          legend.text=element_text(size=20), 
                          legend.title=element_text(size=20),
                          axis.line=element_blank(),axis.text.x=element_blank(),
                          axis.text.y=element_blank(),
                          axis.ticks=element_blank(),
                          axis.title.x=element_blank(),
                          axis.title.y=element_blank(),
                          plot.title = element_text(size=26))
private_net = private_net + guides(colour = guide_legend(override.aes = list(size=6)))

############### Density plots of debt ################
schools = filter(college_data_sub,
      Year == 2013 &
      is.na(CONTROL2) == FALSE &
      is.na(DEBT_MDN) == FALSE &            # Make sure debt is not missing
      grepl("Special", CCBASIC) == FALSE&   # Filter out specialty schools, i.e medical
      DEBT_MDN != 'PrivacySuppressed' &     # Filter out supressed data
      DEBT_MDN != ''                        # Filter out empty string data
    )

schools$DEBT_MDN = as.numeric(paste(schools$DEBT_MDN)) # Convert debt factor data to numeric

## Density plot of median debt by type of college
debt_den = ggplot(schools, aes(x = DEBT_MDN, fill = CONTROL2))
debt_den = debt_den + geom_density(alpha = 0.3) + xlab('Median Debt') + ylab("Density")
debt_den = debt_den + ggtitle("Density of Median Debt") + scale_fill_discrete("College Type")
debt_den = debt_den + theme(plot.title = element_text(size=26),
                            legend.text=element_text(size=16), 
                            legend.title=element_text(size=20),
                            axis.text.x=element_text(size = 14),
                            axis.text.y=element_text(size = 14),
                            axis.title.x=element_text(size = 20),
                            axis.title.y=element_text(size = 20))

############## Density Plot of Median Earnings 10 years out ############

schools = filter(college_data_sub,
      Year == 2011 &              ## 2011 is the latest year with 10 years median earning info
      is.na(CONTROL2) == FALSE &
      is.na(md_earn_wne_p10) == FALSE &  
      md_earn_wne_p10 != 'PrivacySuppressed' &
      md_earn_wne_p10 != ''
  )

# Join 2013 CCBASIC data to 2011 median earning data
temp = select(college_data,INSTNM, Year, CCBASIC)  %>%  filter( Year == 2013)
schools = inner_join(schools[!names(schools) %in% 'CCBASIC'], select(temp,INSTNM, CCBASIC), by = 'INSTNM')
schools = schools %>% filter(CCBASIC != '' &
                               grepl("Special",schools$CCBASIC) == FALSE)

# Convert median earning from factor type to numeric type
schools$md_earn_wne_p10 = as.numeric(paste(schools$md_earn_wne_p10))

# Plot median earning 10 years after as density plot
med_earning = ggplot(schools, aes(x = md_earn_wne_p10, fill = CONTROL2))
med_earning = med_earning + geom_density(alpha=0.3) + xlab('Median Earning') + ylab('Density')
med_earning = med_earning + ggtitle('Density of Median Earning') + scale_fill_discrete("College Type")
med_earning = med_earning + theme(plot.title = element_text(size=26),
                                  legend.text=element_text(size=16), 
                                  legend.title=element_text(size=20),
                                  axis.text.x=element_text(size = 14),
                                  axis.text.y=element_text(size = 14),
                                  axis.title.x=element_text(size = 20),
                                  axis.title.y=element_text(size = 20))

########### Scatter and Heat map of cost and earning #############
schools = filter(college_data_sub,
    Year == 2011 &
      is.na(md_earn_wne_p10) == FALSE &
      (!is.na(NPT4_PRIV) | !is.na(NPT4_PUB)) &
      md_earn_wne_p10 != 'PrivacySuppressed' &
      md_earn_wne_p10 != '' &
      is.na(COSTT4_A) == FALSE 
  )

# Join 2013 CCBASIC data to 2011 median earning data
temp = select(college_data,INSTNM, Year, CCBASIC)  %>%  filter( Year == 2013)
schools = inner_join(schools[!names(schools) %in% 'CCBASIC'], select(temp,INSTNM, CCBASIC), by = 'INSTNM')
schools = schools %>% filter(CCBASIC != '' &
                               grepl("Special",schools$CCBASIC) == FALSE)

# Convert median earning to numeric type
schools$md_earn_wne_p10 = as.numeric(paste(schools$md_earn_wne_p10))

# Combine public and private cost into one column
schools['AVG_NET_COST'] = ifelse(schools$CONTROL2 == 'Public', schools$NPT4_PUB, schools$NPT4_PRIV)

# Scatter plot of net cost vs median earning separated by college type
earning_vs_cost = ggplot(schools, aes(y = md_earn_wne_p10, x = AVG_NET_COST, color = CONTROL2) )
earning_vs_cost = earning_vs_cost + geom_point(size = 0.6, alpha=0.8)
earning_vs_cost = earning_vs_cost + xlab('Net Cost') + ylab('Median Earning') + 
  ggtitle('Net Cost vs Median Earning') + scale_color_discrete('College Type')
earning_vs_cost = earning_vs_cost + theme(plot.title = element_text(size=26),
                                          legend.text=element_text(size=16), 
                                          legend.title=element_text(size=20),
                                          axis.text.x=element_text(size = 14),
                                          axis.text.y=element_text(size = 14),
                                          axis.title.x=element_text(size = 20),
                                          axis.title.y=element_text(size = 20))
earning_vs_cost = earning_vs_cost  + guides(colour = guide_legend(override.aes = list(size=6)))

# Overlay density contour lines
earning_vs_cost_den = earning_vs_cost + geom_density2d(size = 0.6)
