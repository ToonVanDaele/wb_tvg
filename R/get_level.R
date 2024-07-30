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
#' my_level <- get_locs(con = watina, loc_Vec = c("TVGP030", "TVGP023")) %>%
#'                      get_level(con = watina,
#'                                startdate = "01-01-2021",
#'                                enddate = "01-01-2024")
#'
#' @export
#' @importFrom assertthat
#' assert_that
#' is.number
#' is.flag
#' noNA
#' is.date
#' @importFrom rlang .data
#' @importFrom lubridate
#' dmy
#' today
#' day
#' month
#' year
#' @importFrom dplyr
#' %>%
#' copy_to
#' filter
#' left_join
#' inner_join
#' select
#' contains
#' arrange
#' distinct
#' sql
get_level <- function(locs,
                      con,
                      startdate,
                      enddate = paste(day(today()),
                                      month(today()),
                                      year(today())),
                      truncated = TRUE,
                      with_estimated = TRUE,
                      collect = FALSE) {

  assert_that("loc_code" %in% colnames(locs),
              msg = "locs does not have a column name 'loc_code'.")
  assert_that(is.string(startdate),
              is.date(dmy(startdate)))
  assert_that(is.string(enddate),
              is.date(dmy(enddate)))
  assert_that(enddate >= startdate,
              msg = "startdate must not be larger than enddate.")

  assert_that("loc_code" %in% colnames(locs),
              msg = "locs does not have a column name 'loc_code'.")
  assert_that(is.flag(collect), noNA(collect))

  if (inherits(locs, "data.frame")) {
    locs <-
      locs %>%
      distinct("loc_code")

   watina:::require_pkgs("DBI")

    try(DBI::dbRemoveTable(con, "#locs"),
        silent = TRUE)

    locs <-
      copy_to(con,
              locs,
              "#locs2") %>%
      inner_join(tbl(con, "vwDimMeetpunt") %>%
                   select(loc_wid = "MeetpuntWID",
                          loc_code = "MeetpuntCode"),
                 .,
                 by = "loc_code")
  }

  level <-
    tbl(con, "FactPeilMeting") %>%
    select(loc_wid = "MeetpuntWID",
           "TijdWID",
           "PeilmetingCommentaar",
           "Niveau",
           "mTAW",
           "mMaaiveld") %>%
    inner_join(tbl(con, "DimTijd") %>%
                 select("DatumWID",
                        "Datum"),
               by = c("TijdWID" = "DatumWID")) %>%
    inner_join(locs %>%
                 select("loc_wid",
                        "loc_code") %>%
                 distinct,
               .,
               by = "loc_wid") %>%
    mutate(Datum = sql("CAST(Datum AS date)")) %>%
    filter(Datum >= startdate,
           Datum <= enddate) %>%
    select(-c("loc_wid", "TijdWID"))

  if (collect) {
    level <-
      level %>%
      arrange("loc_code",
              "Datum") %>%
      collect
  }
  return(level)
}
