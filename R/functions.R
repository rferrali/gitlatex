read_config <- function() {
  config <- jsonlite::read_json("./gitlatex.lock")
  config$assets_normalized <- normalizePath(config$assets)
  return(config)
}

load_project <- function(project) {
  projects <- read_config()$projects
  names <- sapply(projects, function(project) project$name)
  project <- projects[[names == project]]
  return(project)
}

