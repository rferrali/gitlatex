init <- function() {
  # lockfile exists? 
  exists <- file.exists("./gitlatex.lock")
  # if doesn't exist, create
  if(!exists) {
    lockfile <- jsonlite::toJSON(list(
      assets = "./assets",
      projects = list()
    ))
    write(lockfile, "./gitlatex.lock")
    return()
  }
  # if exists, check schema
  config <- read_config() # read_config errors if schema wrong
  ## if schema wrong, fix
  # TODO
}