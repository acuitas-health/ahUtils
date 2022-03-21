#' validate_config
#'
#' Validates the config.yml in the project repo.
#'
#' @param file The config.yml file you want to validate. You can specify any
#' file, but it defaults to ./config.yml.
#'
#' @return Returns TRUE if no problems are found. Otherwise, it will stop things
#'   and throw an error. This function exists for the side effects.
#' 
#' @export
validate_config <- function(file = "./config.yml") {
  msg <- "\n"
  cfg <- yaml::read_yaml(file)
  stopifnot({
    c(cfg$default$strat_col %in% c("Site", "Subset", "Organization"), is.null(cfg$default$strat_col))[1]
  })
  cfg_default <- cfg$default == "TODO"
  cfg_rsconnect <- cfg$rsconnect == "TODO"
  ## Return values.
  if (max(cfg_default) == TRUE) {
    wrn <- "Config \"default\" incomplete. Replace TODO entries."
    warning(wrn)
    if (config::is_active("rsconnect")) msg <- paste(msg, "\n- ", wrn)
    rm(wrn)
  }
  if (max(cfg_rsconnect) == TRUE) {
    wrn <- "Config \"rsconnect\" incomplete. Replace TODO entries."
    warning(msg, wrn)
    if (config::is_active("rsconnect")) msg <- paste(msg, "\n- ", wrn)
    rm(wrn)
  }
  if (length(msg) == 0) msg <- "\n- No errors found in config."
  return(msg)
} ## END validate_config

