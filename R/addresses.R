#' addresses
#'
#' Separates addresses. This function is deprecated and will be removed in a
#' future release.
#'
#' @param x A vector of email addresses.
#'
#' @return A cleaned up set of addresses.
#'
#' @export
addresses <- function(x) {
  if (x == "") {
    NULL
  } else if (is.null(x)) {
    NULL
  } else if (is.na(x)) {
    NULL
  } else {
    stringr::str_trim(unlist(stringr::str_split(x, ",")))
  }
  ## TODO: Might be nice to add some cleaning here.
} ## END address

