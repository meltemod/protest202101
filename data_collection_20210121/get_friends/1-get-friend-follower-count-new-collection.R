computers=c('home_desktop','carbonate')
co=1 #which computer?
buckets=c("E:\\data\\protest202101","/N/project/c19/protest202101")
bucket=buckets[co]

loc_import= 'data/search_tweets_20210121/merged'
loc_export= 'data/search_tweets_20210121/get_friends'

if(dir.exists(file.path(bucket,loc_export))==FALSE){dir.create(file.path(bucket,loc_export))}

#list tweet files
files=list.files(file.path(bucket,loc_import))
#get the file dates
file_dates=str_extract(files,'[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]')
file_dates=file_dates[!is.na(file_dates)]
#check if they are already used to collect user names
cutoff= file_dates %in% list.files(file.path(bucket,loc_export))
cutoff = max(file_dates[cutoff])
if(!is.na(cutoff)){
  file_dates = file_dates[which(file_dates>cutoff)]
}

files=paste0(file_dates,'-merged.csv')

#open files, remove duplicates
datalist=list()
a=1
for(f in files){
  datalist[[a]]=fread(file.path(bucket,loc_import,f),
                      select=c("user_id","screen_name","hashtags","followers_count","friends_count","account_created_at"))
  a=a+1
}
df=rbindlist(datalist)
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

filename=paste0('friend-count-list-',max(file_dates),'.csv')
fwrite(tmp,file.path(bucket,loc_export,filename))
