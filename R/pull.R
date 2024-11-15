pull <- function(
  config, 
  projects = NULL, 
  uncommitted = TRUE
) {
  projects <- load_projects(projects, config)
  cli::cli_inform(glue::glue("Pulling {nrow(projects)} project(s)"))
  # error if some paths are misspecified
  test <- test_projects(projects, local = TRUE, remote = TRUE, error = TRUE)
  # warnings
  ## uncommitted changes
  interactive_errors(
    success = is_committed(),
    implement = uncommitted,
    message = "The repo has some uncommitted changes",
    confirmation = "Pull anyway? This might erase your changes."
  )
  # pull
  exclude <- sprintf('--exclude="%s"', basename(config$assets))
  for(i in 1:nrow(projects)) {
    project <- projects[i,]
    cli::cli_inform(glue::glue("Pulling {project$name}..."))
    # rsync from remote, except assets
    system2(
      "rsync", args = c(
        "-ar", 
        "--delete", 
        "--exclude" = '--exclude "assets"',
        project$remote_normalized, 
        project$local_parent
      )
    )
  }
  cli::cli_inform(c("v" = "Done"))
}