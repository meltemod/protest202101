#---------------------------------------------
#
#   Collect friends of users
#
#
#
#----------------------------------------------


computers=c('home_desktop','carbonate')
co=1 #which computer?
buckets=c("E:\\data\\protest202101","/N/project/c19/protest202101")
bucket=buckets[co]
loc_key= 'key'
loc_function='functions'

loc_import= 'data/search_tweets_20210121/get_friends'
loc_export= 'data/search_tweets_20210121/get_friends'



#load libraries
library(tidyverse)
library(data.table)
library(rtweet)
library(bit64)

#set app
apps=c('meltemodabas001',
       'modabas006')
app=1 #which app?
n_apps=length(apps)

files=list.files(file.path(bucket,loc_import))
files=files[grep('friend-count-list-',files)]
files=files[files!='friend-count-list-2021-01-07.csv']

datalist=list()
a=1
for (f in files){
  datalist[[a]]=fread(file.path(bucket,loc_import,f))
  a=a+1
}
df=rbindlist(datalist)

#create subfolder to save
date=str_extract(files,'[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]')
date=max(date)
loc_export_sub=file.path(bucket,loc_export,date)
if(dir.exists(loc_export_sub)==FALSE){dir.create(loc_export_sub)}

#get users with highest number of friend count
tmp=df[,max(friends_count),by=screen_name]
setnames(tmp,'V1','friends_count')
tmp2=df[,max(followers_count),by=screen_name]
setnames(tmp2,'V1','followers_count')
tmp=merge(tmp,tmp2)
tmp3=unique(df[,.(user_id,screen_name,account_created_at)])
df=merge(tmp,tmp3)
rm(tmp,tmp2,tmp3)

#authenticate
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

#rate limit stop function
rate_limit_stop=function(check='get_friends'){
  if(rate_limit(check)$remaining==0){ #if this is true
    print(paste('Rate Limit:',round(rate_limit(check)$remaining,2)))
    print(paste('Rate Limit Reset in:',round(rate_limit(check)$reset,2),'minutes'))
    sleep_for=round(rate_limit(check)$reset,2)+.1
    print(paste('Sleeping for',sleep_for,' minutes.'))
    Sys.sleep(60*sleep_for)
    print(paste('Rate Limit:',round(rate_limit(check)$remaining,2)))
    print(paste('Rate Limit Reset in:',round(rate_limit(check)$reset,2),'minutes'))
  }
}

#collect data function
retrieve_get_friends=function(data){
  datalist=list()
  for(i in 1:nrow(data)){
    #rate limit check
    rate_limit_stop(check='get_friends')
    #
    user=data$screen_name[i] #set the username
    print(paste(user,',page 1.', i,'out of', nrow(data)))
    #create list for the user
    tmplist=list()
    #collect the first page
    tmplist[[1]]=get_friends(user)
    if(length(tmplist[[1]])!=0){ #if data is available for the user
      #get the next cursor
      nc=as.integer64(next_cursor(tmplist[[1]]))
      #collect the next page, if exists.
      number=ceiling(data$friends_count[i]/5000)+10 #get loop number based on # followers available on df, add 10 to be safe
      for(j in 2:number){
        if(nc==0){next}else{
          #rate limit check
          rate_limit_stop(check='get_friends')
          #get data for the subsequent pages
          print(paste(user,'page',j))
          tmplist[[j]]=get_friends(user,page=nc)
          nc=as.integer64(next_cursor(tmplist[[j]]))
        }
      }
    }
    tmp=rbindlist(tmplist) #bind the data for user i
    datalist[[i]]=tmp #add to the full datalist
    print(paste('Friends list for',user,'is collected.', i,'out of', nrow(data)))
  }
  
  
  result=rbindlist(datalist)
  result
}

#collect data 
datalist=list()
#for(i in 1:nrow(df)){
for(i in 5866:nrow(df)){  
  #rate limit check
  rate_limit_stop()
  #
  user=df$screen_name[i] #set the username
  print(paste(user,',page 1.', i,'out of', nrow(df),'. Appname:',key$appname[1]))
  #create list for the user
  tmplist=list()
  #collect the first page
  tmplist[[1]]=get_friends(user)
  if(length(tmplist[[1]])!=0){ #if data is available for the user
    #get the next cursor
    nc=as.integer64(next_cursor(tmplist[[1]]))
    #collect the next page, if exists.
    number=ceiling(df$friends_count[i]/5000)+10 #get loop number based on # followers available on df, add 10 to be safe
    for(j in 2:number){
      if(nc==0){next}else{
        #rate limit check
        rate_limit_stop()
        #get data for the subsequent pages
        print(paste(user,'page',j))
        tmplist[[j]]=get_friends(user,page=nc)
        nc=as.integer64(next_cursor(tmplist[[j]]))
      }
    }
  }
  tmp=rbindlist(tmplist) #bind the data for user i
  datalist[[i]]=tmp #add to the full datalist
  datalist[[i]]$collected_on=Sys.time()
  print(paste('Friends list for',user,'is collected.', i,'out of', nrow(df),'. Appname:',key$appname[1]))
}


result=rbindlist(datalist,fill=TRUE)

filename=file.path(loc_export_sub,paste0("user-friends-",date,".csv"))
fwrite(result,filename)



