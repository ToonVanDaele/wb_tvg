
# Load netcdf file

library(ncdf4) # Load the ncdf4 library for handling netCDF files
library(tidyverse) # Load the tidyverse for data manipulation and transformation
library(stars)

# Replace 'your_netcdf_file.nc' with the actual path to your netCDF file
nc_data <- nc_open("./data/input/KNMI/INTER_OPER_R___TX1_____L3__19610101T000000_19610102T000000_0002.nc")

# Get variable names
variable_names <- names(nc_data$var)

# Extract variables from the netCDF file (adjust variable names as needed)
lon <- ncvar_get(nc_data, "lon")
lat <- ncvar_get(nc_data, "lat")
stations <- ncvar_get(nc_data, "stations")
stationvalues <- ncvar_get(nc_data, "stationvalues") # Example variable

mean(stationvalues, na.rm = TRUE)

# Create a stars object
stars_obj <- st_as_stars(list(variable_name = stationvalues),
                         dimensions = st_dimensions(
                           x = lon,
                           y = lat,
                           cell_midpoints = TRUE
                         ))

# Convert stars object to sf object (polygon grid)
sf_grid <- st_as_sf(stars_obj, as_points = FALSE, merge = TRUE)

# Set the CRS (replace EPSG code with the appropriate one)
sf_grid <- st_set_crs(sf_grid, 4326) # Assuming WGS84 CRS

# Plot using ggplot2
ggplot() +
  geom_sf(data = sf_grid, aes(fill = variable_name)) +
  scale_fill_viridis_c() +
  coord_sf() +  # Use coord_sf to handle spatial data
  labs(title = "Variable Name", x = "Longitude", y = "Latitude") +
  theme_minimal()



# Convert stars object to sf object
sf_grid <- st_as_sf(nc_data, as_points = FALSE, merge = TRUE)

# Check the coordinate reference system (CRS)
st_crs(sf_grid)


nc_close(nc_data) # Close the netCDF file


read_stars


# Create a data frame
df <- data.frame(
  longitude = as.vector(longitude),
  latitude = as.vector(latitude),
  time = as.vector(time),
  temperature = as.vector(temperature) # Example variable
)

# Further data transformations or analysis can be performed using tidyverse functions
# For example, to filter data based on a condition
df_filtered <- df %>%
  filter(temperature > 25) # Filter data where temperature is greater than 25

print(head(df)) # Print the first few rows of the data frame
