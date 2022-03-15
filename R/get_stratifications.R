#' get_stratifications
#'
#' Returns the stratifications for a report.
#'
#' @param data The data the stratifications are hiding in.
#' @param strat_col Which column they are hiding in.
#'
#' @return A vector of the stratifications. If there aren't any, "".
#'
#' @import magrittr
#' @export
get_stratifications <- function(data = NULL, strat_col = NULL) {
  stopifnot(exprs = {
    !is.null(data)
    !is.null(strat_col)
  })
  if (is.na(strat_col)) {
    ""
  } else {
    data %>%
      dplyr::select(dplyr::all_of(strat_col)) %>%
      dplyr::distinct() %>%
      dplyr::arrange(strat_col) %>%
      dplyr::pull()
  }
} ## END get_stratifications

