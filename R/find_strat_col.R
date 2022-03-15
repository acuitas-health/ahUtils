#' find_strat_col
#'
#' From a data frame/tibble, find the column labeled "Stratification".
#' This is the column we will use to stratify the reports by.
#' If there isn't a stratification column, find_strat_col returns NA.
#'
#' @param data The data frame to search through.
#' @param col_name The column name value of the stratification column. This can
#' be set in config.yaml.
#'
#' @return This function will return either a number or NA if it cannot locate a
#' stratification column.
#'
#' @export
find_strat_col <- function(data = NULL) {
  config <- config::get()
  col_name <- config$strat_col
  if (is.null(data)) {
    return(NULL)
  }
  if (is_null(col_name)) {
    warning("There is no stratification (strat_col) set in config.yaml.")
    return(NA)
  }
  if (!col_name %in% names(data)) {
    stop(
      "There is no stratification column in 'data'.\n",
      "  Missing: ",
      col_name
    )
    strat_col <- NA
  } else {
    strat_col <- which(stringr::str_detect(col_name, names(data)))
    if (length(strat_col) > 1) {
      stop("Cannot have more than one 'Stratification' column.")
    }
  }
  strat_col
} ## END find_strat_col

