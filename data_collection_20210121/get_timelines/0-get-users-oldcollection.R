#-------------------------
#
# identify people who most frequently tweet using the query hashtags,
# (one hashtag tweet per day)
#
#------------------------

#loadlib
library(data.table)
library(tidyverse)
library(bit64)

computers=c('home_desktop','carbonate')
co=1 #which computer?
buckets=c("E:\\data\\protest202101","/N/project/c19/protest202101")
bucket=buckets[co]

loc_import= 'data/search_tweets/tweet'
loc_export= 'data/search_tweets_20210121/get_timelines'

if(dir.exists(file.path(bucket,loc_export))==FALSE){dir.create(file.path(bucket,loc_export))}

#list tweet files,get only csv file paths
dirs=list.dirs(file.path(bucket,loc_import))
files=c()
for(d in dirs){
  files=c(files,file.path(d,list.files(d)))
}
files=files[grep('.csv',files)]

#open files, remove duplicates
datalist=list()
a=1
for(f in files){
  datalist[[a]]=fread(f,select=c("user_id","status_id","created_at","screen_name","hashtags"))
  datalist[[a]][,user_id:=as.integer64(user_id)]
  datalist[[a]][,status_id:=as.integer64(status_id)]
  datalist[[a]][,created_at:=as.character(created_at)]
  a=a+1
}
df=rbindlist(datalist)
df=df[created_at>'2020-12-31']
#remove polisimin yanindayim hashtags
remove_polis=grep('olisimin',df$hashtags)
df=df[!remove_polis]
setorder(df,screen_name,created_at,user_id)
remove=duplicated(df[,.(user_id,status_id)])
df=df[!remove]
df=unique(df)

#get users with highest number of tweets
df_freq=df[,.N,by=screen_name]
setorder(df_freq,-N)
#set frequency cutoff(one hashtag per day)
N_cutoff_numeric=7
df_freq$N_cutoff_numeric=N_cutoff_numeric
df_freq=df_freq[N>=N_cutoff_numeric]

filename='namelist-2021-01-07.csv'
fwrite(df_freq,file.path(bucket,loc_export,filename))
