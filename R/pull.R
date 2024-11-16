#' Pull changes from remote project directories
#' 
#' @description Pulls changes from remote project directories. 
#' 
#' @param config The config object, should be read using [read_config()]
#' @param projects A character vector of project names. If `NULL`, all projects will be pulled.
#' @param uncommitted Should we test that the repo has no uncommitted changes before pulling? (default: `TRUE`)
#' @param git Should we run the Git tests at all? (default: `TRUE`) 
#' 
#' @details
#' The logical parameter issues warnings when turned off. 
#' If turned on, they issue errors in non-interactive sessions and ask for user confirmation in interactive sessions.
#' All tests are run, even when turned off. The `git` parameter allows to skip the Git tests altogether.
#' This is useful in cases where the local directory is not a Git repo.
#' 
#' @export

pull <- function(
  config, 
  projects = NULL, 
  uncommitted = TRUE,
  git = TRUE
) {
  projects <- load_projects(projects, config)
  cli::cli_inform(glue::glue("Pulling {nrow(projects)} project(s)"))
  # error if some paths are misspecified
  test <- test_projects(projects, local = TRUE, remote = TRUE, error = TRUE)
  # warnings
  ## uncommitted changes
  if(git) {
  interactive_errors(
    success = is_committed(),
    implement = uncommitted,
    message = "The repo has some uncommitted changes",
    confirmation = "Pull anyway? This might erase your changes."
  )}
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