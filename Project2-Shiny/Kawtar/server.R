
# rm(list = setdiff(ls(), lsf.str()))


library(shiny)
library(ggplot2)
library(reshape2)
library(dplyr)
library(googleVis)

suppressWarnings(suppressPackageStartupMessages(library(googleVis)))


file1= "./data/Co2_emission_eu_3.csv"
file2= "./data/Co2_US_3.csv"

Co2_EU= read.csv(file1,stringsAsFactors = FALSE)
Co2_US= read.csv(file2,stringsAsFactors = FALSE)


# no data from 2014,15,16

Co2_EU=select(Co2_EU,- contains('YR2014'),- contains('YR2015'),- contains('YR2016'))
Co2_US=select(Co2_US,- contains('YR2014'),- contains('YR2015'),- contains('YR2016'))


# delete end row

Co2_EU=Co2_EU[-c(374,373,372,371,370),]
Co2_US=Co2_US[-c(6,7,8,9,10),]

#delete columns

Co2_EU=select(Co2_EU,-Series.Code)
Co2_US=select(Co2_US,-Series.Code)


# change column names


# old_colnames=colnames(Co2_EU[,5:n])

new_col_names=c('1990','2000','2007','2008',
                '2009','2010','2011','2012','2013')


aux=Co2_EU


colnames(aux)[colnames(aux)=='X1990..YR1990.'] <- '1990'
colnames(aux)[colnames(aux)=='X2000..YR2000.'] <- '2000'
colnames(aux)[colnames(aux)=='X2007..YR2007.'] <- '2007'
colnames(aux)[colnames(aux)=='X2008..YR2008.'] <- '2008'
colnames(aux)[colnames(aux)=='X2009..YR2009.'] <- '2009'
colnames(aux)[colnames(aux)=='X2010..YR2010.'] <-'2010'
colnames(aux)[colnames(aux)=='X2011..YR2011.'] <- '2011'
colnames(aux)[colnames(aux)=='X2012..YR2012.'] <- '2012'
colnames(aux)[colnames(aux)=='X2013..YR2013.'] <- '2013'

Co2_EU=aux

aux1=Co2_US

colnames(aux1)[colnames(aux1)=='X1990..YR1990.'] <- '1990'
colnames(aux1)[colnames(aux1)=='X2000..YR2000.'] <- '2000'
colnames(aux1)[colnames(aux1)=='X2007..YR2007.'] <- '2007'
colnames(aux1)[colnames(aux1)=='X2008..YR2008.'] <- '2008'
colnames(aux1)[colnames(aux1)=='X2009..YR2009.'] <- '2009'
colnames(aux1)[colnames(aux1)=='X2010..YR2010.'] <- '2010'
colnames(aux1)[colnames(aux1)=='X2011..YR2011.'] <- '2011'
colnames(aux1)[colnames(aux1)=='X2012..YR2012.'] <- '2012'
colnames(aux1)[colnames(aux1)=='X2013..YR2013.'] <- '2013'

Co2_US=aux1


colnames(Co2_EU)[colnames(Co2_EU)== 'ï..Series.Name'] <- 'Series.Name'
colnames(Co2_US)[colnames(Co2_US)== 'ï..Series.Name'] <- 'Series.Name'

# -----Transform to integer before tidy------------------

aux=Co2_EU
aux$'1990'=as.integer(aux$'1990')
aux$'2000'=as.integer(aux$'2000')
aux$'2007'=as.integer(aux$'2007')
aux$'2008'=as.integer(aux$'2008')
aux$'2009'=as.integer(aux$'2009')
aux$'2010'=as.integer(aux$'2010')
aux$'2011'=as.integer(aux$'2011')
aux$'2012'=as.integer(aux$'2012')
aux$'2013'=as.integer(aux$'2013')
Co2_EU=aux
aux=Co2_US
aux$'1990'=as.integer(aux$'1990')
aux$'2000'=as.integer(aux$'2000')
aux$'2007'=as.integer(aux$'2007')
aux$'2008'=as.integer(aux$'2008')
aux$'2009'=as.integer(aux$'2009')
aux$'2010'=as.integer(aux$'2010')
aux$'2011'=as.integer(aux$'2011')
aux$'2012'=as.integer(aux$'2012')
aux$'2013'=as.integer(aux$'2013')


Co2_US=aux




# --------------Transform columns to int----------------------------

test=melt(Co2_EU)

test$Years=test$variable
test$percentage_Co2=test$value
test=select(test,-variable,-value)
Co2_EU=test

test=melt(Co2_US)
test$Years=test$variable
test$percentage_Co2=test$value
test=select(test,-variable,-value)
Co2_US=test

CO2_all_US=test



# ---------------- Co2 kt -----------

aux_CO2_kt=group_by(Co2_EU,Years)
name_Co2_kt=as.character(aux_CO2_kt[1,1])
aux_CO2_kt=filter(aux_CO2_kt,Series.Name==name_Co2_kt)


aux_Co2_US=group_by(Co2_US,Years)
name_aux_Co2_US=as.character(aux_Co2_US[1,1])
aux_Co2_US=filter(aux_Co2_US,Series.Name==name_aux_Co2_US)






#-----------------------------------------------------------------------
EU_Co2_kt=aux_CO2_kt
Co2_US=aux_Co2_US

EU_Co2_kt= select(EU_Co2_kt,-Country.Code,-Series.Name)
EU_Co2_kt$Years=as.numeric(as.character(EU_Co2_kt$Years))
EU_kyoto= filter(EU_Co2_kt,Years == 1990)
EU_Co2_kt= filter(EU_Co2_kt,Years >= 2007)





Co2_US= select(Co2_US,-Country.Code,-Series.Name)
Co2_US$Years=as.numeric(as.character(Co2_US$Years))

US_kyoto= filter(Co2_US,Years == 1990)

Co2_US= filter(Co2_US,Years >= 2007)




Country=as.character(EU_Co2_kt$Country.Name)
Years=EU_Co2_kt$Years
val_Co2=EU_Co2_kt$percentage_Co2
df_CO2_EU=data.frame(Countries= Country, Year=Years, value_Co2=val_Co2)
                  
df_CO2_EU$Countries=as.character(df_CO2_EU$Countries) 

df_CO2_EU=arrange(df_CO2_EU,Year)




Country=as.character(Co2_US$Country.Name)
Years=Co2_US$Years
val_Co2=Co2_US$percentage_Co2
df_Co2_US=data.frame(Countries= Country, Year=Years, value_Co2=val_Co2)

df_Co2_US$Countries=as.character(df_Co2_US$Countries) 

df_Co2_US=arrange(df_Co2_US,Year)

df_CO2=rbind(df_CO2_EU, df_Co2_US)



# #######Progress

Eu_total_Co2=mutate(group_by(df_CO2_EU,Year),total=sum(value_Co2,na.rm = TRUE)/41)

Us_total_Co2=mutate(group_by(df_Co2_US,Year),total=diff(value_Co2,na.rm = TRUE))





# -------------------------Other params--------------------

# Transport

aux_Co2_transport=group_by(Co2_EU,Years)
name_Co2_transport=as.character(aux_Co2_transport[124,1])
aux_Co2_transport=filter(aux_Co2_transport,Series.Name==name_Co2_transport)
aux_Co2_transport=select(aux_Co2_transport,-Country.Code,-Series.Name)
aux_Co2_transport$Years=as.numeric(as.character(aux_Co2_transport$Years))
aux_Co2_transport= filter(aux_Co2_transport,Years >= 2007)


Co2_transport=aux_Co2_transport

# CO2_all_US= select(CO2_all_US,-Country.Code)
CO2_all_US$Years=as.numeric(as.character(CO2_all_US$Years))
Co2_US_all_2007= filter(CO2_all_US,Years >= 2007)

aux_Co2_transport_US=group_by(Co2_US_all_2007,Years)
name_Co2_transport_US=as.character(aux_Co2_transport_US[4,1])
aux_Co2_transport_US=filter(aux_Co2_transport_US,Series.Name==name_Co2_transport_US)
aux_Co2_transport_US=select(aux_Co2_transport_US,-Series.Name)
aux_Co2_transport_US$Years=as.numeric(as.character(aux_Co2_transport_US$Years))



# Houses and commercial activities

aux_Co2_rescom=group_by(Co2_EU,Years)
name_Co2_rescom=as.character(aux_Co2_rescom[83,1])
aux_Co2_rescom=filter(aux_Co2_rescom,Series.Name==name_Co2_rescom)
aux_Co2_rescom=select(aux_Co2_rescom,-Country.Code,-Series.Name)
aux_Co2_rescom$Years=as.numeric(as.character(aux_Co2_rescom$Years))
aux_Co2_rescom= filter(aux_Co2_rescom,Years >= 2007)



Co2_residential_commerces=aux_Co2_rescom




aux_Co2_res_US=group_by(Co2_US_all_2007,Years)
name_Co2_res_US=as.character(aux_Co2_res_US[3,1])
aux_Co2_res_US=filter(aux_Co2_res_US,Series.Name==name_Co2_res_US)
aux_Co2_res_US=select(aux_Co2_res_US,-Series.Name)
aux_Co2_res_US$Years=as.numeric(as.character(aux_Co2_res_US$Years))







# Electr

aux_Co2_elec=group_by(Co2_EU,Years)
name_Co2_elec=as.character(aux_Co2_elec[42,1])
aux_Co2_elec=filter(aux_Co2_elec,Series.Name==name_Co2_elec)
aux_Co2_elec=select(aux_Co2_elec,-Country.Code,-Series.Name)
aux_Co2_elec$Years=as.numeric(as.character(aux_Co2_elec$Years))
aux_Co2_elec= filter(aux_Co2_elec,Years >= 2007)


Co2_elec=aux_Co2_elec

aux_Co2_elec_US=group_by(Co2_US_all_2007,Years)
name_Co2_elec_US=as.character(aux_Co2_elec_US[2,1])
aux_Co2_elec_US=filter(aux_Co2_elec_US,Series.Name==name_Co2_elec_US)
aux_Co2_elec_US=select(aux_Co2_elec_US,-Series.Name)
aux_Co2_elec_US$Years=as.numeric(as.character(aux_Co2_elec_US$Years))

# Industry

aux_Co2_ind=group_by(Co2_EU,Years)
name_Co2_ind=as.character(aux_Co2_ind[165,1])
aux_Co2_ind=filter(aux_Co2_ind,Series.Name==name_Co2_ind)
aux_Co2_ind=select(aux_Co2_ind,-Country.Code,-Series.Name)
aux_Co2_ind$Years=as.numeric(as.character(aux_Co2_ind$Years))
aux_Co2_ind= filter(aux_Co2_ind,Years >= 2007)


Co2_ind=aux_Co2_ind

aux_Co2_ind_US=group_by(Co2_US_all_2007,Years)
name_Co2_ind_US=as.character(aux_Co2_ind_US[5,1])
aux_Co2_ind_US=filter(aux_Co2_ind_US,Series.Name==name_Co2_ind_US)
aux_Co2_ind_US=select(aux_Co2_ind_US,-Series.Name)
aux_Co2_ind_US$Years=as.numeric(as.character(aux_Co2_ind_US$Years))



val1=Co2_transport$percentage_Co2
val2=Co2_residential_commerces$percentage_Co2
val3=Co2_elec$percentage_Co2
val4=Co2_ind$percentage_Co2

Country=Co2_transport$Country.Name
Years=Co2_transport$Years

df_param=data.frame(Contries= Country, Year=Years,transport= val1, 
                Residential_Commercial= val2, industry= val4, Electricity=val3)

# df_param$Countries=as.character(df_param$Countries) 

df_param=arrange(df_param,Year)

#---------------US----------------------

val1=aux_Co2_transport_US$percentage_Co2
val2=aux_Co2_res_US$percentage_Co2
val3=aux_Co2_elec_US$percentage_Co2
val4=aux_Co2_ind_US$percentage_Co2

Country=aux_Co2_transport_US$Country.Name
Years=aux_Co2_transport_US$Years

df_param_US=data.frame(Countries= Country, Year=Years,transport= val1, 
                    Residential_Commercial= val2, industry= val4, Electricity=val3)

# df_param$Countries=as.character(df_param$Countries) 

df_param_US=arrange(df_param_US,Year)


############################---kyoto---########################################

aux_EU_kyoto=mutate(EU_kyoto,total=100*sum(percentage_Co2/100,na.rm = TRUE)/41)
level_1990=aux_EU_kyoto$total[1]

level_US_kyoto=US_kyoto$percentage_Co2[1]

aux_df_CO2=mutate(group_by(df_CO2,Year),total=sum(value_Co2,na.rm = TRUE)/41)

v1=c(rep('Europe',8))
v2=c(level_1990,aux_df_CO2$total[c(1,42,83,124,165,206,247)])
v3=c('1990',seq(from = 2007, to = 2013, by = 1))

df_CO2_kyoto_EU=data.frame(Region=v1, Year=v3,
                           Co2_metric_tons_per_capita= v2
)

v1=c(rep('USA',8))
v2=c(level_US_kyoto,df_Co2_US$value_Co2)
v3=c('1990',seq(from = 2007, to = 2013, by = 1))


df_CO2_kyoto_US=data.frame(Region=v1, Year=v3,
                           Co2_metric_tons_per_capita= v2
)


df_CO2_kyoto=rbind(df_CO2_kyoto_EU, df_CO2_kyoto_US)
df_CO2_kyoto=arrange(df_CO2_kyoto,Year)


aux_df_CO2_kyoto_year=filter(df_CO2_kyoto,(Year=='2009')|(Year=='1990'))





# ---------------------------App----------------------------------------


shinyServer(function(input, output) {
  
  myYear <- reactive({
    input$Years
  })
  
  
  
  output$map <- renderGvis({
    myData = df_CO2
    myData = filter (df_CO2, Year == myYear())
    colnames(myData)[colnames(myData)== 'value_Co2'] <- 'Co2(metric tons per capita)'
                     
    g=gvisGeoChart(myData,colorvar='Co2(metric tons per capita)',locationvar="Countries",
                   options = list(width=800, height=350,
                          colorAxis="{colors:['#CAFF70' ,'#FFB90F' ,'#EE7600','#EE3B3B','#A52A2A']}"
                          )
    )

    # titre color bar 
  
  })
  
  
  
  output$bar <- renderGvis({
    
    myData = df_param
    
    
    myData=group_by(df_param,transport)
    myData = filter (df_param, Year == myYear())
    aux_t=mutate(myData,total_perc=100*sum(transport/100,na.rm = TRUE)/41)
    aux_t=aux_t$total_perc
    
    myData = df_param
    myData=group_by(myData,Residential_Commercial)
    myData = filter (df_param, Year == myYear())
    aux_res_com=mutate(myData,total_perc=100*sum(Residential_Commercial/100,na.rm = TRUE)/41)
    aux_res=aux_res_com$total_perc
    
    myData = df_param
    myData=group_by(myData,industry)
    myData = filter (df_param, Year == myYear())
    aux_ind=mutate(myData,total_perc=100*sum(industry/100,na.rm = TRUE)/41)
    aux_ind=aux_ind$total_perc
    
    
    myData = df_param
    myData=group_by(myData,Electricity)
    myData = filter (df_param, Year ==myYear())
    aux_elec=mutate(myData,total_perc=100*sum(Electricity/100,na.rm = TRUE)/41)
    aux_elec=aux_elec$total_perc
    
    
    
    df_param_plot=data.frame(Transport= aux_t, Residential=aux_res,
                             Industry=aux_ind,Electricity=aux_elec)
    
    test2=melt(df_param_plot)
    test3=test2[c(1,42,83,124),]
    colnames(test3)[which(names(test3) == "value")] <- "Emissions Co2 %"
    test3$Region=c('Europe','Europe','Europe','Europe')
    test3=arrange(test3,Region)
    
    
    #___________________US____________________________________
    
    myData = df_param_US
    myData = filter (myData, Year == myYear())
    
    val=c(myData$transport,myData$Residential_Commercial,myData$industry,myData$Electricity)
    val1=c('USA','USA','USA','USA')
    
    df_US_plot=data.frame( variable=c('Transport','Residential','Industry','Electricity'),
                           CO2 = val, Region=val1)
    
    colnames(df_US_plot)[which(names(df_US_plot) == "CO2")] <- "Emissions Co2 %"
    
    
  
 
    df_CO2_param=rbind(test3, df_US_plot)
    df_CO2_param_2=arrange(df_CO2_param,variable)
    
    c1=df_CO2_param_2$Region
    c2=df_CO2_param_2$variable
    c3=df_CO2_param_2$`Emissions Co2 %`
    
    df_CO2_param_2=data.frame(Type=c2, Region=c1, 'Co2(%)'=c3,
                              Co2.style=c('blue', 'red'),
                              Co2.annotation=c("EU","USA"),
                              Type2=c('Transport','','Residential','','Industry','','Electricity',''),
                              check.names=FALSE)
 

    df_CO2_param_2=arrange(df_CO2_param_2,Type)
    
    
    Bar1 = gvisBarChart(df_CO2_param_2, 
                          xvar='Type2',
                          yvar=c('Co2(%)','Co2.style','Co2.annotation'),
                          options=list(isStacked=TRUE,title='Total % Co2 per category',
                                       width=900, height=450   
                                  )
    )
                                
                          
  
    aux_year_plot_1=filter(df_CO2_kyoto,(Year==myYear())|(Year=='1990'))
    
    v1=c('Europe','USA')
    v2=aux_year_plot_1$Co2_metric_tons_per_capita[c(3,4)]
    v3=aux_year_plot_1$Co2_metric_tons_per_capita[c(1,2)]
    
    
    aux_plot=data.frame(Region=v1, yr= v2, Levels_Kyoto=v3)
    
    yr=as.character(myYear())
    lev='Levels Kyoto 1990'
    
    colnames(aux_plot)[which(names(aux_plot) == "yr")] <- yr
    colnames(aux_plot)[which(names(aux_plot) == "Levels_Kyoto")] <- lev
    
    Bar2 = gvisComboChart(aux_plot, xvar="Region",
                            yvar=c(yr, lev),
                            options=list(seriesType="bars",
                                         series='{1: {type:"line"}}',
                                         title='Co2 (metric tons per capita)',
                                         width=900, height=450))
    
    
    
    
    
    Bar=gvisMerge(Bar1, Bar2,horizontal=TRUE)
 
    

  })
  

 
    
     
  })
  



