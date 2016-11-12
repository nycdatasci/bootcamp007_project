library(dplyr)
library(stringi)
#read the data in
meetup = read.csv('meetupfv.csv')
meetupurl= read.csv('meetupurl.csv')

#write.csv(meetup, file='meetupff.csv')

#drop 'meetup table' useless columns and reorganized columns 
meetup = select(meetup, -X) %>% select(-group)%>% select(-Worldwide)
meetup = meetup[ ,c('Category','name','member','Location',
                    'Region','FoundedDate','Group.reviews','Past.Meetups',
                    'Upcoming.Meetups','UpcommingEventName','UpcommingEventGoing',
                    'UpcommingEventDate','UpcommingEventTime')]

#select only url colume
meetupurl = select(meetupurl, url)

#bind url colume to meetup table
meetup = bind_cols(meetup, meetupurl)

#convert the data to right format 
meetup$member = as.numeric(gsub(',','',meetup$member)) 
meetup$Location = as.factor(paste(meetup$Location , meetup$Region, sep = ", "))
meetup = select(meetup, -Region)

meetup$Past.Meetups = as.numeric(gsub(',','',meetup$Past.Meetups))
meetup$UpcommingEventGoing = as.numeric(stri_sub(meetup$UpcommingEventGoing, 1, -6))

meetup$FoundedDate = as.character(meetup$FoundedDate)
meetup$FoundedDate = as.Date(meetup$FoundedDate, format = '%b %d %Y ')

meetup$UpcommingEventDate = as.character(meetup$UpcommingEventDate)
meetup$U_e_wd= stri_sub(meetup$UpcommingEventDate, 1, 3)
meetup$UpcommingEventDate= stri_sub(meetup$UpcommingEventDate, 4, )
meetup$UpcommingEventDate = paste('2016', meetup$UpcommingEventDate, sep=" " )
meetup$UpcommingEventDate = as.Date(meetup$UpcommingEventDate, format = '%Y %b %d')

meetup$UpcommingEventTime = as.factor(meetup$UpcommingEventTime)

meetup$U_temp_time= as.POSIXct(strptime(meetup$UpcommingEventTime, format = '%I:%M %p'))

#remove groups that has no member 
meetup_no_m = meetup[!is.na(meetup$member),]

#number of meetup in each category 
n_cat = select(meetup_no_m, Category)%>% group_by(Category) %>% count()

#average member in each category
n_mem = select(meetup_no_m, Category, member) %>% group_by(Category) %>% summarise(avg = mean(member))

#number of groups by location in each category
n_loc = select(meetup_no_m, Category, Location) %>% group_by(Category) %>% count(Location)

#number of past meetups 
meetup_no_m$Past.Meetups[is.na(meetup_no_m$Past.Meetups)] = 0  
n_pm = select(meetup_no_m, Category, Past.Meetups) %>% group_by(Category) %>% summarise(avg = mean(Past.Meetups))

