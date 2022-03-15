#' open_con
#'
#' Uses config.yml and ~/.Renviron to open a database connection to the Acuitas
#' EDW. In your .Renviron file you must have the following edw_user and edw_pass
#' defined. In your config.yml file, you must have dsn_name defined for both the
#' default and rsconnect configurations.
#'
#' Because this function uses config.yml and .Renviron, there are NO input
#' parameters to this function.
#'
#' @return A connection object.
#' @export
open_con <- function() {
  config <- config::get()
  connect_rate <- purrr::rate_delay(pause = 30, max_times = 10)
  dbConnectInsistent <- purrr::insistently(DBI::dbConnect, rate = connect_rate)
  ## con <- dbConnect(
  ##   odbc::odbc(),
  ##   dsn = config$dsn_name,
  ##   timeout = 20,
  ##   uid = Sys.getenv("edw_user"),
  ##   pwd = Sys.getenv("edw_pass"))
  dbConnectInsistent(
    odbc::odbc(),
    dsn = config$dsn_name,
    timeout = 20,
    uid = Sys.getenv("edw_user"),
    pwd = Sys.getenv("edw_pass"))
}
