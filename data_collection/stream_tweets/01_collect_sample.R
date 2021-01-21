#-----------------------------
#
# Define Query
#
# Set the query terms for searching new tweets based on fequency of terns in the previous datasets
#
#-----------------------------


computers=c('home_desktop','carbonate')
apps=c('meltemsapp','meltemodabas001','meltemodabas002','meltemodabas003')
co=1 #which computer?
app=2 #which app?

#language
#"" for default
#"Turkish" for Turkish on Windows
#"tr" for Turkish on Linux
lang="Turkish" 
Sys.setlocale(category = "LC_ALL", locale = lang)

#data locations
load(paste0(computers[co],'_data_folder_structure.RData'))
#define 4 new folders
loc_query=file.path(loc_search,'query')
loc_tpilot=file.path(loc_search,'tpilot')
loc_qpilot=file.path(loc_search,'qpilot')
loc_tweet=file.path(loc_search,'tweet')

#load libraries
library(tidyverse)
library(rtweet)
library(data.table)
library(bit64)

#load keys
key = read_csv(file.path(loc_key,"all_app_keys.csv"))
key = key %>%
  filter(appname==apps[app])
#define twitter app keys
twitter_token <- create_token(
  app = key$appname[1],
  consumer_key = key$value[1],
  consumer_secret = key$value[2],
  access_token = key$value[3],
  access_secret = key$value[4])

#load functions
load(file.path(loc_func,'functions.RData'))
#Define %notin% function
`%notin%`=Negate(`%in%`)
#-------------------------------------------------

#gather old hashtags

#list files in the query folder
files=list.files(loc_query)
tmp=list()
for(i in files){
  tmp[[i]]=read_csv(file.path(loc_query,i))
}
hashtags=rbindlist(tmp)
rm(tmp)

oldhashtags=hashtags$term
#correct for mistakes if any (# and whitespace)
oldhashtags=gsub("#","",oldhashtags)              #remove any hashtag signs
oldhashtags=gsub("[[:space:]]","",oldhashtags)    #remove whitespace
oldhashtags = unique(oldhashtags)                 #get unique hashtags


#add versions of these hashtags
tmp=oldhashtags
if(lang=='Turkish'|lang=='tr'){
  #if language IS Turkish
  tmp = c(tmp, tolower(tmp),tureng(tmp),turtwit(tmp),
          tolower(tureng(tmp)),tolower(turtwit(tmp)),
          tureng(turtwit(tmp)),tolower(tureng(turtwit(tmp))))
}else{
  #if language is NOT Turkish
  tmp = c(tmp, tolower(tmp))
}
oldhashtags=unique(tmp)
rm(tmp)

#gather hashtags from newly collected tweet data
searches=dir(file.path(loc_tweet))
import_loc=file.path(loc_tweet,max(searches))
subfolder=dir(import_loc)

#get frequency table of the hashtags from that data
dflist=list()
a=1
for(sf in subfolder){
  files = list.files(file.path(import_loc,sf))
  for (i in 1:length(files)){
    tmp=read_csv(file.path(import_loc,sf,files[i]),col_types=cols(status_id=col_character(), hashtags=col_character()))
    dflist[[a]]=tmp %>%
      select(status_id,hashtags)
    a=a+1
  }
}
tmp=rbindlist(dflist)
tmp=unique(tmp)
tmp=unlist(strsplit(tmp$hashtags, ","))
tmp=gsub("[[:space:]]","",tmp)    #remove whitespace
tmp=tibble(hashtags=unlist(strsplit(tmp, ","))) %>% 
  group_by(hashtags)%>%
  count()%>%
  arrange(desc(n))%>%
  filter(hashtags %notin% oldhashtags)



df=rbindlist(dflist)
df_table=df[,sum(n),by=hashtags]
df_table=df_table[hashtags %notin% oldhashtags]
setorder(df_table,V1)
newhashtags=tail(df_table,50)
removal=c('memur','unutma','Unutma','enflasyon','muazZAMsoyuluyoruz','izmir',
          'HepimizFarkındayız','ahaber','FethiSekin')
newhashtags=newhashtags[,keep:=1]
newhashtags=newhashtags[hashtags %in% removal,keep:=0]

#save
datetime=create_datetime()
filename=gsub('query','tpilot',loadfile)
write_csv(tweets,file.path(loc_tpilot,filename))



