createPredictionRaster <- function(model, covariate_df, temp = NULL, time = NULL, output_path) {
  
  # 1. Get the predictor names used in the model (exclude intercept)
  # Stores the names of the variables used in the model, excluding the intercept
  selected_vars <- names(coef(model))[-1]
  
  # 2. Keep only columns that match model predictors (excluding temperature/time)
  # Select covariates used in the model, excluding temperature and time
  raster_covariates <- setdiff(selected_vars, c("Time", "Temperature"))

  # Keep only those columns from the dataframe
  raster_df <- covariate_df[, intersect(names(covariate_df), raster_covariates), drop = FALSE]

  # 3. Add temperature and time columns 
  # Ensure that when slider value of temperature and time in dashboard can be adjusted
  raster_df$Heat_Index <- temp
  
  # Add time in cyclical way: Hour_cos and Hour_sin
  raster_df$Time <- time
  raster_df <- createCyclicalTime(raster_df, "Time")
  # Remove time column after adding cyclical time
  raster_df <- subset(raster_df, select = -c(Time))
  
  # 4. Predict probabilities for each raster cell
  # Compute probability for each raster cell based on the regression model and values in the raster
  raster_df$prob <- predict(model, newdata = raster_df, type = "response")
  
  # 5. Attach x and y from original covariate_df
  raster_df$x <- covariate_df$x
  raster_df$y <- covariate_df$y
  
  # 6. Convert prediction to raster
  prob_raster <- rast(raster_df[, c("x", "y", "prob")], type = "xyz", crs = "EPSG:32735")

  # 7. Save as GeoTIFF, so that it can be loaded into dashboard
  writeRaster(prob_raster, filename = output_path, overwrite = TRUE)
  
  return(prob_raster)
}