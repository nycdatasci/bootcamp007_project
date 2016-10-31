setwd("~/shiny_proj/data/")
pop = read.csv(file="pop.csv")
head(pop)
ngc = read.csv(file="NatGasConsump.csv")
head(ngc)
coal =  read.csv(file="coalCON.csv")
CO2 = read.csv(file="CO2.csv")
head(CO2)
oil = read.csv(file="oil.2009.csv")
head(oil)
# make individual sub dataframes for 2009 and rename the columns ##### 
# Each new sub dataframehas the first column as country #####
###make population 2009 and rename columns #####
pop2009 = data.frame(pop$X,pop$X2009)
pop1994 = data.frame(pop$X,pop$X1994)
names(pop2009)[2]<-"population"
names(pop2009)[1]<-"country"
names(pop1994)[2]<-"population"
names(pop1994)[1]<-"country"
####make natural gas consumtion 2009 and rename columns #####
ngc2009 = data.frame(ngc$X,ngc$X2009)
ngc1994 = data.frame(ngc$X,ngc$X1994)
names(ngc2009)[2]<-"natural.gas.consumption"
names(ngc2009)[1]<-"country"
names(ngc1994)[2]<-"natural.gas.consumption"
names(ngc1994)[1]<-"country"
####make coal consumtion  and rename columns #####
coal2009 = data.frame(coal$X,coal$X2009)
coal1994 = data.frame(coal$X,coal$X1994)
names(coal2009)[2]<-"coal.consumption"
names(coal2009)[1]<-"country"
names(coal1994)[2]<-"coal.consumption"
names(coal1994)[1]<-"country"
####make CO2 emission  and rename columns #####
CO2.2009 = data.frame(CO2$X,CO2$X2009)
#CO2.1994 = data.frame(CO2$X,CO2$X1994)
names(CO2.2009)[2]<-"CO2.emission"
names(CO2.2009)[1]<-"country"
#names(CO2.1994)[2]<-"CO2.emission"
#names(CO2.1994)[1]<-"country"
####merge population and natural gas consumtion 2009 by country ####
m1.2009 = merge(pop2009,ngc2009,by="country")
m1.1994 = merge(pop1994,ngc1994,by="country")

m2.2009 = merge(m1.2009,coal2009,by="country")
m2.1994 = merge(m1.1994,coal1994,by="country")

m3.2009 = merge(m2.2009,CO2.2009,by="country")
m3.1994 = m2.1994
#####write into new csv file
write.csv(m3.2009, file = "pop-ngc-coal-CO2-2009.csv")
write.csv(m3.1994, file = "pop-ngc-coal-noCO2-1994.csv")


#####make a googlevis map plot with columns##
#temp = read.csv(file="oil.2009.csv")
state_em <- gvisGeoChart(oil, "Country", "oil.consumption", 
                         options=list( 
#                                      displayMode="regions", 
#                                      resolution="provinces",
                                      colorAxis="{colors: ['blue', 'green', 'red']}"))
plot(state_em)



