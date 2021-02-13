#-------------------------
#
# search-tweets
#
#
#------------------------

# 0. prep work
#set query division (1,2,3 or 4)
division=1

#set app
apps=c('meltemodabas001')
app=1 #which app?

#set folder locations
loc_import='data/search_tweets_20210121_de'
loc_export='data/search_tweets_20210121_de'

computers=c('home_desktop','carbonate')
co=1 #which computer?
buckets=c("E:\\data\\protest202101","/N/project/c19/protest202101")
bucket=buckets[co]
loc_key= 'key'
loc_function='functions'

#load functions
load(file.path(getwd(),loc_function,'functions.RData'))

#load libraries
library(tidyverse)
library(rtweet)
library(data.table)

#1.create folder for saving the data with today's date (if does not exist)
date=Sys.time()
date=as.character(as.Date(date))
dirs=dir(file.path(bucket,loc_export))
folder=c()
for(d in dirs){
  if(length(grep(d,date))>0){
    folder=c(folder,d)
  }
}
if(length(folder)==0){
  folder=date
  dir.create(file.path(bucket,loc_export,folder))
}

#2.create subfolder
loc_export_sub=file.path(bucket,loc_export,folder,sprintf('%02d',division))
if(dir.exists(loc_export_sub)==FALSE){
  dir.create(loc_export_sub)
}

#3. select the subset of hashtags to collect
query_df=read_csv(file.path(bucket,loc_export,'query.csv'))
#divide query to 12 word chunks
divisions=list()
a=1
for(d in 1:ceiling(nrow(query_df)/12)){
  divisions[[d]]=c(a:(a+11))
  a=a+12
}
div=divisions[[division]]

query=query_df$value[div]
query=query[is.na(query)==FALSE]
query=paste(query,collapse=' OR ')

#4. set token

#load keys
key = read_csv(file.path(bucket,loc_key,"all_app_keys.csv"))
key = key %>%
  filter(appname==apps[app])

#define twitter app keys
twitter_token <- create_token(
  app = key$appname[1],
  consumer_key = key$value[1],
  consumer_secret = key$value[2],
  access_token = key$value[3],
  access_secret = key$value[4])

#5. collect tweets

#set parameters

#new parameter
since=NULL
until='2021-02-07'


q=query
n_search <- 18000
rt <- FALSE #do not include retweets in our search
maxid <- NULL #for the first round, set maxid to null, which will let us collect the newest tweets.
round_total <-100

tmp_maxid = if(is.null(maxid)){'NULL'}else{maxid}

#save parameters
parameters = data.frame(parameter=c('query',
                                    'n_search',
                                    'rt',
                                    'maxid',
                                    'round_total',
                                    'since',
                                    'until'),
                        value= c(q,
                                 n_search,
                                 rt,
                                 tmp_maxid,
                                 round_total,
                                 since,
                                 until))
write_csv(parameters, file = file.path(loc_export_sub,"parameters.csv"))

meltem_search_tweets(q=q,rt=rt,
                     n_search=n_search,maxid=tmp_maxid,
                     round_total=round_total,
                     loc_export=loc_export_sub,
                     since=since,
                     until=until)



