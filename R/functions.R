load_project <- function(project, config) {
  this_project <- config$projects[config$projects$name == project]
  if(nrow(this_project) == 0) {
    stop(sprintf("Project %s not found", project))
  }
  if(nrow(this_project) > 1) {
    stop(sprintf("Multiple projects with name %s", project))
  }
  return(this_project)
}

test_projects <- function(projects) {
  projects$local <- dir.exists(normalizePath(projects$local))
  projects$remote <- dir.exists(normalizePath(projects$remote))
  return(projects)
}

test_project_paths <- function(project_obj, local = TRUE, remote = TRUE) {
  if(local) {
    stopifnot(dir.exists(project_obj$local_normalized))
  }
  if (remote) {
    stopifnot(dir.exists(project_obj$remote_normalized))
  }
}

warn_unstaged <- function() {
  test <- system2("git", c("status", "--porcelain"), stdout = TRUE)
  ok <- length(test) == 0
  if(!ok) {
    warning("There are unstaged changes in the repository")
  }
  return(!ok)
}

warn_not_main <- function() {
  test <- system2("git", c("branch", "--show-current"), stdout = TRUE)
  ok <- test == "main"
  if(!ok) {
    warning("Not on main branch")
  }
  return(!ok)
}

warn_not_up_to_date <- function() {
  system2("git", "fetch")
  local <- system2("git", c("rev-parse", "HEAD"), stdout = TRUE)
  remote <- system2("git", c("rev-parse", "@{u}"), stdout = TRUE)
  ok <- local == remote
  if(!ok) {
    warning("Not up to date with remote")
  }
  return(!ok)
}

filter_files <- function(files, config) {
  assets_dir <- basename(config$assets)
  # ignore assets
  files <- files[!substr(files, 1, nchar(assets_dir)) == assets_dir]
  # ignore latex build files
  files <- files[!grepl(.LATEX_BUILD_FILES, files)]
  return(files)
}

warn_remote_not_in_local <- function(project_obj, config) {
  files_local <- list.files(project_obj$local_normalized, recursive = TRUE)
  files_local <- filter_files(files_local, config)
  files_remote <- list.files(project_obj$remote_normalized, recursive = TRUE)
  files_remote <- filter_files(files_remote, config)
  unmatched_files <- setdiff(files_remote, files_local)
  ok <- length(unmatched_files) == 0
  if(!ok) {
    warning("Some files in remote are not in local")
  }
  return(!ok)
}

warn_remote_more_recent <- function(project_obj, config) {
  files_local <- list.files(project_obj$local_normalized, recursive = TRUE)
  files_local <- filter_files(files_local, config)
  files_remote <- list.files(project_obj$remote_normalized, recursive = TRUE)
  files_remote <- filter_files(files_remote, config)
  matched_files <- intersect(files_remote, files_local)
  matched_files <- data.frame(
    file = matched_files, 
    local = file.path(project_obj$local_normalized, matched_files), 
    remote = file.path(project_obj$remote_normalized, matched_files)
  )
  # files in remote that are more recent
  matched_files <- matched_files[
    file.info(matched_files$remote)$mtime > file.info(matched_files$local)$mtime,
  ]
  # files in remote that are different
  matched_files <- matched_files[
    rlang::hash(matched_files$local) != rlang::hash(matched_files$remote),
  ]
  ok <- nrow(matched_files) == 0
  if(!ok) {
    warning("Some files in remote are more recent than in local")
  }
  return(!ok)
}
