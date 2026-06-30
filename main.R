# Load in config stuff
source("config.R")

# Prepare data
source("prepare_data.R")

# Load trained model
final_model <- readRDS("models/elephant_model_00.rds")

# Run dashboard
runApp()
