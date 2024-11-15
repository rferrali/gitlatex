test_that("link_to_assets works", {
  init_test()
  withr::local_dir(test_path("tmp"))
  config <- read_config("./gitlatex.json", "./gitlatex.private.json")
  link_to_assets(config)
  expect_true(file.exists("./tex/article/assets"))
})
