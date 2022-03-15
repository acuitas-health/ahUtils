#' extract_urls
#'
#' Extract URLs from a string.
#'
#' @param text The text string you want to extract URLs from.
#'
#' @return A vector of URLs from the text.
#'
#' @export
extract_urls <- function(text = NULL) {
  stopifnot({
    !is.null(text)
  })
  url_patterns <- c(
    "http[s]?://(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\\(\\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+",
    "www.(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\\(\\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+"
  )
  urls <- unlist(stringr::str_extract_all(text, url_patterns))
  urls <- stringr::str_replace(urls, "https://", "")
  urls <- stringr::str_replace(urls, "http://", "")
  urls <- unique(urls)
  urls
} ## END extract_urls

