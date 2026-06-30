addTemperatureData <- function(in_data, datetime_col, temp_data, max_time_diff) {
  # Attach nearest Heat_Index values from a time series (temp_data) to an sf dataframe
  # (in_data) based on timestamps. For each row in in_data the nearest temp_data row
  # (before or after) is selected if within max_time_diff minutes; otherwise NA is used.
  #
  # Inputs:
  #  - in_data: sf/data.frame; input data with a datetime column (POSIXct).
  #  - datetime_col: character; name of the timestamp column in in_data.
  #  - temp_data: data.frame; must contain 'Time' (POSIXct) and 'Heat_Index' (numeric).
  #  - max_time_diff: numeric; maximum allowed time difference in minutes to accept a match.
  #
  # Outputs:
  #  - An sf/data.frame: same rows as in_data with an added numeric column 'Heat_Index'.
  #
  # Example usage:
  #  library(sf)
  #  in_data <- data.frame(id = 1:2, ts = as.POSIXct(c("2025-10-15 10:05", "2025-10-15 11:20"), tz="UTC"))
  #  temp_data <- data.frame(Time = as.POSIXct(c("2025-10-15 10:00","2025-10-15 11:00"), tz="UTC"),
  #                          Heat_Index = c(30.5, 32.1))
  #  result <- addTemperatureData(in_data, "ts", temp_data, max_time_diff = 30)

  # Check columns
  if (!(datetime_col %in% names(in_data))) {
    stop(paste("Column", datetime_col, "not found in in_data"))
  }
  if (!("Time" %in% names(temp_data)) || !("Heat_Index" %in% names(temp_data))) {
    stop("temp_data must contain 'Time' and 'Heat_Index' columns")
  }
  
  # Sort temp_data by time
  temp_data <- temp_data[order(temp_data$Time), ]
  
  # Extract vectors
  in_times <- in_data[[datetime_col]]
  temp_times <- temp_data$Time
  
  # Find position of nearest earlier timestamp
  idx_before <- findInterval(in_times, temp_times)
  
  # Determine which of the two closest (before/after) is nearer
  idx_after <- pmin(idx_before + 1, length(temp_times))
  
  # Compute time differences
  diff_before <- abs(difftime(in_times, temp_times[pmax(idx_before, 1)], units = "mins"))
  diff_after  <- abs(difftime(in_times, temp_times[idx_after], units = "mins"))
  
  # Pick nearest (before or after)
  use_after <- diff_after < diff_before
  nearest_idx <- ifelse(use_after, idx_after, pmax(idx_before, 1))
  
  # Filter out values beyond max_time_diff
  min_diffs <- pmin(diff_before, diff_after)
  heat_index <- ifelse(min_diffs <= max_time_diff,
                       temp_data$Heat_Index[nearest_idx],
                       NA_real_)
  
  # Add to data
  in_data$Heat_Index <- heat_index
  return(in_data)
}