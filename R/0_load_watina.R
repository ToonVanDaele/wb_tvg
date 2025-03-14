# Load Watina data

library(tidyverse)
library(watina)
library(sf)
library(assertthat)
source("R/get_level.R")

# This script downloads data from watina at predefined locations

# Make a connection with the watina database
watina <- connect_watina()

# Load locations wihtin a box
locs_tvg <- get_locs(watina,
                     obswells = TRUE,
                     bbox = c(xmin = 186000,
                              xmax = 194000,
                              ymin = 225000,
                              ymax = 232000),
                     loc_type = c("P", "S"),
                     collect = TRUE)

# Create sf object
locs_tvg_sf <- st_as_sf(locs_tvg, coords = c("x","y"))
st_crs(locs_tvg_sf) <- "EPSG:31370"

str(locs_tvg_sf)
class(locs_tvg_sf)

# Change coordinates to lat/lon wgs84
locs_tvg_sf <- st_transform(locs_tvg_sf, "EPSG:4326")

# A simple leaflet map
library(leaflet)

leaf_map <-
  leaflet(locs_tvg_sf) %>%
  addTiles(group = "OSM") %>%
  addCircleMarkers() %>%
  addLabelOnlyMarkers(label = ~loc_code,
                      labelOptions = labelOptions(noHide = T,
                                                  direction = 'top',
                                                  textOnly = T))

leaf_map

sel_loc_vec <- c("TVGP023", "TVGP026", "TVGP072", "TVGP073", "TVGP305",
                 "TVGS020", "TVGS021", "TVGS060")

# Load level data
locs_tvg_sel <- get_locs(con = watina,
                         loc_type = c("P", "S"),
                         loc_vec = sel_loc_vec)

tvg_level <- get_level(locs = locs_tvg_sel,
                       con = watina,
                       startdate = "01-01-2020",
                       enddate = "01-01-2026",
                       collect = TRUE)

saveRDS(tvg_level, file = "./data/interim/watina_level.rds")



# Load chemical data
tvg_chem <- get_chem(locs = data.frame(loc_code = sel_loc_vec),
                     con = watina,
                     startdate = "01-01-2015",
                     collect = TRUE)

saveRDS(tvg_chem, file = "./data/interim/watina_chem.rds")


# Close database connection
dbDisconnect(watina)
