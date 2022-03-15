#' read_description
#'
#' Reads in values from the Description file.
#'
#' @param values A vector of the values you want to read from Description
#'
#' @return A list of packages to load via library.
#'
#' @export
read_description <- function(values = NULL) {
  stopifnot(exprs = {
    !is.null(values)
  })
  dscn <- read.dcf(file.path(".", "DESCRIPTION"))
  vals <- intersect(values, colnames(dscn))
  pkgs <- unlist(strsplit(dscn[, vals], ","), use.names = FALSE)
  pgks <- gsub("\\s.*", "", trimws(pkgs))
  pkgs[pkgs != "R"]
} ## END read_description
