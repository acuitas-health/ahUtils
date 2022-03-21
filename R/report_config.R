#' report_config
#'
#' Uses the values in config.yml to provide report status information.
#'
#' @param config A configlist. If not provided, the function will open
#'   config.yml itself.
#'
#' @return A tibble which is ready to be dropped into a report.
#'
#' @export
#'
report_config <- function(config = NULL, report_todo = FALSE) {
  if (is.null(config)) {
    config <- config::get()
  }
  rc <- tibble(Config = character(), Details = character())
  if (!report_todo) {
    ## Only report things which exist and aren't left as TODO.
    ## This is for report.Rmd.
    if (!is.null(config$report_name)) {
      if (config$report_name != "TODO") {
        rc <-
          rc |>
          add_row(Config = "Report Name:", Details = config$report_name)
      }
    }
    if (!is.null(config$report_author)) {
      if (config$report_author != "TODO") {
        rc <-
          rc |>
          add_row(Config = "Report Author:", Details = config$report_author)
      }
    }
    if (!is.null(config$requested_by)) {
      if (config$requested_by != "TODO") {
        rc <-
          rc |>
          add_row(Config = "Requested By:", Details = config$requested_by)
      }
    }
    if (!is.null(config$wrike_task)) {
      if (config$wrike_task != "TODO") {
        rc <-
          rc |>
          add_row(Config = "Wrike Task:", Details = config$wrike_task)
      }
    }
    if (!is.null(config$gitlab_repo)) {
      if (config$gitlab_repo != "TODO") {
        rc <-
          rc |>
          add_row(Config = "Gitlab Repo:", Details = config$gitlab_repo)
      }
    }
    if (!is.null(config$application)) {
      if (config$application != "TODO") {
        rc <-
          rc |>
          add_row(Config = "Application Name:", Details = config$application)
      }
    }
    if (!is.null(config$strat_col)) {
      if (config$strat_col != "TODO") {
        rc <-
          rc |>
          add_row(Config = "Stratified By:", Details = config$strat_col)
      }
    }
    if (!is.null(config$dsn_name)) {
      if (config$dsn_name != "TODO") {
        rc <-
          rc |>
          add_row(Config = "Data Source:", Details = config$dsn_name)
      }
    }
  } else {
    ## Report things marked TODO. This is for config.Rmd.
    if (!is.null(config$report_name)) {
      rc <-
        rc |>
        add_row(Config = "Report Name:", Details = config$report_name)
    }
    if (!is.null(config$report_author)) {
      rc <-
        rc |>
        add_row(Config = "Report Author:", Details = config$report_author)
    }
    if (!is.null(config$requested_by)) {
      rc <-
        rc |>
        add_row(Config = "Requested By:", Details = config$requested_by)
    }
    if (!is.null(config$wrike_task)) {
      rc <-
        rc |>
        add_row(Config = "Wrike Task:", Details = config$wrike_task)
    }
    if (!is.null(config$gitlab_repo)) {
      rc <-
        rc |>
        add_row(Config = "Gitlab Repo:", Details = config$gitlab_repo)
    }
    if (!is.null(config$application)) {
      rc <-
        rc |>
        add_row(Config = "Application Name:", Details = config$application)
    }
    if (!is.null(config$strat_col)) {
      rc <-
        rc |>
        add_row(Config = "Stratified By:", Details = config$strat_col)
    }
    if (!is.null(config$dsn_name)) {
      rc <-
        rc |>
        add_row(Config = "Data Source:", Details = config$dsn_name)
    }
  }
  rc |>
    knitr::kable(format = "markdown")
} ## END report_config
