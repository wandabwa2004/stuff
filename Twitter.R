

# Install
install.packages("tm")  # for text mining
install.packages("SnowballC") # for text stemming
install.packages("wordcloud") # word-cloud generator 
install.packages("RColorBrewer") # color palettes
install_github("twitteR", username="geoffjentry")
install.packages("ROAuth")
install.packages("stringr")
#install.packages("methods")
install.packages("httr")

# Load
library("tm")
library("SnowballC")
library("wordcloud")
library("RColorBrewer")
library(devtools)
library(twitteR)
library(ROAuth)
library(stringr)
library(RCurl)
library(methods)
library(httr)


download.file(url="http://curl.haxx.se/ca/cacert.pem",
              destfile="cacert.pem")

requestURL <- "https://api.twitter.com/oauth/request_token"
accessURL <- "https://api.twitter.com/oauth/access_token"
authURL <- "https://api.twitter.com/oauth/authorize"

consumer_key <- "UIga6W97abWKDbh57dWDdANvT"
consumer_secret <- "Nuz8zKzEIOtoTq8wm52XOmV1ef2OmpL8PbNCokDE9wXBg6f8sN"
access_token <- "634505557-t1VkGER1Jj8aSSrSQgL3RL580ZMgJwUmhQgy5BvB"
access_secret <- "RiUaIIXpjDj2ArB4uoaHZb9ehV1LDnWIY2APCyu4KG2Lq"

#setup_twitter_oauth(consumer_key, consumer_secret)
setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_secret)
#save(list="twitCred", file="twitteR_credentials")

tweets <- searchTwitter("#IllRideWithYou", n=1000
                        ,since="2014-12-20", until="2014-12-22")

tweets <- searchTwitter("#NopeNopeNope", n=10000
                        ,since="2015-05-23", until="2015-05-25")
tweets.old <- tweets

head(tweets)

text <- setNames(data.frame(tweets[[1]]$text, tweets[[1]]$created, tweets[[1]]$screenName)
                 ,c("text","created","name"))
for (i in 2:length(tweets)) {
  text <- rbind(text
                ,setNames(data.frame(tweets[[i]]$text, tweets[[i]]$created, tweets[[i]]$screenName)
                     ,c("text","created","name")))
}

#head(text)

#Pull out who a message is to
text$to=sapply(text$text,function(tweet) str_extract(tweet,"^(@[[:alnum:]_]*)"))
#And here's a way of grabbing who's been RT'd
text$rt=sapply(text$text,function(tweet) str_match(tweet,"^RT (@[[:alnum:]_]*)")[2])


##########
# Analysis courtesy of 
# http://www.sthda.com/english/wiki/text-mining-and-word-cloud-fundamentals-in-r-5-simple-steps-you-should-know

docs <- Corpus(VectorSource(text[,1]))

docs <- tm_map(docs,
                   content_transformer(function(x) iconv(x, to='UTF-8-MAC', sub='byte')),
                   mc.cores=1)

toSpace <- content_transformer(function (x , pattern ) gsub(pattern, " ", x))

docs <- tm_map(docs, toSpace, "/")
docs <- tm_map(docs, toSpace, "@")
docs <- tm_map(docs, toSpace, "\\|")
docs <- tm_map(docs, toSpace, "http")

# Convert the text to lower case
docs <- tm_map(docs, content_transformer(tolower), lazy=T)
# Remove numbers
docs <- tm_map(docs, removeNumbers, lazy=T)
# Remove english common stopwords
docs <- tm_map(docs, removeWords, stopwords("english"), lazy=T)
# Remove your own stop word
# specify your stopwords as a character vector
docs <- tm_map(docs, removeWords, c("nopenopenope")) 
# Remove punctuations
docs <- tm_map(docs, removePunctuation, lazy=T)
# Eliminate extra white spaces
docs <- tm_map(docs, stripWhitespace, lazy=T)

docs <- tm_map(docs,toSpace, "tco", lazy=T)
docs <- tm_map(docs,toSpace, "tco", lazy=T)

dtm <- TermDocumentMatrix(docs)
m <- as.matrix(dtm)
v <- sort(rowSums(m),decreasing=TRUE)
d <- data.frame(word = names(v),freq=v)
head(d, 10)

require(RMySQL)

db <- dbConnect(MySQL(), dbname='Twitter', user='root')
tweet.df <- setNames(data.frame(text[,1]),"Tweet")

dbWriteTable(db, "NopeNopeNope_20150525", tweet.df)

# Word cloud
set.seed(42)
wordcloud(words = d$word, freq = d$freq, min.freq = 1,
          max.words=200, random.order=FALSE, rot.per=0.35, 
          colors=brewer.pal(8, "Dark2"))

# further - frequency and association
findFreqTerms(dtm, lowfreq = 4)
findAssocs(dtm, terms = "abbott", corlimit = 0.3)

barplot(d[1:10,]$freq, las = 2, names.arg = d[1:10,]$word,
        col ="lightblue", main ="Most frequent words",
        ylab = "Word frequencies")







mydata.df.scale <- scale(dtm)
d <- dist(mydata.df.scale, method = "euclidean") # distance matrix
fit <- hclust(d, method="ward")
plot(fit) # display dendogram?

groups <- cutree(fit, k=5) # cut tree into 5 clusters
# draw dendogram with red borders around the 5 clusters
rect.hclust(fit, k=5, border="red")


str(tweets[[1]])

i<-1
tweets[[i]]$latitude
tweets[[i]]$longitude
tweets[[i]]$created
tweets[[i]]$retweetCount
tweets[[i]]$urls
tweets[[i]]$screenName
tweets[[i]]$replyToUID
tweets[[i]]$text


jesuischarlie <- searchTwitter('#jesuischarlie', n=1000)

head(tweets)
head(jesuischarlie)

