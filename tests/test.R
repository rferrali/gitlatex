load_all()
clear <- function() {
  unlink(list.files("./data", all.files = T, no.. = T), recursive = T, force = T)
}
init_test <- function() {
  clear()
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
# init
clear()
init()
# load_project
init_test()
identical(load_project("article"), read_config()$projects[[1]])
# push
init_test()
push("article")
# pull 
init_test()
pull("article")
