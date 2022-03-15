#' import_data
#'
#' Looks for "file" in "folder". If it exists, it attempts to run the query
#' AFTER running validation.sql if it exists. If validation.sql exists, all rows
#' must return 1 (TRUE) before the report query in "file" will be run. If
#' validation.sql fails, the function will stop for the number of seconds
#' defined in wait_time before trying to rerun validation.sql.
#'
#' @param file The file where the query lives.
#' @param folder The folder where the query lives. If validation.sql is in this
#' folder it will be run BEFORE the sql file.
#' @param verbose If TRUE, this function talks a lot. Useful for debugging
#' connection issues and not much else.
#' @param params A LIST of parameters to alter the query.
#'
#' @return A data frame with your data.
#'
#' @export
import_data <- function(file = "query.sql", folder = "sql", verbose = FALSE, params = NULL) {
  config <- config::get()
  qry_file <- file.path(folder, file)
  connect_rate <- purrr::rate_delay(pause = 30, max_times = 10)
  dbConnectInsistent <- purrr::insistently(DBI::dbConnect, rate = connect_rate)
  dbGetQueryInsistent <- purrr::insistently(DBI::dbGetQuery, rate = connect_rate)
  if (verbose) cat("\n- Connecting as: ", Sys.getenv("edw_user"))
  ## con <- con <- dbConnect(
  ##   odbc::odbc(),
  ##   dsn = config$dsn_name,
  ##   timeout = 20,
  ##   uid = Sys.getenv("edw_user"),
  ##   pwd = Sys.getenv("edw_pass")
  ## )
  con <- dbConnectInsistent(
    odbc::odbc(),
    dsn = config$dsn_name,
    timeout = 20,
    uid = Sys.getenv("edw_user"),
    pwd = Sys.getenv("edw_pass")
  )
  stopifnot(exprs = {
    file.exists(qry_file)
    exists("con")
  })
  
  

  ## ---- query.sql ----
  qry <- readr::read_file(qry_file)
  if (verbose) cat("\n- Downloading data.")
  qry <- readr::read_file(qry_file)
  if (verbose) cat("\n- Downloading data.")
  if (is.null(params)) {
    res <- tibble::as_tibble(DBI::dbGetQuery(con, qry))
  } else {
    res <- tibble::as_tibble(DBI::dbGetQuery(con, qry, params = params))
  }
  if (verbose) {
    cat(paste("N Rows Downloaded:", nrow(res)))
    cat(head(res))
  }
  DBI::dbDisconnect(con)
  res
} ## END import_data

