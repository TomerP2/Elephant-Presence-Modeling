extractDistanceValues <- function(distance_raster, points, column_name="raster_value") {
  # Uses a distance raster and points to add the value from the raster to the point as a new field/column.
  # Inputs: 
  #   distance_raster -> a SpatRaster or Terra raster
  #   points -> Elephant location points as sf
  #   column_name -> New column will be called this
  # Outputs: points with new column with the raster value
  # Example usage: new_table <- extractDistanceValues(dist_raster, elephantTempData, "dist_to_roads")
  
  # Ensure inputs are in correct terra formats
  if (!inherits(distance_raster, "SpatRaster")) {
    distance_raster <- rast(distance_raster)
  }
  if (!inherits(points, "SpatVector")) {
    points <- vect(points)
  }

  # Reproject points to match raster CRS if needed
  if (crs(points) != crs(distance_raster)) {
    points <- project(points, crs(distance_raster))
  }

  # Extract raster values at each point
  extracted <- extract(distance_raster, points)

  # Combine extracted values with original point data
  # (drop the ID column from extract() output)
  result <- cbind(points, extracted[, -1, drop = FALSE])
  result <- st_as_sf(result)
  
  # Rename column
  # Find which column came from the raster
  raster_names <- names(distance_raster)
  extracted_names <- names(extracted)[-1]  # skip ID column
  
  # Some rasters have no names → terra assigns "lyr.1"
  if (length(raster_names) == 0) {
    raster_names <- extracted_names
  }
  
  # Match the extracted name(s) in the result
  for (old_name in extracted_names) {
    if (old_name %in% names(result)) {
      names(result)[names(result) == old_name] <- column_name
    }
  }
  
  return(result)
}