#-------------------------
#
# identify people who most frequently tweet using the query hashtags,
# (one hahstag tweet per day)
# 
#
#------------------------

computers=c('home_desktop','carbonate')
co=1 #which computer?
buckets=c("E:\\data\\protest202101","/N/project/c19/protest202101")
bucket=buckets[co]

loc_import= 'data/search_tweets_20210121/merged'
loc_export= 'data/search_tweets_20210121/get_timelines'

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
  file_dates = file_dates[which(file_dates)>cutoff]
}

files=paste0(file_dates,'-merged.csv')

#open files, remove duplicates
datalist=list()
a=1
for(f in files){
  datalist[[a]]=fread(file.path(bucket,loc_import,f))
  a=a+1
}
df=rbindlist(datalist)
df=unique(df)
setorder(df,screen_name,created_at,user_id)
remove=duplicated(df[,.(user_id,status_id)])
df=df[!remove]

#get users with highest number of tweets
df_freq=df[,.N,by=screen_name]
setorder(df_freq,-N)
df_freq$min_date=min(df$created_at)
df_freq$max_date=max(df$created_at)
#set frequency cutoff(one hashtag tweet per day)
N_cutoff=ceiling(max(df$created_at)-min(df$created_at))
N_cutoff_numeric=as.numeric(str_extract(as.character(N_cutoff),'[0-9]*'))
df_freq$N_cutoff=N_cutoff
df_freq$N_cutoff_numeric=N_cutoff_numeric
df_freq=df_freq[N>=N_cutoff_numeric]

filename=paste0('namelist-',max(file_dates),'.csv')
fwrite(df_freq,file.path(bucket,loc_export,filename))
