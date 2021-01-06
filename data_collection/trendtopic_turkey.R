#---------------------
# Trending topic data collection, hourly (every 16th minute)
#
#
#---------------------

location='turkey'

#load packages
library(rtweet)
library(tidyverse)
#setwd
wd="E:/code/github/protest202101"
#load data locs
load(file.path(wd,'00_repo_folder_structure.RData'))
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

tt=get_trends(location)

filename=paste0('tt_',location,'_',datetime,'.csv')
loc_export=file.path(loc_data,'trending_topic')

write_csv(tt,file.path(loc_export,filename))

#Run hourly on windows
#SCHTASKS /CREATE /TN "tt_ist" /SC HOURLY /ST 21:52 /SD "01/05/2021" /TR "R CMD BATCH --vanilla "E:/data/protest202101/log/trendtopics.R"
#To delete
#SCHTASKS /DELETE /TN "tt_ist"
