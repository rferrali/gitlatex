init <- function(remote_default) {
  # lockfile exists? 
  exists <- file.exists("./gitlatex.lock")
  # if doesn't exist, create
  if(!exists) {
    lockfile <- jsonlite::toJSON(list(
      assets = "./assets",
      projects = list()
    ), pretty = TRUE, auto_unbox = TRUE)
    write(lockfile, "./gitlatex.lock")
  }
  # if exists, check schema
  if(exists) {
    config <- read_config() # TODO: read_config errors if schema wrong
    ## if schema wrong, fix
    # TODO
  }
}