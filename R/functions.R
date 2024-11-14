read_config <- function() {
  config <- jsonlite::read_json("./gitlatex.lock")
  # check schema
  # TODO
  return(config)
}

load_project <- function(project) {
  projects <- read_config()$projects
  names <- sapply(projects, function(project) project$name)
  project <- projects[[names == project]]
  return(project)
}

