init <- function() {
  file.copy(
    from = list.files(
      "./data", 
      full.names = TRUE, 
      all.files = TRUE, 
      no.. = TRUE
    ), 
    to = "./", 
    recursive = TRUE, 
    overwrite = TRUE
  )
}