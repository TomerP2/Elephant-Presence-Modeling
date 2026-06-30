modelEvaluation <- function(final_model, testElephantData) {
    # 1. Check for multicollinearity among predictors  
    # Variance Inflation Factor (VIF) values > 5–10 indicate possible multicollinearity issues 
    multicollinearity <- vif(final_model) 

    # 2. Generate predictions on the test dataset  
    # 'type = "response"' returns predicted probabilities between 0 and 1 
    testElephantData$prob <- predict(final_model, newdata = testElephantData, type = "response") 

    # Convert probabilities into binary predictions: 
    #   - If predicted probability > 0.5 → predict presence (1) 
    #   - Else → predict absence (0) 
    testElephantData$pred <- ifelse(testElephantData$prob > 0.3, 1, 0) 

    # 3. Evaluate classification performance  
    # Create a confusion matrix comparing predicted vs actual outcomes
    conf_matrix <- confusionMatrix(as.factor(testElephantData$pred), as.factor(testElephantData$Elephant)) 

    # 4. Compute and visualize ROC curve & AUC  
    # ROC (Receiver Operating Characteristic) curve shows trade-off between 
    # true positive rate and false positive rate across probability thresholds. 
    # AUC (Area Under Curve) quantifies model performance (1.0 = perfect, 0.5 = random) 
    roc_obj <- roc(testElephantData$Elephant, testElephantData$prob) 
    cat("AUC value:", auc(roc_obj), "\n") 
    
    # Plot ROC curve 
    plot(roc_obj, col = "skyblue", lwd = 2, main = "Receiver Operating Characteristic (ROC) Curve") 

    return(list(multi_lin = multicollinearity, conf_matrix = conf_matrix))
}