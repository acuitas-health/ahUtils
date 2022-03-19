#' open_con
#'
#' Uses config.yml and ~/.Renviron to open a database connection to the Acuitas
#' EDW. In your .Renviron file you must have the following edw_user and edw_pass
#' defined. In your config.yml file, you must have dsn_name defined for both the
#' default and rsconnect configurations.
#'
#' The function can use any list with a dsn_name variable named. If not, it will
#' open config.yml and find the dsn_name for itself.
#'
#' You an use dbDisconnect with the con object because it is NO different
#' than any other DBI connection object.
#'
#' @param config A configlist. If not provided, the function will open
#'   config.yml itself.
#' 
#' @return A connection object.
#'
#' @export
open_con <- function(config = NULL) {
  if (is.null(config)) {
    config <- config::get()
  }
  stopifnot(exprs = {
    ## Checks for the existence of dsn_name.
    !is.null(config$dsn_name)
    ## Checks for the existence of our system vars.
    Sys.getenv("edw_user") != ""
    Sys.getenv("edw_pass")
  })
  connect_rate <- purrr::rate_delay(pause = 30, max_times = 10)
  dbConnectInsistent <- purrr::insistently(DBI::dbConnect, rate = connect_rate)
  can_connect <-
    DBI::dbCanConnect(
      odbc::odbc(),
      dsn = config$dsn_name,
      uid = Sys.getenv("edw_user"),
      pwd = Sys.getenv("edw_pass"))
  if (can_connect) {
    dbConnectInsistent(
      odbc::odbc(),
      dsn = config$dsn_name,
      timeout = 20,
      uid = Sys.getenv("edw_user"),
      pwd = Sys.getenv("edw_pass"))
  } else {
    cannot_ping <- max(is.na(pingr::ping("acny.hosted"))) == 1
    if (cannot_ping) {
      msg <- paste(
        " **** Unable to ping acny.hosted. Are you connected to the VPN? ****",
        attr(can_connect, "reason"),
        sep = "\n\n")
      stop(msg)
    } else {
      msg <- paste(
        " **** I can ping acny.hosted, but I cannot connect . . . .  ****",
        attr(can_connect, "reason"),
        sep = "\n\n")
      stop(msg)
    }
  }    
}
