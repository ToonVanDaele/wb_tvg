# Load from waterinfo

library(tidyverse)
library(wateRinfo)

# Check supported variables / frequencies
supported_variables(language = "nl")
supported_frequencies(variable_name = "neerslag")

# Get stations with daily precipitation
df_stn <- get_stations("neerslag", frequency = "day")
# Get time series ID for daily precipitation at station in Vosselaar"
voss_ts_id <- df_stn %>%
  filter(station_name == "Vosselaar_P") %>%
  pull(ts_id)

df_in <- get_timeseries_tsid(ts_id = voss_ts_id, from = "2020-01-01", to = "2024-05-01")

saveRDS(df_in, file = "./data/interim/vosselaar_p.rds")

## Get PET values

# list of stations with Penman Monteith PET at daily frequency
stations_pet <- get_stations("verdamping_monteith", frequency = "day")

# Get timeseries_id for Herentals - daily PET Penman Monteith
herent_ts_id <- stations_pet %>%
  filter(station_name == "Herentals_ME") %>%
  pull(ts_id)

df_in <- get_timeseries_tsid(ts_id = herent_ts_id, from = "2020-01-01", to = "2024-05-01")

saveRDS(df_in, file = "./data/interim/herentals_ME.rds")

