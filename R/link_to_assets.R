link_to_assets <- function(project, config) {
  project <- load_project(project, config)
  test_project_paths(project, local = TRUE, remote = FALSE)
  assets <- normalizePath(config$assets)
  withr::with_dir(
    project$local, 
    if(file.exists("assets")) {
      warning("This project is already linked to the assets directory. Symlink will not be created.")
    } else {
      file.symlink(assets, "assets")
    }
  )
}