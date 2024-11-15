#' Create symlinks to the assets directory
#' 
#' @description Creates symlinks to the assets directory in each project local directory
#' 
#' @param config The config object, should be read using [read_config()]
#' @param projects A character vector of project names. If `NULL`, all projects will be linked.
#' 
#' @import withr
#' @export

link_to_assets <- function(config, projects = NULL) {
  projects <- load_projects(projects, config)
  cli::cli_inform(glue::glue("Making symlinks for {nrow(projects)} project(s)"))
  # error if some paths are misspecified
  test <- test_projects(projects, local = TRUE, remote = FALSE, error = TRUE)
  assets <- normalizePath(config$assets)
  for(i in 1:nrow(projects)) {
    project <- projects[i,]
    cli::cli_inform(glue::glue("Linking {project$name}..."))
    withr::with_dir(
      project$local, 
      if(file.exists("assets")) {
        cli::cli_inform("This project is already linked to the assets directory. Symlink will not be created.")
      } else {
        file.symlink(assets, "assets")
      }
    )
  }
}