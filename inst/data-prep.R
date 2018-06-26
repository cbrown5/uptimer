#data prep for uptimer
# CJ Brown 26/06/2018 

#Parameters
minhours <- 10 #min hours for a project to register as a project for graphing
rm_grps <- c("meeting", "email", "admin", "chat") #projects/tasks to remove from graphs of individual projects

#Sourced in 

fdata <- "../data-raw/"

#
# Setup data- need to figure out how to make this internal
#
dat <- read.csv(paste0(fdata, "time-log.csv"), stringsAsFactors = FALSE)
dat$starttime <- (strptime(paste(as.character(dat$Date), as.character(dat$Start)), "%d/%m/%Y %H:%M" )) %>%
  as.POSIXct()
dat$endtime <- strptime(paste(as.character(dat$Date),as.character(dat$End)), "%d/%m/%Y %H:%M" ) %>%
  as.POSIXct()
dat$datex <- as.Date(as.character(dat$Date), "%d/%m/%Y") %>%
  as.POSIXct() %>% format("%Y-%m-%d") %>% as.Date()
dat$Year <- year(dat$datex)
dat$time_taken <- as.numeric(dat$endtime - dat$starttime)

#fix empty slots
iemp <- which(is.na(dat$Project) | (dat$Project == ""))
dat$Project[iemp] <- dat$Task[iemp]
iemp <- which(is.na(dat$Task) | (dat$Task == ""))
dat$Task[iemp] <- dat$Project[iemp]



#Identify project codes (only this with > 5 hours)
project_codes <- dat %>%
  group_by(Project) %>% 
  summarize(hours = sum(time_taken)/60) %>%
  filter(hours > minhours)
project_codes <- as.character(unique(project_codes$Project))

#Move direct reports that used to be recorded in Project over to Person
dr_old <- c("dale", "kris", "andrew", "laura", "brett", "mischa", "tessie")


direct_reports <- unique(dat$Person)[nchar(unique(dat$Person))>0]
sdat <- dat %>% filter(nchar(Person)>0)

#project baselines, if they exist 
if ("baseline-projects.csv" %in% list.files(fdata)){
  baselines <- read.csv(paste0(fdata,"baseline-projects.csv"))
  baselines <- dat %>% group_by(Project) %>% summarize(hours = sum(time_taken)/60) %>%
    right_join(baselines)
  mintime <- min(baselines$hours)
  maxtime <- max(baselines$hours)
  medtime <- median(baselines$hours)
} else {
  mintime <- maxtime <- medtime <- NA
}