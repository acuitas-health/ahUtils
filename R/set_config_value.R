#' set_config_value
#'
#' Sets the values of EXISTING parameters. You have to be careful with this
#' thing, today, because it can only set EXISTING values. But, as long as they
#' exist, you can hack away.
#'
#' There is a preview mode, so you can admire your handiwork.
#'
#' @param parameter Which parameter do you want to set?
#' @param value What value do you want to set?
#' @param configuration Which named configuration from config.yml do you want to
#' use? Must be "default", "prod", or "rsconnect". The default is . . . default.
#' @param preview Do you want to just "see" what it would look like? This is for
#' interactive/testing purposes. Don't use this in a script. Seriously. It won't
#' do anything useful. The default is zero.
#'
#' @return None
#' @export
set_config_value <- function(parameter, value, configuration = "default", preview = FALSE) {
  stopifnot(exprs = {
    !missing(parameter)
    !missing(value)
    file.exists("config.yml")
    configuration %in% c("default", "rsconnect", "all")
  })
  cfg <- yaml::read_yaml("config.yml")
  if (configuration == "default" | configuration == "all") {
    ## if (length(cfg$default[names(cfg$default) == value]) == 0) {
    ##    ## TODO: It would be nice to not have to error out here.
    ##    stop("set_config_value only SETS existing parameters.")
    ## }
    cfg$default[names(cfg$default) == parameter] <- value
  }
  if (configuration == "rsconnect" | configuration == "all") {
    ## if (length(cfg$rsconnect[names(cfg$rsconnect) == value]) == 0) {
    ##    ## TODO: It would be nice to not have to error out here.
    ##    stop("set_config_value only SETS existing parameters.")
    ## }
    cfg$rsconnect[names(cfg$rsconnect) == parameter] <- value
  }
  if (preview) {
    cat(yaml::as.yaml(cfg, indent.mapping.sequence = TRUE))
  } else {
    yaml::write_yaml(cfg, "config.yml", indent.mapping.sequence = TRUE)
  }
} ## END set_config_value
