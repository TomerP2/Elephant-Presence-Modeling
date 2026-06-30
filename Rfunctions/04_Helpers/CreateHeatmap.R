createHeatMap <- function(sf_elephantPoints, resolution = 1000){
  # Description:
  #   Create a kernel density estimate (heatmap) from elephant location points.
  #
  # Inputs:
  #   - sf_elephantPoints: sf POINT object; an sf data.frame (or object accepted by sf.kde)
  #                        containing elephant location coordinates (geometry column).
  #   - resolution: numeric; output grid resolution (in meters) used by sf.kde. Default 1000.
  #
  # Outputs:
  #   - Heatmap raster
  #
  # Example usage:
  #   library(sf)
  #   pts <- st_as_sf(data.frame(id = 1:2, x = c(0,1), y = c(0,1)),
  #                   coords = c("x","y"), crs = 4326)
  #   kde <- createHeatMap(pts, resolution = 500)
  
  kde <- sf.kde(x = sf_elephantPoints, res = resolution)
  return(kde)
}