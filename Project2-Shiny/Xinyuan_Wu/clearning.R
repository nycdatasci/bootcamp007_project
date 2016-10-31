setwd("C:/Users/Xinyuan Wu/Dropbox/NYC DS Academy/Project 2")
library(dplyr)

# load
raw2012 <- read.csv("Cars/12data/12.csv",header = TRUE)
raw2013 <- read.csv("Cars/13data/13.csv",header = TRUE)
raw2014 <- read.csv("Cars/14data/14.csv",header = TRUE)
raw2015 <- read.csv("Cars/15data/15.csv",header = TRUE)
raw2016 <- read.csv("Cars/16data/16.csv",header = TRUE)
raw2017 <- read.csv("Cars/17data/17.csv",header = TRUE)

# subset
raw_sub2012 <- raw2012[, c(1, 3, 4, 6:12, 21, 23, 25, 29, 34, 35, 45, 67)]
raw_sub2013 <- raw2013[1:1167, c(1, 3, 4, 6:12, 21, 23, 25, 29, 34, 35, 45, 70)]
raw_sub2014 <- raw2014[, c(1, 3, 4, 6:12, 21, 23, 25, 29, 34, 35, 45, 70)]
raw_sub2015 <- raw2015[1:1253, c(1, 3, 4, 6:12, 21, 23, 25, 29, 34, 35, 45, 70)]
raw_sub2016 <- raw2016[, c(1, 3, 4, 6:12, 21, 23, 25, 29, 34, 35, 45, 70)]
raw_sub2017 <- raw2017[, c(1, 3, 4, 6:12, 21, 23, 25, 29, 34, 35, 45, 70)]

# test data type for each column
#class2012 <- sapply(raw_sub2012, class)
#class2013 <- sapply(raw_sub2013, class)
#class2014 <- sapply(raw_sub2014, class)
#class2015 <- sapply(raw_sub2015, class)
#class2016 <- sapply(raw_sub2016, class)
#class2017 <- sapply(raw_sub2017, class)

#class_df <- cbind(class2012 != class2012, 
                  #class2013 != class2012, 
                  #class2014 != class2012,
                  #class2015 != class2012,
                  #class2016 != class2012,
                  #class2017 != class2012)
#colSums(class_df)

# change colnames
colnames(raw_sub2012) <- c('year', 'make', 'model', 'model_index',
                           'disp', 'cyl', 'trans', 'mpg_city',
                           'mpg_hwy', 'mpg_mix', 'air_asp', 
                           'trans_desc', 'gears', 'drive_desc', 
                           'fuel_type', 'fuel_unit', 'ann_fuel', 
                           'carline_class')

colnames(raw_sub2013) <- c('year', 'make', 'model', 'model_index',
                           'disp', 'cyl', 'trans', 'mpg_city',
                           'mpg_hwy', 'mpg_mix', 'air_asp', 
                           'trans_desc', 'gears', 'drive_desc', 
                           'fuel_type', 'fuel_unit', 'ann_fuel', 
                           'carline_class')
colnames(raw_sub2014) <- c('year', 'make', 'model', 'model_index',
                           'disp', 'cyl', 'trans', 'mpg_city',
                           'mpg_hwy', 'mpg_mix', 'air_asp', 
                           'trans_desc', 'gears', 'drive_desc', 
                           'fuel_type', 'fuel_unit', 'ann_fuel', 
                           'carline_class')
colnames(raw_sub2015) <- c('year', 'make', 'model', 'model_index',
                           'disp', 'cyl', 'trans', 'mpg_city',
                           'mpg_hwy', 'mpg_mix', 'air_asp', 
                           'trans_desc', 'gears', 'drive_desc', 
                           'fuel_type', 'fuel_unit', 'ann_fuel', 
                           'carline_class')
colnames(raw_sub2016) <- c('year', 'make', 'model', 'model_index',
                           'disp', 'cyl', 'trans', 'mpg_city',
                           'mpg_hwy', 'mpg_mix', 'air_asp', 
                           'trans_desc', 'gears', 'drive_desc', 
                           'fuel_type', 'fuel_unit', 'ann_fuel', 
                           'carline_class')
colnames(raw_sub2017) <- c('year', 'make', 'model', 'model_index',
                           'disp', 'cyl', 'trans', 'mpg_city',
                           'mpg_hwy', 'mpg_mix', 'air_asp', 
                           'trans_desc', 'gears', 'drive_desc', 
                           'fuel_type', 'fuel_unit', 'ann_fuel', 
                           'carline_class')

# combine all raw data
full <- rbind(raw_sub2012, raw_sub2013, raw_sub2014,
                  raw_sub2015, raw_sub2016, raw_sub2017)

# fine tune
full <- select(full, -model_index)  # useless column
full <- full[-671, ]  # hygrogen car
full <- select(full, -fuel_unit)   # get rid of unit column
#full$year <- factor(full$year)   # convert year to factor

# clean factor columns
full$drive_desc <- factor(full$drive_desc)
levels(full$drive_desc) <- c('Front Wheel Drive', 'Rear Wheel Drive', 
                             'All Wheel Drive', 'All Wheel Drive', 'Part-time AWD')

full$air_asp <- factor(full$air_asp)
levels(full$air_asp) <- c('Naturally Aspirated', 'Supercharged', 
                          'Turbocharged', 'Twincharged')

full <- full[!(full$fuel_type == 'Compressed Natural Gas'), ]
full$fuel_type <- factor(full$fuel_type)
levels(full$fuel_type) <- c('Diesel', 'Mid-Grade Gasoline', 'Premium Gasoline', 
                            'Premium Gasoline', 'Regular Gasoline', 'Mid-Grade Gasoline', 'Diesel')
full$fuel_type <- factor(full$fuel_type, levels = c("Regular Gasoline", "Mid-Grade Gasoline",
                                                    "Premium Gasoline", "Diesel"))

full$trans_desc <- factor(full$trans_desc)
levels(full$trans_desc) <- c('Automated Manual', 'Automated Manual', 'Automatic', 
                             'Continuously Variable', 'Manual', 'Automatic', 
                             'Continuously Variable', 'Automated Manual')
full$trans_desc <- factor(full$trans_desc, levels = c('Manual', 'Automatic',
                                                      'Automated Manual', 'Continuously Variable'))

full <- full[!(full$carline_class == 'Special Purpose Vehicle cab chassis'), ]    # no interest in this car
full <- full[!(full$model == 'XTS HEARSE'), ]
full <- full[!(full$model == 'XTS LIMO'), ]
full$carline_class <- factor(full$carline_class)
full2 <- full
full2$carline_class <- as.character(full2$carline_class)
full2[full$model == 'MKT LIVERY FWD', 'carline_class'] = 'Full Size SUV'
full2[full$model == 'MKT LIVERY AWD', 'carline_class'] = 'Full Size SUV'
full$carline_class <- factor(full2$carline_class)
levels(full$carline_class) <- c('Compact Cars', 'Standard SUV', 'Large Cars', 
                                'Midsize Cars', 'Station Wagons', 'Minicompact Cars', 
                                'Small Pick-up Trucks', 'Small Pick-up Trucks', 
                                'Station Wagons', 'Small SUV', 'Small SUV', 
                                'Van', 'Minivan', 'Minivan', 'SUV', 'SUV',
                                'Standard Pick-up Trucks', 'Standard Pick-up Trucks', 
                                'Standard SUV', 'Standard SUV', 'Subcompact Cars', 
                                'Two seaters', 'Cargo Van', 'Passenger Van')
full$carline_broad <- factor(full$carline_class)
levels(full$carline_broad) <- c('Cars', 'SUV', 'Cars', 'Cars', 'Cars', 
                                'Cars', 'Trucks', 'SUV', 'Van', 'Van',
                                'SUV', 'Trucks', 'Cars', 'Cars', 'Van', 'Van')

full$make <- as.character(full$make)
full[full$make == 'SUZUKI', 'make'] <- 'Suzuki'
full[full$make == 'CHEVROLET', 'make'] <- 'Chevrolet'
full[full$make == 'Jaguar Cars Ltd', 'make'] <- 'Jaguar'
full[full$make == 'Aston Martin Lagonda Ltd', 'make'] <- 'Aston Martin'
full[full$make == 'Bentley Motors Ltd.', 'make'] <- 'Bentley'
full[full$make == 'Ferrari North America, Inc.', 'make'] <- 'Ferrari'
full[full$make == 'ALFA ROMEO', 'make'] <- 'Alfa Romeo'
full[full$make == 'HYUNDAI MOTOR COMPANY', 'make'] <- 'Hyundai'
full[full$make == 'KIA MOTORS CORPORATION', 'make'] <- 'KIA'
full[full$make == 'Lotus Cars Ltd', 'make'] <- 'Lotus'
full[full$make == 'McLaren Automotive Limted', 'make'] <- 'McLaren'
full[full$make == 'Mitsubishi Motors Corporation', 'make'] <- 'Mitsubishi'
full[full$make == 'Mitsubishi Motors North America', 'make'] <- 'Mitsubishi'
full[full$make == 'Mobility Ventures LLC', 'make'] <- 'Mobility Ventures'
full[full$make == 'Pagani Automobili S.p.A.', 'make'] <- 'Pagani'
full[full$make == 'Rolls-Royce Motor Cars Limited', 'make'] <- 'Rolls-Royce'
full[full$make == 'Roush Industries, Inc.', 'make'] <- 'Roush'
full[full$make == 'The Vehicle Production Group LLC', 'make'] <- 'The Vehicle Production Group'
full[full$make == 'Volvo Cars of North America, LLC', 'make'] <- 'Volvo'
full[full$make == 'TOYOTA', 'make'] <- 'Toyota'
full$make <- factor(full$make)
full <- select(full, -trans)
full$ann_fuel <- as.numeric(full$ann_fuel)

full$model <- factor(tolower(full$model))
full <- select(full, year:model, carline_class, carline_broad, cyl,
               disp, air_asp:fuel_type, mpg_city:mpg_mix, ann_fuel)

# add a column condition
get_condition <- function(x) {
    condition <- ''
    for (i in 1:dim(full)[1]) {
        condition[i] <- switch(as.character(full$year[i]),
                               '2012' = 'Used', 
                               '2013' = 'Used',
                               '2014' = 'Like new',
                               '2015' = 'Like new',
                               '2016' = 'New',
                               '2017' = 'New')
    }
    factor(condition)
}
full$condition <- get_condition()
levels(full$condition) <- c("New", "Like new", "Used")

# add a column lux
get_lux <- function(x) {
    lux <- ''
    for (i in 1:dim(full)[1]) {
        lux[i] <- switch(as.character(full$make)[i],
                         'Aston Martin' = 'Super', 'Audi' = 'Luxury',
                         'Bentley' = 'Super', 'BMW' = 'Luxury',
                         'Bugatti' = 'Super', 'Chevrolet' = 'Family',
                         'Ferrari' = 'Super', 'Honda' = 'Family',
                         'Lamborghini' = 'Super', 'LEXUS' = 'Luxury',
                         'MAZDA' = 'Family', 'McLaren' = 'Super',
                         'Mercedes-Benz' = 'Luxury', 'Mini' = 'Luxury',
                         'NISSAN' = 'Family', 'Porsche' = 'Luxury',
                         'FIAT' = 'Family', 'Jaguar' = 'Luxury',
                         'Lotus' = 'Super', 'Mitsubishi' = 'Family',
                         'SCION' = 'Family', 'Ford' = 'Family',
                         'Hyundai' = 'Family', 'INFINITI' = 'Luxury',
                         'MASERATI' = 'Super', 'Roush' = 'Luxury',
                         'Volkswagen' = 'Family', 'Volvo' = 'Luxury',
                         'Acura' = 'Luxury', 'Buick' = 'Family',
                         'Chrysler' = 'Family', 'KIA' = 'Family',
                         'Rolls-Royce' = 'Super', 'Saab' = 'Family',
                         'Subaru' = 'Family', 'Suzuki' = 'Family',
                         'Toyota' = 'Family', 'Cadillac' = 'Luxury',
                         'Dodge' = 'Family', 'Lincoln' = 'Family',
                         'GMC' = 'Family', 'The Vehicle Production Group' = 'Family',
                         'Jeep' = 'Family', 'Land Rover' = 'Luxury',
                         'SRT' = 'Family', 'RAM' = 'Family',
                         'Mobility Ventures' = 'Family', 'Pagani' = 'Super',
                         'Alfa Romeo' = 'Super', 'GENESIS' = 'Luxury'
                         )
    }
    factor(lux)
}

full$lux <- get_lux()

full$trans_broad <- factor(ifelse(as.character(full$trans_desc) == 'Manual', 'Manual', 'Automatic'))

write.csv(full, file = 'tidy.csv' , row.names = FALSE)
