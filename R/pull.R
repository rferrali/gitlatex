pull <- function(project, config) {
  project <- load_project(project, config)
  # error
  ## no remote
  stopifnot(dir.exists(project$remote_normalized))
  ## no local
  stopifnot(dir.exists(project$local_normalized))
  # warn
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