# Code connects to LinkedIn, and can run searches on a list of company names
# Doesn't work as of 2015 - LinkedIn have changed the API limit

#install.packages("lsa")

# https://github.com/mpiccirilli/Rlinkedin

install.packages("Rtools")
install.packages("devtools")
require(devtools)
install_github("mpiccirilli/Rlinkedin")

require(Rlinkedin)

app_name <- ""
consumer_key <- ""
consumer_secret <- ""

in.auth <- inOAuth(app_name, consumer_key, consumer_secret)

#my.connections <- getMyConnections(in.auth)
my.profile <- getProfile(in.auth)
#connections.profiles <- getProfile(in.auth, connections = TRUE)
#individual.profile <- getProfile(in.auth, id = my.connections$id[1])

# list of companies imported as csv
data <- read.csv("",sep=",")

head(data$Company.Name)

clean.text <- function(some_txt)
{
  try.tolower = function(x)
  {
    y = NA
    try_error = tryCatch(tolower(x), error=function(e) e)
    if (!inherits(try_error, "error"))
      y = tolower(x)
    return(y)
  }
  some_txt = sapply(some_txt, try.tolower)
  some_txt = gsub(" corporation", "", some_txt)
  some_txt = gsub(" inc.", "", some_txt)
  some_txt = gsub("(rt|via)((?:\\b\\W*@\\w+)+)", "", some_txt)
  some_txt = gsub("@\\w+", "", some_txt)
  some_txt = gsub("[[:punct:]]", "", some_txt)
  some_txt = gsub("[[:digit:]]", "", some_txt)
  some_txt = gsub("http\\w+", "", some_txt)
  some_txt = gsub("[ \t]{2,}", "", some_txt)
  some_txt = gsub("^\\s+|\\s+$", "", some_txt)
  some_txt = gsub("-", " ", some_txt)
  some_txt = gsub("amp", "", some_txt)
  some_txt = gsub(" llc", "", some_txt)
  some_txt = gsub(" ltd", "", some_txt)
  some_txt = gsub(" limited", "", some_txt)
  some_txt = gsub(" company", "", some_txt)
  some_txt = gsub(" inc", "", some_txt)
  some_txt = gsub(" corp", "", some_txt)
  # define "tolower error handling" function
  
  some_txt = some_txt[some_txt != ""]
  names(some_txt) = NULL
  return(some_txt)
}



companies <- data.frame("name"=character(), "website"=character())

companies <- setNames(data.frame(clean.text(data$Company.Name)
                                 ,gsub('google.com/intl/en/about/index.html','google.com',
                                   gsub("www.","",gsub("http://www.","", data$Web.Address))))
                      ,c("name","website"))


# direct name matches
matches <- data.frame("field"=character(),"value"=character()
                      ,"type"=character(), "type.value"=character())

# email domain matches


#getCompany(token=in.auth, email_domain="google.com")
#getCompany(token=in.auth, universal_name="google")

companies.nosite <- companies[companies$website=="",]

searchMatches <- data.frame("company_id"=character(), "company_name"=character(), "universal_name"=character()
                            ,"website"=character(),"num_followers"=character(),"industry"=character(), "employee_count"=character(),"type"=character()
                            ,"type.value"=character())
i<-4
#length(companies$name)
for (i in 51:100) {
  try(search.comp <- searchCompanies(token=in.auth, keywords=companies$name[i]), silent=T)  
  temp.hold <- data.frame("company_id"=character(), "company_name"=character(), "universal_name"=character()
                      ,"website"=character(),"num_followers"=character(),"industry"=character(), "employee_count"=character(),"type"=character()
                      ,"type.value"=character())
  try(for (j in 1:length(search.comp)) {
    try(temp <- setNames(data.frame(data.frame(t(sapply(search.comp[j], function(x){
      x[c("company_id", "company_name", "universal_name", "website", "num_followers", "industry1", "employee_count")]
    })))
    ,"keywords",companies2[i], j) 
    ,c("company_id", "company_name", "universal_name", "website", "num_followers", "industry", "employee_count"
       ,"type","type.value","matchNo")), silent=T)
    try(temp.hold <- rbind(temp.hold, temp))
  }, silent=T)
  try(searchMatches <- rbind(searchMatches
                       ,temp.hold )
      ,silent=T) 
  if (exists("temp")) {
    rm(temp)
    rm(search.comp)
  }
}



searchMatches.df <- setNames(data.frame(unlist(searchMatches$company_id)
                            ,unlist(searchMatches$company_name)
                            ,unlist(searchMatches$universal_name)
                            ,unlist(searchMatches$website)
                            ,unlist(searchMatches$num_followers)
                            #,unlist(searchMatches$industry1)
                            ,unlist(searchMatches$employee_count)
                            ,unlist(searchMatches$type)
                            ,unlist(searchMatches$type.value)
                            ,unlist(searchMatches$matchNo))
                          ,c("company_id", "company_name", "universal_name", "website", "num_followers", "employee_count","type","type.value","matchNo"))

write.csv(searchMatches.df,file="/Users/stephancuriskis/Documents/Work/Nearmap/LinkedIn_SearchMatches2.csv")



for (i in 1:length(companies$name)) {
  try(temp <- setNames(data.frame(unlist(getCompany(token=in.auth
                                                    , email_domain=companies$website[i]) )
                                  ,"email_domain",companies$name[i]) 
                       ,c("value","type","type.value")), silent=T)
  try(matches <- rbind(matches
                       ,setNames(data.frame(rownames(temp),temp),c("field",colnames(temp))) )
      ,silent=T) 
  if (exists("temp")) {
    rm(temp)
  }
}

for (i in 1:length(companies$name)) {
  try(temp <- setNames(data.frame(unlist(getCompany(token=in.auth
                                                    , universal_name=companies$name[i]) )
                                  ,"universal_name",companies$name[i]) 
                       ,c("value","type","type.value")), silent=T)
  try(matches <- rbind(matches
                       ,setNames(data.frame(rownames(temp),temp),c("field",colnames(temp))) )
      ,silent=T) 
  if (exists("temp")) {
    rm(temp)
  }
}



write.csv(matches, file="/Users/stephan.curiskis/Documents/Work/LinkedIn_Matches.csv")