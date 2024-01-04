perma_link <- function() {
  a <- rstudioapi::getSourceEditorContext()
  a
  rstudioapi::insertText("hi mom")
}

perma_return_link <- function(perma_link) {

  rstudioapi::navigateToFile(file = ".",
                             line = 0,
                             column = 0,
                             moveCursor = TRUE)

}
