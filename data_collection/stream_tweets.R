#stream tweets

#after running set_token.R

#load libraries
library(rtweet)
library(tidyverse)
library("rjson")
library(data.table)
library(readr)

loc <- '/N/project/redditmusic/c19/c19_poetics'

## Stream keywords used to filter tweets
query <- "#coronavirus,#corona,#viruscorona,#koronavirus,#korona,#viruskorona,#covid19,#covid-19,#covid_19,#covid2019,#sarscov2,#sars-cov-2,#sars_cov_2"
seconds <- 600
streamtime <- seconds

a <- 28
b <- 13
for (i in 1:100){                              #create new directory for each hour(b) in each day(a)
  print("let's get started!")
  flush.console()
  datetime=as.character(Sys.time())
  datetime=gsub('\\s','',datetime)
  datetime=gsub('-','',datetime)
  datetime=gsub(':','',datetime)
  date=substr(datetime,1,8)
  try(
    dir.create(path = file.path(loc,date))
  )
  ## Filename to save json data (backup)
  json_path = file.path(loc,date,paste0("json_",datetime))
  dir.create(path = json_path)
  setwd(json_path)
  getwd()
  out_csv <- file.path(loc,date,paste0("c19tweet_",datetime,".csv"))
  ## Stream covid tweets
  print('streaming tweets')
  
  tweets <- NULL                          #make at most 5 attempts to gather the first 30 sec tweet data
  attempt <- 1
  while( is.null(tweets) && attempt <= 5 ) {
    attempt <- attempt + 1
    try(
      tweets <- stream_tweets(q = query, timeout = streamtime)
    )
  } 
  print(paste("Datetime:",datetime,"nrow:",nrow(tweets)))
  for(k in 2:120){ 
    ## Continue streaming covid tweets
    print('continues streaming tweets...')
    print(Sys.time())
    tryCatch({
      temp <- stream_tweets(q = query, timeout = streamtime)
      print(paste("Day",a,"Hour",b,"file",k,"nrow binded:",nrow(tweets)))
      tweets <- bind_rows(tweets,temp)
      print(paste("Day",a,"Hour",b,"file",k,"nrow binded:",nrow(tweets)))
      rm(temp)
    }, error=function(e){cat("ERROR :",conditionMessage(e), "\n")})
  }
  fwrite(tweets, out_csv)
  rm(tweets)
  gc()
  if (b==24){
    b <- 1
    a <- a+1
  }else{
    b <- b+1
  }
  
}

