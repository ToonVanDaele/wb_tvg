##Load KMI automatic wheater station (AWS) daily

library(tidyverse)
library(httr)
library(ows4R)
library(inborutils)

#https://opendata.meteo.be/service/aws/wfs?service=WFS&version=1.1.0&request=GetCapabilities.


wfs_kmi_aws <- "https://opendata.meteo.be/service/aws/wfs"

url <- parse_url(wfs_kmi_aws)

url$query <- list(service = "wfs",
                  request = "GetCapabilities")

request <- build_url(url)
request

kmi_client <- WFSClient$new(wfs_kmi_aws, serviceVersion = "2.0.0")
kmi_client
kmi_client$getFeatureTypes(pretty = TRUE)

# The last line gives the stations 'aws:aws_station'

kmi_client$
  getCapabilities()$
  findFeatureTypeByName("aws:aws_station")$
  getDescription() %>%
  map_chr(function(x){x$getName()})

url$query <- list(service = "WFS",
                  request = "GetFeature",
                  typename = "aws:aws_station",
                  outputformat = "csv")

request <- build_url(url)
request

file <- tempfile(fileext = ".csv")
GET(url = request,
    write_disk(file))

kmi_stations_aws <- read.csv(file)
kmi_stations_aws

# Only 3 stations (Ukkel, Zeebrugge & Humain)
