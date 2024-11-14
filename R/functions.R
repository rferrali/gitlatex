read_config <- function() {
  dotenv::load_dot_env()
  config <- jsonlite::read_json("./gitlatex.lock")
  # check schema
  # TODO
  # augment projects
  config$projects <- lapply(config$projects, function(project) {
    project$remote <- Sys.getenv(sprintf("GITLATEX_PROJECT_%s", project$name))
    project$remote_normalized <- normalizePath(project$remote)
    project$remote_parent <- normalizePath(sprintf("%s/..", project$remote_normalized))
    project$local_normalized <- normalizePath(project$local)
    project$local_parent <- normalizePath(sprintf("%s/..", project$local_normalized))
    return(project)
  })
  return(config)
}

load_project <- function(project) {
  projects <- read_config()$projects
  names <- sapply(projects, function(project) project$name)
  return(projects[[names == project]])
}

