test_that("pull works", {
  init_test()
  withr::local_dir(test_path("tmp"))
  config <- read_config("./gitlatex.json", "./gitlatex.private.json")
  pull("article", config)
  expect_equal(
    sort(c("assets", list.files("tex/article"))), 
    sort(list.files("remote/article")))
})
