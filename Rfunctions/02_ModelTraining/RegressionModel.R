regressionModel <- function(trainElephantData) {
    # Creating a forward stepwise regression model 
    # This script iteratively adds predictor variables to a logistic regression 
    # model based on statistical significance (p-values). In each step, the variable 
    # that most improves model fit (lowest p-value from a likelihood ratio test) 
    # is added — until no remaining variables meet the threshold for inclusion. 

    # Create variable to select all the variables that will be included in the model except the Elephant presence column
    all_vars <- setdiff(colnames(trainElephantData), "Elephant")
    # Create empty variable to store variables in the model 
    selected_vars <- c() 
    # Create variable to show variables that are not included in the model 
    remaining_vars <- all_vars 

    # Set threshold for model inclusion 
    threshold <- 0.05 

    # Creating the Forward Stepwise Logistic Regression Model by a stepwise selection loop 
    # Initialize step counter 
    step <- 1   

    # Start the stepwise selection loop
    repeat { 
        cat("Step", step, "\n") 
        # 1. Compute p-values for all remaining variables 
        # For each variable not yet in the model: 
        #   - A logistic regression model is fitted that includes all selected 
        #     variables + this remaining variable. 
        #   - If there are no selected variables yet, a univariate model is fitted. 
        #   - Compare the full model (reduced model + one additional candidate 
        #     variable) to the reduced model (model consisting of variables that are 
        #     currently selected) using a likelihood ratio test (Chi-square test). 
        #   - The p-value is recorded for that variable’s contribution. 

        # If no variables are left, stop
        if (length(remaining_vars) == 0) {
        cat("  --> No remaining variables to add. Stopping.\n\n")
        break
        }
        
        p_values <- sapply(remaining_vars, function(var) { 
            # Build formulas dynamically, e.g. "Elephant ~ var1 + var2" 
            formula_with_candidate <- as.formula(paste("Elephant ~", paste(c(selected_vars, var), collapse = " + "))) 

            if (length(selected_vars) == 0) { 
                # Case 1: No variables are selected yet -> just fit a simple univariate model: Elephant ~ var 
                single_model <- glm(formula_with_candidate, data = trainElephantData, family = binomial) 
                return(summary(single_model)$coefficients[2, "Pr(>|z|)"]) 
            } else { 
                # Case 2: Some variables already selected -> fit two models: 
                #   (a) Current model: with currently selected variables 
                #   (b) Model with candidate: same + one additional candidate variable 
                formula_current <- as.formula(paste("Elephant ~", paste(selected_vars, collapse = " + "))) 
                model_current <- glm(formula_current, data = trainElephantData, family = binomial) 
                model_with_candidate <- glm(formula_with_candidate, data = trainElephantData, family = binomial)

                # Likelihood ratio test (Chi-square) comparing reduced vs. full model 
                comparison_test <- anova(model_current, model_with_candidate, test = "Chisq") 

                # Return p-value of the additional variable (row 2 of test output) 

                return(comparison_test$`Pr(>Chi)`[2]) 
            } 
        })

        # 2. Select the best variable (lowest p-value) 
        min_p <- min(p_values, na.rm = TRUE) # smallest p-value among candidates 
        best_candidate <- names(p_values)[which.min(p_values)] # corresponding variable name to smallest p-value 

        # 3. Decide whether to add the variable to the model 
        if (min_p < threshold) { 
            # Add the selected variable to the model 
            selected_vars   <- c(selected_vars, best_candidate) 
            remaining_vars  <- setdiff(remaining_vars, best_candidate) 
            cat("  --> Added:", best_candidate, "with p =", round(min_p, 4), "\n\n") 
            step <- step + 1  # Increment step counter 
        } else { 
            # Stop when no variable meets the significance threshold 
            cat("  --> No additional variables below p =", threshold, ". Stopping.\n\n") 
            break 
        } 
    } 

    # Final model with all selected variables
    final_formula <- as.formula(paste("Elephant ~", paste(selected_vars, collapse = " + "))) 
    cat("Final model formula:\n") 

    # Fit the final logistic regression model on the training data 
    # 'family = binomial' specifies logistic regression (for binary outcomes) 
    final_model <- glm(final_formula, data = trainElephantData, family = binomial) 
    
    # View model summary (coefficients, significance, etc.) 
    summary_final_model <- summary(final_model) 

    return(list(formula = final_formula, model = final_model, summary = summary_final_model))
}
