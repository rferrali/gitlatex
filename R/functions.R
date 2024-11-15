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

