# ==================================================================================================
# 
# runModel.R 
#
# Author: Stephan Curiskis
# Date: 15 April 2016
# 
# NOTES:  Model is called with a data set as input.  This data set MUST HAVE an ID as the first 
# column, and the supervised prediction target as the second column


runModel <- function(data, sample_training = 0.7, sample_True = 1, sample_False = 1, 
                      balanceClasses = F, model = "random forest", maxnodes, nodesize) {
  
  # Trains a classification model on a data set.  The function partitions the data into testing and 
  # training sets, samples True and False claseses, replicates the False class if required, builds
  # a classification model (either RF, SVM or CART), creates binary and probability predictions,
  # calculates measures on the confusion matrix and creates ROC charts.
  #
  # Arguments: 
  #   data: input data set for classification.  The first column must be an ID, and the 
  #         classification target must be the second column.  
  #   sample_training:  Proportion between 0 and 1 for the training partition size.
  #   sample_True:      Sampling ratio for the True class.
  #   sample_False:     Sampling ratio for the False class.
  #   balanceClasses:   If True, replicates the False class to represent 50% of all records.
  #   model:            Specifies which model to use.  Default is "random forest", but can also take
  #                     values "SVM" and "CART".
  #   maxnodes:         The maximum depth of nodes used in the random forest model.
  #   nodesize:         The minimum node size used in the random forest model.
  #
  # Returns:
  #   confusion:        The confusion matrix calculated on the testing data.
  #   evaluation:       Evaluation measures calculated on the testing data confusion matrix.
  #   model:            The trained model object.
  #   precision_recall: Precision recall performance object, used for ROC prec rec chart.
  #   tpr_fpr:          ROC performance object with true positive rates and false positive rates.
  #   test_deciles:     Prediction deciles calculated on the testing data.
  #   importance:       Random forest variable importance scores.

  # Record start time
  ptm <- proc.time()
  
  # Load packages and dependencies -----------------------------------------------------------------

  list.of.packages <- c("ggplot2", "xlsx","Hmisc","randomForest","ROCR","e1071","rpart")
  new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
  if(length(new.packages)) install.packages(new.packages)
  
  # Load required packages
  library(ggplot2, lib.loc="~/R/win-library/3.1", quietly=T)
  library(randomForest, quietly=T)
  library(Hmisc, quietly=T)
  library(ROCR, quietly=T)
  suppressMessages(library(xlsx, quietly=T))
  
  # Load functions in file profile.R - needs to be in the same directory
  #source("profile.R")
  
  # Data preparation -------------------------------------------------------------------------------

  cat("\nPreparing model dataset ...")
  # Convert target to factor
  data$Target <- factor(data$Target)
  # Impute missing values - median if numeric, mode if categorical
  data_rf <- na.roughfix(data)
  
  if (balanceClasses == T) {
    tab <- table(data$Target)
    if (sample_False == 1) {
      sample_True <- floor(tab[1] / tab[2])
    } else {
      sample_True <- floor(tab[1] * sample_False / tab[2])
    }
  }
  
  # Partition data into training and testing data sets
  set.seed(42); samp.n <- setNames(data.frame(1:dim(data_rf)[1], 0), c("row","partition"))
  set.seed(42); samp.train <- sample(samp.n$row, dim(samp.n)[1] * sample_training)
  set.seed(42); samp.test <- sample(samp.n$row[-samp.train], dim(samp.n)[1] * (1 - sample_training))
  
  # Replicate or sample True classes in training data
  if (sample_True < 1) {
    samp.train_T <- samp.train[sample(which(data_rf$Target[samp.train]==1, arr.ind=T), 
                                    length(data_rf[data_rf$Target[samp.train]==1,1]) * sample_True)]
  } else {
    samp.train_T <- samp.train[rep(which(data_rf$Target[samp.train]==1, arr.ind=T), 
                                    each = sample_True)]
  }
  # Replicate or sample False classes in training data
  if (sample_False < 1) {
    samp.train_F <- samp.train[sample(which(data_rf$Target[samp.train]==0, arr.ind=T), 
                            length(which(data_rf$Target[samp.train]==0, arr.ind=T)) * sample_False)]
  } else {
    samp.train_F <- samp.train[rep(which(data_rf$Target[samp.train]==0, arr.ind=T), 
                            each = sample_False)]
  }
  
  data.test <- data_rf[samp.test, ]
  data.train <- data_rf[c(samp.train_T, samp.train_F), ]
  
  cat("Finished\n\nTrue class replicated", sample_True, "times\n")
  
  cat("Training data split over the target as:")
  print(table(data.train$Target))
  
  # Train classification model ---------------------------------------------------------------------

  cat("\nBuilding", model, "model... ")
  
  if (model == "random forest") {
    # Build RF model
    if (!missing(maxnodes)) {
      data.model <- randomForest(factor(Target) ~ ., data=data.train[, -1]
                                 ,maxnodes=maxnodes, nodesize=nodesize)
    } else {
      data.model <- randomForest(factor(Target) ~ ., data=data.train[, -1])
    }
    importance <- data.frame(importance(data.model, type=2))
    importance$variable <- row.names(importance)
    row.names(importance) <- NULL
    par(mfrow=c(3,1))
    varImpPlot(data.model, main="Variable Importance Scores")
    
                            #,replace=T, classwt=c(1,100))
  } else if (model == "SVM") {
    # Build SVM model
    library(e1071, quietly=T)
    data.model <- svm(factor(Target) ~., data=data.train[, -1])
    par(mfrow=c(2,1))
  } else if (model == "CART") {
    library(rpart, quietly=T)
    data.model <- rpart(factor(Target) ~., data=data.train[, -1], method  = "class")
    par(mfrow=c(2,1))
  }
  
  # Create model predictions -----------------------------------------------------------------------

  cat("predicting... ")
  # Create predictions against the test data
  set.seed(42); data.test$pred <- predict(data.model, data.test, type="class")
  set.seed(42); data.test.confusion <- table(data.test$Target, data.test$pred)
  set.seed(42); data.test$predProb <- predict(data.model, data.test, type="prob")
  set.seed(42); data.test.rf.pred <- prediction(data.test$predProb[,2], data.test$Target)  
  
  # Calculate prediction probability deciles
  set.seed(42); data.test$pred_Prob_decile <- cut(data.test$predProb[,2], 
                                                  breaks=unique(quantile(data.test$predProb[,2], 
                                                    probs = seq(0,1,length=11))))
  
  # Count the observations by the target, and calculate percentages
  test_deciles <- table(data.test$pred_Prob_decile, data.test$Target)
  test_deciles <- cbind(test_deciles, prop.table(test_deciles, 2))
  test_deciles <- setNames(data.frame(test_deciles, rev(cumsum(rev(test_deciles[,4]))))
                           , c("Base","Target","Base%","Target%","Target%_cum"))
  test_deciles[, 3:5] <- round(test_deciles[, 3:5] * 100, 1)
  
  # Create predictions against the training data set
  set.seed(42); data.train$predProb <- predict(data.model, data.train, type="prob")
  set.seed(42); data.train.rf.pred <- prediction(data.train$predProb[,2], data.train$Target)
  
  # ROC precision and recall, tpr and fpr
  set.seed(42); precision_recall <- performance(data.test.rf.pred, "prec","rec")
  set.seed(42); tpr_fpr <- performance(data.test.rf.pred, "tpr","fpr")
  set.seed(42); train_prec_rec <- performance(data.train.rf.pred, "prec","rec")
  set.seed(42); train_tpr_fpr <- performance(data.train.rf.pred, "tpr","fpr")
  #set.seed(42); data.test.rf.auc <- performance(data.test.rf.pred, "auc")
  #set.seed(42); data.test.rf.lift <- performance(data.test.rf.pred, "lift")
  #auc <- unlist(slot(data.test.rf.auc, "y.values"))
  
  # Plot the tpr and fpr gains chart ROC for both testing and training data
  plot(tpr_fpr, main="Gains Chart ROC", type="l", col="red", lwd=2, xlim=c(0,1), ylim=c(0,1))
  plot(train_tpr_fpr, add=T, col="blue", lwd=2, lty=2, xlim=c(0,1), ylim=c(0,1))
  legend("bottomright", legend=c("Training","Testing"), col=c(1,2), lty=1)
  abline(0,1, col="darkgray")
  grid(5)
  
  # Plot the precision and recall chart on the testing data
  plot(precision_recall, main="Precision and Recall chart", type="l", col="red", lwd=2)
  grid(5)
  
  # Finalise outputs -------------------------------------------------------------------------------

  cat("evaluating... ")
  evaluation <- eval(data.test.confusion, binary=T)
  
  if (model == "random forest") {
    results <- list("confusion" = data.test.confusion, "evaluation" = evaluation, 
                    "importance" = importance, "model" = data.model, 
                    "precision_recall" = precision_recall, "tpr_fpr" = tpr_fpr, 
                    "test_deciles" = test_deciles)
  } else {
    results <- list("confusion" = data.test.confusion, "evaluation" = evaluation, 
                    "model" =data.model, "precision_recall" = precision_recall, 
                    "tpr_fpr" = tpr_fpr, "test_deciles" = test_deciles)
  }
  cat("Finished\n")
  
  time <- sprintf("Script run time was %s seconds (%s min)",
                  round(((proc.time() - ptm)[3]), 2), round(((proc.time() - ptm)[3]) / 60, 2))
  cat("\n", time, "\n", sep="")
  cat(sprintf("\nOverall model accuracy is %s \n", 
              paste(round(evaluation$Accuracy * 100, 1), "%", sep="")))
  cat(sprintf("Model precision is %s and recall is %s \n",
              paste(round(evaluation$precision * 100, 1), "%", sep=""),
              paste(round(evaluation$recall * 100, 1), "%", sep="")))
  cat("\nConfusion matrix:")
  print(data.test.confusion)
  cat("\nPrediction deciles on test data:\n")
  print(test_deciles)
  cat("\nThe following objects have been added:\n")
  print(names(results))
  return(results)
  gc()
  
}
