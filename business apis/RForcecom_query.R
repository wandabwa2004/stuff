RForcecom.query <- function (session, soqlQuery) 
{
  if (!require(XML)) {
    install.packages("XML")
    stop(!require(XML))
  }
  if (!require(RCurl)) {
    install.packages("RCurl")
    stop(!require(RCurl))
  }
  h <- basicHeaderGatherer()
  t <- basicTextGatherer()
  endpointPath <- rforcecom.api.getSoqlEndpoint(session["apiVersion"])
  URL <- paste(session["instanceURL"], endpointPath, curlEscape(soqlQuery), 
               sep = "")
  OAuthString <- paste("Bearer", session["sessionID"])
  httpHeader <- c(Authorization = OAuthString, Accept = "application/xml")
  curlPerform(url = URL, httpheader = httpHeader, headerfunction = h$update, 
              writefunction = t$update, ssl.verifypeer = F)
  if (exists("rforcecom.debug") && rforcecom.debug) {
    message(URL)
  }
  if (exists("rforcecom.debug") && rforcecom.debug) {
    message(t$value())
  }
  x.root <- xmlRoot(xmlTreeParse(t$value(), asText = T))
  errorcode <- NA
  errormessage <- NA
  errorcode <- try(iconv(xmlValue(x.root[["Error"]][["errorCode"]]), 
                         from = "UTF-8", to = ""), TRUE)
  errormessage <- try(iconv(xmlValue(x.root[["Error"]][["message"]]), 
                            from = "UTF-8", to = ""), TRUE)
  if (!is.na(errorcode) && !is.na(errormessage)) {
    stop(paste(errorcode, errormessage, sep = ": "))
  }
  xns <- try(getNodeSet(xmlParse(t$value()), "//records"), silent=T)
  xls <- try(lapply(lapply(xns, xmlToList), unlist), silent=T)
  xdf <- try(as.data.frame(do.call(rbind, xls)), silent=T)
  xdf <- try(xdf[, !grepl("\\.attrs\\.", names(xdf))], silent=T)
  xdf.iconv <- try(data.frame(lapply(xdf, iconv, from = "UTF-8", 
                                 to = "")), silent=T)
  try(nextRecordsUrl <- iconv(xmlValue(x.root[["nextRecordsUrl"]]), 
                              from = "UTF-8", to = ""), silent=TRUE)
  if (!is.na(nextRecordsUrl)) {
    nextRecords <- rforcecom.queryMore(session, nextRecordsUrl)
    xdf.iconv <- try(rbind(xdf.iconv, nextRecords), silent=T)
  }
  return(data.frame(xdf.iconv))
}