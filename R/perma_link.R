#' `perma_open_perma_link`
#' @export
perma_open_perma_link <- function() {
  utils::browseURL(perma_get_link())
}
#' `perma_link_to_console`
#' @export
perma_link_to_console <- function() {
  rstudioapi::executeCommand("activateConsole")
  rstudioapi::sendToConsole(perma_get_link(), execute = FALSE)
}
#' `perma_get_link`
#' @export
perma_get_link <- function() {

  perma_assert_addin_requirements()
  repo_info <- perma_get_remote_info()
  editor_info <- perma_get_editor_info()

  perma_create_link(organization = repo_info$organization,
                    repository = repo_info$repository,
                    sha = repo_info$head_sha,
                    file = editor_info$file,
                    line = editor_info$lines)

}
#' `perma_get_editor_info`
#' @export
perma_get_editor_info <- function() {

  top_level_project_dir <-
    rstudioapi::getActiveProject() |>
    basename()

  top_level_project_dir_pattern <-  paste0("~/", top_level_project_dir, "/")

  editor_location <- rstudioapi::getSourceEditorContext()
  file <- stringr::str_remove(editor_location$path,
                              pattern = top_level_project_dir_pattern)

  perma_is_clean_git_state(file_linked = file)

  lines <- perma_get_document_selection(editor_location = editor_location)

  list(file = file, lines = lines)

}
#' `perma_is_clean_git_state`
#' @param file_linked check file linked for uncomitted work or comitted work
#' that is not pushed. This will throw a warning if the file does not match the
#' remote.
#' @export
perma_is_clean_git_state <- function(file_linked = "") {

  status <- git2r::status()

  uncomitted_changes <- list(status$unstaged,
                             status$staged) |>
    unlist()

  if (file_linked %in% uncomitted_changes) { # perhaps this should be an error
    cat(crayon::red("Uncommitted changes affects the accuracy of the link locations"))
    return(FALSE)
  }

  diff <- git2r::diff(git2r::repository(), as_char = TRUE)
  if (diff != "") {
    cat(crayon::red("Discrepancies between local and remote affects links"))
    return(FALSE)
  }

  return(TRUE)

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
    stringr::str_remove("git@github.com:") |>
    tools::file_path_sans_ext() |>
    stringr::str_split("/") |>
    unlist() |>
    stats::setNames(c("organization", "repository"))
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
#' @param line which line number in the file
#' @param blob not sure what this is or does
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
#' `perma_move_to_link` naviage to location
#' @export
perma_move_to_link <- function() {
  rstudioapi::executeCommand("activateConsole")
  link <- readline(prompt = "Enter Perma Link: ")
  perma_link_info <- perma_parse_and_validate_link(link)
  perma_nav_to_git_link_state(perma_link_info)
  perma_navigate_to_link(perma_link_info)
}
#' `perma_nav_to_git_link_state`
#' @param perma_link_info item that contains parsed perma link issues
#' @export
perma_nav_to_git_link_state <- function(perma_link_info) {

  if (!perma_is_clean_git_state()) {
    stop("Uncommitted work locally sync with remote for this to work")
  }

  sha <- perma_link_info$sha
  if (perma_get_head_sha() != sha) {
    git2r::checkout(object = git2r::repository(), branch = sha)
    message("Note Auto Executed `git checkout ", sha, "`")
  }

  perma_navigate_to_link(perma_link_info)

}
#' `perma_parse_and_validate_link`
#' This funicton will crash if we do not have a valid github perma link
#' @param link perma link
#' @param host hose name (DEFAULT to https://github.com)
#' @export
perma_parse_and_validate_link <- function(link, host = "https://github.com/") {

  if (stringr::str_detect(link, host, negate = TRUE)) {
    stop("invalid host")
  }

  link <- stringr::str_remove(link, host)

  link_items <- link |>
    stringr::str_split("/|#") |>
    unlist()

  n_link_attrs <- length(link_items)

  if (n_link_attrs < 5) {
    stop("Insuffecient items to be a valid link")
  }

  n_folders <- n_link_attrs - 6
  link_names <- c("organization", "repository", "blob", "sha")
  if (n_folders > 0) {
    link_names <- c(link_names, paste0("folder", seq(n_folders)))
  }

  link_names <- c(link_names, "file", "line")
  names(link_items) <- link_names
  lapply(link_items, \(.x) .x)
}
#' `perma_navigate_to_link_spot`
#' @param link_items item that contains parsed perma link issues
#' @export
perma_navigate_to_link <- function(link_items) {

  folders <- link_items[stringr::str_starts(names(link_items), "folder")]
  file_in_link <- c(as.character(folders), link_items$file) |>
    paste0(collapse = "/")

  line <- link_items$line |>
    stringr::str_remove_all("L") |>
    stringr::str_split("-") |>
    unlist() |>
    as.numeric() |>
    utils::head(1)

  rstudioapi::navigateToFile(file = file_in_link, line = line)
  rstudioapi::sendToConsole("")

}
#' `perma_assert_addin_requirements`
#' @export
perma_assert_addin_requirements <- function() {

  if (is.null(git2r::discover_repository())) {
    stop("Your project must be in a git repository ",
         "your current dir is currently` ",
         getwd(), "`")
  }

  if (!rstudioapi::isAvailable()) {
    stop("You must be using RStudio for permr to work")
  }

}
