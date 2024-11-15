push <- function(project, config) {
  project <- load_project(project, config)
  # error
  test_project_paths(project, local = TRUE, remote = TRUE)
  # warn
  ## not on main
  is_warning_main <- warn_not_main()
  ## not on latest commit
  is_warning_not_up_to_date <- warn_not_up_to_date()
  ## some files in remote are not in local (except LaTeX build files)
  is_warning_remote_not_in_local <- warn_remote_not_in_local(project, config)
  ## some files in remote are different from local and more recent
  is_warning_remote_more_recent <- warn_remote_more_recent(project, config)
  # push
  ## rsync from local, except assets
  assets <- normalizePath(config$assets)
  exclude <- sprintf('--exclude="%s"', basename(config$assets))
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