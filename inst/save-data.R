#data saving functions
# CJ Brown 26/06/2018

outputDir <- "."
fields <- c("projcode_targets", "hours_targets")

saveData <- function(data) {
  data <- t(data)
  # Create a unique file name
  fileName <- "my-uptimer-targets.csv"
  # Write the file to the local system
  write.csv(
    x = data,
    file = file.path(outputDir, fileName), 
    row.names = FALSE, quote = TRUE
  )
}

loadData <- function() {
  # Read all the files into a list
  files <- list.files(outputDir, full.names = TRUE)
  data <- lapply(files, read.csv, stringsAsFactors = FALSE) 
  # Concatenate all data together into one data.frame
  data <- do.call(rbind, data)
  data
}