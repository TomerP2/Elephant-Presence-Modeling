ui <- fluidPage(
  # Used a nice looking theme:)
  theme = bs_theme(bootswatch = "yeti"),

  titlePanel("Elephant Locations Dashboard"),
  # Sidebar layout
  sidebarLayout(
    sidebarPanel(
      
      selectInput("Maps", "Choose what you want to see", choices = c('General Elephant Presence', 'Elephant Location Predictor')),
      # resolution slider only when "General Elephant Presence" is selected
      conditionalPanel(condition = "input.Maps == 'General Elephant Presence'",
        sliderInput(inputId = 'resolution', label = "Resolution (rec:1000)", min = 100, max = 1000, value = 1000),
      ),
      # time and temp inputs only when "Elephant Location Predictor" is selected
      conditionalPanel(condition = "input.Maps == 'Elephant Location Predictor'",
        sliderInput(inputId = "temp", label = "enter temperature in C:", min = 10, max = 30, value = 10),
        timeInput(inputId = "time", label = "Enter time of day:", value = strptime("10:00", "%H:%M"), seconds = FALSE)
      ),
      # action button to run the model and export the raster
      actionButton("run", "Run"),
      downloadButton("exp", "Export")
    ),
    # Main panel for displaying outputs
    mainPanel(
      plotOutput("kde_plot"),
    )
  )
)
