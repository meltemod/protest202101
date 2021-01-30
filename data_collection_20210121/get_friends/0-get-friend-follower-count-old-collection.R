#----------------------------------
#
# Get the list of users (from the old collection)
#
#----------------------------------

#loadlib
library(data.table)
library(tidyverse)
library(bit64)

computers=c('home_desktop','carbonate')
co=1 #which computer?
buckets=c("E:\\data\\protest202101","/N/project/c19/protest202101")
bucket=buckets[co]

loc_import= 'data/search_tweets/tweet'
loc_export= 'data/search_tweets_20210121/get_friends'

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
  datalist[[a]]=fread(f,select=c("user_id","screen_name","hashtags","followers_count","friends_count","account_created_at"))
  datalist[[a]][,user_id:=as.integer64(user_id)]
  a=a+1
}
df=rbindlist(datalist)
df=df[created_at>'2020-12-31']
#remove polisimin yanindayim hashtags
remove_polis=grep('olisimin',df$hashtags)
df=df[!remove_polis,.(user_id,screen_name,friends_count,followers_count)]
df=unique(df)
setorder(df,screen_name)

#get users with highest number of friend count
tmp=df[,max(friends_count),by=screen_name]
setnames(tmp,'V1','friends_count')
tmp2=df[,max(followers_count),by=screen_name]
setnames(tmp2,'V1','followers_count')
tmp=merge(tmp,tmp2)
tmp3=unique(df[,.(user_id,screen_name,account_created_at)])
tmp=merge(tmp,tmp3)

#save data
filename='friend-count-list-2021-01-07.csv'
fwrite(tmp,file.path(bucket,loc_export,filename))
