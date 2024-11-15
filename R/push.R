push <- function(
  config, 
  projects = NULL, 
  main = TRUE, 
  latest = TRUE, 
  up_to_date = TRUE,
  no_local = TRUE, 
  more_recent = TRUE
) {
  projects <- load_projects(projects, config)
  cli::cli_inform(glue::glue("Pushing {nrow(projects)} project(s)"))
  # error if some paths are misspecified
  test <- test_projects(projects, local = TRUE, remote = TRUE, error = TRUE)
  # warnings
  ## not on main
  interactive_errors(
    success = is_main(),
    implement = main,
    message = "The repo is not on the main branch",
    confirmation = "Push anyway? You might be pushing outdated data"
  )
  ## not on latest commit
  interactive_errors(
    success = is_up_to_date(),
    implement = up_to_date,
    message = "The repo is not up to date with master",
    confirmation = "Push anyway? You might be pushing outdated data"
  )
  ## some files in remote are not in local (except LaTeX build files)
  remote_in_local <- is_remote_in_local(projects, config$assets)
  interactive_errors(
    success = remote_in_local,
    implement = no_local,
    message = attr(remote_in_local, "message"),
    confirmation = "Push anyway? Those files will be deleted."
  )
  ## some files in remote are different from local and more recent
  remote_less_recent <- is_remote_less_recent(projects, config$assets)
  interactive_errors(
    success = remote_in_local,
    implement = no_local,
    message = attr(remote_less_recent, "message"),
    confirmation = "Push anyway? Those files will be deleted."
  )
  # push
  assets <- normalizePath(config$assets)
  exclude <- sprintf('--exclude="%s"', basename(config$assets))
  for(i in 1:nrow(projects)) {
    project <- projects[i,]
    cli::cli_inform(glue::glue("Pushing {project$name}..."))
    ## rsync from local, except assets
    system2(
      "rsync", args = c(
        "-ar", 
        "--delete", 
        exclude,
        project$local_normalized,
        project$remote_parent
      )
    )
    ## rsync assets
    system2(
      "rsync", args = c(
        "-r", 
        "--delete",
        assets,
        project$remote_normalized
      )
    )
  }
  cli::cli_inform(c("v" = "Done"))
}