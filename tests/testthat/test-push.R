test_that("push works", {
  init_test()
  withr::local_dir(test_path("tmp"))
  push("article")
  expect_equal(
    list.files("tex/article"), 
    list.files("remote/article"))
})
