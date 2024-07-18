## Load KMI data

library(tidyverse)
library(httr)
library(ows4R)
library(inborutils)

# https://opendata.meteo.be/geonetwork/srv/dut/catalog.search;jsessionid=0BFD16752CA6C0748B83F916086F6E6B#/metadata/RMI_DATASET_SYNOP

# Link to the WFS service

wfs_kmi <- "https://opendata.meteo.be/service/synop/wfs"

url <- parse_url(wfs_kmi)

url$query <- list(service = "wfs",
                  request = "GetCapabilities")

request <- build_url(url)
request

kmi_client <- WFSClient$new(wfs_kmi, serviceVersion = "2.0.0")
kmi_client
kmi_client$getFeatureTypes(pretty = TRUE)

kmi_client$getCapabilities()

kmi_client$
  getCapabilities()$
  findFeatureTypeByName("synop:synop_station")$
  getDescription() %>%
  map_chr(function(x){x$getName()})

url$query <- list(service = "WFS",
                  request = "GetFeature",
                  typename = "synop:synop_station",
                  outputformat = "csv")

request <- build_url(url)
request

file <- tempfile(fileext = ".csv")
GET(url = request,
    write_disk(file))

kmi_stations <- read.csv(file)
kmi_stations

# We choose 1 station -> Retie - code = 6464

kmi_client$
  getCapabilities()$
  findFeatureTypeByName("synop:synop_data")$
  getDescription() %>%
  map_chr(function(x){x$getName()})

url$query <- list(service = "WFS",
                  request = "GetFeature",
                  typename = "synop:synop_data",
                  cql_filter = "(code = '6464') AND (timestamp > '2024-07-01T00:00:00')",
                  count = 500,
                  outputformat = "csv")

request <- build_url(url)
request

file2 <- tempfile(fileext = ".csv")
GET(url = request,
    write_disk(file2))

kmi_retie_data <- read.csv(file2)
kmi_retie_data

ts_retie <- kmi_retie_data %>%
  mutate(datetime = as.POSIXct(timestamp, format="%Y-%m-%dT%H:%M"))

ts_retie %>%
  ggplot(aes(x = datetime, y = temp)) + geom_point() + geom_line()


# https://opendata.meteo.be/service/ows?
#   service=WFS&
#   version=2.0.0&
#   request=GetFeature&
#   typenames=synop:synop_station&
#   outputformat=csv



df_kmi_station <- read.csv(file = "./data/input/KMI/synop_station.csv", header = TRUE)
df_kmi_in <- read.csv(file = "./data/input/KMI/synop_data.csv", header = TRUE)
df_kmi_in <- read.csv(file = "./data/input/KMI/synop_data_2023.csv", header = TRUE)


unique(df_kmi_in$code)
# station 'Retie' -> code = 6464

df_kmi_pp <- df_kmi_in %>%
  filter(code == "6464")

df_kmi_ps <- df_kmi_pp %>%
  slice(1:20) %>%
  dplyr::select(timestamp, p = precip_quantity, t = temp) %>%
  mutate(datetime = as.POSIXct(timestamp, format="%Y-%m-%dT%H:%M")) %>%
  replace_na(list(p = 0)) %>%
  arrange(datetime)


summary(df_kmi_ps)
min(df_kmi_ps$datetime)

head(df_kmi_in)
