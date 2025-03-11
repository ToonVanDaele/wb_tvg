### load KNMI radar


#RMI_DATASET_QPE


library(tidyverse)
library(httr)
library(ows4R)
library(inborutils)

# Link to the WFS service
wfs_kmi_qpe <- "https://opendata.meteo.be/service/GRIDDEDOBS/wfs"

url <- parse_url(wfs_kmi_qpe)

url$query <- list(service = "wfs",
                  request = "GetCapabilities")

request <- build_url(url)
request

kmi_client <- WFSClient$new(wfs_kmi_qpe, serviceVersion = "2.0.0")
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
