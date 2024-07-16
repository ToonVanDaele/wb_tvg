# Load raw data from KNMI

library(tidyverse)
library(lubridate)

# manual download (ascii txt)

# website
#
# https://www.knmi.nl/nederland-nu/klimatologie/monv/reeksen
#
# station: Esbeek 831
#
# unzipped file is ascii .(txt)
#
# STN = stationnumber
# YYYYMMDD = date (YYYY=year MM=month DD=day)
# RD       = daily precipitation amount (sum) in 0.1 mm
#            period 08.00 preceding day - 08.00 UTC present day
# SX       = code for the snow cover at 08.00 UTC:
#
#   code    snow cover
# 1                                    1 cm
# ...                                   ...
# 996                                996 cm
#
# 997 broken snow cover < 1 cm
# 998 broken snow cover >=1 cm
# 999 snow dunes
#
# 5 spaces represents a missing value

df_in <- read.csv(file = "../data/input/KNMI/neerslaggeg_ESBEEK_831.txt",
         header = TRUE,
         sep = ",",
         skip = 23)

str(df_in)

# processing of snow data to be added

df_in$YYYYMMDD <- ymd(df_in$YYYYMMDD)

df_pp <- df_in %>%
  rename(loc = STN,
         date = YYYYMMDD,
         value = RD) %>%
  mutate(loc = paste0("NL_", loc),
         value = value / 10,
         var = "P")  %>%  # from 0.1mm to mm
  dplyr::select(loc, date, var, value) %>%
  dplyr::filter(date > "2020-01-01")

#ggplot(df_pp, aes(x = date, y = n)) + geom_line()

saveRDS(df_pp, file = "../data/interim/N_NL.rds")
#df_nl <- readRDS(file = "../data/interim/N_NL.rds")
