#-------------------------------------------------
# collect users' most recent 3.2K tweets
# (get_timeline)
#------------------------------------------------

#loadlib
library(data.table)
library(tidyverse)

computers=c('home_desktop','carbonate')
co=1 #which computer?
buckets=c("E:\\data\\protest202101","/N/project/c19/protest202101")
bucket=buckets[co]
loc_key= 'key'
loc_function='functions'

#set app
apps=c('meltemodabas001','modabas001',
       'meltemodabas002','modabas002',
       'meltemodabas003','modabas003',
       'meltemodabas004','modabas004',
       'meltemodabas005','modabas005',
       'meltemodabas006','modabas006')
app=1 #which app?
n_apps=length(apps)

loc_import= 'data/search_tweets_20210121/get_timelines'
loc_export= 'data/search_tweets_20210121/get_timelines'

files=list.files(file.path(bucket,loc_import))
files=files[grep('namelist',files)]

datalist=list()
a=1
for (f in files){
  datalist[[a]]=fread(file.path(bucket,loc_import,f),select='screen_name')
  a=a+1
}
df=rbindlist(datalist)
names=unique(df$screen_name)

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

n=0
for(i in 1:length(names)){
  #load keys
  print(paste(names[i],';',i,'out of',length(names),". App:",key$appname[1]))
  flush.console()
  datalist[[i]]=get_timeline(names[i],n=1000,check=FALSE)
  n=n+nrow(datalist[[i]])
  if (n>148000) {
    n=0
    if(app!=n_apps){
      app=app+1
    }else{
      app=1
    }
    #sleep for 8 minutes
    print('Sleeping for 8 minutes')
    Sys.sleep(8*60)
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
  }
}

df=rbindlist(datalist)
df=df[created_at>as.POSIXct('2020-12-31')]
df_freq=df[,.N,by=screen_name]
df_freq=df_freq[N==1000]

date=str_extract(files,'[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]')
date=max(date)
loc_export_sub=file.path(bucket,loc_export,date)
if(dir.exists(loc_export_sub)==FALSE){dir.create(loc_export_sub)}
filename=file.path(loc_export_sub,paste0("user-tweets-upto-1K-",date,".csv"))
filename1K=file.path(loc_export_sub,paste0("users-with-more-than-1K-tweets-",date,".csv"))
fwrite(df,filename)
fwrite(df_freq,filename1K)

##collect 3.2K tweets of high freq users
if(app!=n_apps){
  app=app+1
}else{
  app=1
}

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

new_names=df_freq$screen_name

new_datalist=list()
n=0
for(i in 1:length(new_names)){
  #load keys
  print(paste(new_names[i],';',i,'out of',length(new_names),". App:",key$appname[1]))
  flush.console()
  mid=tail(df[screen_name==new_names[i]],1)$status_id
  new_datalist[[i]]=get_timeline(new_names[i],n=3200,check=FALSE,max_id = mid)
  n=n+nrow(new_datalist[[i]])
  if (n>100000) {
    n=0
    if(app!=n_apps){
      app=app+1
    }else{
      app=1
    }
    #sleep for 8 minutes
    print('Sleeping for 8 minutes')
    Sys.sleep(8*60)
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
  }
}

new_df=rbindlist(new_datalist)
new_df=new_df[created_at>as.POSIXct('2020-12-31')]

filename3K=file.path(loc_export_sub,paste0("user-tweets-more-than-1K-",date,".csv"))
fwrite(new_df,filename3K)
