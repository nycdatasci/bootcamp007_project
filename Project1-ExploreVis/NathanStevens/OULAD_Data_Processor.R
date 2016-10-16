# specify the data directory where the csv files are
library(dplyr)
library(ggplot2)

# the directory where the data files are stored
data.dir = "C:/Users/nathan/Google Drive/Data Science Boot Camp/data/oulad/"

# the direcotry where the plots and any data should be saved
save.dir = "C:/Users/nathan/Documents/DataScience2016/Project01/"

# function to load the data
loadData = function() {
  # load the courses
  cat("Loading courses ...\n")
  coursesDF <<- read.csv(paste0(data.dir, 'courses.csv'))

  # load the student registeration for a course
  cat("Loading registration information ...\n")
  registrationsDF <<- read.csv(paste0(data.dir, 'studentRegistration.csv'))

  # load the assessment data
  cat("Loading assessment information ...\n")
  assessmentsDF = read.csv(paste0(data.dir, 'assessments.csv'))

  # load the grades and merge it with the assessment table
  cat("Loading grades information ...\n")
  gradesDF = read.csv(paste0(data.dir, 'studentAssessment.csv'))
  gradesDF <<- inner_join(gradesDF, assessmentsDF)
  

  # load the student information
  cat("Loading student information ...\n")
  studentInfoDF <<- read.csv(paste0(data.dir, 'studentInfo.csv'))

  # finally load the vle access data and filter it out
  cat("Loading content access information ...\n")
  
  tempDF1 = read.csv(paste0(data.dir, 'vle.csv'))
  tempDF2 = read.csv(paste0(data.dir, 'studentVle.csv'))
  tempDF3 = inner_join(tempDF1, tempDF2) # join the two dataframes from above

  # filter out row by the activity type since we don't
  # need all the rows to get usefull information
  vleDF <<- filter(tempDF3, activity_type == 'oucontent' | 
                 activity_type == 'resource' | 
                 activity_type == 'url')

  # delete all the temp data frames to save memory
  rm(tempDF1, tempDF2, tempDF3)
  
  cat("Done loading data\n")
}

# function to save plots for how early the student accessed 
# the content for a particular course
plotStudentAccess = function(courseInfo) {
  course_vle = courseInfo$course_vle
  student_info = courseInfo$student_info
  student_grades = courseInfo$student_grades
  
  # filter out students who have dropped the class
  withdrawn = filter(student_info, final_result == 'Withdrawn')[[3]]
  course_vle = filter(course_vle, !(id_student %in% withdrawn))
  student_grades = filter(student_grades, !(id_student %in% withdrawn) &
                            assessment_type != "Exam")
  
  # add row to normalize the dates to the first date the content was accessed
  course_vle = mutate(course_vle, norm_date = date - min_date_all)
  
  ## group access date and average interactions by student id
  df = group_by(course_vle, id_student)
  sdata1 = summarise(df, med_date = median(norm_date), sd_date = sd(norm_date), total_clicks = sum(sum_click))
  sdata1 = mutate(sdata1, x_data = as.factor(id_student), click_date_ratio = total_clicks/med_date)

  # plot histogram of showing distribution of the number of clicks
  ghp = ggplot(data = sdata1, aes(x = total_clicks)) + 
    geom_histogram(binwidth = 100, fill = "dodgerblue2") +
    xlab("Total Clicks") + 
    ylab("Count") + 
    theme(text=element_text(size=14, face="bold"))
  filename = paste0(save.dir, 'StudentAccessClicks_', course_vle[1,2], '_', course_vle[1,3],'.png')
  ggsave(filename, plot = ghp)
  
  # plot average time to access course content by student
  gpp = ggplot(data = sdata1, aes(x = reorder(x_data, med_date), y = med_date)) + 
    geom_point(colour = "red2", size = 3) + 
    xlab("Student") + 
    ylab("Median Access Time (days)") +
    theme(axis.text.x = element_blank(), text=element_text(size=14, face="bold"))
  filename = paste0(save.dir, 'StudentAccessTimes_', course_vle[1,2], '_', course_vle[1,3],'.png')
  ggsave(filename, plot = gpp)
  
  # get the number of assessments so we can calculate the means
  # correctly if student missed an test
  tdf = group_by(student_grades, id_assessment)
  assessment.total = nrow(summarise(tdf, n = n()))
  
  # group score by student id
  student_grades = mutate(student_grades, 
                          norm_score = ifelse(weight != 0, score*(weight/100), score))
  df = group_by(student_grades, id_student)
  
  sdata2 = summarise(df, avg_score = sum(score)/assessment.total, 
                     final_score = ifelse(sum(norm_score) <= 100, sum(norm_score), sum(score)/assessment.total))
  sdata2 = mutate(sdata2, x_data = as.factor(id_student))
  sdata2 = inner_join(sdata2, sdata1)
  sdata2 = inner_join(sdata2, student_info)
  
  gbp = ggplot(data = sdata2, aes(x = total_clicks, y = final_score)) + 
    geom_point(size = 3, aes(color = final_result)) +
    xlab("Clicks") + 
    ylab("Average Score") +
    theme(text=element_text(size=14, face="bold"))
  filename = paste0(save.dir, 'StudentScore_', course_vle[1,2], '_', course_vle[1,3],'-01.png')
  ggsave(filename, plot = gbp)
  
  gbp = ggplot(data = sdata2, aes(x = med_date, y = final_score)) + 
    geom_point(size = 3, aes(color = final_result)) + 
    xlab("Median Access Time") + 
    ylab("Average Score") +
    theme(text=element_text(size=14, face="bold"))
  filename = paste0(save.dir, 'StudentScore_', course_vle[1,2], '_', course_vle[1,3],'-02.png')
  ggsave(filename, plot = gbp)
  
  # add boxplot comparing final result to total clicks
  gbp = ggplot(data = sdata2, aes(x = final_result, y = total_clicks)) + 
    geom_boxplot(aes(fill = final_result)) + 
    xlab("") + 
    ylab("Clicks") +
    theme(text=element_text(size=14, face="bold"), 
          axis.text=element_text(size=12, face="bold"), 
          legend.position="none")
  filename = paste0(save.dir, 'StudentScore_', course_vle[1,2], '_', course_vle[1,3],'-03.png')
  ggsave(filename, plot = gbp)
  
  # add box plot comparing the median access time of students who passed and failed
  gbp = ggplot(data = sdata2, aes(x = final_result, y = med_date)) +
    geom_boxplot(aes(fill = final_result)) +
    xlab("") + 
    ylab("Median Access Time") +
    theme(text=element_text(size=14, face="bold"), 
          axis.text=element_text(size=12, face="bold"), 
          legend.position="none")
  filename = paste0(save.dir, 'StudentScore_', course_vle[1,2], '_', course_vle[1,3],'-04.png')
  ggsave(filename, plot = gbp)
  
  # plot the total access clicks by age
  gbp = ggplot(data = sdata2, aes(x = age_band, y = total_clicks)) +
    geom_boxplot(aes(fill = age_band)) +
    #geom_boxplot(aes(fill = final_result)) + 
    xlab("") + 
    ylab("Clicks") +
    theme(text=element_text(size=14, face="bold"), 
          axis.text=element_text(size=12, face="bold"),
          legend.position="none")
    
  filename = paste0(save.dir, 'StudentScore_', course_vle[1,2], '_', course_vle[1,3],'-05.png')
  ggsave(filename, plot = gbp)
  
  # plot the total access clicks by gender
  gbp = ggplot(data = sdata2, aes(x = gender, y = total_clicks)) +
    geom_boxplot(aes(fill = gender)) +
    #geom_boxplot(aes(fill = final_result)) + 
    xlab("") + 
    ylab("Clicks") +
    theme(text=element_text(size=14, face="bold"), 
          axis.text=element_text(size=12, face="bold"),
          legend.position="none")
  
  filename = paste0(save.dir, 'StudentScore_', course_vle[1,2], '_', course_vle[1,3],'-06.png')
  ggsave(filename, plot = gbp)
  
  # save out some statistics about the course
  filename = paste0(save.dir, 'StudentStatistics', course_vle[1,2], '_', course_vle[1,3],'.txt')
  cat("Total Registered:", courseInfo$student_count, 
      "Total Withdrawn:", length(withdrawn), 
      "% Withdrawn:", 
      (length(withdrawn)/courseInfo$student_count)*100,
      file = filename, sep="\n")
} 

# function to filter information by the course
filterByCourse = function(cm, cp) {
  courseInfo = list()
  courseInfo$cm = cm
  courseInfo$cp = cp
  
  # get the vle content access for this course only
  ctdf = filter(vleDF, code_module == cm & 
                  code_presentation == cp)
  
  # create a data frame that has the date the content was first 
  # access by a particular student
  tdf = group_by(ctdf, id_student, id_site)
  sdf = summarise(tdf, min_date = min(date), total_clicks = sum(sum_click))
  courseInfo$date_clicks = sdf
  
  # get the minium date for a particular content and the average clicks
  tdf2 = group_by(ctdf, id_site)
  sdf2 = summarise(tdf2, min_date_all = min(date), mean_clicks = mean(sum_click), clicks_all = sum(sum_click))
  
  # join the access date information to the above
  courseInfo$course_vle = inner_join(ctdf, sdf2)
  
  # add information about the students in the course here as well
  courseInfo$student_info = filter(studentInfoDF, 
                                   code_module == cm, 
                                   code_presentation == cp)
  # get the grades for this course
  courseInfo$student_grades = filter(gradesDF, 
                                     code_module == cm, 
                                     code_presentation == cp)
  
  return(courseInfo)
}

# This list the number of students in a course
processCourse = function(x) {
  cm = x[1]
  cp = x[2]
  
  # to improve performance get a subset of the vleDF containing
  # data for this course only
  courseInfo = filterByCourse(cm, cp)
  
  # get the student registered for the course
  srV = filter(registrationsDF, code_module == cm & 
                          code_presentation == cp)[[3]]
  
  courseInfo$student_count = length(srV)
  
  cat('Course:', cm, '-' ,cp, '/ Number Students:', courseInfo$student_count, '\n')
  cat('Generating plots')
  
  # call functions to genecourseInfo$student_countrate some "usefull" plots
  plotStudentAccess(courseInfo)
  
  return()
}

# firt load the data
#loadData()
apply(coursesDF, 1, processCourse)