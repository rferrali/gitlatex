clear <- function() {
  unlink(test_path("tmp"), recursive = T, force = T)
  dir.create(test_path("tmp"))
}
init_test <- function() {
  clear()
  file.copy(
    from = list.files(test_path("fixtures"), all.files = TRUE, no.. = TRUE, full.names = TRUE), 
    to = test_path("tmp"), 
    recursive = TRUE, 
    overwrite = TRUE
  )
}