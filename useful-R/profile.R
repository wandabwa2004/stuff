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
  profile <- list("Z"=ggplot(profile.df, aes(x=FieldValue, y=ZScore, fill=Sig)) + geom_bar() + coord_flip() + labs(x="Variables",title="Z-Score Plot") + scale_fill_manual(values=c("red","green"))
                  ,"Index"=ggplot(profile.df, aes(x=FieldValue, y=Index-100, fill=Field)) + geom_bar() + coord_flip() + geom_text(aes(label=Index)) + 
                    labs(x="Variables",y="Index Score - 100",title="Index Plot") 
                  ,"table"=profile.df)
  return(profile)
}










