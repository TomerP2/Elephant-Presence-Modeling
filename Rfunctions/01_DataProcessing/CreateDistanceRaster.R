createDistanceRaster <- function(in_vector, ext_vector, resolution = 100, output_path = NULL) {
# Description:
#   Create a raster of Euclidean distance (in meters) to the nearest feature
#   in `in_vector`. The raster extent is taken from `ext_vector`. Both input
#   vectors are reprojected to EPSG:32735 (UTM zone 35S) before raster creation.
#   https://www.rdocumentation.org/packages/terra/versions/0.2-9/topics/distance
#
# Inputs:
#  - in_vector: sf or SpatVector; features for which distances are computed.
#  - ext_vector: sf or SpatVector; used to determine the raster extent.
#  - resolution: numeric; raster cell size in meters (default 100).
#  - output_path: character or NULL; file path to save the distance raster (optional).
#
# Outputs:
#  - A SpatRaster (terra) containing Euclidean distances in meters. CRS is EPSG:32735.
#  - If output_path is provided, the raster is also written to disk (GeoTIFF).
#
# Example usage:
#  in_vec <- st_read("data/GIS/roads.shp")
#  ext_vec <- st_read("data/GIS/boundary.shp")
#  dist_r <- createDistanceRaster(in_vec, ext_vec, resolution = 100, output_path = "data/interim/roads_dist.tif")

  # Ensure the input is a SpatVector
  if (!inherits(in_vector, "SpatVector")) {
    in_vector <- vect(in_vector)
  }
  if (!inherits(ext_vector, "SpatVector")) {
    ext_vector <- vect(ext_vector)
  }

  # Reproject to EPSG:32735 (UTM Zone 35S)
  in_vector <- project(in_vector, "EPSG:32735")
  ext_vector <- project(ext_vector, "EPSG:32735")

  # Create raster template covering extent of ext_vector
  r_template <- rast(ext_vector, res = resolution)

  # Compute Euclidean distance to nearest feature
  distance_raster <- distance(r_template, in_vector)

  # Save to file if path provided
  if (!is.null(output_path)) {
    writeRaster(distance_raster, output_path)
  }

  return(distance_raster)
}