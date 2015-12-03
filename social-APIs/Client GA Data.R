

library(RODBC)
GA <- odbcDriverConnect('driver={SQL Server};server=SCURISKISLPT7\\SQLDEV_SC;database=Mirvac;trusted_connection=true')


#u: retail.mirvac@gmail.com
#p: h0113rlytics


require(RGoogleAnalytics)

# Loading the RGoogleAnalytics library
# 1. Authorize your account and paste the accesstoken 

query <- QueryBuilder()
access_token <- query$authorize()       

# 2.  Create a new Google Analytics API object
ga <- RGoogleAnalytics()

ga.profiles <- ga$GetProfileData(access_token)
sqlDrop(GA, "STG.Profiles")
sqlSave(GA, ga.profiles, "STG.Profiles", rownames=NULL)

#ga.profiles <- sqlQuery(GA, "SELECT id, name, Brand, Site
#                            FROM dbo.ga_Profiles WhERE BRAND = 'Vanish'")


start.date = "2012-12-01"
end.date = "2013-11-30"

sqlClear(GA, "STG.Host")
sqlClear(GA, "STG.Page")
sqlClear(GA, "STG.Source")
sqlClear(GA, "STG.Keyword")
sqlClear(GA, "STG.Device")
sqlClear(GA, "STG.Location")
sqlClear(GA, "STG.Event")
sqlClear(GA, "STG.EventLabel")
sqlClear(GA, "STG.SourceEvent")
sqlClear(GA, "STG.SourceHour")
sqlClear(GA, "STG.SourceDevice")
sqlClear(GA, "STG.DeviceEvent")
sqlClear(GA, "STG.LocationEvent")
sqlClear(GA, "STG.Hour")
sqlClear(GA, "STG.HourEvent")
sqlClear(GA, "STG.DeviceHour")



for (i in 1:nrow(ga.profiles))
{
  #Page
  query$Init(start.date = start.date,
             end.date = end.date,
             dimensions = "ga:date,ga:hostname,ga:pageTitle,ga:pagePath",
             metrics = "ga:visitors,ga:visits,ga:newVisits,ga:bounces,ga:pageviews,ga:timeOnPage,ga:timeOnSite,ga:avgtimeonSite",
             max.results = 1000000,
             table.id = paste("ga:",ga.profiles$id[i],sep="",collapse=","),
             access_token=access_token)
  
  try(ga.data <- ga$GetReportData(query), silent=T)
  try(ga.datamerge <- merge(ga.data,data.frame(ProfileID = ga.profiles$id[i])), silent=T)
  try(sqlSave(GA, ga.datamerge, "STG.Page", append=TRUE, rownames=FALSE, verbose=FALSE, fast=TRUE), silent=T)
  try(rm(ga.data), silent=T)
  try(rm(ga.datamerge), silent=T)
}
  
  
  #Host
  query$Init(start.date = start.date,
             end.date = end.date,
             dimensions = "ga:date,ga:hostname",
             metrics = "ga:visitors,ga:visits,ga:newVisits,ga:bounces,ga:pageviews,ga:timeOnPage,ga:timeOnSite,ga:avgtimeonSite",
             max.results = 1000000,
             table.id = paste("ga:",ga.profiles$id[i],sep="",collapse=","),
             access_token=access_token)
  
  try(ga.data <- ga$GetReportData(query), silent=T)
  try(ga.datamerge <- merge(ga.data,data.frame(ProfileID = ga.profiles$id[i])), silent=T)
  try(sqlSave(GA, ga.datamerge, "STG.Host", append=TRUE, rownames=FALSE, verbose=FALSE, fast=TRUE), silent=T)
  try(rm(ga.data), silent=T)
  try(rm(ga.datamerge), silent=T)
  
  #Page
  query$Init(start.date = start.date,
             end.date = end.date,
             dimensions = "ga:date,ga:hostname,ga:pageTitle",
             metrics = "ga:visitors,ga:visits,ga:newVisits,ga:bounces,ga:pageviews,ga:timeOnPage,ga:timeOnSite,ga:avgtimeonSite",
             max.results = 1000000,
             table.id = paste("ga:",ga.profiles$id[i],sep="",collapse=","),
             access_token=access_token)
  
  try(ga.data <- ga$GetReportData(query), silent=T)
  try(ga.datamerge <- merge(ga.data,data.frame(ProfileID = ga.profiles$id[i])), silent=T)
  try(sqlSave(GA, ga.datamerge, "STG.Page", append=TRUE, rownames=FALSE, verbose=FALSE, fast=TRUE), silent=T)
  try(rm(ga.data), silent=T)
  try(rm(ga.datamerge), silent=T)

  #Source
  
  query$Init(start.date = start.date,
             end.date = end.date,
             dimensions = "ga:date,ga:hostname,ga:Source,ga:Medium,ga:campaign",
             metrics = "ga:visitors,ga:visits,ga:newVisits,ga:bounces,ga:pageviews,ga:timeOnPage,ga:timeOnSite,ga:avgtimeonSite",
             max.results = 1000000,
             table.id = paste("ga:",ga.profiles$id[i],sep="",collapse=","),
             access_token=access_token)
  
  try(ga.data <- ga$GetReportData(query), silent=T)
  try(ga.datamerge <- merge(ga.data,data.frame(ProfileID = ga.profiles$id[i])), silent=T)
  try(sqlSave(GA, ga.datamerge, "STG.Source", append=TRUE, rownames=FALSE, verbose=FALSE, fast=TRUE), silent=T)
  try(rm(ga.data), silent=T)
  try(rm(ga.datamerge), silent=T)

  #Keyword
  
  query$Init(start.date = start.date,
             end.date = end.date,
             dimensions = "ga:date,ga:hostname,ga:Source,ga:Medium,ga:campaign,ga:keyword",
             metrics = "ga:visitors,ga:visits,ga:newVisits,ga:bounces,ga:pageviews,ga:timeOnPage,ga:timeOnSite,ga:avgtimeonSite",
             max.results = 1000000,
             table.id = paste("ga:",ga.profiles$id[i],sep="",collapse=","),
             access_token=access_token)
  
  try(ga.data <- ga$GetReportData(query), silent=T)
  try(ga.datamerge <- merge(ga.data,data.frame(ProfileID = ga.profiles$id[i])), silent=T)
  try(sqlSave(GA, ga.datamerge, "STG.Keyword", append=TRUE, rownames=FALSE, verbose=FALSE, fast=TRUE), silent=T)
  try(rm(ga.data), silent=T)
  try(rm(ga.datamerge), silent=T)
  
  #Device
  
  query$Init(start.date = start.date,
             end.date = end.date,
             dimensions = "ga:date,ga:hostname,ga:DeviceCategory",
             metrics = "ga:visitors,ga:visits,ga:newVisits,ga:bounces,ga:pageviews,ga:timeOnPage,ga:timeOnSite,ga:avgtimeonSite",
             max.results = 1000000,
             table.id = paste("ga:",ga.profiles$id[i],sep="",collapse=","),
             access_token=access_token)
  
  try(ga.data <- ga$GetReportData(query), silent=T)
  try(ga.datamerge <- merge(ga.data,data.frame(ProfileID = ga.profiles$id[i])), silent=T)
  try(sqlSave(GA, ga.datamerge, "STG.Device", append=TRUE, rownames=FALSE, verbose=FALSE, fast=TRUE), silent=T)
  try(rm(ga.data), silent=T)
  try(rm(ga.datamerge), silent=T)
  #Location
  
  query$Init(start.date = start.date,
             end.date = end.date,
             dimensions = "ga:date,ga:hostname,ga:continent,ga:country,ga:region,ga:metro,ga:city",
             metrics = "ga:visitors,ga:visits,ga:newVisits,ga:bounces,ga:pageviews,ga:timeOnPage,ga:timeOnSite,ga:avgtimeonSite",
             max.results = 1000000,
             table.id = paste("ga:",ga.profiles$id[i],sep="",collapse=","),
             access_token=access_token)
  
  try(ga.data <- ga$GetReportData(query), silent=T)
  try(ga.datamerge <- merge(ga.data,data.frame(ProfileID = ga.profiles$id[i])), silent=T)
  try(sqlSave(GA, ga.datamerge, "STG.Location", append=TRUE, rownames=FALSE, verbose=FALSE, fast=TRUE), silent=T)
  try(rm(ga.data), silent=T)
  try(rm(ga.datamerge), silent=T)
  #Event
  
  query$Init(start.date = start.date,
             end.date = end.date,
             dimensions = "ga:date,ga:hostname,ga:eventCategory,ga:eventAction",
             metrics = "ga:TotalEvents,ga:UniqueEvents",
             max.results = 1000000,
             table.id = paste("ga:",ga.profiles$id[i],sep="",collapse=","),
             access_token=access_token)
  
  try(ga.data <- ga$GetReportData(query), silent=T)
  try(ga.datamerge <- merge(ga.data,data.frame(ProfileID = ga.profiles$id[i])), silent=T)
  try(sqlSave(GA, ga.datamerge, "STG.Event", append=TRUE, rownames=FALSE, verbose=FALSE, fast=TRUE), silent=T)
  try(rm(ga.data), silent=T)
  try(rm(ga.datamerge), silent=T)
  #Hour
  
  query$Init(start.date = start.date,
             end.date = end.date,
             dimensions = "ga:date,ga:hostname,ga:hour",
             metrics = "ga:visitors,ga:visits,ga:newVisits,ga:bounces,ga:pageviews,ga:timeOnPage,ga:timeOnSite,ga:avgtimeonSite",
             max.results = 1000000,
             table.id = paste("ga:",ga.profiles$id[i],sep="",collapse=","),
             access_token=access_token)
  
  try(ga.data <- ga$GetReportData(query), silent=T)
  try(ga.datamerge <- merge(ga.data,data.frame(ProfileID = ga.profiles$id[i])), silent=T)
  try(sqlSave(GA, ga.datamerge, "STG.Hour", append=TRUE, rownames=FALSE, verbose=FALSE, fast=TRUE), silent=T)
  try(rm(ga.data), silent=T)
  try(rm(ga.datamerge), silent=T)
  #EventLabel
  
  query$Init(start.date = start.date,
             end.date = end.date,
             dimensions = "ga:date,ga:hostname,ga:eventCategory,ga:eventAction,ga:eventLabel",
             metrics = "ga:TotalEvents,ga:UniqueEvents",
             max.results = 1000000,
             table.id = paste("ga:",ga.profiles$id[i],sep="",collapse=","),
             access_token=access_token)
  
  try(ga.data <- ga$GetReportData(query), silent=T)
  try(ga.datamerge <- merge(ga.data,data.frame(ProfileID = ga.profiles$id[i])), silent=T)
  try(sqlSave(GA, ga.datamerge, "STG.EventLabel", append=TRUE, rownames=FALSE, verbose=FALSE, fast=TRUE), silent=T)
  try(rm(ga.data), silent=T)
  try(rm(ga.datamerge), silent=T)
  #SourceEvent
  
  query$Init(start.date = start.date,
             end.date = end.date,
             dimensions = "ga:date,ga:hostname,ga:Source,ga:medium,ga:eventCategory,ga:eventAction,ga:eventLabel",
             metrics = "ga:TotalEvents,ga:UniqueEvents",
             max.results = 1000000,
             table.id = paste("ga:",ga.profiles$id[i],sep="",collapse=","),
             access_token=access_token)
  
  try(ga.data <- ga$GetReportData(query), silent=T)
  try(ga.datamerge <- merge(ga.data,data.frame(ProfileID = ga.profiles$id[i])), silent=T)
  try(sqlSave(GA, ga.datamerge, "STG.SourceEvent", append=TRUE, rownames=FALSE, verbose=FALSE, fast=TRUE), silent=T)
  try(rm(ga.data), silent=T)
  try(rm(ga.datamerge), silent=T)
  #SourceHour
  
  query$Init(start.date = start.date,
             end.date = end.date,
             dimensions = "ga:date,ga:hostname,ga:Source,ga:medium,ga:campaign,ga:hour",
             metrics = "ga:visitors,ga:visits,ga:newVisits,ga:bounces,ga:pageviews,ga:timeOnPage,ga:timeOnSite,ga:avgtimeonSite",
             max.results = 1000000,
             table.id = paste("ga:",ga.profiles$id[i],sep="",collapse=","),
             access_token=access_token)
  
  try(ga.data <- ga$GetReportData(query), silent=T)
  try(ga.datamerge <- merge(ga.data,data.frame(ProfileID = ga.profiles$id[i])), silent=T)
  try(sqlSave(GA, ga.datamerge, "STG.SourceHour", append=TRUE, rownames=FALSE, verbose=FALSE, fast=TRUE), silent=T)
  try(rm(ga.data), silent=T)
  try(rm(ga.datamerge), silent=T)
  #SourceDevice
  
  query$Init(start.date = start.date,
             end.date = end.date,
             dimensions = "ga:date,ga:hostname,ga:Source,ga:medium,ga:campaign,ga:DeviceCategory",
             metrics = "ga:visitors,ga:visits,ga:newVisits,ga:bounces,ga:pageviews,ga:timeOnPage,ga:timeOnSite,ga:avgtimeonSite",
             max.results = 1000000,
             table.id = paste("ga:",ga.profiles$id[i],sep="",collapse=","),
             access_token=access_token)
  
  try(ga.data <- ga$GetReportData(query), silent=T)
  try(ga.datamerge <- merge(ga.data,data.frame(ProfileID = ga.profiles$id[i])), silent=T)
  try(sqlSave(GA, ga.datamerge, "STG.SourceDevice", append=TRUE, rownames=FALSE, verbose=FALSE, fast=TRUE), silent=T)
  try(rm(ga.data), silent=T)
  try(rm(ga.datamerge), silent=T)
  #DeviceHour
  
  query$Init(start.date = start.date,
             end.date = end.date,
             dimensions = "ga:date,ga:hostname,ga:hour,ga:DeviceCategory",
             metrics = "ga:visitors,ga:visits,ga:newVisits,ga:bounces,ga:pageviews,ga:timeOnPage,ga:timeOnSite,ga:avgtimeonSite",
             max.results = 1000000,
             table.id = paste("ga:",ga.profiles$id[i],sep="",collapse=","),
             access_token=access_token)
  
  try(ga.data <- ga$GetReportData(query), silent=T)
  try(ga.datamerge <- merge(ga.data,data.frame(ProfileID = ga.profiles$id[i])), silent=T)
  try(sqlSave(GA, ga.datamerge, "STG.DeviceHour", append=TRUE, rownames=FALSE, verbose=FALSE, fast=TRUE), silent=T)
  try(rm(ga.data), silent=T)
  try(rm(ga.datamerge), silent=T)  
  #HourEvent
  
  query$Init(start.date = start.date,
             end.date = end.date,
             dimensions = "ga:date,ga:hostname,ga:hour,ga:eventCategory,ga:eventAction,ga:eventLabel",
             metrics = "ga:TotalEvents,ga:UniqueEvents",
             max.results = 1000000,
             table.id = paste("ga:",ga.profiles$id[i],sep="",collapse=","),
             access_token=access_token)
  
  try(ga.data <- ga$GetReportData(query), silent=T)
  try(ga.datamerge <- merge(ga.data,data.frame(ProfileID = ga.profiles$id[i])), silent=T)
  try(sqlSave(GA, ga.datamerge, "STG.HourEvent", append=TRUE, rownames=FALSE, verbose=FALSE, fast=TRUE), silent=T)
  try(rm(ga.data), silent=T)
  try(rm(ga.datamerge), silent=T)
  #DeviceEvent
  
  query$Init(start.date = start.date,
             end.date = end.date,
             dimensions = "ga:date,ga:hostname,ga:DeviceCategory,ga:eventCategory,ga:eventAction,ga:eventLabel",
             metrics = "ga:TotalEvents,ga:UniqueEvents",
             max.results = 1000000,
             table.id = paste("ga:",ga.profiles$id[i],sep="",collapse=","),
             access_token=access_token)
  
  try(ga.data <- ga$GetReportData(query), silent=T)
  try(ga.datamerge <- merge(ga.data,data.frame(ProfileID = ga.profiles$id[i])), silent=T)
  try(sqlSave(GA, ga.datamerge, "STG.DeviceEvent", append=TRUE, rownames=FALSE, verbose=FALSE, fast=TRUE), silent=T)
  try(rm(ga.data), silent=T)
  try(rm(ga.datamerge), silent=T)
  #LocationEvent
  
  query$Init(start.date = start.date,
             end.date = end.date,
             dimensions = "ga:date,ga:hostname,ga:region,ga:city,ga:eventCategory,ga:eventAction,ga:eventLabel",
             metrics = "ga:TotalEvents,ga:UniqueEvents",
             max.results = 1000000,
             table.id = paste("ga:",ga.profiles$id[i],sep="",collapse=","),
             access_token=access_token)
  
  try(ga.data <- ga$GetReportData(query), silent=T)
  try(ga.datamerge <- merge(ga.data,data.frame(ProfileID = ga.profiles$id[i])), silent=T)
  try(sqlSave(GA, ga.datamerge, "STG.LocationEvent", append=TRUE, rownames=FALSE, verbose=FALSE, fast=TRUE), silent=T)
  try(rm(ga.data), silent=T)
  try(rm(ga.datamerge), silent=T)
}


sqlQuery(GA, "exec dbo.usp_GA_API_Transform_INSERT" )

sqlQuery(GA, "exec dbo.usp_GA_API_Transform" )





#query$Init(start.date = start.date,
#           end.date = end.date,
#           dimensions = "ga:date,ga:hostname,ga:pageTitle",
#           metrics = "ga:visitors,ga:visits,ga:newVisits,ga:bounces,ga:pageviews,ga:timeOnPage,ga:timeOnSite,ga:avgtimeonSite",
#           max.results = 1000000,
#           table.id = paste("ga:",ga.profiles$id,sep="",collapse=","),
#           access_token=access_token)

#ga.data <- ga$GetReportData(query)

#sqlSave(GA, ga.datamerge, "STG.Page", append=TRUE, rownames=FALSE, verbose=FALSE, fast=TRUE)
#rm(ga.data)






