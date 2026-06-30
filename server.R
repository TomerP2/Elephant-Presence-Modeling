server <- function(input, output) {

  current_raster <- reactiveVal(NULL)
  
  # Event after user clicks "Run" button
  observeEvent(input$run, {

    # Events when "Elephant Location Predictor" is selected
    if (input$Maps == "Elephant Location Predictor") {
      # Run the time and temp based model to create an elephant prediction raster
      timetemp_elephant_loc <- createPredictionRaster(
      model = final_model,
      covariate_df = covariate_df,
      temp = input$temp,
      time = input$time,
      output_path = "elephant_heatmap_dashboard.tif")
      # Save timetemp_elephant_loc to reactiveVal
      current_raster(timetemp_elephant_loc)
      # Plot the raster in the main panel
      output$kde_plot <- renderPlot({
      plot(current_raster(), main = paste("Probability Distribution of Elephant Presence:", input$temp, "C at", format(input$time, "%H:%M")))
      })
    }

    # Events when "General Elephant Presence" is selected
    if (input$Maps == "General Elephant Presence") {
      # Retrieve elephant data and create KDE raster based on selected resolution
      df <- retrieveElephantsData(elephant_points_path, elephant_attributes_path)
      kde <- createHeatMap(df, input$resolution)
      # Save kde to reactiveVal
      current_raster(kde)
      # Plot the raster in the main panel
      output$kde_plot <- renderPlot({
        plot(current_raster(), main = paste("Resolution:", input$resolution))
      })
    }
  })
  
  output$exp <- downloadHandler(
    # Download the currently displayed raster
    filename = function() {
      paste0("exported_map", ".tif")
    },
    content = function(file) {
      terra::writeRaster(current_raster(), file, filetype = "GTiff", overwrite = TRUE)
    }
  )
}