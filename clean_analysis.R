library(streamR)
library(Rfacebook)
library(smappR)
library(ROAuth)
library(ggplot2)
library(RCurl)
library(httr)
library(twitteR)
library(grid)
library(maps)
library(dplyr)
library(tidyr)

#Loading credentials necessary to interact with the twitter API
load("./credentials/my_oauth.Rdata")

#Top 3 non-political twitter users to be potentially used in analysis


potential_users=c("katyperry","justinbieber","taylorswift13")
user_ids=c("21447363","27260086","17919972")
potential_user.df=data.frame(potential_users,user_ids)


#Pull 5 minutes of tweets for sampling
for (i in 1:nrow(potential_user.df)){
  user=as.character(potential_user.df$potential_users[i])
  user_id=as.character(potential_user.df$user_ids[i])
  
  tweets2.df=data.frame()
  
  minutes=5
  for (i in 1:minutes){
    try(file.remove("tweets2.json"))
    filterStream("tweets2.json", timeout = 60, follow=c(user_id),
                 oauth = my_oauth)
    tmp<-try(parseTweets("tweets2.json", verbose  = FALSE))
    if (class(tmp) != "try-error") tweets2.df <- rbind(tweets2.df,tmp)
    if (sum(duplicated(tweets2.df))>0) tweets2.df=tweets2.df[!duplicated(tweets2.df),]
  }
  save(tweets2.df, file=paste0("./",user,"2.rda"))
}


#Collect information on tweets gathered
tweet_tot_n=NULL
tweet_geo_n=NULL
tweet_geo_lat_sd=NULL
tweet_geo_lon_sd=NULL
for (i in 1:nrow(potential_user.df)){
  user=as.character(potential_user.df$potential_users[i])
  user_id=as.character(potential_user.df$user_ids[i])
  load(paste0("./",user,"2.rda"))
  
  tweet_tot_n=c(tweet_tot_n,nrow(tweets2.df))
  tweet_geo_n=c(tweet_geo_n,sum(!is.na(tweets2.df$place_lat)))
  tweet_geo_lat_sd=c(tweet_geo_lat_sd,sd(tweets2.df$place_lat,na.rm=TRUE))
  tweet_geo_lon_sd=c(tweet_geo_lon_sd,sd(tweets2.df$place_lon,na.rm=TRUE))
  
}
potential_user.df=data.frame(potential_user.df,
                             Total_sample=tweet_tot_n,
                             Geo_tagged_count=tweet_geo_n,
                             Geo_lat_sd=tweet_geo_lat_sd,
                             Geo_lon_sd=tweet_geo_lon_sd)




#Taylor Swift seems the ideal candidate
user="taylorswift13"
user_id="17919972"

#Gathering 60 minutes worth of tweets
tweets3.df=data.frame()
minutes=180
for (i in 1:minutes){
  try(file.remove("tweets3.json"))
  filterStream("tweets3.json", timeout = 60, follow=c(user_id),
               oauth = my_oauth)
  tmp<-try(parseTweets("tweets3.json", verbose  = FALSE))
  if (class(tmp) != "try-error") tweets3.df <- rbind(tweets3.df,tmp)
  if (sum(duplicated(tweets3.df))>0) tweets3.df=tweets3.df[!duplicated(tweets3.df),]
}

 save(tweets3.df, file=paste0("./",user,"3.rda"))


#Combing Taylor's two data sets
load(paste0("./",user,"3.rda"))
load(paste0("./",user,"2.rda"))
final_data=rbind(tweets2.df,tweets3.df)


# load(paste0("./final_data.rda"))
if (sum(duplicated(final_data))>0) final_data=final_data[!duplicated(final_data),]
# save(final_data, file=paste0("./final_data.rda"))

# some statistics on the final data set
nrow(final_data)
sum(!is.na(final_data$place_lat))

final_data=final_data[!is.na(final_data$place_lat),]
final_data=final_data[!is.na(final_data$place_lon),]

final_data=tbl_df(final_data)
final_data %>% summarise(Min_Longitude=min(place_lat),Max_Longitude=max(place_lat),
                         SD_Longitude=sd(place_lat))
final_data %>% summarise(Min_Longitude=min(place_lon),Max_Longitude=max(place_lon),
                         SD_Longitude=sd(place_lon))



#Plot out the locations

map.data <- map_data(map="world")
points <- data.frame(x = as.numeric(final_data$place_lon), y = as.numeric(final_data$place_lat))
ggplot(map.data) + 
  geom_map(aes(map_id = region), map = map.data, fill = "white",color = "grey20", size = 0.25) + 
  geom_point(data = points,aes(x = x, y = y), size = 7, alpha = 1/5, color = "darkblue") +
  ggtitle("Locations of Taylor Swift's Tweets")+xlab("Longitude")+ylab("Latitude")

# dividing locations into grids
grids_x=10
lon_min=floor(min(final_data$place_lon))
lon_max=ceiling(max(final_data$place_lon))
grid_lon=seq(lon_min,lon_max,((lon_max-lon_min)/grids_x))

lat_min=floor(min(final_data$place_lat))
lat_max=ceiling(max(final_data$place_lat))
grid_lat=seq(lat_min,lat_max,((lat_max-lat_min)/grids_x))

final_data$lon_grid=NA
final_data$lat_grid=NA
for (i in 2:(grids_x+1)){
  lon_ind=which(final_data$place_lon<=grid_lon[i] & final_data$place_lon>=grid_lon[i-1])
  final_data$lon_grid[lon_ind]=(i-1)
  lat_ind=which(final_data$place_lat<=grid_lat[i] & final_data$place_lat>=grid_lat[i-1])
  final_data$lat_grid[lat_ind]=(i-1)
}

final_data$grid=paste(final_data$lat_grid,final_data$lon_grid)



#Grid Distributions

final_data %>% group_by(grid) %>% summarise(Count=n(),
                                            Probability=round(n()/nrow(final_data),4),                            
                                            Longitude_Minimum=min(place_lon),
                                            Longitude_Maximum=max(place_lon),
                                            Latitude_Minimum=min(place_lat),
                                            Latitude_Maximum=max(place_lat)) %>% 
  arrange(desc(Count))

#Longitude Disributions
final_data %>% group_by(lon_grid) %>% summarise(Count=n(),
                                                Probability=round(n()/nrow(final_data),4),                            
                                                Longitude_Minimum=min(place_lon),
                                                Longitude_Maximum=max(place_lon)) %>% 
  arrange(desc(Count))

#Latitude Distributions
final_data %>% group_by(lat_grid) %>% summarise(Count=n(),
                                                Probability=round(n()/nrow(final_data),4),                            
                                                Latitude_Minimum=min(place_lat),
                                                Latitude_Maximum=max(place_lat)) %>% 
  arrange(desc(Count))
