push <- function(project) {
  print("pushing")
  # warn
  ## not on main
  ## not on latest commit
  ## some files in remote are not in local (except LaTeX build files)
  ## some files in remote are different from local and more recent
  # push
  ## rsync from local, except assets
  exclude <- sprintf('--exclude="%s"', read_config()$assets)
  system2(
    "rsync", args = c(
      "-r", 
      "--delete", 
      "--exclude" = exclude,
      project$local,
      Sys.getenv(project$remote)
    )
  )
  ## rsync assets
  system2(
    "rsync", args = c(
      "-r", 
      "--exclude" = exclude,
      read_config()$assets,
      Sys.getenv(project$remote)
    )
  )
}