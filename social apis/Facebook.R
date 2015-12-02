
# Downloaded.  doesn't seem to work!
#facebook <-  function( path = path, options, access_token = access_token){
#  if( !missing(options) ){
#    options <- sprintf( "?%s", paste( names(options), "=", unlist(options), collapse = "&", sep = "" ) )
#  } else {
#    options <- ""
#  }
#  data <- getURL( sprintf( "https://graph.facebook.com/%s%s&access_token=%s", path, options, access_token ))
#  fromJSON( data )
#}



facebook <- function(path = path, options, access_token = access_token){
  data <- getURL(URLencode(sprintf( "https://graph.facebook.com/%s%s&access_token=%s", path, options, access_token )), quote=T )
  #data <- gsub("\\\\","",gsub("\\\\\"","",data))
  tryCatch({
  #data <- gsub("\\o/","",gsub("\\m/","",gsub("\xed","",gsub("\u00","",gsub("\\\\","",gsub("\\\\","",data))))))
  #data <- gsub("\"Bring on the Spray\"","",data)
  data <- str_replace_all(data, "[^[:alnum:][ ][\\][/][:][,][{][}]","")
  #data <- gsub("攼㹤愼㹥戼㸸攼㹤戼㹤㠼㸷","",data)
  #data <- str_replace_all(data, "\"","""")
  fromJSON( data, method = "C",unexpected.escape="skip" )

  }, error=function(e){cat("ERROR :",conditionMessage(e), "\n")})
}

# data <- str_replace_all(data, "[^[:alnum:][^[:punct:]][ ]","")
getAccessToken <- function(){
  browseURL("https://developers.facebook.com/tools/explorer",browser = getOption("browser")) 
  access_token <- scan(what = "string", nlines = 1)
}




