retrieveWaterData <- function(water_path){
  # Retrieve and process water data
  # 
  # Input: Water shapefile path
  # Output: sf dataframe with only the geometry column and in the correct coordinate system
  #

  water_data <- st_read(water_path)
  
  # Drop all columns besides geometry (Points)
  water_data <- water_data %>%
    select(geometry)
  
  water_data <- st_transform(water_data, crs=32735)
  
  return(water_data)
}