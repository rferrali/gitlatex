push <- function(project) {
  project <- load_project(project)
  dotenv::load_dot_env()
  # warn
  ## not on main
  ## not on latest commit
  ## some files in remote are not in local (except LaTeX build files)
  ## some files in remote are different from local and more recent
  # push
  ## rsync from local, except assets
  local <- normalizePath(project$local)
  remote <- normalizePath(Sys.getenv(project$remote))
  remote_parent_dir <- sprintf("%s/..", remote) |> normalizePath()
  assets <- normalizePath(read_config()$assets)
  exclude <- sprintf('--exclude="%s"', basename(read_config()$assets))
  system2(
    "rsync", args = c(
      "-ar", 
      "--delete", 
      exclude,
      local,
      remote_parent_dir
    )
  )
  ## rsync assets
  system2(
    "rsync", args = c(
      "-r", 
      exclude,
      assets,
      remote
    )
  )
}