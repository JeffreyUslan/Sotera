library(streamR)
library(Rfacebook)
library(smappR)
library(ROAuth)
library(ggplot2)
library(RCurl)
library(httr)
library(twitteR)


requestURL <- "https://api.twitter.com/oauth/request_token"
accessURL <- "https://api.twitter.com/oauth/access_token"
authURL <- "https://api.twitter.com/oauth/authorize"
consumerKey <- "KSNLkhWfZBOreqrZ9Mbfm5wEA"
consumerSecret <- "7GEOe2giB1I4soi9b1iUSyFPP5fOD9uMDqEh33N8k71QoPgGmM"
my_oauth <- OAuthFactory$new(consumerKey=consumerKey, 
                             consumerSecret=consumerSecret, 
                             requestURL=requestURL, 
                             accessURL=accessURL, 
                             authURL=authURL)

 my_oauth$handshake(cainfo = system.file("CurlSSL", "cacert.pem", package = "RCurl"))

 


 save(my_oauth, file="./credentials/my_oauth.Rdata")
 
#############################
 
