source("config.R")

# Load in data
source("prepare_data.R")

# --- Global variables ---

# Output path
model_output_path <- "models/elephant_model_00.rds"

# Amount of random points to create. 
# Used to give model data on where the elephants are not present.
# Needed for class balancing
# 600000 becomes about the same amount of points as elephant_points
random_points_count <- 600000

# Create models folder if not exist
if (!dir.exists("models")){
  dir.create("models")
}

# --- Get and preprocess data ---

elephant_data <- retrieveElephantsData(elephant_points_path, elephant_attributes_path)
temperature_data_list <- retrieveTemperatureData(temperature_data_folder)
temperature_data <- temperature_data_list$heat_index_data
daily_temp_data <- temperature_data_list$daily_data

# --- Get random points (points in park extent with a random timestamp) ---

# Random points' Timestamp is a random time between the earliest and latest date in elephant point dataframe
timestamp_start = min(elephant_data$TimeStamp..UTC.)
timestamp_end = max(elephant_data$TimeStamp..UTC.)
random_data_frame <- makeRandomDataFrame(random_points_count, ext_vector_path, timestamp_start, timestamp_end)

# --- Add values from covariance rasters to both elephants data and random points data ---
addVariablesToData <- function(df){
  df <- addTemperatureData(df, "TimeStamp", temperature_data, 30)
  df <- df[!is.na(df$geometry), ]
  df <- df[!is.na(df$Heat_Index), ]
  
  df <- extractDistanceValues(distance_to_roads_rast, df, column_name = "dist_roads")
  df <- extractDistanceValues(distance_to_settlements_rast, df, column_name = "dist_settlements")
  df <- extractDistanceValues(distance_to_water_rast, df, column_name="dist_water")
  df <- extractDistanceValues(elevation_rast, df, column_name = "elevation")
  df <- extractDistanceValues(slope_rast, df, column_name = "slope")
  df <- extractDistanceValues(tri_rast, df, column_name = "tri")
  
  df <- subset(df, select = c(Heat_Index, dist_roads, dist_settlements, dist_water, elevation, slope, tri, Hour_sin, Hour_cos))
  df <- cbind(st_drop_geometry(df), st_coordinates(df))
  return(df)
}

elephant_data <- addVariablesToData(elephant_data)
random_data_frame <- addVariablesToData(random_data_frame)

# --- Prepare data for model training ---

model_data <- dataPreparationForModel(elephant_data, random_data_frame)

# Get train and test split from model data
trainElephantData <- model_data$trainingData
testElephantData <- model_data$testData

# Remove x and y columns and remove na values
trainElephantData <- trainElephantData %>%
  select(-X, -Y) 
trainElephantData <- na.omit(trainElephantData)

# --- Create and train regression model ---

regression_model <- regressionModel(trainElephantData)
final_model <- regression_model$model
summary <- regression_model$summary
print(final_model)
print(summary)

# --- Evaluate model ---
testElephantData <- testElephantData %>%
  select(-X, -Y) 
testElephantData <- na.omit(testElephantData)
model_evaluation <- modelEvaluation(final_model, testElephantData)

# --- Save to models folder ---
saveRDS(final_model, file = model_output_path)
