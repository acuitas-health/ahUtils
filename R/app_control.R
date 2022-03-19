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
app_control <- function(config = NULL) {
  ## 
  if (is.null(config)) {
    config <- config::get()
  }
  stopifnot({
    !is.null(config$application)
  })
  run_flag <<- FALSE
  email_flag <<- FALSE
  qry <- "select * from IDEA.AppControl1.AppControl1 where AppNM = ?"
  app_control <-
    ahUtils::import_data(
      config = config,
      qry = qry,
      params = list(config$application))
  app_control_today <-
    app_control %>%
    filter(
    (today() >= StartDTS & today() <= EndDTS) |
      (is.na(StartDTS) & today() <= EndDTS) |
      (is.na(EndDTS) & today() >= StartDTS)
    )
  app_control_any_day <-
    app_control %>%
    filter(is.na(StartDTS), is.na(EndDTS))
  if (nrow(app_control_today) > 0) {
    run_flag <<- as.logical(min(app_control_today$RunFLG, na.rm = TRUE))
    email_flag <<- as.logical(min(app_control_today$MailFLG, na.rm = TRUE))
    app_control_today %>% kable()
  } else {
    run_flag <<- as.logical(min(app_control_any_day$RunFLG, na.rm = FALSE))
    email_flag <<- as.logical(min(app_control_any_day$MailFLG, na.rm = FALSE))
    app_control_any_day %>% kable()
    msg <- "Report not run because no entry created in App Control 1."
    warning(msg)
    cat(msg)
  }
} ## END app_control
