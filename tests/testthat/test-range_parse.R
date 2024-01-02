test_that("multiplication works", {

  document_range <- rstudioapi::document_range(start = c(2, 0), end = c(5, 0))
  rstudioapi::setSelectionRanges(document_range)
  start_position <- document_range$start[["row"]]
  expect_equal(start_position, 2)
  end_position <- document_range$end[["row"]]
  expect_equal(end_position, 5)

})
