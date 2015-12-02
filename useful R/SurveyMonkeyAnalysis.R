#require(ggplot2)

data <- read.table('C:/Users/Stephan Curiskis/Documents/Work/Marketing/Analysis/SurveyResponses_20150304_R.txt',sep="\t",header=T)

x <- names(data)

tab <- data.frame(Feature=character(), Field=character(), FieldValue=character(), True=character(), False=character()
                       , True_Prop=character(), False_Prop=character(), True_Index=character(), Z=character())

for (j in 2:8) {
  for (i in c(13:27,58,60:63)) {
    
    temp <- as.data.frame.matrix(table(data[,j], data[,i]))
    temp <- setNames(data.frame(row.names(temp), temp), c(x[j],"True","False"))
    
    prop_temp <- as.data.frame.matrix(prop.table(table(data[,j], data[,i]),1))
    prop_temp <- setNames(data.frame(row.names(prop_temp), prop_temp)
                          , c(x[j],"True","False"))
    
    tab <- rbind(tab, setNames(data.frame(x[i], x[j]
                ,merge(x=temp, y=data.frame(prop_temp,prop_temp$True / (sum(temp$True)/sum(temp$True+temp$False))
                  ,sqrt(temp$True+temp$False) * (prop_temp$True - (sum(temp$True)/sum(temp$True+temp$False))) / sd(temp$True/(temp$True+temp$False)) )
                    ,by=c(x[j],x[j]))), c("Feature","Field","FieldValue","True","False","True_Prop","False_Prop","True_Index","Z")))
    rm(temp)
    rm(prop_temp)
  }
}


tab_mult <- data.frame(Feature=character(), Field=character(), FieldValue=character(), True=character(), False=character()
                  , True_Prop=character(), False_Prop=character(), True_Index=character(), Z=character())

for (j in 2:8) {
  for (i in c(43:57,64:65)) {
    
    temp <- data.frame(tapply(data[,i][!is.na(data[,i])], data[,j][!is.na(data[,i])], mean))
    temp <- setNames(data.frame(row.names(temp), temp), c(x[j],"Avg_Sat"))
    temp <- merge(x=temp, y=setNames(data.frame(table(data[,j][!is.na(data[,i])])),c(x[j],"Total"))
                  ,by=c(x[j],x[j]))
    
    tab_mult <- rbind(tab_mult, 
                      setNames(data.frame(x[i], x[j], temp
                        ,temp[,2] / mean(data[,i][!is.na(data[,i])])
                        ,(sqrt(temp[,3]) * (temp[,2] / mean(data[,i][!is.na(data[,i])]) - mean(data[,i][!is.na(data[,i])]))) 
                                    / sd(data[,i][!is.na(data[,i])])) 
                               ,c("Feature","Field", "FieldName", "Avg_Sat", "Total", "Sat_Index", "Z")))   
    rm(temp)

  }
}



write.csv(tab, file='C:/Users/Stephan Curiskis/Documents/Work/Marketing/Analysis/SurveyResponses_OUTPUT.csv')
write.csv(tab_mult, file='C:/Users/Stephan Curiskis/Documents/Work/Marketing/Analysis/SurveyResponsesMult_OUTPUT.csv')