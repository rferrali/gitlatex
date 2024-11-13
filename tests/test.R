load_all()
clear <- function() {
  unlink(list.files("./data", all.files = T, no.. = T), recursive = T, force = T)
}
# load_project
clear()
init()
identical(load_project("article"), read_config()$projects[[1]])
# push
clear()
init()
push("article")
# pull 
clear()
init()
pull("article")
