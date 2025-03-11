## KNMI radar data -
# Precipitation - radar/gauge 24 hour accumulations over the Netherlands
# https://dataplatform.knmi.nl/dataset/radar-corr-accum-24h-1-0
#  	urn:xkdc:ds:nl.knmi::radar_corr_accum_24h/1.0/


# Precipitation - 24 hour precipitation accumulations from climatological gauge-adjusted radar # # # # dataset for The Netherlands (1 km) in KNMI HDF5 format
# https://dataplatform.knmi.nl/dataset/rad-nl25-rac-mfbs-24h-2-0
# urn:xkdc:ds:nl.knmi::rad_nl25_rac_mfbs_24h/2.0/


library(tidyverse)
library(httr)
#library(rhdf5)



#  	radar_corr_accum_24h
#  	urn:xkdc:ds:nl.knmi::radar_corr_accum_24h/1.0/

url <- "https://api.dataplatform.knmi.nl/open-data/v1/datasets/radar_corr_accum_24h/versions/1.0/files"

apikey <- "eyJvcmciOiI1ZTU1NGUxOTI3NGE5NjAwMDEyYTNlYjEiLCJpZCI6ImE1OGI5NGZmMDY5NDRhZDNhZjFkMDBmNDBmNTQyNjBkIiwiaCI6Im11cm11cjEyOCJ9"

## connect to API
res <- GET(url, add_headers(Authorization = apikey))

# extract content
ttemp <- content(res, simplifyVector = TRUE)$files
tibble::as_tibble(ttemp)

# API request to fetch download URL for the 1st nc file:
file_url_req <- paste0(url, ttemp$filename[10], "/url")
file_url_req

res <- GET(file_url_req, add_headers(Authorization = apikey))
dl_url <- content(res)$temporaryDownloadUrl

# actual download:
download.file(dl_url, destfile = "c:/temp/", mode = "wb")
