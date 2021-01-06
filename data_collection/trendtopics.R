#---------------------
# Data collection
#
#
#---------------------

#load packages
library(rtweet)
library(tidyverse)
#load data locs
load('00_repo_folder_structure.RData')
# load keys
key = read_csv(file.path(loc_key,"meltem_key.csv"))
#define twitter app keys
twitter_token <- create_token(
  app = 'meltemsapp',
  consumer_key = key$value[1],
  consumer_secret = key$value[2],
  access_token = key$value[3],
  access_secret = key$value[4])

datetime=as.character(Sys.time())
datetime=gsub('\\s','',datetime)
datetime=gsub('-','',datetime)
datetime=gsub(':','',datetime)

tt=get_trends('istanbul')

filename=paste0('tt_istanbul',datetime,'.csv')
loc_export=file.path(loc_data,'trending_topic')

write_csv(tt,file.path(loc_export,filename))
