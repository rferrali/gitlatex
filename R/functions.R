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

test_projects <- function(projects, error = TRUE, local = TRUE, remote = TRUE) {
  if(local) {
    projects$local <- dir.exists(normalizePath(projects$local))
  } else {
    projects$local <- rep(TRUE, nrow(projects))
  }
  if(remote) {
    projects$remote <- dir.exists(normalizePath(projects$remote))
  } else {
    projects$remote <- rep(TRUE, nrow(projects))
  }
  ok <- all(projects$local & projects$remote)
  if(!ok) {
    projects <- projects[!(projects$local & projects$remote),]
    msg <- "Some projects have paths that do not exist"
    for(i in 1:nrow(projects)) {
      if((!projects$local[i]) & (!projects$remote[i])) {
        mini <- "local and remote do not exist"
      } else if(!projects$local[i]) {
        mini <- "local does not exist"
      } else if (!projects$remote[i]) {
        mini <- "remote does not exist"
      }
      msg <- c(
        msg, 
        glue::glue("{test$name[i]}: {mini}")
      )
    }
    if(error) {
      cli::cli_abort(msg)
    } else {
      cli::cli_warn(msg)
    }
  }
}

load_projects <- function(projects, config) {
  if(is.null(projects)) {
    projects <- config$projects
  } else {
    ok <- !all(projects %in% config$projects$name)
    if(!ok) {
      msg <- paste(projects[!(projects %in% config$projects$name)], sep = ", ")
      cli::cli_abort(glue::glue("Project(s) {msg} not configured"))
    }
    projects <- config$projects[config$projects$name %in% projects,]
  }
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

is_committed <- function() {
  test <- system2("git", c("status", "--porcelain"), stdout = TRUE)
  ok <- length(test) == 0
  return(ok)
}

is_main <- function() {
  test <- system2("git", c("branch", "--show-current"), stdout = TRUE)
  ok <- test == "main"
  return(ok)
}

is_up_to_date <- function() {
  system2("git", "fetch")
  local <- system2("git", c("rev-parse", "HEAD"), stdout = TRUE)
  remote <- system2("git", c("rev-parse", "@{u}"), stdout = TRUE)
  ok <- local == remote
  return(ok)
}

filter_files <- function(files, assets) {
  assets_dir <- basename(assets)
  # ignore assets
  files <- files[!substr(files, 1, nchar(assets_dir)) == assets_dir]
  # ignore latex build files
  files <- files[!grepl(.LATEX_BUILD_FILES, files)]
  return(files)
}

is_remote_in_local <- function(projects, assets) {
  out <- c()
  for (i in 1:nrow(projects)) {
    project_obj <- projects[i,]
    files_local <- list.files(project_obj$local_normalized, recursive = TRUE)
    files_local <- filter_files(files_local, assets)
    files_remote <- list.files(project_obj$remote_normalized, recursive = TRUE)
    files_remote <- filter_files(files_remote, assets)
    unmatched_files <- setdiff(files_remote, files_local)
    if(length(unmatched_files) > 0) {
      out <- c(out, "*" = glue::glue("Project {project_obj$name}: "), unmatched_files)
    }
  }
  ok <- length(out) == 0
  if(!ok) {
    out <- c("Some files in remote are not in local", out)
  }
  attr(ok, "message") <- out
  return(ok)
}

is_remote_less_recent <- function(projects, assets) {
  out <- c()
  for (i in 1:nrow(projects)) {
    project_obj <- projects[i,]
    files_local <- list.files(project_obj$local_normalized, recursive = TRUE)
    files_local <- filter_files(files_local, assets)
    files_remote <- list.files(project_obj$remote_normalized, recursive = TRUE)
    files_remote <- filter_files(files_remote, assets)
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
    if(nrow(matched_files) > 0) {
      out <- c(out, "*" = glue::glue("Project {project_obj$name}: "), matched_files$file)
    }
  }
  ok <- length(out) == 0
  if(!ok) {
    out <- c("Some files in remote are more recent than in local", out)
  }
  attr(ok, "message") <- out
  return(ok)
}

interactive_errors <- function(success, implement, message, confirmation) {
  if(!success) {
    if(!implement) {
      cli::cli_warn(message)
    } else {
      if(!interactive()) {
        cli::cli_abort(message)
      } else {
        cli::cli_alert_warning(message)
        choice <- utils::menu(c("Yes", "No"), title = confirmation)
        if(choice != 1) {
          cli::cli_abort("Aborted by user")
        }
      }
    }
  }
}