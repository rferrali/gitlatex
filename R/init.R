init <- function(
  public = "./gitlatex.json", 
  private = "./gitlatex.private.json", 
  assets = "./assets"
) {
  if(!interactive()) {
    stop("gitlatex must be initialized interactively")
  }
  # error on prior existence
  exists <- c(
    "public" = file.exists(public),
    "private" = file.exists(private),
    "assets" = dir.exists(assets)

  )
  if(any(exists)) {
    stop("gitlatex has already been initialized")
  }
  cli::cli_inform(c(
    "The following files will be created:",
    "*" = glue::glue("Public config: {public}"),
    "*" = glue::glue("Private config: {private}"),
    "*" = glue::glue("Assets directory: {assets}")
  ))
  choice <- menu(c("Yes", "No"), title = "Initialize gitlatex?")
  if(choice == 1) {
    cfg <- .CONFIG_EXAMPLE
    cfg$assets <- assets
    jsonlite::write_json(cfg, public, auto_unbox = TRUE, pretty = TRUE)
    jsonlite::write_json(.CONFIG_PRIVATE_EXAMPLE, private, auto_unbox = TRUE, pretty = TRUE)
    dir.create(assets)
    cli::cli_alert_success("gitlatex initialized")
  } else {
    cli::cli_alert_danger("gitlatex initialization cancelled")
  }
}