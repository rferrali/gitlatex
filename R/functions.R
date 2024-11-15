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

test_project_paths <- function(project, local = TRUE, remote = TRUE) {
  if(local) {
    stopifnot(dir.exists(project$local_normalized))
  }
  if (remote) {
    stopifnot(dir.exists(project$remote_normalized))
  }
}