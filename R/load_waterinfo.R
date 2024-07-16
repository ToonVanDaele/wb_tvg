# Load from waterinfo

library(tidyverse)
library(wateRinfo)


# Vosselaar_P

#supported_frequencies(variable_name = "rainfall")

df_stn <- get_stations("rainfall", frequency = "day")
voss <- df_stn %>%
  filter(station_name == "Vosselaar_P")

voss_ts_id <- "35169042"

df_in <- get_timeseries_tsid(ts_id = "35169042", from = "2020-01-01", to = "2021-01-01")

str(df_in)

#Check quality code (nog aan ta passen)
df_in %>%
  filter(is.na(Value))

df_in %>%
  filter('Quality Code' == "130")

df_pp <- df_in %>%
  mutate(loc = "Vosselaar",
         date = as.Date(Timestamp),
         var = "P") %>%
  dplyr::select(loc, date, var, value = Value)

saveRDS(df_pp, file = "../data/interim/waterinfo_P.rds")
