init <- function() {
  file.copy(list.files("./data", full.names = TRUE), "./", recursive = TRUE)
}