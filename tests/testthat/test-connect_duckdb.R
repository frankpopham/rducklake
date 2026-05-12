test_that("errors if duckdbname is not character", {

  test_obj <- mtcars
  expect_error(connect_duckdb(duckdbname = test_obj))
})
