retrieveElephantsData <- function(elephantPoints_path, elephantDescription_path){
  # Description:
  #  Read elephant points and description CSV files.
  #
  # Inputs:
  #  - elephantPoints_path: character; path to the elephant points CSV. Should contain
  #    columns "TimeStamp..UTC.", "Longitude", "Latitude", and "Tag".
  #  - elephantDescription_path: character; path to the elephant description CSV. Should
  #    contain "Tag" and descriptive fields (e.g., Name, Sex).
  #
  # Outputs:
  #  - An sf object (POINT) with geometries in CRS 32735. Includes original attributes,
  #    Hour, and cyclical time feature columns.
  #
  # Example usage:
  #  points <- "data/elephant_points.csv"
  #  desc   <- "data/elephant_description.csv"
  #  elephants_sf <- retrieveElephantsData(points, desc)
  
  # Read elephant csv   
  elephantPointsDF <- read.csv(elephantPoints_path)
  elephantDescriptionDF <- read.csv(elephantDescription_path)

  # Get timestamp from string in dataframe
  elephantPointsDF$TimeStamp <- as.POSIXct(elephantPointsDF$TimeStamp..UTC., format = "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")
  
  # Extract hour from timestamp
  elephantPointsDF$Hour <- hour(elephantPointsDF$TimeStamp)
  
  # Cyclical encoding. Needed for model training/usage.
  elephantPointsDF <- createCyclicalTime(elephantPointsDF, "TimeStamp")
  
  # Merge both elephant data.frames to include Names, Sex in main table
  elephantPointsMerged <- merge(elephantPointsDF, elephantDescriptionDF, by = "Tag")
  
  # Create st object from merged data.frame
  sf_elephantPoints <- st_as_sf(elephantPointsMerged, coords=c('Longitude', 'Latitude'), crs=4326)
  
  # Transform to correct crs
  sf_elephantPoints <- st_transform(sf_elephantPoints, crs=32735)
  
  return(sf_elephantPoints)
}
