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

# Open WFS
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

# We choose data from station Retie (code = 6464)
kmi_client$
  getCapabilities()$
  findFeatureTypeByName("synop:synop_data")$
  getDescription() %>%
  map_chr(function(x){x$getName()})

url$query <- list(service = "WFS",
                  request = "GetFeature",
                  typename = "synop:synop_data",
                  cql_filter = "(code = '6464') AND (timestamp > '2021-01-01T00:00:00')",
                  outputformat = "csv")

request <- build_url(url)
request

file2 <- tempfile(fileext = ".csv")
GET(url = request,
    write_disk(file2))

df_kmi_retie <- read.csv(file2)
head(df_kmi_retie)

saveRDS(df_kmi_retie, file = "./data/interim/kmi_retie.rds")

