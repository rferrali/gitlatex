pull <- function(project) {
  # rsync from remote, except assets
  exclude <- sprintf('--exclude="%s"', read_config()$assets)
  system2(
    "rsync", args = c(
      "-r", 
      "--delete", 
      "--exclude" = exclude,
      Sys.getenv(project$remote), 
      project$local
    )
  )
}