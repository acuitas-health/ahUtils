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
#' You an use dbDisconnect with this returned object because it is NO different
#' than any other DBI connection object.
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
