createCyclicalTime <- function(in_df, timestamp_col) {
  # Description:
  #   Encode hour-of-day as cyclical features (sine and cosine) and append them to the input dataframe.
  #   This preserves the circular nature of time for models (e.g., 23:00 close to 00:00).
  #   See also: 
  #   https://developer.nvidia.com/blog/three-approaches-to-encoding-time-information-as-features-for-ml-models/
  #
  # Inputs:
  #   - in_df: data.frame or tibble; dataframe containing a POSIXct/POSIXlt timestamp column.
  #   - timestamp_col: character; name of the timestamp column in `in_df` (string).
  #
  # Outputs:
  #   - Returns the input dataframe (data.frame/tibble) with three new columns added:
  #       * Hour      : integer hour extracted from the timestamp (0-23)
  #       * Hour_sin  : numeric; sin(2*pi*Hour/24)
  #       * Hour_cos  : numeric; cos(2*pi*Hour/24)
  #
  # Example usage:
  #   df <- data.frame(ts = as.POSIXct(c('2021-01-01 00:00', '2021-01-01 12:00'), tz='UTC'))
  #   df_out <- createCyclicalTime(df, 'ts')

  # Extract hour from timestamp column
  in_df$Hour <- lubridate::hour(in_df[[timestamp_col]])

  # Cyclical encoding
  in_df$Hour_sin <- sin(2 * pi * in_df$Hour / 24)
  in_df$Hour_cos <- cos(2 * pi * in_df$Hour / 24)

  return(in_df)
}