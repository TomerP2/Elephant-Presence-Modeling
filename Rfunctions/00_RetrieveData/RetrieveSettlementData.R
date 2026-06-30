retrieveSettlementData <- function(accom_path, lodges_path) {
  # Description: 
  #   Read two settlement shapefiles (accommodation and lodges),
  #   extract and combine their geometry columns into a single sf object,
  #   and transform the result to EPSG:32735 (UTM zone 35S).
  #
  # Inputs:
  #  - accom_path: character; path to the accommodation settlements shapefile (string).
  #  - lodges_path: character; path to the lodges settlements shapefile (string).
  #
  # Outputs:
  #  - An sf object. Contains the combined geometry column for both input layers. CRS 32735.
  #
  # Example usage:
  #  accom <- "data/GIS/accommodation.shp"
  #  lodges <- "data/GIS/lodges.shp"
  #  settlements_sf <- retrieveSettlementData(accom, lodges)

  accom_sf <- st_read(accom_path)
  lodges_sf <- st_read(lodges_path)
  
  sf_settlements <- rbind(lodges_sf[, "geometry"], accom_sf[, "geometry"])
  
  sf_settlements <- st_transform(sf_settlements, crs=32735)
  
  return(sf_settlements)
}

