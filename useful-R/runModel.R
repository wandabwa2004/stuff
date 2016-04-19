############################################################################################
# Model is called with a data set as input.  This data set MUST HAVE an ID as the first column,
# and the supervised prediction target as the second column
#
# Author: Stephan Curiskis
# Date: 15 April 2016
############################################################################################

runModel <- function(data, excelFile = "ModelOutput.xlsx", sample_training = 0.7
                       , sample_True = 1, sample_False = 1, balanceClasses = F
                       , model = "random forest", maxnodes, nodesize) {
  
  ptm <- proc.time()
  
  list.of.packages <- c("ggplot2", "xlsx","Hmisc","randomForest","ROCR","e1071","rpart")#,"dplyr")
  new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
  if(length(new.packages)) install.packages(new.packages)
  
  # Load required packages
  library(ggplot2, lib.loc="~/R/win-library/3.1", quietly=T)
  library(randomForest, quietly=T)
  library(Hmisc, quietly=T)
  library(ROCR, quietly=T)
  suppressMessages(library(xlsx, quietly=T))
  
  # Load functions in file profile2.R - needs to be in the same directory
  #source("profile.R")
  
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
    samp.train_T <- samp.train[sample(which(data_rf$Target[samp.train]==1, arr.ind=T)
                                      , length(data_rf[data_rf$Target[samp.train]==1,1]) * sample_True)]
  } else {
    samp.train_T <- samp.train[rep(which(data_rf$Target[samp.train]==1, arr.ind=T), each = sample_True)]
  }
  # Replicate or sample False classes in training data
  if (sample_False < 1) {
    samp.train_F <- samp.train[sample(which(data_rf$Target[samp.train]==0, arr.ind=T)
                                      , length(which(data_rf$Target[samp.train]==0, arr.ind=T)) * sample_False)]
  } else {
    samp.train_F <- samp.train[rep(which(data_rf$Target[samp.train]==0, arr.ind=T), each = sample_False)]
  }
  
  data.test <- data_rf[samp.test, ]
  data.train <- data_rf[c(samp.train_T, samp.train_F), ]
  
  cat("Finished\n\nTrue class replicated", sample_True, "times\n")
  
  cat("Training data split over the target as:")
  print(table(data.train$Target))
  
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
  
  cat("predicting... ")
  set.seed(42); data.test$pred <- predict(data.model, data.test, type="class")
  set.seed(42); data.test.confusion <- table(data.test$Target, data.test$pred)
  set.seed(42); data.test$predProb <- predict(data.model, data.test, type="prob")
  set.seed(42); data.test.rf.pred <- prediction(data.test$predProb[,2], data.test$Target)  
  set.seed(42); data.test$pred_Prob_decile <- cut(data.test$predProb[,2], breaks=quantile(data.test$predProb[,2]
                                                                                       , probs = seq(0,1,length=11)))
  test_deciles <- table(data.test$pred_Prob_decile, data.test$Target)
  set.seed(42); data.train$predProb <- predict(data.model, data.train, type="prob")
  set.seed(42); data.train.rf.pred <- prediction(data.train$predProb[,2], data.train$Target)
  
  # ROC
  set.seed(42); precision_recall <- performance(data.test.rf.pred, "prec","rec")
  set.seed(42); tpr_fpr <- performance(data.test.rf.pred, "tpr","fpr")
  set.seed(42); train_prec_rec <- performance(data.train.rf.pred, "prec","rec")
  set.seed(42); train_tpr_fpr <- performance(data.train.rf.pred, "tpr","fpr")
  #set.seed(42); data.test.rf.auc <- performance(data.test.rf.pred, "auc")
  #set.seed(42); data.test.rf.lift <- performance(data.test.rf.pred, "lift")
  #auc <- unlist(slot(data.test.rf.auc, "y.values"))
  
  plot(tpr_fpr, main="Gains Chart ROC", type="l", col="red", lwd=2)
  plot(train_tpr_fpr, add=T, col="blue", lwd=2, lty=2)
  legend("bottomright", legend=c("Training","Testing"), col=c(1,2), lty=1)
  abline(0,1, col="darkgray")
  grid(5)
  
  plot(precision_recall, main="Precision and Recall chart", type="l", col="red", lwd=2)
  grid(5)
  
  cat("evaluating... ")
  evaluation <- eval(data.test.confusion, binary=T)
  
  cat("Finished\nRunning comparisons... ")
  
  # Take only categorical predictors for profile function
  data_profile <- data[, c(1,2)]
  data_correlate <- data[, c(1,2)]
  for (i in colnames(data[, -c(1,2)])) {
    if (is.factor(data[, i]) == T) {
      data_profile <- cbind(data_profile, setNames(data.frame(data[, i]), i))
    } else {
      data_correlate <- cbind(data_correlate, setNames(data.frame(data[, i]), i))
    }
  }
  
  profiles <- data.frame(profile(data_profile))
  
  # Correlation analysis and comparison of averages between two groups
  corr <- correlate(data_correlate)
  #corr_varimp <- merge(x = importance, y = corr, by="variable", all.x = T)
  #means <- profileMeans(data_correlate, num_filters = 0)
  
  cat("Finished\n\n")
  cat(sprintf("Writing results to Excel file: %s ... ", excelFile))
  
  write.xlsx2(corr, excelFile, sheetName="Correlations", row.names=F, showNA=F)
  #write.xlsx2(means, excelFile, sheetName="Means", append=T, row.names=F, showNA=F)
  write.xlsx2(profiles, excelFile, sheetName="Profiles", row.names=F, showNA=F, append=T)
  if (model == "random forest") {
    results <- list("confusion"=data.test.confusion, "evaluation"=evaluation, "importance"=importance
                    ,"model"=data.model, "precision_recall"=precision_recall, "tpr_fpr"=tpr_fpr
                    ,"test_deciles"=test_deciles)
  } else {
    results <- list("confusion"=data.test.confusion, "evaluation"=evaluation
                    ,"model"=data.model, "precision_recall"=precision_recall, "tpr_fpr"=tpr_fpr
                    ,"test_deciles"=test_deciles)
  }
  
  cat("Finished\n\n")
  time <- sprintf("Script run time was %s seconds (%s min)",
                  round(((proc.time() - ptm)[3]), 2), round(((proc.time() - ptm)[3]) / 60, 2))
  cat("\n", time, "\n", sep="")
  cat(sprintf("\nOverall model accuracy is %s \n", paste(round(evaluation$Accuracy * 100, 1), "%", sep="")))
  cat(sprintf("Model precision is %s and recall is %s \n",
              paste(round(evaluation$precision * 100, 1), "%", sep=""),
              paste(round(evaluation$recall * 100, 1), "%", sep="")))
  cat("\nConfusion matrix:")
  print(data.test.confusion)
  cat("\nPrediction deciles on test data:")
  print(test_deciles)
  cat("\nThe following objects have been added:\n")
  print(names(results))
  return(results)
  gc()
  
}
