prepareCovariateDf <- function(rasters, res, target_crs = "EPSG:32735") {
  # Combines rasters in 'rasters' into one dataframe. Needed for running model.
  # Example usage:
  # r1 <- rast("roads_distance.tif")
  # r2 <- rast("settlements_distance.tif")
  # r3 <- rast("elevation.tif")
  
  # rasters_list <- list(,dist_roads = r1, dist_settlements = r2, elevation = r3)
  # covariate_df <- prepareCovariateDf(rasters_list, res = 1000)
  
  # Check input validity
  if (!is.list(rasters) || is.null(names(rasters))) {
    stop("`rasters` must be a *named list* of terra SpatRaster objects.")
  }
  
  # 1. Reproject all rasters to the same CRS
  rasters_proj <- lapply(rasters, function(r) project(r, target_crs))
  
  # 2. Compute the union of all extents manually (numeric min/max)
  xmin <- ymin <- Inf
  xmax <- ymax <- -Inf
  for (r in rasters_proj) {
    e <- ext(r)
    xmin <- min(xmin, e[1])
    xmax <- max(xmax, e[2])
    ymin <- min(ymin, e[3])
    ymax <- max(ymax, e[4])
  }
  all_ext <- ext(xmin, xmax, ymin, ymax)
  
  # 3. Create a template raster with desired resolution and CRS
  template <- rast(crs = target_crs, extent = all_ext, resolution = res)
  
  # 4. Resample all rasters to the template
  rasters_resamp <- lapply(rasters_proj, function(r) {
    resample(r, template, method = "bilinear")
  })
  
  # 5. Combine into single SpatRaster
  cov_stack <- rast(rasters_resamp)
  names(cov_stack) <- names(rasters)
  
  # 6. Convert to data frame
  covariate_df <- as.data.frame(cov_stack, xy = TRUE, na.rm = TRUE)
  
  return(covariate_df)
}
