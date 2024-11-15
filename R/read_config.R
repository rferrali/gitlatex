read_config <- function(public, private) {
  # check schema
  if(!file.exists(public)) {
    stop("Public config file does not exist")
  }
  if(!file.exists(private)) {
    stop("Public config file does not exist")
  }
  valid_public <- jsonvalidate::json_validate(
    json = public,
    schema = .CONFIG_SCHEMA,
    engine = "ajv",
    greedy = TRUE,
    verbose = TRUE
  )
  valid_private <- jsonvalidate::json_validate(
    json = public,
    schema = .CONFIG_SCHEMA,
    engine = "ajv",
    greedy = TRUE,
    verbose = TRUE
  )
  if(!valid_public) {
    stop("Public config file is invalid")
    # TODO: show errors
  }
  if(!valid_private) {
    stop("Private config file is invalid")
    # TODO: show errors
  }
  # read config
  public <- jsonlite::read_json(public)
  private <- jsonlite::read_json(private)
  # check that projects are the same
  public_projects <- sort(sapply(public$project, function(x) x$name))
  private_projects <- sort(sapply(private, function(x) x$name))
  if(!identical(public_projects, private_projects)) {
    stop("Public and private config files do not have the same projects")
  }
  # create config
  public_projects <- do.call(
    rbind, 
    lapply(public$projects, function(project) {
      data.frame(
        name = project$name,
        local = project$local
      )
    })
  )
  private_projects <- do.call(
    rbind, 
    lapply(private, function(project) {
      data.frame(
        name = project$name,
        remote = project$remote
      )
    })
  )
  projects <- merge(public_projects, private_projects, by = "name")
  projects$remote_normalized <- normalizePath(projects$remote)
  projects$remote_parent <- normalizePath(file.path(projects$remote_normalized, ".."))
  projects$local_normalized <- normalizePath(projects$local)
  projects$local_parent <- normalizePath(file.path(projects$local_normalized, ".."))
  config <- list(
    assets = public$assets,
    projects = projects
  )
  # check that all paths exist
  if(!dir.exists(config$assets)) {
    stop("Assets directory does not exist")
  }
  for(i in 1:nrow(config$projects)) {
    project <- config$projects[i,]
    if(!dir.exists(project$local)) {
      warning(sprintf("Project %s: Local project directory does not exist", project$name))
    }
    if(!dir.exists(project$remote)) {
      warning(sprintf("Project %s: Remote project directory does not exist", project$name))
    }
  }
  # return
  return(config)  
}