#-------------------------
#
# merge collection results at a given date search
# removes duplicates
#
#------------------------


# 0. prep work

#folder date:
date='2021-02-07'

#set folder locations
computers=c('home_desktop','carbonate')
co=1 #which computer?
buckets=c("E:\\data\\protest202101","/N/project/c19/protest202101")
bucket=buckets[co]

loc_import='data/search_tweets_20210121'

#load libraries
library(tidyverse)
library(stringr)
library(data.table)
library(bit64)

subfolders=dir(file.path(bucket,loc_import,date))

datalist=list()
a=1
#remove the parameters.csv file
for(s in subfolders){
  files=list.files(file.path(bucket,loc_import,date,s))
  remove=match(1,str_detect(files,'parameter'))
  files=files[-remove]
  for (f in files){
    datalist[[a]]=fread(file.path(bucket,loc_import,date,s,f))
    datalist[[a]]$created_at=as.character(datalist[[a]]$created_at)
    datalist[[a]]$quoted_created_at=as.character(datalist[[a]]$quoted_created_at)
    datalist[[a]]$retweet_created_at=as.character(datalist[[a]]$retweet_created_at)
    datalist[[a]]$ext_media_type=as.character(datalist[[a]]$ext_media_type)
    datalist[[a]]$user_id=as.integer64(datalist[[a]]$user_id)
    datalist[[a]]$status_id=as.integer64(datalist[[a]]$status_id)
    datalist[[a]]$quoted_user_id=as.integer64(datalist[[a]]$quoted_user_id)
    datalist[[a]]$reply_to_status_id=as.integer64(datalist[[a]]$reply_to_status_id)
    datalist[[a]]$mentions_user_id=as.integer64(datalist[[a]]$mentions_user_id)
    a=a+1
  }
}

df=rbindlist(datalist)
df=unique(df)

loc_export_merged=file.path(bucket,loc_import,'merged')
if(dir.exists(loc_export_merged)==FALSE){dir.create(loc_export_merged)}
fwrite(df,file.path(loc_export_merged,paste0(date,'-merged.csv')))
       