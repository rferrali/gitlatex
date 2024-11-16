#' Initialize gitlatex
#' 
#' @description Initializes gitlatex in a new or existing project, by creating the relevant config files and directories.
#' 
#' @param public Path to the public config file (default: `./gitlatex.json`)
#' @param private Path to the private config file (default: `./gitlatex.private.json`)
#' @param assets Path to the assets directory (default: `./assets`)
#' 
#' 
#' @import cli
#' @import jsonlite
#' @import glue
#' @export

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
  if(any(exists[-"assets"])) {
    stop("gitlatex has already been initialized")
  }
  msg <- c(
    "i" = "The following files will be created:",
    "*" = glue::glue("Public config: {public}"),
    "*" = glue::glue("Private config: {private}")
  )
  if(!exists["assets"]) {
    msg <- c(msg, "*" = glue::glue("Assets directory: {assets}"))
  }
  cli::cli_bullets(msg)
  choice <- utils::menu(c("Yes", "No"), title = "Initialize gitlatex?")
  if(choice == 1) {
    cfg <- .CONFIG_EXAMPLE
    cfg$assets <- assets
    jsonlite::write_json(cfg, public, auto_unbox = TRUE, pretty = TRUE)
    jsonlite::write_json(.CONFIG_PRIVATE_EXAMPLE, private, auto_unbox = TRUE, pretty = TRUE)
    if(!exists("assets")) {
      dir.create(assets)
    }
    cli::cli_alert_success("gitlatex initialized")
  } else {
    cli::cli_alert_danger("gitlatex initialization cancelled")
  }
}