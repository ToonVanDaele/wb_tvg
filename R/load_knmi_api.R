# KNMI data

library(tidyverse)
library(httr)
library(ows4R)
library(inborutils)
library(ncdf4)


## Quality controlled rain gauge data of water board De Dommel
# waterboard_raingauge_quality_controlled_dommel   -> start 2023-06-01
#

# Combined quality controlled rain gauge data of water boards and water companies
# waterboard_raingauge_quality_controlled_all_combined
# start time :  	2023-10-01

# Meteo data - daily quality controlled climate data KNMI, the Netherlands
#  	etmaalgegevensKNMIstations
#  	urn:xkdc:ds:nl.knmi::etmaalgegevensKNMIstations/1/

# Precipitation - gridded daily precipitation sum in the Netherlands
#  	Rd1
#  	urn:xkdc:ds:nl.knmi::Rd1/5/
# ordinary kriging - tussen gauging stations

# Precipitation - daily updated gridded fields for daily precipitation amount derived from stations observations in Europe (E-OBS dataset)
# https://dataplatform.knmi.nl/dataset/daily-updated-rr-eobs-1
# E-OBS dataset (https://surfobs.climate.copernicus.eu/dataaccess/access_eobs.php)
# daily_updated_rr_eobs
#  	urn:xkdc:ds:nl.knmi::daily_updated_rr_eobs/1/





# curl --location --request GET \
# "https://api.dataplatform.knmi.nl/open-data/v1/datasets/Actuele10mindataKNMIstations/versions/2/files" \
# --header "Authorization: <API_KEY>"


## Quality controlled rain gauge data of water board Limburg
#
## 	urn:xkdc:ds:nl.knmi::waterboard_raingauge_quality_controlled_limburg/1.0/

# https://api.dataplatform.knmi.nl/open-data/v1/datasets/Actuele10mindataKNMIstations/versions/2/files?maxKeys=10&sorting=asc&orderBy=filename


# Link to the WFS service

api_knmi <- "https://api.dataplatform.knmi.nl/open-data/v1"

url <- parse_url(api_knmi)

url$query <- list(service = "wfs",
                  request = "GetCapabilities")

request <- build_url(url)
request

kmi_client <- WFSClient$new(api_knmi, serviceVersion = "v1")
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


#### voorbeeld uit stackoverflow

library(httr)
## fetch data from KNMI
# url <- 'https://api.dataplatform.knmi.nl/open-data/v1/datasets/Tx1/versions/2/files/'
url <- "https://api.dataplatform.knmi.nl/open-data/v1/datasets/Actuele10mindataKNMIstations/versions/2/files"

## this key is publicly available directly from KNMI

# eyJvcmciOiI1ZTU1NGUxOTI3NGE5NjAwMDEyYTNlYjEiLCJpZCI6ImE1OGI5NGZmMDY5NDRhZDNhZjFkMDBmNDBmNTQyNjBkIiwiaCI6Im11cm11cjEyOCJ9
apikey <- "eyJvcmciOiI1ZTU1NGUxOTI3NGE5NjAwMDEyYTNlYjEiLCJpZCI6ImE1OGI5NGZmMDY5NDRhZDNhZjFkMDBmNDBmNTQyNjBkIiwiaCI6Im11cm11cjEyOCJ9"

## connect to API
res <- GET(url, add_headers(Authorization = apikey))

# extract content
ttemp <- content(res, simplifyVector = TRUE)$files
# nc_files <- content(res, simplifyVector = TRUE)$files
tibble::as_tibble(nc_files)
tibble::as_tibble(ttemp)

# API request to fetch download URL for the 1st nc file:
file_url_req <- paste0(url, nc_files$filename[1], "/url")
file_url_req
#> [1] "https://api.dataplatform.knmi.nl/open-data/v1/datasets/Tx1/versions/2/files/INTER_OPER_R___TX1_____L3__19610101T000000_19610102T000000_0002.nc/url"
res <- GET(file_url_req, add_headers(Authorization = apikey))
dl_url <- content(res)$temporaryDownloadUrl

# actual download:
download.file(dl_url, destfile = nc_files$filename[1], mode = "wb")
#> ...
#> Content type 'application/x-netcdf' length 531307 bytes (518 KB)
#> downloaded 518 KB

# list downloaded file(s):
fs::dir_info(glob = "*.nc")[,1:3]


#Let's see what's inside

our_nc_data <- nc_open("./INTER_OPER_R___TX1_____L3__19610101T000000_19610102T000000_0002.nc")
print(our_nc_data)

attributes(our_nc_data$var)
attributes(our_nc_data$dim)


lat <- ncvar_get(our_nc_data, "lat")
lon <- ncvar_get(our_nc_data, "lon")

nlat <- dim(lat) #to check it matches the metadata: 23> lon <- ncvar_get(our_nc_data, "lon")
nlon <- dim(lon) #to check, should be 24
# Check your lat lon dimensions match the information in the metadata we explored before:

print(c(nlon, nlat))
# Get the time variable.
# Remember: our metadata said our time units are in seconds since 1981-01-01 00:00:00
# so you will not see a recognizable date and time format
# but a big number like "457185600". We will take care of this later
time <- ncvar_get(our_nc_data, "time")
head(time) # just to have a look at the numbers
tunits <- ncatt_get(our_nc_data, "time", "units") #check units
nt <- dim(time) #should be 2622


#get the variable in "matrix slices"
lswt_array <- ncvar_get(our_nc_data, "stationvalues")

fillvalue <- ncatt_get(our_nc_data, "stationvalues", "_FillValue")

dim(lswt_array) #to check; this should give you 24 23 2622
#right away let's replace the nc FillValues with NAs
lswt_array[lswt_array == fillvalue$value] <- NA
lswt_array

time_obs <- as.POSIXct(time, origin = "1981–01–01", tz = "CET")

dim(time_obs) #should be 2622> range(time_obs)
[1] "1995-06-28 12:00:00 GMT"
[2] "2016-12-31 12:00:00 GMT"

################ voorbeeld uit python vertaald

# Libraries
library(httr)  # for making HTTP requests
#library(logging)  # for logging

# Configure logging (similar to basicConfig in Python)
# basicConfig(level = getOption("LOG_LEVEL", default = LOG_INFO))
# logger <- getLogger("")

# OpenDataAPI class
OpenDataAPI <- R6Class(
  classname = "OpenDataAPI",
  private = list(
    base_url = "https://api.dataplatform.knmi.nl/open-data/v1",
    get_data = function(url, params = NULL) {
      response <- GET(url, addHeaders(.headers), params = params)
      content(response, as = "json")
    }
  ),
  public = list(
    initialize = function(api_token) {
      self$headers <- list(Authorization = api_token)
    },
    list_files = function(dataset_name, dataset_version, params = list(maxKeys = 1, orderBy = "created", sorting = "desc")) {
      url <- paste0(self$base_url, "/datasets/", dataset_name, "/versions/", dataset_version, "/files")
      self$get_data(url, params)
    },
    get_file_url = function(dataset_name, dataset_version, file_name) {
      url <- paste0(self$base_url, "/datasets/", dataset_name, "/versions/", dataset_version, "/files/", file_name, "/url")
      self$get_data(url)
    }
  )
)

# Download function
download_file_from_temporary_download_url <- function(download_url, filename) {
  tryCatch({
    response <- GET(download_url, stream = TRUE)
    stopIfNotFound(response)

    with(open(filename, "wb"), {
      for (chunk in content(response, as = "raw")) writeBin(chunk, .)
    })
    message(paste("Successfully downloaded dataset file to", filename))
  }, error = function(e) {
    message(paste("Unable to download file using download URL:", e))
    stop(run = 1)  # Exit with error code 1
  })
}

# Main function
main <- function() {
  api_key <- "<API_KEY>"
  dataset_name <- "Actuele10mindataKNMIstations"
  dataset_version <- "2"
  message(paste("Fetching latest file of", dataset_name, "version", dataset_version))

  api <- OpenDataAPI$new(api_token = api_key)

  # List files, similar logic to Python with sorting and retrieving first
  params <- list(maxKeys = 1, orderBy = "created", sorting = "desc")
  response <- tryCatch({ api$list_files(dataset_name, dataset_version, params) }, error = function(e) {
    message(paste("Unable to retrieve list of files:", e$message))
    stop(run = 1)
  })

  latest_file <- response$files[[1]]$filename
  message(paste("Latest file is:", latest_file))

  # Get download URL and download
  response <- api$get_file_url(dataset_name, dataset_version, latest_file)
  download_file_from_temporary_download_url(response$temporaryDownloadUrl, latest_file)
}

if (!is.null(environmentName()) && environmentName() == "package.start") {
  # When running the script as a source file, prevent main from being run
  next
} else {
  main()
}


