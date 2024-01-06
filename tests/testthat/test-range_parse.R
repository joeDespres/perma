test_that("link works", {


  perma_link <- perma_create_link(organization = "joe",
                                  repository = "permr",
                                  sha = "main",
                                  file = "R/perma_link.R",
                                  line = "L23"
  )

  expect_equal(perma_link, "https://github.com/joe/permr/blob/main/R/perma_link.R#L23")


})
