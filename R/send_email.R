#' send_email
#'
#' Sends the recipients in config.yml an email.
#' They get their report. We get paid. Everyone wins.
#' When run with the prod or rsconnect configs, it logs the sent email data to
#' the EDW (dev and prod).
#'
#' @param emails_to_send A table of emails to send.
#'
#' @return Returns emails sent status for each record in emails_to_send
#'
#' @export
send_email <- function(emails_to_send = NULL) {
  stopifnot(exprs = {
    file.exists("config.yml")
    !is.null(emails_to_send)
    ## TODO: Test to see if the user has defined smtp_pass, smtp_from,
    ## smtp_user, smtp_prov in .Renviron
    ## And if not, do something that the user can understand.
  })
  config <- config::get()
  smtp_send_possibly <- purrr::possibly(
    blastula::smtp_send,
    otherwise = FALSE,
    quiet = FALSE
  )
  connect_rate <- purrr::rate_delay(pause = 30, max_times = 10)
  dbConnectInsistent <- purrr::insistently(DBI::dbConnect, rate = connect_rate)
  dbWriteTableInsistent <- purrr::insistently(DBI::dbWriteTable, rate = connect_rate)
  greeting <- dplyr::if_else(
    lubridate::am(lubridate::now(tzone = "America/New_York")),
    "Good Morning",
    "Good Afternoon"
  )
  emails_to_send$report <- config$report_name
  emails_to_send$report_description <- config$report_description
  emails_to_send$customer <- config$customer
  emails_to_send$sent <- FALSE
  emails_to_send <-
    emails_to_send %>%
    dplyr::mutate("date_sent" = lubridate::today()) %>%
    dplyr::rename(
      to = Email,
      app = App,
      subset = Subset,
      site = Site,
      organization = Organization
    ) %>%
    dplyr::group_by(app, subset, site, organization, stratification, created_dt, report, report_description, report_name, customer, sent, date_sent) %>%
    dplyr::summarize(to = paste(iconv(to, to = "ASCII"), collapse = ", ")) %>%
    ungroup() %>%
    dplyr::select(
      "date_sent",
      "customer",
      "report",
      "report_description",
      "stratification",
      "to",
      "report_name",
      "created_dt",
      "sent"
    )
  for (i in 1:nrow(emails_to_send)) {
    if (i > config$number_reports_to_send) break()
    if (emails_to_send$stratification[i] == "") {
      cat("\n\n- Sending (one) email.")
    } else {
      cat("\n\n- Sending email:", emails_to_send$stratification[i])
    }
    email_to_send <-
      blastula::render_email(
        input = "email.Rmd",
        envir = knitr::knit_global()
      ) %>%
      blastula::add_attachment(file = emails_to_send$report_name[i])
    email_sent <- FALSE
    try <- 1
    while (email_sent == FALSE & try <= 3) {
      email_sent <- smtp_send_possibly(
        email_to_send,
        to = addresses(emails_to_send$to[i]),
        from = Sys.getenv("smtp_user"),
        subject = config$report_name,
        ## cc = addresses(emails_to_send$cc[i]),
        ## bcc = addresses(emails_to_send$bcc[i]),
        credentials = blastula::creds_envvar(
          user = Sys.getenv("smtp_user"),
          pass_envvar = "smtp_pass",
          provider = "gmail"
        )
      )
      if (is.null(email_sent)) {
        email_sent <- TRUE
        emails_to_send$sent[i] <- TRUE
      } else if (email_sent == FALSE) {
        cat("\n    - Email failed to send on try ", try, ". Trying again.")
      } else {
        cat("\n    - Email failed to send on try ", try, ". Trying again.")
      }
      try <- try + 1
      ## I remember Steven saying he had to add something like this or he
      ## had problems with gmail bouncing his emails.
      Sys.sleep(1)
    }
    if (try > 3) {
      msg <- paste0(
        "\n    - Unable to send ",
        emails_to_send$stratification[i],
        " email."
      )
      cat(msg)
      if (config::is_active("rsconnect")) {
        httr::POST(
          url = config$slack_webhook_url,
          body = list(text = msg),
          encode = "json"
        )
      }
    }
  }
  cat("\n- All done sending email.")
  if (config::is_active("rsconnect")) {
    to_upload <-
      dplyr::bind_rows(
        emails_to_send %>%
          ## dplyr::select(-"cc", -"bcc") %>%
          dplyr::mutate("to" = str_split(to, ",")) %>%
          tidyr::unnest(cols = c("to")),
        ## emails_to_send %>%
        ##    dplyr::select(-"to", -"bcc") %>%
        ##    dplyr::mutate("cc" = str_split(cc, ",")) %>%
        ##    tidyr::unnest(cols = c("cc")),
        ## emails_to_send %>%
        ##    dplyr::select(-"cc", -"to") %>%
        ##    dplyr::mutate("bcc" = str_split(bcc, ",")) %>%
        ##    tidyr::unnest(cols = c("bcc"))
      ) %>%
      dplyr::filter(!is.na(to)) %>%
      dplyr::mutate(
        sent = as.integer(sent)
      ) %>%
      dplyr::select(
        "date_sent",
        "customer",
        "report",
        "report_description",
        "stratification",
        "report_name",
        "recipient" = to,
        "created_dt",
        "sent"
      )
    tryCatch(
      {
        con <- dbConnectInsistent(
          odbc::odbc(),
          dsn = config$dsn_name,
          database = "AHDSSandbox",
          uid = Sys.getenv("edw_user"),
          pwd = Sys.getenv("edw_pass")
        )
        dbWriteTableInsistent(
          con,
          "ReportsEmailLog",
          to_upload,
          append = TRUE,
          overwrite = FALSE,
          batch_rows = nrow(to_upload)
        )
      },
      error = function(err) {
          paste0("Unable to log emails sent. ", as.character(err))
      }
    )
  }
  return({
    emails_to_send %>%
      dplyr::select(
        "stratification",
        "to",
        ## "cc",
        ## "bcc",
        "report_name",
        "created_dt",
        "sent"
      )
  })
} ## END send_email
