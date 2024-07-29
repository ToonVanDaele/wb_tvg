#' Get level data from the database
#'
#' Returns hydrochemical data from the \emph{Watina} database, either as a
#' lazy object or as a local tibble.
#'
#' @param locs A \code{tbl_lazy} object or a dataframe, with at least a column
#' \code{loc_code} that defines the locations for which values are to be
#' returned.
#' Typically, this will be the object returned by \code{\link{get_locs}}.
#' @param startdate First date of the timeframe (string).
#' @param enddate Last date of the timeframe.
#'
#' @return
#' By default, a \code{tbl_lazy} object.
#' With \code{collect = TRUE},
#' a local \code{\link[tibble]{tibble}} is returned.
#'
#' @family functions to query the database
#'
#' @examples
#' \dontrun{
#' watina <- connect_watina()
#' library(dplyr)
#' my_level <- get_level(c("TVGP030", "TVGP023), watina, "1/1/2017")
#' plot(my_level)
#'
