#' @rdname preprocess.Rd
#' @export
#'
preprocess <- function(filepath = "/data-raw/",
                       timelog = "time-log.csv",
                       firstproj = "first-author-projects.csv",
                        students = "students.csv"){
  dat <- read.csv(paste0(filepath, timelog), stringsAsFactors = FALSE)
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

  rm_grps <- c("meeting", "email", "admin", "chat")

  project_codes <- as.character(unique(dat$Project))

  students <- as.character(read.csv(paste0(filepath,students), header = FALSE))
  sdat <- dat %>% filter(Project %in% students) %>%
    rename(Person = Project)

  #project baselines
  baselines <- read.csv(paste0(filepath, firstproj))
  baselines <- dat %>% group_by(Project) %>% summarize(hours = sum(time_taken)/60) %>%
    right_join(baselines)
  mintime <- min(baselines$hours)
  maxtime <- max(baselines$hours)
  medtime <- median(baselines$hours)

}
