############################################################################################
# Functions to profile one group against another
# 
# profile - compares categorical variables only
# profileMeans - compares means of numeric variables
# correlate - calculates correlations between all numeric variables and a numeric target
# eval - predictive model evaluation measures, for either binary or categorical response
#
# Author: Stephan Curiskis
# Date: 15 April 2016
############################################################################################



comparisons <- function(data, excelFile = "Comparisons.xlsx") {
  cat("Running comparisons... ")
  
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
  cat(" categorical profiles...")
  profiles <- data.frame(profile(data_profile))
  
  cat(" correlations...")
  # Correlation analysis and comparison of averages between two groups
  corr <- correlate(data_correlate)
  
  cat(" means...")
  means <- profileMeans(data_correlate, num_filters = 0)
  
  cat("Finished\n\n")
  cat(sprintf("Writing results to Excel file: %s ... ", excelFile))
  
  write.xlsx2(corr, excelFile, sheetName="Correlations", row.names=F, showNA=F)
  write.xlsx2(means, excelFile, sheetName="Means", append=T, row.names=F, showNA=F)
  write.xlsx2(profiles, excelFile, sheetName="Profiles", row.names=F, showNA=F, append=T)
  
  cat("Finished\n\n")
}



profile <- function(data) {
  
  profile.df <- data.frame(Field=character(),FieldValue=character(),Base=character(),Target=character(),Base_PT=character(),Total_PT=character()
                           ,Index=character(),ZScore=character())
  
  for (i in 3:length(data)){
    a <- setNames(data.frame(table(data[i][data[2]==0])), c("FieldValue","Base"))
    b <- setNames(data.frame(table(data[i][data[2]==1])), c("FieldValue","Target"))
    c <- merge(a, b, by = intersect(names(a),names(b)), all = TRUE)
    c[2][is.na(c[2])] <- 0; c[3][is.na(c[3])] <- 0
    n1 <- sapply(c[2], sum); n2 <- sapply(c[3], sum)
    c <- setNames(data.frame(c, c[2]/n1, c[3]/n2, (c[2]+c[3])/sapply(c[2]+c[3], sum) ), c(colnames(c),"Base_PT","Target_PT","Total_PT"))
    c <- setNames(data.frame(c, 100*c[5]/c[4],(c[5]-c[4])/sqrt(c[6]*(1-c[6])*(1/n1+1/n2) ) ), c(colnames(c), "Index","ZScore"))
    c <- setNames(data.frame(rep(names(data[i]),length(c[,1])), c, row.names=NULL), c("Field", colnames(c))  )
    profile.df <- rbind(profile.df, c)
    
  }
  
  profile.df <- setNames(data.frame(profile.df[profile.df$Index != 0 & profile.df$Index != Inf,]
                                    ,ifelse(abs(profile.df[profile.df$Index != 0 & profile.df$Index != Inf,]$ZScore) > 2.58,"Y","N")) 
                         ,c(colnames(profile.df),"Sig", row.names=NULL))
  profile.df <- data.frame(profile.df[with(profile.df, order(Field, ZScore)),], row.names=NULL)
  profile.df <- setNames(data.frame(profile.df$Field, profile.df$FieldValue, profile.df$Base, profile.df$Target
                                    ,paste(100*round(profile.df$Base_PT,4),"%",sep=""),paste(100*round(profile.df$Target_PT,4),"%",sep="")
                                    ,paste(100*round(profile.df$Total_PT,4),"%",sep=""),round(profile.df$Index,2), round(profile.df$ZScore,2),profile.df$Sig)
                         ,colnames(profile.df))
  profile <- list(#"Z"=ggplot(profile.df, aes(x=FieldValue, y=ZScore, fill=Sig)) + geom_bar() + coord_flip() + labs(x="Variables",title="Z-Score Plot") + scale_fill_manual(values=c("red","green"))
                  #,"Index"=ggplot(profile.df, aes(x=FieldValue, y=Index-100, fill=Field)) + geom_bar() + coord_flip() + geom_text(aes(label=Index)) + 
                  #  labs(x="Variables",y="Index Score - 100",title="Index Plot") 
                  #,
                  "table"=profile.df)
  return(profile)
}




profileMeans <- function(data, num_filters = 0) {
  library(Hmisc, quietly=T)
  psych_summary <- data.frame()
  numbers <- sapply(data[, -c(1,2)], is.numeric)
  
  if (any(numbers)) {
    
    for (i in 1:(ncol(data) - num_filters - 2)) {
      
      # subset data
      if (num_filters == 0) {
        psych.d <- data[, -c(1,2)]
        target <- data$Target
        
        # Calculate total mean
        psych_summary_total <- sapply(list(psych.d[, i])
                                      , FUN=function(x) {c("mean"=mean(x, na.rm=T), "sd"=sd(x, na.rm=T), "count"=length(x))})
        # Calculate group means
        psych_summary_temp <- summarize(psych.d[, i], target
                                        , function(x) {c("mean"=mean(x, na.rm=T), "sd"=sd(x, na.rm=T), "count"=length(x[!is.na(x)]))})
        # Calculate Z-score
        psych_summary_temp$Z <- (psych_summary_temp[2, 2] - psych_summary_temp[1, 2]) / (psych_summary_total[2] / sqrt(psych_summary_temp[2, 4]))
        # Add column names
        psych_summary_temp <- data.frame(psych_summary_temp, colnames(psych.d)[i])
        colnames(psych_summary_temp) <- c("Target", "mean", "sd", "count", "Z-score", "attribute")
        # Flatten
        if (length(psych_summary_temp$Target) < 2) {next} else {
          psych_summary_temp2 <- data.frame("Variable" = psych_summary_temp$attribute[1]
                                            ,"Base_score" = psych_summary_temp$mean[psych_summary_temp$Target==0]
                                            ,"Target_score" = psych_summary_temp$mean[psych_summary_temp$Target==1]
                                            ,"Difference" = psych_summary_temp$mean[psych_summary_temp$Target==1]
                                            - psych_summary_temp$mean[psych_summary_temp$Target==0]
                                            ,"Base_n" = psych_summary_temp$count[psych_summary_temp$Target==0]
                                            ,"Target_n" = psych_summary_temp$count[psych_summary_temp$Target==1]
                                            ,"Z-score" = psych_summary_temp[psych_summary_temp$Target==1, 5])
        }
        # Append rows to final data.frame
        psych_summary <- rbind(psych_summary, psych_summary_temp2)
      } else {
        for (j in 1:num_filters) {
          # Create unique vector of filter values
          filter <- unique(data[, (j+2)])
          for (k in 1:length(filter)) {
            psych.d <- data[data[, (j+2)] == filter[k], -c(1:(2+num_filters))]
            target <- data$Taret[data[, (j+2)] == filter[k]]
            
            # Calculate total mean
            psych_summary_total <- sapply(list(psych.d[, i])
                                          , FUN=function(x) {c("mean"=mean(x, na.rm=T), "sd"=sd(x, na.rm=T), "count"=length(x))})
            # Calculate group means
            psych_summary_temp <- summarize(psych.d[, i], target
                                            , function(x) {c("mean"=mean(x, na.rm=T), "sd"=sd(x, na.rm=T), "count"=length(x[!is.na(x)]))})
            # Calculate Z-score
            psych_summary_temp$Z <- (psych_summary_temp[2, 2] - psych_summary_temp[1, 2]) / (psych_summary_total[2] / sqrt(psych_summary_temp[2, 4]))
            # Add column names
            psych_summary_temp <- data.frame(psych_summary_temp, colnames(psych.d)[i])
            colnames(psych_summary_temp) <- c("Target", "mean", "sd", "count", "Z-score", "attribute")
            # Flatten
            if (length(psych_summary_temp$Target) < 2) {next} else {
              psych_summary_temp2 <- data.frame("Variable" = psych_summary_temp$attribute[1]
                                                ,"Base_score" = psych_summary_temp$mean[psych_summary_temp$Target==0]
                                                ,"Target_score" = psych_summary_temp$mean[psych_summary_temp$Target==1]
                                                ,"Difference" = psych_summary_temp$mean[psych_summary_temp$Target==1]
                                                - psych_summary_temp$mean[psych_summary_temp$Target==0]
                                                ,"Base_n" = psych_summary_temp$count[psych_summary_temp$Target==0]
                                                ,"Target_n" = psych_summary_temp$count[psych_summary_temp$Target==1]
                                                ,"Z-score" = psych_summary_temp[psych_summary_temp$Target==1, 5])
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



correlate <- function(data=data, variables=0) {
  
  numbers <- sapply(data[, -c(1,2)], is.numeric)
  
  if (any(numbers)) {
    # Initialise results data.frame
    correlations <- data.frame()
    data$Target <- as.numeric(as.character(data$Target))
    
    # Clean up data
    data <- data[, -c(1, variables)]
    data <- data[, which(colMeans(is.na(data)) <= 0.15)]
    data <- data[complete.cases(data), ]
    
    # Loop through variables and calculate correlation
    for (i in colnames(data[, -1])) {
      correlation <- data.frame("variable" = i,
                                "Pearson" = cor(data$Target, data[, i], method="pearson"),
                                #"Kendall" = cor(data$Target, data[, i], method="kendall"),
                                "Spearman" = cor(data$Target, data[, i], method="spearman"),
                                "test" = cor.test(data$Target, data[, i])$p.value)
      correlations <- rbind(correlations, correlation)
      rm(correlation)
    }
    return(correlations)
  } 
}





eval <- function(confusion=data.test.confusion, binary=T) {
  if (binary == F) {
    eval <- data.frame(precision = sum(diag(confusion)) / sum(confusion[upper.tri(confusion)]) 
                       + sum(diag(confusion)),
                       recall = sum(diag(confusion)) / (sum(confusion[lower.tri(confusion)])
                                                        + sum(diag(confusion))),
                       F1 = 2*sum(diag(confusion)) / (2*sum(diag(confusion)) + sum(confusion[lower.tri(confusion)])
                                                      + sum(confusion[upper.tri(confusion)])),
                       Accuracy = sum(diag(confusion)) / sum(confusion))
  } else {
    eval <- data.frame(precision = confusion[2,2] / sum(confusion[, 2]),
                       recall = confusion[2,2] / sum(confusion[2, ]),
                       F1 = 2*confusion[2,2] / (sum(confusion[2, ]) + sum(confusion[, 2])),
                       TruePos = confusion[2,2],
                       FalseNeg = confusion[2,1],
                       FalsePos = confusion[1,2],
                       TrueNeg = confusion[1,1],
                       Accuracy = sum(diag(confusion)) / sum(confusion))
  }
  return(eval)
}




toFactor <- function(data) {    
    for (var in colnames(data[, -c(1,2)])) {
      if (is.numeric(data[, var])) {
        if (length(unique(data[, "tot_serv"])) > 10) {
          data[, var] <- cut(data[, var], 10)
        } else {
          data[, var] <- as.factor(data[, var])
        }
      }
    }
  return(data)
}


