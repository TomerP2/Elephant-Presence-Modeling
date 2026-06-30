dataPreparationForModel <- function(elephantData, noElephantData) {
    # Add extra column to both datasets indicating whether the location is an elephant or non-elephant location 
    # (1 = elephant present, 0 = no elephant present) to both data sets.
    elephantData$Elephant <- 1 
    noElephantData$Elephant <- 0 

    # Combine elephant and non-elephant datasets into one dataset 
    elephantData <- bind_rows(elephantData, noElephantData)

    # --- Splitting of training and testing data sets for model reaction (training data) and model accuracy (testing data) ---

    # Setting seed for reproducibility; now it will always split the same way (can be set to any random number)
    set.seed(42) 
    # Creating index for splitting the data; 80% training data and 20% testing data 
    train_index <- createDataPartition(elephantData$Elephant, p = 0.8, list = FALSE) 
    # Separating the training data from the elephant data (80% of elephant data) 
    trainElephantData <- elephantData[train_index, ] 
    # Separating the testing data from the elephant data (20% of elephant data) 
    testElephantData <- elephantData[-train_index, ] 

    # Standardizing the numeric values within the model so that magnitude of coefficient in model can be compared to each other 
    # Selecting columns for standardization
    # Standardizing the numeric values within the model

    # Seperating numeric columns except the Elephant presence column
    numeric_columns <- sapply(trainElephantData, is.numeric)

    # Seperating the Elephant presence column from numeric columns
    numeric_columns["Elephant"] <- FALSE

    # Getting the names of numeric columns
    numeric_names <- names(trainElephantData)[numeric_columns]

    # Calculate mean and standard deviation of columns in numeric_names of the training data 
    train_means <- sapply(trainElephantData[, numeric_columns], mean, na.rm = TRUE)
    train_sds <- sapply(trainElephantData[, numeric_columns], sd, na.rm = TRUE)

    # Standardize training data (create data frames for these so they can be used in regrassion model later)
    trainElephantData[, numeric_names] <- as.data.frame(scale(trainElephantData[, numeric_names], center = train_means, scale = train_sds))
    
    # Standardize test data using training means and standard deviations, this is done with the training data’s means and standard deviations, because the testing data is treated as is doesn’t exist yet
    testElephantData[, numeric_names] <- as.data.frame(scale(testElephantData[, numeric_names], center = train_means, scale = train_sds))

    return(list(trainingData = trainElephantData, testData=testElephantData))
}