# ==================================================================================================
# Functions to profile one group against another
# 
# profile - compares categorical variables only
# profileMeans - compares means of numeric variables
# correlate - calculates correlations between all numeric variables and a numeric target
# eval - predictive model evaluation measures, for either binary or categorical response
#
# Author: Stephan Curiskis
# Date: 15 April 2016


comparisons <- function(data, excelFile = "Comparisons.xlsx") {
  # Function runs full profiling of a binary target.
  #
  # Args:
  #   data:   Input data set.  First column must be an ID, second column must be the target.  
  #   excelFile:  File name to ouptu profiles to.
  # Returns:
  #   No R objects are returned.  
  #   An excel file with name excelFile is created, with three sheets:
  #     Correlations:  Output from correlations function.
  #     Means:         Output from profileMeans function.
  #     Profiles:      Output from profile function.

  cat("Running comparisons... ")
  
  # Take only categorical predictors for profile function, numeric for correlate function
  data_profile <- data[, c(1,2)]
  data_correlate <- data[, c(1,2)]
  for (i in colnames(data[, -c(1,2)])) {
    if (is.factor(data[, i]) == T) {
      data_profile <- cbind(data_profile, setNames(data.frame(data[, i]), i))
    } else {
      data_correlate <- cbind(data_correlate, setNames(data.frame(data[, i]), i))
    }
  }

  # Run profile() function -----------------------------
  cat(" categorical profiles...")
  profiles <- data.frame(profile(data_profile))
  
  # Run correlate() function -----------------------------
  cat(" correlations...")
  # Correlation analysis and comparison of averages between two groups
  corr <- correlate(data_correlate)
  
  # Run profileMeans() function -----------------------------
  cat(" means...")
  means <- profileMeans(data_correlate, num_filters = 0)
  
  cat("Finished\n\n")

  # Write results to Excel file 
  cat(sprintf("Writing results to Excel file: %s ... ", excelFile))
  write.xlsx2(corr, excelFile, sheetName="Correlations", row.names=F, showNA=F)
  write.xlsx2(means, excelFile, sheetName="Means", append=T, row.names=F, showNA=F)
  write.xlsx2(profiles, excelFile, sheetName="Profiles", row.names=F, showNA=F, append=T)
  
  cat("Finished\n\n")
}



profile <- function(data, num_filters = 0) {
  # Function runs categorical profiles of a binary target.
  #
  # Args:
  #   data:  Input data set.  First column must be an ID, second column must be a binary target,
  #          all other columns should be factors
  # Returns:
  #   table:  data.frame with profiling for all fields against the target, complete with index 
  #           scores and Z-scores
  
  data_profile <- data[, 1:2]
  for (i in colnames(data[, -c(1,2)])) {
    if (is.factor(data[, i]) == T) {
      data_profile <- cbind(data_profile, setNames(data.frame(data[, i]), i))
      }
  }
  data <- data_profile
  rm(data_profile)
  
  if (num_filters == 0) {
    # Initialise empty data.frame
    profile.df <- data.frame(Field = character(), FieldValue = character(), Base = character(),
                            Target = character(), Base_PT = character(), Total_PT = character(),
                            Index = character(), ZScore = character())
    
    # Iterate over the profiling fields
    for (i in 3:length(data)) {
      # Calculate frequency of False class by the profiling field
      a <- setNames(data.frame(table(data[i][data[2] == 0])), c("FieldValue","Base"))
      # Calculate frequency of True class by the profiling field
      b <- setNames(data.frame(table(data[i][data[2] == 1])), c("FieldValue","Target"))
      # Merge frequencies for both classes together into the same data.frame
      c <- merge(a, b, by = intersect(names(a), names(b)), all = TRUE)
      # Set any NAs to be 0
      c$Base[is.na(c$Base)] <- 0; c$Target[is.na(c$Target)] <- 0
      # Calculate total counts for each class
      n1 <- sapply(c[2], sum); n2 <- sapply(c[3], sum)
      # Calculate percentages
      c <- setNames(data.frame(c, c[2] / n1, c[3] / n2, (c[2] + c[3]) / sapply(c[2] + c[3], sum) ), 
                    c(colnames(c), "Base_PT", "Target_PT", "Total_PT"))
      # Calculate Index and Z scores
      c <- setNames(data.frame(c, 
                    100 * c[5] / c[4], (c[5] - c[4]) / sqrt(c[6] * (1 - c[6]) * (1 / n1 + 1 / n2) ) ),
                      c(colnames(c), "Index","ZScore"))
      # Add field name to the data.frame
      c <- setNames(data.frame(rep(names(data[i]), length(c[, 1])), c, row.names = NULL), 
                      c("Field", colnames(c)) )
      # Add rows to main data.frame
      profile.df <- rbind(profile.df, c)
    }
    
    # Add Significance field
    profile.df <- setNames(data.frame(profile.df[profile.df$Index != Inf, ] 
                        ,ifelse(abs(profile.df[profile.df$Index != Inf, ]$ZScore) > 2.58, "Y", "N")) 
                           ,c(colnames(profile.df), "Sig", row.names = NULL))
    # Re-order data
    profile.df <- data.frame(profile.df[with(profile.df, order(Field, FieldValue)), ], 
                              row.names = NULL)
    # Format output
    profile.df <- setNames(data.frame(profile.df$Field, profile.df$FieldValue, 
                                      profile.df$Base, profile.df$Target, 
                                      paste(100 * round(profile.df$Base_PT, 4), "%", sep = ""),
                                      paste(100 * round(profile.df$Target_PT, 4), "%", sep = ""),
                                      paste(100 * round(profile.df$Total_PT, 4), "%", sep = ""),
                                      round(profile.df$Index, 2), 
                                      round(profile.df$ZScore, 2), profile.df$Sig)
                                        ,colnames(profile.df))
    profile.df <- profile.df[with(profile.df, order(Field, FieldValue)), ]
                           
  } else {
    # Initialise empty data.frame
    profile.df <- data.frame(Field = character(), FieldValue = character(), Base = character(),
                            Target = character(), Base_PT = character(), Total_PT = character(),
                            Index = character(), ZScore = character(), FilterField = character(),
                            FilterValue = character())
    data_original <- data
    # If num_filters is not 0, then subset the data by values of filter fields ----------------
    # Iterate over filter fields
    for (j in 1:num_filters) {
      # Create unique vector of filter values
      filter <- unique(data_original[, (j + 2)])
      filter <- filter[!is.na(filter)]
      # Iterate over field values
      for (k in 1:length(filter)) {
        # Subset the data
        data <- data_original[data_original[, (j + 2)] == filter[k], -c(3:(2 + num_filters))]
        # Create target
        #target <- data_original$Target[data_original[, (j + 2)] == filter[k]]
        # Iterate over the profiling fields
        for (i in 3:length(data)) {
          # Calculate frequency of False class by the profiling field
          a <- setNames(data.frame(table(data[i][data[2] == 0])), c("FieldValue","Base"))
          # Calculate frequency of True class by the profiling field
          try(b <- setNames(data.frame(table(data[i][data[2] == 1])), c("FieldValue","Target")), silent=T)
          if (!exists("b")) {
            b <- setNames(data.frame(unique(data[i]), 0), c("FieldValue","Target"))
          }
          # Merge frequencies for both classes together into the same data.frame
          c <- merge(a, b, by = intersect(names(a), names(b)), all = TRUE)
          # Set any NAs to be 0
          c$Base[is.na(c$Base)] <- 0; c$Target[is.na(c$Target)] <- 0
          # Calculate total counts for each class
          n1 <- sapply(c[2], sum); n2 <- sapply(c[3], sum)
          # Calculate percentages
          c <- setNames(data.frame(c, c[2] / n1, c[3] / n2, (c[2] + c[3]) / sapply(c[2] + c[3], sum) ), 
                        c(colnames(c), "Base_PT", "Target_PT", "Total_PT"))
          # Calculate Index and Z scores
          c <- setNames(data.frame(c, 
                        100 * c[5] / c[4], (c[5] - c[4]) / sqrt(c[6] * (1 - c[6]) * (1 / n1 + 1 / n2) ) ),
                          c(colnames(c), "Index","ZScore"))
          # Add field name to the data.frame
          c <- setNames(data.frame(rep(names(data[i]), length(c[, 1])), c, row.names = NULL), 
                          c("Field", colnames(c)) )
          # Add filter field and value to data.frame
          c <- data.frame(c, data.frame(colnames(data_original)[2 + j], filter[k]))
          colnames(c) <- c(colnames(c)[1:9], "FilterField", "FilterValue")
          # Add rows to main data.frame
          profile.df <- rbind(profile.df, c)
          # Clean up
          rm(a); rm(b); rm(c)
        }
      }
    }
        
    # Add Significance field
    profile.df <- setNames(data.frame(profile.df[profile.df$Index != Inf, ] 
                        ,ifelse(abs(profile.df[profile.df$Index != Inf, ]$ZScore) > 2.58, "Y", "N")) 
                           ,c(colnames(profile.df), "Sig", row.names = NULL))
    # Re-order data
    profile.df <- data.frame(profile.df[with(profile.df, order(Field, FieldValue)), ], 
                              row.names = NULL)
    # Format output
    profile.df <- setNames(data.frame(profile.df$Field, profile.df$FieldValue, 
                                      profile.df$Base, profile.df$Target, 
                                      paste(100 * round(profile.df$Base_PT, 4), "%", sep = ""),
                                      paste(100 * round(profile.df$Target_PT, 4), "%", sep = ""),
                                      paste(100 * round(profile.df$Total_PT, 4), "%", sep = ""),
                                      round(profile.df$Index, 2), 
                                      round(profile.df$ZScore, 2), 
                                      profile.df$FilterField, profile.df$FilterValue, profile.df$Sig)
                                        ,colnames(profile.df))
    profile.df <- profile.df[with(profile.df, order(FilterField, FilterValue, Field, FieldValue)), ]  
  }
  
  profile <- list("table" = profile.df)
  return(profile)
}




profileMeans <- function(data, num_filters = 0) {
  # Function calculates and compares average values for numeric fields across binary classes
  # 
  # Args:
  #   data:   Input data set.  First column must be an ID, second column must be a binary target,
  #           all other columns should be numeric or will be ignored
  #   num_filters:   Specifies how many fields should be used to filter the dataset by.  Filtering
  #                  subsets the data be each unique value of the field, and recalculates.  
  #                  Filtering fields should be the third field onwards.
  # Returns:  data.frame with profiling for all fields against the target, complete with index 
  #           scores and Z-scores

  # Load required packages
  library(Hmisc, quietly=T)
  # Initialise data.frame
  psych_summary <- data.frame()
  # Create logical vector indicating whether fields are numeric
  numbers <- sapply(data[, -c(1,2)], is.numeric)
  
  # Check whether there are any numeric fields
  if (any(numbers)) {
    # Iterate over profiling numeric fields
    for (i in 1:(ncol(data) - num_filters - 2)) {
      # If num_filters is 0, calcualte mean profiles
      if (num_filters == 0) {
        # Create new data set removing non-numeric fields
        psych.d <- data[, -c(1,2)]
        # Create target variable
        target <- data$Target
        # Calculate total mean
        psych_summary_total <- sapply(list(psych.d[, i])
                                      , FUN = function(x) {c("mean" = mean(x, na.rm = T), 
                                                           "sd" = sd(x, na.rm = T), 
                                                           "count" = length(x))})
        # Calculate group means
        psych_summary_temp <- summarize(psych.d[, i], target
                                        , function(x) {c("mean" = mean(x, na.rm = T), 
                                                         "sd" = sd(x, na.rm = T), 
                                                         "count" = length(x[!is.na(x)]))})
        # Calculate Z-score
        psych_summary_temp$Z <- (psych_summary_temp[2, 2] - psych_summary_temp[1, 2]) / 
                                    (psych_summary_total[2] / sqrt(psych_summary_temp[2, 4]))
        # Add column names
        psych_summary_temp <- data.frame(psych_summary_temp, colnames(psych.d)[i])
        colnames(psych_summary_temp) <- c("Target", "mean", "sd", "count", "Z-score", "attribute")
        # Flatten
        if (length(psych_summary_temp$Target) < 2) {
          next
          } else {
          psych_summary_temp2 <- data.frame("Variable" = psych_summary_temp$attribute[1],
                          "Base_score" = psych_summary_temp$mean[psych_summary_temp$Target == 0],
                          "Target_score" = psych_summary_temp$mean[psych_summary_temp$Target == 1],
                          "Difference" = psych_summary_temp$mean[psych_summary_temp$Target == 1]
                              - psych_summary_temp$mean[psych_summary_temp$Target == 0],
                          "Base_n" = psych_summary_temp$count[psych_summary_temp$Target == 0],
                          "Target_n" = psych_summary_temp$count[psych_summary_temp$Target == 1],
                          "Z-score" = psych_summary_temp[psych_summary_temp$Target == 1, 5])
        }
        # Append rows to final data.frame
        psych_summary <- rbind(psych_summary, psych_summary_temp2)
      } else {
        # If num_filters is not 0, then subset the data by values of filter fields ----------------
        # Iterate over filter fields
        for (j in 1:num_filters) {
          # Create unique vector of filter values
          filter <- unique(data[, (j + 2)])
          # Iterate over field values
          for (k in 1:length(filter)) {
            # Subset the data
            psych.d <- data[data[, (j + 2)] == filter[k], -c(1:(2 + num_filters))]
            # Create target
            target <- data$Target[data[, (j + 2)] == filter[k]]
            
            # Calculate total mean
            psych_summary_total <- sapply(list(psych.d[, i])
                                          , FUN = function(x) {c("mean" = mean(x, na.rm = T), 
                                                                 "sd" = sd(x, na.rm = T), 
                                                                 "count" = length(x))})
            # Calculate group means
            psych_summary_temp <- summarize(psych.d[, i], target
                                            , function(x) {c("mean" = mean(x, na.rm = T), 
                                                             "sd" = sd(x, na.rm = T), 
                                                             "count" = length(x[!is.na(x)]))})
            # Calculate Z-score
            psych_summary_temp$Z <- (psych_summary_temp[2, 2] - psych_summary_temp[1, 2]) / 
                                        (psych_summary_total[2] / sqrt(psych_summary_temp[2, 4]))
            # Add column names
            psych_summary_temp <- data.frame(psych_summary_temp, colnames(psych.d)[i])
            colnames(psych_summary_temp) <- c("Target", "mean", "sd", "count", 
                                              "Z-score", "attribute")
            # Flatten
            if (length(psych_summary_temp$Target) < 2) {next} else {
              psych_summary_temp2 <- data.frame("Variable" = psych_summary_temp$attribute[1],
                          "Base_score" = psych_summary_temp$mean[psych_summary_temp$Target == 0],
                          "Target_score" = psych_summary_temp$mean[psych_summary_temp$Target == 1],
                          "Difference" = psych_summary_temp$mean[psych_summary_temp$Target == 1]
                              - psych_summary_temp$mean[psych_summary_temp$Target == 0],
                          "Base_n" = psych_summary_temp$count[psych_summary_temp$Target == 0],
                          "Target_n" = psych_summary_temp$count[psych_summary_temp$Target == 1],
                          "Z-score" = psych_summary_temp[psych_summary_temp$Target == 1, 5])
            }
            # Append rows to final data.frame
            psych_summary <- rbind(psych_summary, psych_summary_temp2)
          }
        }
      }
    }
    results <- list(psych_summary)
    return(results)
  }
}



correlate <- function(data = data, variables = 0) {
  # Function calculates correlations between a binary target and all numeric variables
  # Args:
  #   data:   Input data set.  First column must be an ID, second column must be a binary target,
  #           all other columns should be numeric or will be ignored
  #   variables:  Variable column number to ignore
  # Returns:  data.frame with correlations for all numeric fields against the target
  
  # Create list of which columns are numeric
  numbers <- sapply(data[, -c(1,2)], is.numeric)
  
  # If any columns are numeric
  if (any(numbers)) {
    # Initialise results data.frame
    correlations <- data.frame()
    # Create numeric target
    data$Target <- as.numeric(as.character(data$Target))
    
    # Clean up data - remove variables which won't be used
    data <- data[, -c(1, variables)]
    # Only include variables with less than 25% NA values
    data <- data[, which(colMeans(is.na(data)) <= 0.75)]
    # Only use complete rows
    data <- data[complete.cases(data), ]
    
    # Loop through variables and calculate correlation
    for (i in colnames(data[, -1])) {
      correlation <- data.frame("variable" = i,
                                "Pearson" = cor(data$Target, data[, i], method = "pearson"),
                                #"Kendall" = cor(data$Target, data[, i], method="kendall"),
                                "Spearman" = cor(data$Target, data[, i], method = "spearman"),
                                "test" = cor.test(data$Target, data[, i])$p.value)
      correlations <- rbind(correlations, correlation)
      rm(correlation)
    }
    return(correlations)
  } 
}





eval <- function(confusion = data.test.confusion, binary = T) {
  # Function calculates model performance measures based on a confusion matrix
  # 
  # Args:
  #   confusion:    Confusion matrix, should be from the testing data set
  #   binary:       Logical value for whether the target is binary or not
  # Returns:
  #   eval:         data.frame with performance measures calculated

  # Multinomial target
  if (binary == F) {
    eval <- data.frame(precision = sum(diag(confusion)) / sum(confusion[upper.tri(confusion)]) 
                          + sum(diag(confusion)),
                       recall = sum(diag(confusion)) / (sum(confusion[lower.tri(confusion)])
                                                        + sum(diag(confusion))),
                       F1 = 2 * sum(diag(confusion)) / 
                                (2 * sum(diag(confusion)) + sum(confusion[lower.tri(confusion)])
                                                      + sum(confusion[upper.tri(confusion)])),
                       Accuracy = sum(diag(confusion)) / sum(confusion))
  } else {
    eval <- data.frame(precision = confusion[2,2] / sum(confusion[, 2]),
                       recall = confusion[2,2] / sum(confusion[2, ]),
                       F1 = 2 * confusion[2,2] / (sum(confusion[2, ]) + sum(confusion[, 2])),
                       TruePos = confusion[2,2],
                       FalseNeg = confusion[2,1],
                       FalsePos = confusion[1,2],
                       TrueNeg = confusion[1,1],
                       Accuracy = sum(diag(confusion)) / sum(confusion))
  }
  return(eval)
}




toFactor <- function(data) {   
  # Function converts numeric columns to factors, binning into deciles if they have more than 
  # 10 unique values
  # 
  # Args:
  #   data:  Input data set.  First two columns should be an ID and a Target.  Rest can be anything
  #
  # Returns:
  #   data:  Outputs the same data set but with numeric columns converted to factors with either 
  #          less than 10 unique values, or deciles

  # Iterate over columns
  for (var in colnames(data[, -c(1, 2)])) {
    # Check if column is numeric
    if (is.numeric(data[, var])) {
      # Check if number of unique values is greater than 10
      if (length(unique(data[, var])) > 10) {
        # convert to deciles
        data[, var] <- cut(data[, var], 10)
      } else {
        # convert to factor
        data[, var] <- as.factor(data[, var])
      }
    }
  }
  return(data)
}
