#----------------------------------
#
# Get the list of users (from the old collection)
#
#----------------------------------

#loadlib
library(data.table)
library(tidyverse)
library(bit64)

#set language
#"" for default
#"Turkish" for Turkish on Windows
#"tr" for Turkish on Linux
lang="Turkish" 
Sys.setlocale(category = "LC_ALL", locale = lang)

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
  datalist[[a]]=read_csv(f)%>%
    select(c("user_id","screen_name","hashtags",
                                            "followers_count","friends_count",
                                            "account_created_at","created_at"))%>%
    mutate(user_id=as.integer64(user_id))
  a=a+1
}
df=rbindlist(datalist)
df=df[created_at>'2020-12-31']

#limit tweets to those who have hashtags listed in the new query
query_df=read_csv(file.path(bucket,'data/search_tweets_20210121','query.csv'))
query=query_df$value
query=gsub('#','',query)

#filter tweetsayim hashtags
df[,keep:=0]
for(q in query){
  print(paste(q,match(q,query)))
  keep_tweet=grep(q,df$hashtags)
  df[keep_tweet,keep:=1]
}
df=df[keep==1]
df=df[,.(user_id,screen_name,friends_count,followers_count,account_created_at)]

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
