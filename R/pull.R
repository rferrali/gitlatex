pull <- function(project) {
  project <- load_project(project)
  dotenv::load_dot_env()
  # warn
  ## changes -> offer to commit
  # rsync from remote, except assets
  exclude <- sprintf('--exclude="%s"', basename(read_config()$assets))
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