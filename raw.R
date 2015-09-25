library(streamR)
library(Rfacebook)
library(smappR)
library(ROAuth)
library(ggplot2)
library(RCurl)
library(httr)
library(twitteR)


load("./credentials/my_oauth.Rdata")

# Getting a sample of geotagged tweets from the whole world. 9 hours 10 minutes at a time
# Twitter colses connection a the slightest banwidth blip. 
# Best practice is to make many small queries and save them periodically.
tweets.df=data.frame()
for (i in 1:54){
  try(file.remove("tweets.json"))
  filterStream("tweets.json", timeout = 600, locations=c(-125, 25, -66, 50), language=c("en"), oauth = my_oauth)
  tmp<-try(parseTweets("tweets.json", verbose  = FALSE))
  if (class(tmp) != "try-error") tweets.df <- rbind(tweets.df,tmp)
  if (sum(duplicated(tweets.df))>0) tweets.df=tweets.df[!duplicated(tweets.df),]
}

save(tweets.df, file="./world_tweets.rda")
# load("./world_tweets.rda")
tweets.df=tweets.df[!is.na(tweets.df$place_lat),]
tweets.df=tweets.df[!is.na(tweets.df$place_lon),]

# Extracted high volume users
geo_table=as.data.frame(table(tweets.df$user_id_str))
geo_table <- geo_table[order(-geo_table$Freq),]
head(geo_table)
high_id=as.character(geo_table$Var1[1])
tweets.df$screen_name[tweets.df$user_id_str==high_id][1]

high_tweets=tweets.df[which(tweets.df$user_id_str==high_id),]
sd(high_tweets$place_lat)
sd(high_tweets$place_lon)



#You must follow the account first!
# Pulling 1 hour of tweets 5 minutes at a time for the previously discovered highest volume user.
katyperry="21447363"
justinbieber="27260086"
taylorswift13="17919972"


# potential_users=c("katyperry","justinbieber","taylorswift13")
# user_ids=c("21447363","27260086","17919972")
# potential_user.df=data.frame(potential_users,user_ids)
# 
# for (i in 1:nrow(potential_user.df)){
#   print(potential_user.df$potential_users[i])
#   print(potential_user.df$user_ids[i])
# }

tweets2.df=data.frame()
minutes=5
for (i in 1:minutes){
  try(file.remove("tweets2.json"))
  filterStream("tweets2.json", timeout = 60, follow=c(rihanna),
               oauth = my_oauth)
  tmp<-try(parseTweets("tweets2.json", verbose  = FALSE))
  if (class(tmp) != "try-error") tweets2.df <- rbind(tweets2.df,tmp)
  if (sum(duplicated(tweets2.df))>0) tweets2.df=tweets2.df[!duplicated(tweets2.df),]
}
save(tweets2.df, file="./rihanna.rda")
# load("./taylorswift13.rda")
sum(!is.na(tweets2.df$place_lat))
nrow(tweets2.df)
sd(tweets2.df$place_lat,na.rm=TRUE)


summary(tweets2.df$place_lat)
sd(tweets2.df$place_lat,na.rm=TRUE)
summary(tweets2.df$place_lon)
sd(tweets2.df$place_lon,na.rm=TRUE)
sum(!is.na(tweets2.df$place_lat))
tweets2.df=tweets2.df[!is.na(tweets2.df$place_lat),]
tweets2.df=tweets2.df[!is.na(tweets2.df$place_lon),]





