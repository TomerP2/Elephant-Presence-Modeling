# Modeling Elephant Presence Using Environmental Covariates in the Welgevonden Game Reserve 
**Team name:** speedy_ducks_of_Alisa_and_Tomer

**Names:** Alisa Janssen, Jurre Bakker, Tomer Peled, Sophia Staheli

**Challenge 10**

**Notes**: We worked in a different repository: https://git.wur.nl/speedy-geese-of-defiance/speedy-elephants-of-defiance


## Objective
This project aims to model elephant presence based on environmental covariates, visualizing the results in an interactive dashboard. 

**Specifically, we aim to answer these questions:**
* Where is elephant presence most frequent throughout the years 2018-2020 in the Welgevonden Game Reserve?
    - Can kernel density estimates (KDE) of elephant locations identify hotspots of elephant activity?
* Using a logistic regression model, how accurately can we predict the event of an elephant being at a location given a specific time and temperature?
* Which environmental factors are most strongly correlated with elephant presence in the study area?

Although this project uses elephant data from the Welgevonden Game Reserve, users can easily adapt the code for their own reserve by changing the data inputs and environmental variables.

## Methods

### Data Sources
All data used in this project belongs to the Welgevonden Game Reserve, and shared with Wageningen University for education purposes only.

This data includes elephant tracking data, elephant metadata, weather data, and additional GIS layers used as environmental covariates.

### Data Summary
* **Elephant tracking data:** 10 African elephants (linked with tag attribute) in the reserve from 2018-2021, with temporal resolution mainly between 30 and 10 minutes
* **Elephant metadata:** Includes the tag, sex, and name of all elephants
* **Weather data:** Captured near the main gate (-24.203323°, 27.903202°), with 3 minute time intervals between 01-01-2018 and 01-01-2020.
* **GIS Layers:**
    + **Human Settlements:** 2 vector point layers depicting staff accommodations and lodges.
    + **Roads:** A vector point layer showing the roads on the reserve.
    + **Elevation:** A DEM raster layer of the elevation of the reserve.
    + **Reserve Area:** Boundary polygon shapefile of the reserve.
    + **Reservoirs and Cribs:** A vector point layer showing artificial water sources.

### Logistic Regression Model

Logistic regression to predict the probability of elephant presence.  
- Uses environmental covariates (e.g., distance to roads, settlements, elevation, temperature, time).  
- Evaluated with confusion matrix, ROC curve, and AUC; multicollinearity checked with VIF.  

Output: Pre-trained model saved as `final_model.rds` and used in the dashboard for interactive probability maps.  

## How to run
1. **Obtaining the data**
    * To get access to the data, email tomer.peled@wur.nl.
    * If you already have the data, make sure the file paths in config.R are pointing to the right location.

2. **Train the model**
    * Run `train_model.R` to prepare the data, train the logistic regression model, and save the trained model as an .rds file (`final_model.rds`).
    * This step only needs to be done once! The saved model will be used directly by the dashboard.

3. **Launch the dashboard**
    * Run `main.R` to start the interactive Shiny application.
    * The dashboard will load the saved model (`final_model.rds`) and have options of displaying:
        - A Kernel Density Estimation (KDE) map of elephant locations.
        - A Location Predictor tool where users can adjust environmental sliders (temperature, time of day) to visualize predicted elephant occurrence probabilities.


## File Structure
**main.R:** 
* Prepares and then runs dashboard.

**train_model.R:** 
* Trains the model based on the data given in config.R, and saves the final model (`models/final_model.rds`).

**ElephantFunctions:**
* Folder that contains all the functions to process the data, train the model, and run the model from the dashboard.
* Subdirectories:
    - 00_RetrieveData
    - 01_DataProcessing
    - 02_ModelTraining
    - 03_ModelUsage
    - 04_Helpers

**server.R:**
* Contains code to run the dashboard.

**ui.R:**
* Specifies dashboard functionality and user interaction.

**config.R:**
* Contains code for loading packages, functions, and defines data paths.

**prepare_data.R**
* Reads and runs functions to prepare data for training the model, as well as running the model. 

**models**
* Folder that contains saved final model after training the model.

## Acknowledgements

We would like to thank Jasper Eikelboom for providing the elephant tracking data and project framework, as well as for his guidance and support throughout the process.


## References

* The logistic regression model implemented in this dashboard was originally developed by group member Alisa Janssen for her bachelor's thesis at the University of Amsterdam.
* Chatgpt was used to help debug and write code in this project.
* Source: [RDocumentation.org](https://www.rdocumentation.org/)
    - Main source for function references.

