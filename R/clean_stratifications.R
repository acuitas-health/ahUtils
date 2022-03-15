#' clean_stratifications
#'
#' Removes things like /, \, :, ", ', <, > which would be invalid file names.
#' All such values are replaced with -, which is OK in a file name.
#'
#' @param s A vector of stratifications
#'
#' @return A vector of cleaned stratifications.
#'
#' @export
clean_stratifications <- function(s) {
  stopifnot(exprs = {
    !missing(s)
  })
  ## TODO Add missing Windows special characters: * ? |
  s <- stringr::str_replace(s, "/", "-")
  s <- stringr::str_replace(s, "\\\\", "-")
  s <- stringr::str_replace(s, ":", "-")
  s <- stringr::str_replace(s, '"', "-")
  s <- stringr::str_replace(s, "'", "-")
  s <- stringr::str_replace(s, "<", "-")
  s <- stringr::str_replace(s, ">", "-")
  s
} ## END clean_stratifications

