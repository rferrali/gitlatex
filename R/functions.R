read_config <- function() {
  dotenv::load_dot_env()
  # check schema
  valid_lock <- jsonvalidate::json_validate(
    json = "./gitlatex.lock",
    schema = LOCKFILE_SCHEMA,
    engine = "ajv",
    greedy = TRUE,
    verbose = TRUE
  )
  ## if schema invalid, error, TODO
  config <- jsonlite::read_json("./gitlatex.lock")
  # augment config with secrets
  config$remote_default <- Sys.getenv("GITLATEX_REMOTE_DEFAULT")
  # augment and check projects 
  config$projects <- lapply(config$projects, function(project) {
    # augment with secrets and local path info
    project$remote <- Sys.getenv(sprintf("GITLATEX_PROJECT_%s", project$name))
    project$remote_normalized <- normalizePath(project$remote)
    project$remote_parent <- normalizePath(file.path(project$remote_normalized, ".."))
    project$local_normalized <- normalizePath(project$local)
    project$local_parent <- normalizePath(file.path(project$local_normalized, ".."))
    # check
      ## check existence of project paths
    # TODO
      ## in local, create symlinks to assets if missing
      wd <- getwd()
      assets <- normalizePath(config$assets)
    withr::with_dir(
      project$local_normalized, 
      if(!file.exists("assets")) {
        file.symlink(assets, "assets")
      }
    )
      
    return(project)
  })
  return(config)
}

load_project <- function(project) {
  projects <- read_config()$projects
  names <- sapply(projects, function(project) project$name)
  return(projects[[names == project]])
}

