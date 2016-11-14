library(dplyr)
library(stringi)
library(plotly)
library(ggplot2)
library(googleVis)
#read the data in
meetup = read.csv('meetupfv.csv')
meetupurl= read.csv('meetupurl.csv')

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

lct <- Sys.getlocale("LC_TIME")
Sys.setlocale("LC_TIME", "C")
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
catp = plot_ly(n_cat, x= ~Category, y= ~n, type='bar', marker = list(color = c('rgba(185,66,64,0.9)', 'rgba(177, 78, 42, 0.9)',
                                                                               'rgba(201, 147, 38, 0.9)', 'rgba(136, 214, 72, 0.9)',
                                                                               'rgba(136, 214, 146, 0.9)','rgba(136, 214, 193, 0.9)',
                                                                               'rgba(152, 119, 237, 0.9)','rgba(104, 119, 237, 0.9)',
                                                                               'rgba(191, 106, 211, 0.9)','rgba(177, 106, 228, 0.9))',
                                                                               'rgba(177, 163, 228, 0.9)', 'rgba(217, 129, 228, 0.9)',
                                                                               'rgba(168, 146, 228, 0.9)', 'rgba(130, 146, 228, 0.9)',
                                                                               'rgba(130, 177, 228, 0.9)','rgba(130, 177, 179, 0.9)',
                                                                               'rgba(130, 177, 131, 0.9)','rgba(181, 165, 96, 0.9)',
                                                                               'rgba(217, 177, 73, 0.9)','rgba(217, 137, 73, 0.9)',
                                                                               'rgba(217, 108, 73, 0.9)','rgba(217, 85, 123, 0.9)',
                                                                               'rgba(217, 85, 180, 0.9)','rgba(168, 85, 180, 0.9)'
                                                                               )))


#average member in each category
n_mem = select(meetup_no_m, Category, member) %>% group_by(Category) %>% summarise(avg = mean(member))
avgcp = plot_ly(n_mem, x= ~Category, y= ~avg, type='bar', marker = list(color = c('rgba(185,66,64,0.9)', 'rgba(177, 78, 42, 0.9)',
                                                                               'rgba(201, 147, 38, 0.9)', 'rgba(136, 214, 72, 0.9)',
                                                                               'rgba(136, 214, 146, 0.9)','rgba(136, 214, 193, 0.9)',
                                                                               'rgba(152, 119, 237, 0.9)','rgba(104, 119, 237, 0.9)',
                                                                               'rgba(191, 106, 211, 0.9)','rgba(177, 106, 228, 0.9))',
                                                                               'rgba(177, 163, 228, 0.9)', 'rgba(217, 129, 228, 0.9)',
                                                                               'rgba(168, 146, 228, 0.9)', 'rgba(130, 146, 228, 0.9)',
                                                                               'rgba(130, 177, 228, 0.9)','rgba(130, 177, 179, 0.9)',
                                                                               'rgba(130, 177, 131, 0.9)','rgba(181, 165, 96, 0.9)',
                                                                               'rgba(217, 177, 73, 0.9)','rgba(217, 137, 73, 0.9)',
                                                                               'rgba(217, 108, 73, 0.9)','rgba(217, 85, 123, 0.9)',
                                                                               'rgba(217, 85, 180, 0.9)','rgba(168, 85, 180, 0.9)'
)))

#number of groups by location in each category
#shiny select category
n_loc = select(meetup_no_m, Category, Location) %>% group_by(Category) %>% count(Location)
locp = plot_ly(n_loc, x= ~Category, y= ~n, color= ~Location)

##########

#number of past meetups 
meetup_no_m$Past.Meetups[is.na(meetup_no_m$Past.Meetups)] = 0  
meetup_no_m$Upcoming.Meetups[is.na(meetup_no_m$Upcoming.Meetups)] = 0



scatplm = plot_ly(meetup_no_m, x= ~Past.Meetups, y= ~member, color= ~Category)
scatplu = plot_ly(meetup_no_m, x= ~Upcoming.Meetups, y= ~member, color= ~Category)

scat3d = plot_ly(meetup_no_m, x= ~Past.Meetups, y= ~Upcoming.Meetups, 
                 z= ~member, color = ~Category, text= ~paste("Past:", Past.Meetups, '<br>Upcoming:', Upcoming.Meetups, '<br>Members:',member)) %>% 
  add_markers() %>% layout(scene = list(xaxis= list(title ='Past.Meetups'),
                                        yaxis = list(title = 'Upcoming.Meetups'),
                                        zaxis = list(title = 'member')))
###################### heatmap
meetup_up_event = filter(meetup_no_m, meetup_no_m$UpcommingEventTime != "")
meetup_up_event$U_temp_time = as.POSIXct(meetup_up_event$U_temp_time, format="%H:%M")

cut_time = c("03:00", "06:00", "09:00", "12:00", "15:00", "18:00", "21:00", "24:00")
cut_time= as.POSIXct(strptime(cut_time, format = '%H:%M'))

category = c("3am-6am", "6am-9am", "9am-12pm", "12pm-3pm", "3pm-6pm", "6pm-9pm", "9pm-12am")
time_category = NULL
for (i in seq(1,length(category))){
  time_category[which(meetup_up_event$U_temp_time >= cut_time[i] & meetup_up_event$U_temp_time < cut_time[i+1])] = category[i]
}
time_category[which(meetup_up_event$U_temp_time < cut_time[1])] = "12am-3am"
meetup_up_event$Timeslot = time_category

heatm_df = group_by(meetup_up_event, Timeslot, U_e_wd) %>% 
  summarise("event_n" = n(), "going" = sum(UpcommingEventGoing), "average" = round(mean(UpcommingEventGoing)))


heatm_df$U_e_wd = factor(heatm_df$U_e_wd , levels = c('Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'), ordered = TRUE)
heatm_df$Timeslot = factor(heatm_df$Timeslot, levels = c("12am-3am", "3am-6am","6am-9am", 
                                                                                   "9am-12pm", "12pm-3pm", "3pm-6pm", "6pm-9pm", "9pm-12am"), ordered = TRUE)

heatm_poptime = plot_ly(x= heatm_df$Timeslot, y=heatm_df$U_e_wd, z=heatm_df$event_n, type = "heatmap")


