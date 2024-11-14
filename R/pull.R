pull <- function(project) {
  project <- load_project(project)
  dotenv::load_dot_env()
  # warn
  ## changes -> offer to commit
  # rsync from remote, except assets
  local <- normalizePath(project$local)
  local_parent_dir <- sprintf("%s/..", local) |> normalizePath()
  remote <- normalizePath(Sys.getenv(project$remote))
  exclude <- sprintf('--exclude="%s"', basename(read_config()$assets))
  system2(
    "rsync", args = c(
      "-ar", 
      "--delete", 
      "--exclude" = '--exclude "assets"',
      remote, 
      local_parent_dir
    )
  )
}