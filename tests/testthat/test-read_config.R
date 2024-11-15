test_that("read_config works", {
  init_test()
  config <- withr::with_dir(
    test_path("tmp"),
    read_config(
      public = "./gitlatex.json",
      private = "./gitlatex.private.json"
    )
  )
  expect_no_error(config)
})
