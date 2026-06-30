# Get data for covariates
settlement_data <- retrieveSettlementData(accommodation_path, lodges_path)
waterpoints_data <- retrieveWaterData(water_points_path)

roads_data <- st_read(roads_path)
elevation_rast <- rast(elevation_path)

#create slope and terrain ruggedness index spatrasters from the elevation_rast
tri_rast <- terrain(elevation_rast, v = "TRI") 
slope_rast <- terrain(elevation_rast, v = "slope", unit = "degrees") 

# Get extent vector
extent_vector <- st_read(ext_vector_path)

# Create distance rasters for roads, settlements and water
distance_to_roads_rast <- createDistanceRaster(roads_data, extent_vector)
distance_to_settlements_rast <- createDistanceRaster(settlement_data, extent_vector)
distance_to_water_rast <- createDistanceRaster(waterpoints_data, extent_vector)

# Combine covariate-rasters to use when running model
rasters_list <- list(
  dist_roads = distance_to_roads_rast,
  dist_settlements = distance_to_settlements_rast,
  dist_water = distance_to_water_rast,
  elevation = elevation_rast,
  tri = tri_rast,
  slope = slope_rast
)
covariate_df <- prepareCovariateDf(rasters_list, 100)