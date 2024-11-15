read_config <- function(public, private) {
  # public
  ## check existence
  if(!file.exists(public)) {
    cli::cli_abort("Public config file does not exist")
  }
  ## check schema
  valid_public <- jsonvalidate::json_validate(
    json = public,
    schema = .CONFIG_SCHEMA,
    engine = "ajv",
    greedy = FALSE
  )
  if(!valid_public) {
    cli::cli_alert_danger("Public config file is invalid")
    jsonvalidate::json_validate(
      json = public,
      schema = .CONFIG_SCHEMA,
      engine = "ajv",
      greedy = TRUE, 
      error = TRUE
    )
  }
  ## read config
  public <- jsonlite::read_json(public)
  # private
  ## check existence
  if(!file.exists(private)) {
    if(!interactive()) {
      cli::cli_abort("Private config file does not exist")
    } else {
      cli::cli_alert_warning("Private config file does not exist. Perhaps you moved to a new environment?")
      choice <- menu(c("Yes", "No"), title = "Create private config file?")
      if(choice == 1) {
        jsonlite::write_json(.CONFIG_PRIVATE_EXAMPLE, private, auto_unbox = TRUE, pretty = TRUE)
        cli::cli_bullets(c(
          "v" = glue::glue("Private config file created at {private}"),
          "!" = "Please edit the file according to the public config file"
        ))
      }
      cli::cli_alert("Exiting...")
      return()
    }
  }
  ## check schema
  valid_private <- jsonvalidate::json_validate(
    json = private,
    schema = .CONFIG_PRIVATE_SCHEMA,
    engine = "ajv",
    greedy = FALSE
  )
  if(!valid_private) {
    cli::cli_alert_danger("Private config file is invalid")
    jsonvalidate::json_validate(
      json = private,
      schema = .CONFIG_PRIVATE_SCHEMA,
      engine = "ajv",
      greedy = TRUE, 
      error = TRUE
    )
  }
  ## read config
  private <- jsonlite::read_json(private)
  # check that projects are the same
  public_projects <- sort(sapply(public$project, function(x) x$name))
  private_projects <- sort(sapply(private, function(x) x$name))
  if(!identical(public_projects, private_projects)) {
    msg <- c("x" = "Public and private config files do not have the same projects")
    no_public_path <- setdiff(private_projects, public_projects) 
    if(length(no_public_path) > 0) {
      no_public_path <- paste(no_public_path, collapse = ", ")
      msg <- c(msg, glue::glue("These projects have no local path: {no_public_path}"))
    }
    no_private_path <- setdiff(public_projects, private_projects) 
    if(length(no_private_path) > 0) {
      no_private_path <- paste(no_private_path, collapse = ", ")
      msg <- c(msg, glue::glue("These projects have no remote path: {no_private_path}"))
    }
    cli::cli_abort(msg)
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
    cli::cli_abort(glue::glue("Assets directory not found at {config$assets}"))
  }
  # check that all projects exist
  test_projects(config$projects, local = TRUE, remote = TRUE, error = FALSE)
  # return
  return(config)  
}