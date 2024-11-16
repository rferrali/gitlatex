#' Push changes to remote project directories
#' 
#' @description Pushes changes to remote project directories. 
#' 
#' @param config The config object, should be read using [read_config()]
#' @param projects A character vector of project names. If `NULL`, all projects will be pushed.
#' @param main Should we test that the repo is on the main branch before pushing? (default: `TRUE`)
#' @param latest Should we test that the repo is up to date with master before pushing? (default: `TRUE`)
#' @param in_local Should we test that all files in remote are also in local? (default: `TRUE`; this ignores LaTeX build files)
#' @param more_recent Should we test that all files in local are more recent than in remote? (default: `TRUE`)
#' @param git Should we run the Git tests at all? (default: `TRUE`)
#' 
#' @details
#' The logical parameters issue warnings when turned off. 
#' If turned on, they issue errors in non-interactive sessions and ask for user confirmation in interactive sessions.
#' All tests are run, even when turned off. The `git` parameter allows to skip the Git tests altogether. 
#' This is useful in cases where the local directory is not a Git repo.
#' 
#' @export

push <- function(
  config, 
  projects = NULL, 
  main = TRUE, 
  latest = TRUE, 
  in_local = TRUE, 
  more_recent = TRUE,
  git = TRUE
) {
  projects <- load_projects(projects, config)
  cli::cli_inform(glue::glue("Pushing {nrow(projects)} project(s)"))
  # error if some paths are misspecified
  test <- test_projects(projects, local = TRUE, remote = TRUE, error = TRUE)
  # warnings
  ## not on main
  if(git) {
  interactive_errors(
    success = is_main(),
    implement = main,
    message = "The repo is not on the main branch",
    confirmation = "Push anyway? You might be pushing outdated data"
  )}
  ## not on latest commit
  if(git) {
  interactive_errors(
    success = is_up_to_date(),
    implement = latest,
    message = "The repo is not up to date with master",
    confirmation = "Push anyway? You might be pushing outdated data"
  )}
  ## some files in remote are not in local (except LaTeX build files)
  remote_in_local <- is_remote_in_local(projects, config$assets)
  interactive_errors(
    success = remote_in_local,
    implement = in_local,
    message = attr(remote_in_local, "message"),
    confirmation = "Push anyway? Those files will be deleted."
  )
  ## some files in remote are different from local and more recent
  remote_less_recent <- is_remote_less_recent(projects, config$assets)
  interactive_errors(
    success = remote_less_recent,
    implement = more_recent,
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