
#browseURL("http://developers.facebook.com/tools/explorer")

require(RCurl)
require(rjson)

library(RODBC)
DB <- odbcDriverConnect('driver={SQL Server};server=\\SQLDEV_SC;database=Social;trusted_connection=true')

# download the file needed for authentication
download.file(url="http://curl.haxx.se/ca/cacert.pem", destfile="cacert.pem")

# set the curl optionNs
curl <- getCurlHandle()
options(RCurlOptions = list(capath = system.file("CurlSSL", "cacert.pem",
                                                 package = "RCurl"),
                            ssl.verifypeer = FALSE))
curlSetOpt(.opts = list(proxy = 'proxyserver:port'), curl = curl)


source("facebook.R")

# get access token.  Opens up browser, copy access token and paste into console
access_token <- getAccessToken()



accounts <- fromJSON(getURL( sprintf( "https://graph.facebook.com/me/accounts?&access_token=%s", access_token ) ))

accounts.df <- as.data.frame(t(sapply(c(accounts$data[[1]]$id, accounts$data[[1]]$name, accounts$data[[1]]$category), unlist)))
accounts.df <- setNames(accounts.df, c("ID", "Name","Category"))


for (i in 1:length(accounts$data) ) {
  if(i == 1) {
    accounts.df <- as.data.frame(t(sapply(c(accounts$data[[1]]$id, accounts$data[[1]]$name, accounts$data[[1]]$category), unlist)))
    accounts.df <- setNames(accounts.df, c("ID", "Name","Category"))
  } else {
    tempAccounts.df <- as.data.frame(t(sapply(c(accounts$data[[i]]$id, accounts$data[[i]]$name, accounts$data[[i]]$category), unlist)))
    tempAccounts.df <- setNames(tempAccounts.df, c("ID", "Name","Category"))
    accounts.df <- rbind.data.frame(tempAccounts.df, accounts.df)
    rm(tempAccounts.df)
  }
}


app <- as.character(accounts.df$ID)
appname <- data.frame(as.character(accounts.df$Name), as.character(accounts.df$Category))
appname <- setNames(appname, c("Name","Category"))

metrics <- c("/insights/page_fans/lifetime","/insights/page_storytellers/day","/insights/page_engaged_users/day","/insights/page_impressions_unique/day"
             ,"/insights/page_impressions_paid_unique/day","/insights/page_impressions_organic_unique/day","/insights/page_impressions_viral_unique/day")

options <- "?since=2013-09-01&until=2013-11-01&limit=1000000"


# Initialise key data frame
data.df <- data.frame(AppName=character(), category=character(),app_id=character(), Metric=character()
                      ,Value=character(), Date=as.Date(character())
                      ,stringsAsFactors=FALSE
                      ,row.names=NULL)

for (i in 1:length(metrics)){
  for (j in 1:length(app)){
    
    path = paste(app[j],metrics[i], sep="")
    datatemp <- facebook(path, options, access_token)
    rm(path)
    
    datatemp.df <- data.frame(app[j],metrics[i], t(sapply(datatemp$data[[1]]$values, unlist)))
    datatemp.df <- data.frame(c(rep(as.character(appname[j,2]),length(datatemp.df$value))), datatemp.df)
    datatemp.df <- data.frame(c(rep(as.character(appname[j,1]),length(datatemp.df$value))), datatemp.df)
    datatemp.df <- setNames(datatemp.df, c("AppName","category", "app_id", "Metric", "Value", "Date"))
    
    data.df <- rbind.data.frame(data.df, datatemp.df)
    rm(datatemp.df)
  }
}


sqlDrop(DB, "STG.Page")
sqlSave(DB, data.df, "STG.Page")
sqlQuery(DB, "usp_RPT_Page")


metric2 <- c("/insights/page_storytellers_by_age_gender/day","/insights/page_fans_gender_age/lifetime")

dem.df <- data.frame(AgeGender=character(),AppName=character(),category=character(),app_id=character(),Metric=character()
                     , date=character(), value=character(),stringsAsFactors=FALSE,row.names=NULL)

for (j in 1:length(app)){
  for (k in 1:length(metric2)) {
    path = paste(app[j],metric2[k], sep="")
    demtemp <- facebook(path, options, access_token)
    
    for (i in 1:length(demtemp$data[[1]]$values)){
      
      if ( length(demtemp$data[[1]]$values[[i]]$end_time) == 0 | length(demtemp$data[[1]]$values[[i]]$value) ==0) {
        next
      } else {
        
        demtemp.df <- data.frame(app[j],metric2[k],demtemp$data[[1]]$values[[i]]$end_time,
                                 sapply(demtemp$data[[1]]$values[[i]]$value, unlist))
        demtemp.df <- data.frame(c(rep(as.character(appname[j,2]),length(demtemp.df[,1]))), demtemp.df)
        demtemp.df <- data.frame(c(rep(as.character(appname[j,1]),length(demtemp.df[,1]))), demtemp.df)
        demtemp.df <- data.frame(row.names(demtemp.df), demtemp.df)
        demtemp.df <- setNames(demtemp.df, c("AgeGender","AppName","category","app_id","Metric","date","value"))
        dem.df <- rbind.data.frame(demtemp.df,dem.df)
        rm(demtemp.df)
      }
    }
  }
}

sqlDrop(DB, "STG.Demographics")
sqlSave(DB, dem.df, "STG.Demographics")


postid.df <- data.frame(app_id=character(),post_id=character(),created_time=character(),stringsAsFactors=FALSE,row.names=NULL)
post.df <- data.frame(app_id=character(),post_id=character(),created_time=character(),updated_time=character(),message=character()
                      ,type=character(),shares=character(),stringsAsFactors=FALSE,row.names=NULL)
postlikes.df <- data.frame(app_id=character(),post_id=character(),user_id=character(),name=character(),stringsAsFactors=FALSE,row.names=NULL)
postcomments.df <- data.frame(app_id=character(),post_id=character(),user_post_id=character(),name=character(),user_id=character()
                              ,comment=character(), comment_time=character(), like_count=character(),stringsAsFactors=FALSE,row.names=NULL)



for (k in 1:length(app)){
  path <- paste(app[k], "/feed", sep="")
  appposts <- facebook(path, options, access_token)
  if ( length(appposts$data) == 0 ) {
    next
  } else { 
    for (i in 1:length(appposts$data)) {
      postid <- data.frame(app[k],t(sapply(appposts$data[[i]]$id, unlist)),t(sapply(appposts$data[[i]]$created_time, unlist)))
      postid <- setNames(postid, c("app_id","post_id","created_time"))
      postid.df <- rbind(postid.df, postid)
      
      post <- facebook(postid.df[i,2], options, access_token)
      
      if ( length(post$message) == 0) {
        next
      } else {
        post$share[is.null(post$share)] <- 0
        post.df0 <- data.frame(app[k],postid.df[i,2], post$created_time, post$updated_time, post$message, post$type, post$share,row.names=NULL)
        post.df0 <- setNames(post.df0, c("app_id","post_id","created_time","updated_time","message","type","shares"))
        post.df <- rbind(post.df,post.df0)
        
        postlikes <- facebook(paste(postid.df[i,2],"/likes", sep=""),options, access_token)
        if (length(postlikes$data) == 0) { next } else {
          postlikes.df0 <- data.frame(app[k],postid.df[i,2], t(sapply(postlikes$data,unlist)),row.names=NULL)
          postlikes.df0 <- setNames(postlikes.df0, c("app_id","post_id","user_id","name")) 
          postlikes.df <- rbind(postlikes.df,postlikes.df0)
          
          if (length(postlikes$paging$cursors$after) != 0){
            repeat{
              postlikes <- facebook(paste(postid.df[i,2],"/likes", sep=""),options, paste(access_token,"&after=",postlikes$paging$cursors$after,sep=""))
              if (length(postlikes$paging$cursors$after) != 0){
                postlikes.df0 <- data.frame(app[k],postid.df[i,2], t(sapply(postlikes$data,unlist)),row.names=NULL)
                postlikes.df0 <- setNames(postlikes.df0, c("app_id","post_id","user_id","name")) 
                postlikes.df <- rbind(postlikes.df,postlikes.df0)
              } else { break }
            }
          }
        }
        postcomments <- facebook(paste(postid.df[i,2],"/comments", sep=""),options, access_token)
        if (is.null(postcomments)){
          postcomments <- fromJSON( gsub("\\\\","",getURL( sprintf( "https://graph.facebook.com/%s%s&access_token=%s", paste(postid.df[i,2],"/comments", sep=""), options, access_token ) )))
        }
        if (length(postcomments$data) != 0) {
          for (j in 1:length(postcomments$data)) {
            postcomments.df0 <- data.frame(app[k],postid.df[i,2], t(sapply(postcomments$data[[j]]$id,unlist))
                                           ,t(sapply(postcomments$data[[j]]$from$name,unlist)),t(sapply(postcomments$data[[j]]$from$id,unlist)), t(sapply(postcomments$data[[j]]$message,unlist))
                                           ,t(sapply(postcomments$data[[j]]$created_time,unlist)),t(sapply(postcomments$data[[j]]$like_count,unlist))
                                           ,row.names=NULL)
            postcomments.df0 <- setNames(postcomments.df0, c("app_id","post_id","user_post_id","name","user_id","comment","comment_time","like_count"))
            postcomments.df <- rbind(postcomments.df,postcomments.df0)
          }
        }
      }
    }
  }
}

