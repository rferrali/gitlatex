link_to_assets <- function(project, config) {
  project <- load_project(project, config)
  test_project_paths(project, local = TRUE, remote = FALSE)
  assets <- normalizePath(config$assets)
  withr::with_dir(
    project$local, 
    if(!file.exists("assets")) {
      file.symlink(assets, "assets")
    }
  )
}