#' import_data
#'
#' Looks for "file" in "folder". If it exists, it attempts to run the query.
#' The user may also pass a query directly to import_data.
#'
#' @param file The file where the query lives.
#' @param folder The folder where the query lives. If validation.sql is in this
#' folder it will be run BEFORE the sql file.
#' @param qry A query to import, without a file.
#' @param verbose If TRUE, this function talks a lot. Useful for debugging
#' connection issues and not much else.
#' @param params A LIST of parameters to alter the query.
#'
#' @return A data frame with your data. If the query doesn't return anything,
#'   you will receive an empty tibble.
#'
#' @export
import_data <- function(file = "query.sql", folder = "sql", qry = NULL, config = NULL,  verbose = FALSE, params = NULL) {
  connect_rate <- purrr::rate_delay(pause = 30, max_times = 10)
  dbGetQueryInsistent <- purrr::insistently(
    DBI::dbGetQuery,
    rate = connect_rate)
  if (verbose) cat("\n- Connecting as: ", Sys.getenv("edw_user"))
  if (is.null(config)) {
    con <- ahUtils::open_con()
  } else {
    con <- ahUtils::open_con(config = config)
  }
  if (is.null(qry)) {
    qry_file <- file.path(folder, file)
    stopifnot(exprs = {
      file.exists(qry_file)
    })
    qry <- readr::read_file(qry_file)
  } else {
    stopifnot(exprs = {
    })
  }
  stopifnot(exprs = {
    exists("con")
    stringr::str_detect(qry, "select")
    stringr::str_detect(qry, "from")
  })
  if (verbose) cat("\n- Downloading data.")
  if (is.null(params)) {
    res <- dbGetQueryInsistent(con, qry)
  } else {
    res <- dbGetQueryInsistent(con, qry, params = params)
  }
  DBI::dbDisconnect(con)
  if (verbose) {
    cat(paste("N Rows Downloaded:", nrow(res)))
    cat(head(res))
  }
  return(tibble::as_tibble(res))  
} ## END import_data
