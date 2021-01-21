#functions
rm(list=ls())

#which computer? computers=c('home_desktop','carbonate')
co=1

working_directories=c("E:/code/github/protest202101",
                      "/geode2/home/u060/modabas/Carbonate/Projects/protest202101")
#setwd
wd=working_directories[co]

#if on carbonate
#bucket <- '/N/project/c19/protest202101'
loc_func = file.path(wd,'functions')

#create datetime
create_datetime = function(){
  datetime=as.character(Sys.time())
  datetime=gsub('\\s','',datetime)
  datetime=gsub('-','',datetime)
  datetime=gsub(':','',datetime)
  datetime
}


#take turkish letter variations of a word/hahstag
tureng = function(word){
  #lowercase
  word=gsub('ç','c',word)
  word=gsub('ö','o',word)
  word=gsub('ü','u',word)
  word=gsub('ı','i',word)
  word=gsub('ş','s',word)
  word=gsub('ğ','g',word)
  #uppercase
  word=gsub('Ç','C',word)
  word=gsub('Ö','O',word)
  word=gsub('Ü','U',word)
  word=gsub('İ','I',word)
  word=gsub('Ş','S',word)
  word=gsub('Ğ','G',word)
  word
}

#take Twitter variations of letters ö and ü
turtwit = function(word){
  #lowercase
  word=gsub('ö','oe',word)
  word=gsub('ü','ue',word)
  #uppercase
  word=gsub('Ö','OE',word)
  word=gsub('Ü','UE',word)
  word
}


#unlist the list columns in twitter
adjust_data= function(list){
  df_tweets <- rbindlist(list) #bind all the dataframes in the list to one dataframe. a data.table function.
  df_tweets[,hashtags:= sapply(hashtags, toString)]
  df_tweets[,symbols:= sapply(symbols, toString)]
  df_tweets[,urls_url:= sapply(urls_url, toString)]
  df_tweets[,urls_t.co:= sapply(urls_t.co, toString)]
  df_tweets[,urls_expanded_url:= sapply(urls_expanded_url, toString)]
  df_tweets[,media_url:= sapply(media_url, toString)]
  df_tweets[,media_t.co:= sapply(media_t.co, toString)]
  df_tweets[,media_expanded_url:= sapply(media_expanded_url, toString)]
  df_tweets[,media_type:= sapply(media_type, toString)]
  df_tweets[,ext_media_url:= sapply(ext_media_url, toString)]
  df_tweets[,ext_media_t.co:= sapply(ext_media_t.co, toString)]
  df_tweets[,ext_media_expanded_url:= sapply(ext_media_expanded_url, toString)]
  df_tweets[,ext_media_type:= sapply(ext_media_type, toString)]
  df_tweets[,mentions_user_id:= sapply(mentions_user_id, toString)]
  df_tweets[,mentions_screen_name:= sapply(mentions_screen_name, toString)]
  df_tweets[,geo_coords:= sapply(geo_coords, toString)]
  df_tweets[,coords_coords:= sapply(coords_coords, toString)]
  df_tweets[,bbox_coords:= sapply(bbox_coords, toString)]
  df_tweets
}

#search tweets with 15 min. sleeping + data org method.
meltem_search_tweets = function(q, # query
                                rt=FALSE, #whether include  retweets or not
                                n_search=18000, #how many tweets to search at a time
                                maxid=NULL, # default is NULL
                                round_total=100, #max. rounds of search
                                since=NULL,
                                until=NULL,
                                loc_export){ #location to save file
  #create an empty list
  tweetList <- list() 
  isit="NO"
  for(i in 1:round_total){
    print(paste("data number:",i,"out of",round_total))
    tweets <- search_tweets(q=q,
                            include_rts=rt, 
                            n=n_search,
                            max_id = maxid,
                            since=since,
                            until=until)
    tweetList[[1]] <- tweets
    df_tweets=adjust_data(list=tweetList)
    if(is.null(maxid)==FALSE){
      if(maxid==tail(tweets,1)$status_id){isit='YES'} 
    }
    #stop the loop if maxid does not update anymore, after sleeping for 2 minutes.
    if(isit=="YES"){
      print('search complete. Will close after 2 minutes of sleep time.')
      Sys.sleep(60*2)
      break}
    #reset the maxid to use it in the next round of tweet collection
    maxid <- tail(tweets,1)$status_id 
    #save data
    filename=paste0('search_tweets_',maxid,'.csv')
    fwrite(df_tweets,file.path(loc_export,filename))
    print('Data saved.')
    rm(tweets)
    #sleep for 15 minutes before collecting the next dataset
    print('sleeping for 15 minutes')
    Sys.sleep(60*15)
  }
}

save.image(file.path(loc_func,'functions.RData'))
