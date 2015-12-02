

require(RCurl)
require(rjson)
require(stringr)
require(RJSONIO)

library(RODBC)
DB <- odbcDriverConnect('driver={SQL Server};server=SCURISKISLPT7\\SQLDEV_SC;database=Social;trusted_connection=true')

# download the file needed for authentication
download.file(url="http://curl.haxx.se/ca/cacert.pem", destfile="cacert.pem")

# set the curl optionNs
curl <- getCurlHandle()
options(RCurlOptions = list(capath = system.file("CurlSSL", "cacert.pem",package = "RCurl"),ssl.verifypeer = FALSE))
curlSetOpt(.opts = list(proxy = 'proxyserver:port'), curl = curl)


source("facebook.R")

access_token <- getAccessToken()

options <- "&since=2013-10-01&until=2013-12-31&limit=1000000"

#postid.df <- data.frame(app_id=character(),post_id=character(),country=character(),created_time=character(),stringsAsFactors=FALSE,row.names=NULL)
post.df <- data.frame(app_id=character(),post_id=character(),country=character(),created_time=character(),updated_time=character(),message=character()
                      ,type=character(),shares=character(),stringsAsFactors=FALSE,row.names=NULL)
postlikes.df <- data.frame(app_id=character(),post_id=character(),user_id=character(),name=character(),stringsAsFactors=FALSE,row.names=NULL)
postcomments.df <- data.frame(app_id=character(),post_id=character(),user_post_id=character(),name=character(),user_id=character()
                              ,comment=character(), comment_time=character(), like_count=character(),stringsAsFactors=FALSE,row.names=NULL)

# Key four brands
appname <- appname[appname$id == "424151720932367" | appname$id == "127245917377737" | appname$id == "209039632473496" | appname$id == "118858551569975",]
# Heineken
#appname <- appname[appname$id == "7174672354",]
# Air Wick
#appname <- appname[appname$id == "118858551569975",]


for (j in 1:length(appname)) {
  path <- paste(appname[j,1], "/posts?fields=id,privacy,message,application,shares,updated_time,type", sep="")
  appposts <- facebook(path, sprintf("&%s",substr(options, 2,nchar(options))), access_token)
  #appposts <- fromJSON( gsub("\\\\","",getURL( paste("https://graph.facebook.com/",appname[k,1], "/posts?fields=id,privacy,message,application,shares,updated_time,type,likes.limit(100000),comments.limit(100000)&access_token=",access_token, sep="" ))))     
  if (length(appposts$data) != 0) {
    for (i in 1:length(appposts$data)) {
      appposts$data[[i]]$shares[is.null(appposts$data[[i]]$shares)] <- 0
      appposts$data[[i]]$message[is.null(appposts$data[[i]]$message)] <- ""
      post <- data.frame(appname[j,1],t(sapply(appposts$data[[i]]$id, unlist)),t(sapply(appposts$data[[i]]$privacy[1],unlist)),t(sapply(appposts$data[[i]]$created_time, unlist))
                         ,t(sapply(appposts$data[[i]]$updated_time, unlist)),t(sapply(appposts$data[[i]]$message, unlist)),t(sapply(appposts$data[[i]]$type, unlist)),t(sapply(appposts$data[[i]]$shares, unlist)))
      post <- setNames(post, c("app_id","post_id","country","created_time","updated_time","message","type","shares"))
      post.df <- rbind(post.df, post)
    }
  }
}

write.table(post.df, "posts_Q4.txt", sep="|", quote=T)


if (length(appposts$paging[2]) != 0 ){ # was previously postlikes$paging$cursors$after
  repeat{
    try(if (length(appposts$paging[2]) != 0 ) {
      #appposts <- fromJSON(str_replace_all( gsub("\\\\","",getURL( appposts$paging[2] )), "[^[:alnum:][ ][\\][/][:][,][{][}]",""))      
      appposts <- fromJSON(getURL( appposts$paging[2] ))
      if (appposts$error$type == "OAuthException") { break } else {
        for (i in 1:length(appposts$data)) {
          appposts$data[[i]]$shares[is.null(appposts$data[[i]]$shares)] <- 0
          appposts$data[[i]]$message[is.null(appposts$data[[i]]$message)] <- ""
          post <- data.frame(appname[,1],t(sapply(appposts$data[[i]]$id, unlist)),t(sapply(appposts$data[[i]]$privacy[1],unlist)),t(sapply(appposts$data[[i]]$created_time, unlist))
                             ,t(sapply(appposts$data[[i]]$updated_time, unlist)),t(sapply(appposts$data[[i]]$message, unlist)),t(sapply(appposts$data[[i]]$type, unlist)),t(sapply(appposts$data[[i]]$shares, unlist)))
          post <- setNames(post, c("app_id","post_id","country","created_time","updated_time","message","type","shares"))
          post.df <- rbind(post.df, post)
        }
      }
    }, silent=T)
  } 
}







path <- paste(appname[k,1], "/posts?fields=id,privacy,message,application,shares,updated_time,type,likes.limit(100000),comments.limit(100000)", sep="")
appposts <- facebook(path, sprintf("&%s",substr(options, 2,nchar(options))), access_token)
#appposts <- fromJSON( gsub("\\\\","",getURL( paste("https://graph.facebook.com/",appname[k,1], "/posts?fields=id,privacy,message,application,shares,updated_time,type,likes.limit(100000),comments.limit(100000)&access_token=",access_token, sep="" ))))     
if (length(appposts$data) != 0) {
  for (i in 1:length(appposts$data)) {
    appposts$data[[i]]$shares[is.null(appposts$data[[i]]$shares)] <- 0
    appposts$data[[i]]$message[is.null(appposts$data[[i]]$message)] <- ""
    post <- data.frame(appname[k,1],t(sapply(appposts$data[[i]]$id, unlist)),t(sapply(appposts$data[[i]]$privacy[1],unlist)),t(sapply(appposts$data[[i]]$created_time, unlist))
            ,t(sapply(appposts$data[[i]]$updated_time, unlist)),t(sapply(appposts$data[[i]]$message, unlist)),t(sapply(appposts$data[[i]]$type, unlist)),t(sapply(appposts$data[[i]]$shares, unlist)))
    post <- setNames(post, c("app_id","post_id","country","created_time","updated_time","message","type","shares"))
    post.df <- rbind(post.df, post)
    
    postlikes.df0 <- data.frame(app[k],post.df[i,2], t(sapply(appposts$data[[i]]$likes$data,unlist)),row.names=NULL)
    postlikes.df0 <- setNames(postlikes.df0, c("app_id","post_id","user_id","name"))  
    postlikes.df <- rbind(postlikes.df,postlikes.df0)
    rm(postlikes.df0)
    try(if (length( appposts$data[[i]]$likes$paging$'next' ) != 0 ){ # was previously postlikes$paging$cursors$after
      repeat{
        #postlikes <- facebook(paste(postidAU.df[i,2],"/likes", sep=""),options, paste(access_token,"&after=",postlikes$paging$cursors[1],sep=""))
        if ( length(apppostslikes$data[[i]]$likes$paging$'next' ) != 0 ) {
          apppostslikes <- fromJSON( gsub("\\\\","",getURL( apppostslikes$data[[i]]$likes$paging$'next' ) ))          
          postlikes.df0 <- data.frame(app[k],post.df[i,2], t(sapply(apppostslikes$data,unlist)),row.names=NULL)
          postlikes.df0 <- setNames(postlikes.df0, c("app_id","post_id","user_id","name"))  
          postlikes.df <- rbind(postlikes.df,postlikes.df0) 
        } else {break}
      } 
    }, silent=T)
  }
}

if (length(appposts$paging[2]) != 0 ){ # was previously postlikes$paging$cursors$after
  repeat{
    if (length(appposts$paging[2]) != 0 ) {
      #appposts <- fromJSON(str_replace_all( gsub("\\\\","",getURL( appposts$paging[2] )), "[^[:alnum:][ ][\\][/][:][,][{][}]",""))      
      appposts <- fromJSON(getURL( appposts$paging[2] ))
      for (i in 1:length(appposts$data)) {
        appposts$data[[i]]$shares[is.null(appposts$data[[i]]$shares)] <- 0
        appposts$data[[i]]$message[is.null(appposts$data[[i]]$message)] <- ""
        post <- data.frame(appname[k,1],t(sapply(appposts$data[[i]]$id, unlist)),t(sapply(appposts$data[[i]]$privacy[1],unlist)),t(sapply(appposts$data[[i]]$created_time, unlist))
                ,t(sapply(appposts$data[[i]]$updated_time, unlist)),t(sapply(appposts$data[[i]]$message, unlist)),t(sapply(appposts$data[[i]]$type, unlist)),t(sapply(appposts$data[[i]]$shares, unlist)))
        post <- setNames(post, c("app_id","post_id","country","created_time","updated_time","message","type","shares"))
        post.df <- rbind(post.df, post)
        
        postlikes.df0 <- data.frame(app[k],post.df[i,2], t(sapply(appposts$data[[i]]$likes$data,unlist)),row.names=NULL)
        postlikes.df0 <- setNames(postlikes.df0, c("app_id","post_id","user_id","name"))  
        postlikes.df <- rbind(postlikes.df,postlikes.df0)
        rm(postlikes.df0)
        try(if (length( appposts$data[[i]]$likes$paging$'next' ) != 0 ){ # was previously postlikes$paging$cursors$after
          repeat{
            #postlikes <- facebook(paste(postidAU.df[i,2],"/likes", sep=""),options, paste(access_token,"&after=",postlikes$paging$cursors[1],sep=""))
            if ( length(apppostslikes$data[[i]]$likes$paging$'next' ) != 0 ) {
              apppostslikes <- fromJSON( gsub("\\\\","",getURL( apppostslikes$data[[i]]$likes$paging$'next' ) ))          
              postlikes.df0 <- data.frame(app[k],post.df[i,2], t(sapply(apppostslikes$data,unlist)),row.names=NULL)
              postlikes.df0 <- setNames(postlikes.df0, c("app_id","post_id","user_id","name"))  
              postlikes.df <- rbind(postlikes.df,postlikes.df0) 
            } else {break}
          } 
        }, silent=T)
      }
    } else {break}
  } 
} else {break}

write.table(post.df, "test3.txt", sep="|")

sqlDrop(DB, "STG.Post")
sqlSave(DB, post.df,"STG.Post")



for (i in 1:length(postAU.df[,1])){
  postcomments <- facebook(paste(postAU.df[i,2],"/comments", sep=""),sprintf("?%s",substr(options, 2,nchar(options))), access_token)
  try(if (length(postcomments$data) == 0) { next } else {
    for (j in 1:length(postcomments$data)) {
      postcomments.df0 <- data.frame(app[k],postAU.df[i,2], t(sapply(postcomments$data[[j]]$id,unlist))
                                     ,t(sapply(postcomments$data[[j]]$from[length(postcomments$data[[j]]$from)-1],unlist)),t(sapply(postcomments$data[[j]]$from[length(postcomments$data[[j]]$from)],unlist)), t(sapply(postcomments$data[[j]]$message,unlist))
                                     ,t(sapply(postcomments$data[[j]]$created_time,unlist)),t(sapply(postcomments$data[[j]]$like_count,unlist))
                                     ,row.names=NULL)
      postcomments.df0 <- setNames(postcomments.df0, c("app_id","post_id","user_post_id","name","user_id","comment","comment_time","like_count"))
      postcomments.df <- rbind(postcomments.df,postcomments.df0)
      rm(postcomments.df0)
      try(if (length(postcomments$paging$'next') != 0 ){ # was previously postcomments$paging$cursors$after
        repeat{
          #postcomments <- facebook(paste(postAU.df[i,2],"/likes", sep=""),options, paste(access_token,"&after=",postcomments$paging$cursors[1],sep=""))
          if (length(postcomments$paging$'next') != 0 ) {
            postcomments <- fromJSON( gsub("\\\\","",getURL( postcomments$paging$'next' ) ))    
            postcomments.df0 <- data.frame(app[k],postAU.df[i,2], t(sapply(postcomments$data[[j]]$id,unlist))
                                           ,t(sapply(postcomments$data[[j]]$from[length(postcomments$data[[j]]$from)-1],unlist)),t(sapply(postcomments$data[[j]]$from[length(postcomments$data[[j]]$from)],unlist)), t(sapply(postcomments$data[[j]]$message,unlist))
                                           ,t(sapply(postcomments$data[[j]]$created_time,unlist)),t(sapply(postcomments$data[[j]]$like_count,unlist))
                                           ,row.names=NULL)
            postcomments.df0 <- setNames(postcomments.df0, c("app_id","post_id","user_post_id","name","user_id","comment","comment_time","like_count"))
            postcomments.df <- rbind(postcomments.df,postcomments.df0)
            rm(postcomments.df0) 
          } else {break}
        } 
      }, silent=T)
    }# else { break } 
  }, silent=T) 
}




## Use for Heineken
postAU.df <- post.df[post.df$country=="Australia",] #| post.df$country=="Public",]
postAU.df <- post.df[post.df$country=="Public",] 

for (i in 1:length(postAU.df[,1])){
  postlikes <- facebook(paste(postAU.df[i,2],"/likes", sep=""),sprintf("?%s",substr(options, 2,nchar(options))), access_token)
  if (length(postlikes$data) == 0) { next } else {
    postlikes.df0 <- data.frame(app[k],postAU.df[i,2], t(sapply(postlikes$data,unlist)),row.names=NULL)
    postlikes.df0 <- setNames(postlikes.df0, c("app_id","post_id","user_id","name"))  
    postlikes.df <- rbind(postlikes.df,postlikes.df0)
    rm(postlikes.df0)
    if (length(postlikes$paging$'next') != 0 ){ # was previously postlikes$paging$cursors$after
      repeat{
        #postlikes <- facebook(paste(postidAU.df[i,2],"/likes", sep=""),options, paste(access_token,"&after=",postlikes$paging$cursors[1],sep=""))
        if (length(postlikes$paging$'next') != 0 ) {
          postlikes <- fromJSON( gsub("\\\\","",getURL( postlikes$paging$'next' ) ))          
          postlikes.df0 <- data.frame(app[k],postAU.df[i,2], t(sapply(postlikes$data,unlist)),row.names=NULL)
          postlikes.df0 <- setNames(postlikes.df0, c("app_id","post_id","user_id","name"))  
          postlikes.df <- rbind(postlikes.df,postlikes.df0) 
        } else {break}
      } 
    }# else { break } 
  } 
}

for (i in 1:length(postAU.df[,1])){
  postcomments <- facebook(paste(postAU.df[i,2],"/comments", sep=""),sprintf("?%s",substr(options, 2,nchar(options))), access_token)
  try(if (length(postcomments$data) == 0) { next } else {
    for (j in 1:length(postcomments$data)) {
      postcomments.df0 <- data.frame(app[k],postAU.df[i,2], t(sapply(postcomments$data[[j]]$id,unlist))
            ,t(sapply(postcomments$data[[j]]$from[length(postcomments$data[[j]]$from)-1],unlist)),t(sapply(postcomments$data[[j]]$from[length(postcomments$data[[j]]$from)],unlist)), t(sapply(postcomments$data[[j]]$message,unlist))
            ,t(sapply(postcomments$data[[j]]$created_time,unlist)),t(sapply(postcomments$data[[j]]$like_count,unlist))
            ,row.names=NULL)
      postcomments.df0 <- setNames(postcomments.df0, c("app_id","post_id","user_post_id","name","user_id","comment","comment_time","like_count"))
      postcomments.df <- rbind(postcomments.df,postcomments.df0)
      rm(postcomments.df0)
      try(if (length(postcomments$paging$'next') != 0 ){ # was previously postcomments$paging$cursors$after
        repeat{
          #postcomments <- facebook(paste(postAU.df[i,2],"/likes", sep=""),options, paste(access_token,"&after=",postcomments$paging$cursors[1],sep=""))
          if (length(postcomments$paging$'next') != 0 ) {
            postcomments <- fromJSON( gsub("\\\\","",getURL( postcomments$paging$'next' ) ))    
            postcomments.df0 <- data.frame(app[k],postAU.df[i,2], t(sapply(postcomments$data[[j]]$id,unlist))
                                           ,t(sapply(postcomments$data[[j]]$from[length(postcomments$data[[j]]$from)-1],unlist)),t(sapply(postcomments$data[[j]]$from[length(postcomments$data[[j]]$from)],unlist)), t(sapply(postcomments$data[[j]]$message,unlist))
                                           ,t(sapply(postcomments$data[[j]]$created_time,unlist)),t(sapply(postcomments$data[[j]]$like_count,unlist))
                                           ,row.names=NULL)
            postcomments.df0 <- setNames(postcomments.df0, c("app_id","post_id","user_post_id","name","user_id","comment","comment_time","like_count"))
            postcomments.df <- rbind(postcomments.df,postcomments.df0)
            rm(postcomments.df0) 
          } else {break}
        } 
      }, silent=T)
    }# else { break } 
  }, silent=T) 
}



sqlDrop(DB, "STG.Post")
sqlSave(DB, postAU.df, "STG.Post", varTypes=c(app_id="varchar(50)",post_id="varchar(50)",created_time="varchar(50)",updated_time="varchar(50)"
                                            ,message="varchar(1000)",type="varchar(50)",shares="int"))

sqlDrop(DB, "STG.PostLikes")
sqlSave(DB, postlikes.df, "STG.PostLikes", varTypes=c(app_id="varchar(50)",post_id="varchar(50)",user_id="varchar(50)",name="varchar(255)"))

sqlDrop(DB, "STG.PostComments")
sqlSave(DB, postcomments.df, "STG.PostComments", varTypes=c(app_id="varchar(50)",post_id="varchar(50)",user_post_id="varchar(50)",name="varchar(255)"
                                                            ,user_id="varchar(50)",comment="varchar(5000)",comment_time="varchar(50)",like_count="varchar(50)"))



write.table(postcomments.df, "test2.txt", sep="\t")

i=1
path = paste(post.df[i,2],"/insights", sep="")

postinsights.df <- data.frame(post_id=character(),engaged_users=character(),people_talking=character(),total_reach=character(),paid_reach=character(),
                              organic_reach=character(),viral_reach=character())

for (i in 1:length(post.df[,2])){
  postinsights <- fromJSON(getURL(URLencode(sprintf("https://graph.facebook.com/%s/insights?limit=1000000&access_token=%s",post.df[i,2],access_token)),quote=T))
  if (length(postinsights$data) != 0) {
    postinsights.df0 <- data.frame(post.df[i,2],t(sapply(postinsights$data[[21]]$values,unlist)),t(sapply(postinsights$data[[1]]$values,unlist))
                          ,t(sapply(postinsights$data[[5]]$values,unlist)),t(sapply(postinsights$data[[7]]$values,unlist)),t(sapply(postinsights$data[[9]]$values,unlist))
                          ,t(sapply(postinsights$data[[11]]$values,unlist))
                                   ,row.names=NULL)
    postinsights.df0 <- setNames(postinsights.df0, c("post_id","engaged_users","people_talking","total_reach","paid_reach","organic_reach","viral_reach"))
    postinsights.df <- rbind(postinsights.df, postinsights.df0)
    rm(postinsights.df0)
  }
}

sqlDrop(DB, "STG.PostInsights")
sqlSave(DB, postinsights.df, "STG.PostInsights")

path1 <- "423998310994817_517821604945820/insights/post_story_adds_unique/lifetime?"
path2 <- "423998310994817_517821604945820/insights/post_story_adds_unique/lifetime?"
x <- c(facebook(path1,options, access_token),facebook(path2,options, access_token) 


postinsights$data[[21]]$values


# Stories
t(sapply(postinsights$data[[1]]$values,unlist))
# Unique impressions / Total Reach
t(sapply(postinsights$data[[5]]$values,unlist))
# Paid Reach
t(sapply(postinsights$data[[7]]$values,unlist))
# Organic Reach
t(sapply(postinsights$data[[9]]$values,unlist))
# Viral Reach
t(sapply(postinsights$data[[11]]$values,unlist))
# Consumers / clicks
t(sapply(postinsights$data[[21]]$values,unlist))
# Consumers / clicks by type
t(sapply(postinsights$data[[23]]$values,unlist))

# Stories by type
t(sapply(postinsights$data[[3]]$values[[1]]$value,unlist))
# Viral reach by story type
t(sapply(postinsights$data[[13]]$values,unlist))
