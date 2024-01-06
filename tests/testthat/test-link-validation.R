test_that("link parsing", {

  link <- "https://github.com/joe/permr/blob/main/R/perma_link.R#L23"
  link_components <- perma_parse_and_validate_link(link)

  vec_names <- c("organization",
                 "repository",
                 "blob",
                 "sha",
                 "folder1",
                 "file",
                 "line")

  expect_equal(vec_names, names(link_components))

  components <- c("joe", "permr", "blob", "main", "R", "perma_link.R", "L23")
  expect_equal(as.character(unlist(link_components)), components)

  link <- "https://github.com/joe/permr/blob/main/perma_link.R#L23"
  link_components <- perma_parse_and_validate_link(link)
  vec_names <- c("organization", "repository", "blob", "sha", "file", "line")
  expect_equal(vec_names, names(link_components))
  components <- c("joe", "permr", "blob", "main", "perma_link.R", "L23")
  expect_equal(as.character(link_components), components)

  link <- "https://github.com/joe/permr/blob/main/R/a/b/c/perma_link.R#L23"
  link_components <- perma_parse_and_validate_link(link)

  vec_names <- c("organization",
                 "repository",
                 "blob",
                 "sha",
                 "folder1",
                 "folder2",
                 "folder3",
                 "folder4",
                 "file",
                 "line")

  expect_equal(vec_names, names(link_components))

  components <- c("joe",
                  "permr",
                  "blob",
                  "main",
                  "R",
                  "a",
                  "b",
                  "c",
                  "perma_link.R",
                  "L23")
  expect_equal(as.character(link_components), components)


  link <- paste0("https://github.com/joeDespres/permr/blob/",
                 "f137d80918c6ddaf79bda74e49069afc6882becd/",
                 "R/perma_link.R#L8-L16")
  link_info <- perma_parse_and_validate_link(link)
  expect_equal(link_info$organization, "joeDespres")
  expect_equal(link_info$repository, "permr")
  expect_equal(link_info$line, "L8-L16")

  link_items <- perma_parse_and_validate_link(link)
})

test_that("validation works", {
  expect_error(perma_parse_and_validate_link(""))
  expect_error(perma_parse_and_validate_link("hey/this/not/link"))
  expect_error(perma_parse_and_validate_link("hey/this/not/link.R"))
  "https://github.com/hey/this/not/link.R" |>
    perma_parse_and_validate_link() |>
    expect_error()
})
