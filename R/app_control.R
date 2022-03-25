#' app_control
#'
#' To run or not to run. That 'tis the question. Based on the IDEA app, App
#' Control 1. This is a "naughty" fuction. It exists for the side-effects. Used
#' to enable/disable code chunks and specific parts of the code.
#'
#' @param config A list of config settings. If NULL, the function will open
#'   config.yml for you.
#'
#' @return Sets the global variables run_flag and email_flag. These control if things run or not and allows staff to disable reports from App Control 1.
#' 
#' @export
#' 
app_control <- function(config = NULL, permissive = FALSE) {
  if (is.null(config)) {
    config <- config::get()
  }
  stopifnot({
    !is.null(config$application)
  })
  run_flag <<- FALSE
  email_flag <<- FALSE
  ## There is no App Control 1 on Dev, so we have to force Prod, not matter
  ## what the config.yml says.
  config$dsn_name <- stringr::str_replace(config$dsn_name, "dev", "prod")
  if (is.null(config$server)) {
    qry <- "select * from IDEA.AppControl1.AppControl1 where AppNM like ?"
    app_control_1 <-
      import_data(
        config = config,
        qry = qry,
        params = list(config$application))
  } else {
    qry <- "select * from IDEA.AppControl1.AppControl1 where ServerNM like ? and AppNM like ?"
    app_control_1 <-
      import_data(
        config = config,
        qry = qry,
        params = list(config$server, config$application))
  }
  app_control_today <-
    app_control_1 %>%
    dplyr::filter(
    (lubridate::today() >= StartDTS & lubridate::today() <= EndDTS) |
      (is.na(StartDTS) & lubridate::today() <= EndDTS) |
      (is.na(EndDTS) & lubridate::today() >= StartDTS))
  app_control_any_day <-
    app_control_1 %>%
    dplyr::filter(is.na(StartDTS), is.na(EndDTS))
  if (nrow(app_control_today) > 0) {
    run_flag <<- as.logical(min(app_control_today$RunFLG, na.rm = TRUE))
    email_flag <<- as.logical(min(app_control_today$MailFLG, na.rm = TRUE))
    app_control_today
  } else if (nrow(app_control_any_day) > 0) {
    run_flag <<- as.logical(min(app_control_any_day$RunFLG, na.rm = FALSE))
    email_flag <<- as.logical(min(app_control_any_day$MailFLG, na.rm = FALSE))
    app_control_any_day
  } else if (permissive) {
    msg <- "No entry created in App Control 1."
    warning(msg)
    cat(msg)
    run_flag <<- TRUE
    email_flag <<- TRUE
    app_control_1
  } else {
    msg <- "Report not run because no entry created in App Control 1."
    warning(msg)
    cat(msg)
    run_flag <<- FALSE
    email_flag <<- FALSE
    app_control_1
  }
} ## END app_control
