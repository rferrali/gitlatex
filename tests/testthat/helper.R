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
  file.rename(test_path("tmp", "env"), test_path("tmp", ".env"))
}
# init
# clear()
# init()
# load_project
# init_test()
# identical(load_project("article"), read_config()$projects[[1]])
# push
# init_test()
# push("article")
# pull 
# init_test()
# pull("article")
# init_test()
# create("report")
