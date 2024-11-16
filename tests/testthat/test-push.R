test_that("push works", {
  init_test()
  withr::local_dir(test_path("tmp"))
  config <- read_config("./gitlatex.json", "./gitlatex.private.json")
  push(config, main = FALSE, latest = FALSE, in_local = FALSE, more_recent = FALSE, git = FALSE)
  expect_equal(
    sort(c("assets", list.files("tex/article"))), 
    sort(list.files("remote/article")))
})
