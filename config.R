# Define package names
packages <- c("sf", "dplyr", "spatialEco", "terra", "epitools", "lubridate", "shiny", "leaflet", "shinyTime","car", "caret", "pROC", "bslib")

# Install packages that are not yet installed
installed_packages <- packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  install.packages(packages[!installed_packages])
}

# Load packages
invisible(lapply(packages, library, character.only = TRUE))

# Load all functions from ElephantFunctions
invisible(lapply(list.files("Rfunctions/00_RetrieveData", pattern = "\\.R$", full.names = TRUE), source))
invisible(lapply(list.files("Rfunctions/01_DataProcessing", pattern = "\\.R$", full.names = TRUE), source))
invisible(lapply(list.files("Rfunctions/02_ModelTraining", pattern = "\\.R$", full.names = TRUE), source))
invisible(lapply(list.files("Rfunctions/03_ModelUsage", pattern = "\\.R$", full.names = TRUE), source))
invisible(lapply(list.files("Rfunctions/04_Helpers", pattern = "\\.R$", full.names = TRUE), source))

# Define paths
temperature_data_folder = "data/weather/Main Gate/"
elephant_points_path = "data/elephants_WelgevondenGameReserve_2018-2021.csv"
elephant_attributes_path = "data/elephants_WelgevondenGameReserve.csv"
accommodation_path <- "data/GIS/staff_accommodation_UTM35S.shp"
lodges_path <- "data/GIS/Sites_UTM35S_lodges.shp"
roads_path <- "data/GIS/WGR_Roads_OCT2019.shp"
elevation_path <- "data/GIS/WGR_2m_DEM_3m_cell_Feb16.tif"
ext_vector_path <- "data/GIS/WGR_Boundary_New_Apr15.shp"
water_points_path <- "data/GIS/reservoirs_and_cribs_UTM35S.shp"