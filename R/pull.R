pull <- function(project, config) {
  project <- load_project(project, config)
  # error
  test_project_paths(project, local = TRUE, remote = TRUE)
  # warn
  is_warning_unstaged <- warn_unstaged()
  ## changes -> offer to commit, TODO
  # rsync from remote, except assets
  exclude <- sprintf('--exclude="%s"', basename(config$assets))
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