############################################################################################
# Model is called with a data set as input.  This data set MUST HAVE an ID as the first column,
# and the supervised prediction target as the second column
#
# Author: Stephan Curiskis
# Date: 15 April 2016
############################################################################################

runRFmodel <- function(data, excelFile = "ModelOutput.xlsx", sample_training = 0.7
		,sample_True = 200, sample_False = 0.5) {

	ptm <- proc.time()
	
	# Install packages if not already installed
	list.of.packages <- c("ggplot2", "xlsx","Hmisc","randomForest")
  	new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
  	if(length(new.packages)) install.packages(new.packages)
	
	# Load required packages
	library(ggplot2, quietly=T)
	library(randomForest, quietly=T)
	suppressMessages(library(xlsx, quietly=T))

	# Load functions in file profile2.R - needs to be in the same directory
	source("profile2.R")

	cat("\nPreparing model dataset ...")
	# Convert target to factor
	data$Target <- factor(data$Target)
	# Impute missing values - median if numeric, mode if categorical
	data_rf <- na.roughfix(data)

	# Partition data into training and testing data sets
	set.seed(42); samp.n <- setNames(data.frame(1:dim(data_rf)[1], 0), c("row","partition"))
	set.seed(42); samp.train <- sample(samp.n$row, dim(samp.n)[1] * 0.7)
	set.seed(42); samp.test <- sample(samp.n$row[-samp.train], dim(samp.n)[1] * 0.3)
	
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
	                              , length(data_rf[data_rf$Target[samp.train]==0,1]) * sample_False)]
	} else {
	samp.train_F <- samp.train[rep(which(data_rf$Target[samp.train]==0, arr.ind=T), each = sample_True)]
	}
	
	data.train <- data_rf[c(samp.train_T, samp.train_F), ]
	data.test <- data_rf[samp.test, ]
	
	cat("Finished\nBuilding random forest model... ")

	# Build RF model
	data.rf <- randomForest(factor(Target) ~ ., data=data.train[, -1])

	cat("prediction... ")
	set.seed(42); data.test$pred <- predict(data.rf, data.test)
	set.seed(42); data.test.confusion <- table(data.test$Target, data.test$pred)

	cat("evaluating... ")
	evaluation <- eval(data.test.confusion, binary=T)
	varImpPlot(data.rf, main="Variable Importance Scores")

	importance <- data.frame(importance(data.rf, type=2))
	importance$variable <- row.names(importance)
	row.names(importance) <- NULL
	cat("Finished]\nRunning comparisons... ")

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
	corr_varimp <- merge(x = importance, y = corr, by="variable", all.x = T)
	means <- profileMeans(data_correlate, num_filters = 0)

	cat("Finished\n\n")
	cat(sprintf("Writing results to Excel file: %s ... ", excelFile))

	write.xlsx2(corr_varimp, excelFile, sheetName="Correlations", row.names=F, showNA=F)
	write.xlsx2(means, excelFile, sheetName="Means", append=T, row.names=F, showNA=F)
	write.xlsx2(profiles, excelFile, sheetName="Profiles", append=T, row.names=F, showNA=F)

	results <- list("confusion"=data.test.confusion, "evaluation"=evaluation, "importance"=importance)

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
	cat("\nThe following objects have been added:\n")
	print(names(results))
	return(results)

}
