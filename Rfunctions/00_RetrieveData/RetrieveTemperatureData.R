retrieveTemperatureData <- function(data_path = "data/weather/Biomonitoring Camp/") {
  # Description: 
  #   Reads all CSV temperature files in the specified weather data folder,
  #   combines them into a single dataset of timestamped heat index values,
  #   computes daily average heat index values between 07:00 and 19:00, and
  #   classifies each day into quartiles based on the distribution of daily averages.
  #
  # Inputs:
  #  - data_path: character; path to the folder containing the temperature csv's.
  #
  # Outputs:
  #  - A list with two data frames:
  #    - heat_index_data: Data frame with columns `Time`, `Heat_Index`
  #    - daily_data: Data frame with columns `Date`, `Avg_Heat_Index`, `Quartile`
  # 
  # The quartile thresholds (`IQR1`, `IQR2`, `IQR3`) are stored as an
  # attribute named `"Quartile"` in `daily_data`.
  #
  # Example usage:
  #  temperature_data_list <- retrieveTemperatureData("data/temperature_data")
  #  temperature_data <- temperature_data_list$heat_index_data
  #  daily_temp_data <- temperature_data_list$daily_data

  # Get all CSV files
  files <- list.files(path = data_path, pattern = "\\.csv$", full.names = TRUE)
  
  # Initialize combined datasets
  heat_index_combined <- data.frame()
  daily_heat_index_combined <- data.frame()
  
  for (file in files) {
    # Read CSV safely
    df <- tryCatch({
      read.csv(file, check.names = FALSE, stringsAsFactors = FALSE)
    }, error = function(e) {
      message(paste("Failed to read", file, ":", e$message))
      return(NULL)
    })
    if (is.null(df)) next
    
    # Detect date format. 
    # Needed because some files use first format and others use second format.
    if (grepl("/", df$Time[1])) {
      df$Time <- as.POSIXct(df$Time, format = "%m/%d/%Y %H:%M", tz = "UTC")
    } else {
      df$Time <- as.POSIXct(df$Time, format = "%Y-%m-%d %H:%M:%S", tz = "UTC")
    }
    
    # Keep only Time and Heat Index
    df <- df[, c("Time", "Heat Index")]
    names(df) <- c("Time", "Heat_Index")
    
    # Combine timestamp-level data
    heat_index_combined <- bind_rows(heat_index_combined, df)
  }
  
  # ---- Create daily averages and quartile classification ----

  # Get temperatures between 07 and 19 (daytime)
  heat_between_07_19 <- heat_index_combined %>%
    filter(format(Time, "%H") >= "07", format(Time, "%H") < "19")
  
  # Get averages per day
  daily_heat_index_combined <- heat_between_07_19 %>%
    mutate(Date = as.Date(Time)) %>%
    group_by(Date) %>%
    summarise(Avg_Heat_Index = mean(Heat_Index, na.rm = TRUE), .groups = "drop")
  
  # Compute quartiles
  quants <- quantile(daily_heat_index_combined$Avg_Heat_Index, probs = c(0.25, 0.5, 0.75), na.rm = TRUE)
  IQR1 <- quants[1]; IQR2 <- quants[2]; IQR3 <- quants[3]
  
  # Classify quartiles
  daily_heat_index_combined <- daily_heat_index_combined %>%
    mutate(Quartile = case_when(
      Avg_Heat_Index < IQR1 ~ 1,
      Avg_Heat_Index < IQR2 ~ 2,
      Avg_Heat_Index < IQR3 ~ 3,
      TRUE ~ 4
    ))
  
  # Attach IQRs as attribute
  attr(daily_heat_index_combined, "IQRs") <- c(IQR1 = IQR1, IQR2 = IQR2, IQR3 = IQR3)
  
  # Return both datasets
  return(list(
    heat_index_data = heat_index_combined,
    daily_data = daily_heat_index_combined
  ))
}