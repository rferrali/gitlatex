create <- function(name, remote = NULL, local = NULL) {
  # errors
  ## name exists
  # TODO
  ### default remote is remote_default/name
  if(is.null(remote)) {
    remote <- file.path(read_config()$remote_default, name)
  }
  ## error if remote doesn't exist
  stopifnot(dir.exists(remote))
  ### default local is local_default/name
  if(is.null(local)) {
    local <- file.path(read_config()$local_default, name)
  }
  # create local if local doesn't exist
  if(!dir.exists(local)) {
    # create local dir
    dir.create(local)
  }
  # create symlinks to assets if missing
  # symlink assets
  wd <- getwd()
  assets <- normalizePath(read_config()$assets)
  withr::with_dir(
    local, 
    if(!file.exists("assets")) {
      file.symlink(assets, "assets")
    }
  )
  # add remote to .env
  cat(sprintf('GITLATEX_PROJECT_%s="%s"\n', name, remote), file = ".env", append = TRUE)
  # add project to lockfile
  lockfile <- jsonlite::read_json("./gitlatex.lock")
  lockfile$projects[[length(lockfile$projects)+1]] <- list(
    name = name,
    local = local
  )
  lockfile <- jsonlite::toJSON(lockfile, pretty = TRUE, auto_unbox = TRUE)
  write(lockfile, "./gitlatex.lock")
}