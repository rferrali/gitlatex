push <- function(project) {
  project <- load_project(project)
  # warn
  ## not on main
  # TODO
  ## not on latest commit
  # TODO
  ## some files in remote are not in local (except LaTeX build files)
  # TODO
  ## some files in remote are different from local and more recent
  # TODO
  # push
  ## rsync from local, except assets
  assets <- normalizePath(read_config()$assets)
  exclude <- sprintf('--exclude="%s"', basename(read_config()$assets))
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