#' `perma_link_to_console`
#' @export
perma_link_to_console <- function() {
  perma_link <- perma_create_link()
  rstudioapi::executeCommand("activateConsole")
  rstudioapi::sendToConsole(perma_link)
}
#' `perma_open_link`
#' @export
perma_open_link <- function() {

  perma_link <- perma_create_link()
  browseURL(perma_link)

}

perma_create_link <- function() {
  repo_info <- perma_get_remote_info()
  editor_info <- perma_get_editor_info()

  perma_link <- perma_create_link(organization = repo_info$organization,
                                  repository = repo_info$repository,
                                  sha = repo_info$head_sha,
                                  file = editor_info$file,
                                  line = editor_info$lines
  )

  return(perma_link)

}
#' `perma_get_editor_info`
#' @export
perma_get_editor_info <- function() {

  editor_location <- rstudioapi::getSourceEditorContext()

  top_level_project_dir <-
    rstudioapi::getActiveProject() |>
    basename()

  file <- stringr::str_remove(editor_location$path,
                              pattern = paste0("~/",
                                               top_level_project_dir,
                                               "/"))

  lines <- perma_get_document_selection(editor_location = editor_location)

  list(file = file,
       lines = lines)

}
#' `perma_get_document_selection`
#' @param editor_location result of rstudioapi::getSourceEditorContext()
#' @export
perma_get_document_selection <- function(editor_location) {

  selection <- editor_location$selection |>
    unlist() |>
    lapply(\(.x) .x)

  start <- selection$range.start.row
  end <- selection$range.end.row

  if (start == end) {
    return(paste0("L", start))
  }

  paste0("L", start, "-", "L", end)

}
#' `perma_get_head_sha`
#' @export
perma_get_head_sha <- function() {
  last_commit <- git2r::last_commit()
  last_commit[["sha"]]
}
#' `perma_get_org_and_repo`
#' @export
perma_get_org_and_repo <- function() {
  git2r::repository() |>
    git2r::remote_url() |>
    stringr::str_remove_all("git@github.com:") |>
    stringr::str_remove_all(".git") |>
    stringr::str_split("/") |>
    unlist() |>
    setNames(c("organization", "repository"))
}
#' `perma_get_remote_info`
#' @export
perma_get_remote_info <- function() {
  perma_get_org_and_repo() |>
    c(head_sha = perma_get_head_sha()) |>
    lapply(\(.x) .x)
}
#' `perma_create_link`
#' @param organization owner or the repository
#' @param repository repo name
#' @param sha this will usually be the sha of the state rather than the branch
#' @param file particular file name
#' @param host hose name (DEFAULT to https://github.com)
#' @export
perma_create_link <- function(organization,
                              repository,
                              sha,
                              file,
                              line,
                              blob = "blob",
                              host = "https://github.com") {

  stringr::str_glue(
    "{host}/{organization}/{repository}/{blob}/{sha}/{file}#{line}"
  )

}
