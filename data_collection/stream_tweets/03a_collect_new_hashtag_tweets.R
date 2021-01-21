#-----------------
#
#   Gather Tweets
#
#------------------

X=4 #n groups to divide it into
n=1 #the group you will collect now
number=paste0('n',sprintf('%02d',n))

#language
#"" for default
#"Turkish" for Turkish on Windows
#"tr" for Turkish on Linux
lang="Turkish" 
Sys.setlocale(category = "LC_ALL", locale = lang)

computers=c('home_desktop','carbonate')
apps=c('meltemsapp','meltemodabas001','meltemodabas002','meltemodabas003')
co=1 #which computer?
app=2 #which app?

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

#load keys
key = read_csv(file.path(loc_key,"all_app_keys.csv"))
key = key %>%
  filter(appname=apps[app])
#load functions
load(file.path(loc_func,'functions.RData'))
#define %notin% function
`%notin%` = Negate(`%in%`)
#------------------------------------------

#define twitter app keys
twitter_token <- create_token(
  app = key$appname[1],
  consumer_key = key$value[1],
  consumer_secret = key$value[2],
  access_token = key$value[3],
  access_secret = key$value[4])

#list files in the query folder
files=list.files(loc_query)
#select the newest one
newfile=max(files)

#get new list of hashtags
newhashtags=read.csv(file.path(loc_query,newfile))
newlist=gsub('\\?','İ',hashtags$term)
#correct for mistakes if any (# and whitespace)
newlist=gsub("#","",newlist)              #remove any hashtag signs
newlist=gsub("[[:space:]]","",newlist)    #remove whitespace
newlist = unique(newlist)                 #get unique hashtags
newlist = paste0('#',newlist)             #add one hashtags at the beginning of the search

#get old list of hashtags (if any)
if(files!=newfile){
  oldfiles=files %notin% newfile
  tmp=list()
  for(i in 1:length(oldfiles)){
    tmp[[i]]=read.csv(file.path(loc_query,oldfiles[i]))
  }
  oldhashtags=rbindlist(tmp)
  rm(tmp)
  oldlist=gsub('\\?','İ',hashtags$term)
  #correct for mistakes if any (# and whitespace)
  oldlist=gsub("#","",oldlist)              #remove any hashtag signs
  oldlist=gsub("[[:space:]]","",oldlist)    #remove whitespace
  oldlist = unique(oldlist)                 #get unique hashtags
  oldlist = paste0('#',oldlist)             #add one hashtags at the beginning of the search
}
#define query based on only new hashtags
newlist = newlist %notin% oldlist

#divide query into X groups. 
querylist=list()
Y=ceiling(tmp/X) #n hashtags to include in each group
a=1
for (j in 1:X){
  if (j!=X){
    querylist[[j]]=tmp[a:(a+Y)]
    a=a+Y
  }else{
    querylist[[j]]=tmp[a,length(tmp)]
  }
}

#query the group you selected 
query=querylist[n]

#create folder for the search
search_folder_name=gsub('search_datetime_','',newfile)
loc_search_folder = file.path(loc_tweet,search_folder_name)
if(dir.exists(loc_search_folder)==FALSE){dir.create(loc_search_folder)}

#create group folder (ex.n01)
subfolder_name = number
loc_subfolder = file.path(loc_search_folder,search_folder_name)
if(dir.exists(loc_subfolder)==FALSE){dir.create(loc_subfolder)}

#set this folder as the export location
loc_export = loc_subfolder

#gather tweets and save

#select query words, make sure they do not exceed 500 characters

a=1 #start with the first term in the query (update along)
a0=1 #start with the first term in the query 
for(count in 1:30){
  q=c() #create a query list
  for(i in 1:100){
    if(a>length(query)){break} #break the loop when all terms are searched.
    tmp = paste(q,collapse = " OR ")
    if(nchar(tmp)>400){break} #break the loop right before the selected query 
    q = c(q,query[a])
    a = a+1
  }
  q = paste(q,collapse = " OR ")
  print(q)
  flush.console()
  loc_export_sub = file.path(loc_export,sprintf('%03d',a))
  if(dir.exists(loc_export_sub)==F){dir.create(loc_export_sub)}
  files=list.files(loc_export_sub)
  if(length(files)!=0){
    numbers= gsub("\\D", "", files)
    maxid=min(numbers)
  }
  print(paste('starting to collect data for',a0,'-',a,'out of',length(query)))
  flush.console()
  meltem_search_tweets(q=q,rt=rt,
                       n_search=n_search,maxid=maxid,
                       round_total=round_total,
                       loc_export=loc_export_sub)
  print(paste('collection for',a0,'-',a,'out of',length(query),'is complete.'))
  flush.console()
  a0=a
}


