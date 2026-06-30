
makeRandomDataFrame <- function(size, path_shapefile, timestamp_start, timestamp_end) {
  # Description:
  #   Generate random point locations sampled within a provided polygon shapefile.
  #
  # Inputs:
  #  - size: integer; number of random points to generate.
  #  - path_shapefile: character; path to a polygon shapefile used for sampling.
  #  - timestamp_start: POSIXct or string; start of the timestamp range (coerced to POSIXct, UTC).
  #  - timestamp_end: POSIXct or string; end of the timestamp range (coerced to POSIXct, UTC).
  #
  # Outputs:
  #  - An sf object (POINT geometry) with CRS EPSG:32735. Contains columns X, Y,
  #    TimeStamp (POSIXct) and additional cyclical time columns added by
  #    createCyclicalTime, plus the geometry column.
  #
  # Example usage:
  #  size <- 100
  #  shp_path <- "data/park_boundary.shp"
  #  ts_start <- "2020-01-01 00:00:00"
  #  ts_end   <- "2020-01-07 23:59:59"
  #  points_sf <- makeRandomDataFrame(size, shp_path, ts_start, ts_end)

  # Convert timestamps to POSIXct if they aren't already
  timestamp_start <- as.POSIXct(timestamp_start, tz = "UTC")
  timestamp_end <- as.POSIXct(timestamp_end, tz = "UTC")
  
  # Create empty data frame
  df <- data.frame(X = numeric(size), Y = numeric(size))
  
  # Fill coordinates using random points from shapefile
  shp <- st_read(path_shapefile, quiet = TRUE)
  point <- st_sample(shp, size = size, type="random", quiet = TRUE)
  coords <- st_coordinates(point, quiet = TRUE)
  
  df <- data.frame(X = coords[, "X"], Y = coords[, "Y"])
  
  # Add random timestamps
  random_seconds <- runif(size, 0, as.numeric(difftime(timestamp_end, timestamp_start, units = "secs")))
  df$TimeStamp <- timestamp_start + random_seconds
  
  # Add cyclical time columns to dataframe
  df <- createCyclicalTime(df, "TimeStamp")
  
  # Read shapefile
  shp <- st_read(path_shapefile, quiet = TRUE)
  
  # Convert df to sf object with same CRS as shapefile
  points_sf <- st_as_sf(df, coords = c("X", "Y"), crs = st_crs(shp))
  
  # Reproject to EPSG:32735
  points_sf <- st_transform(points_sf, crs = 32735)
  
  return(points_sf)
}
