#TRThaber-news-links-search

#Note: uses java script. To be edited.

newspaper='TRThaber'
start_on='2020-12-31'

#0. prep
bucket_url="https://www.trthaber.com/"
url='https://www.trthaber.com/arama.html?q=boğaziçi+üniversitesi'

#set language
lang="Turkish" 
Sys.setlocale(category = "LC_ALL", locale = lang)

#load libraries
library(data.table)
library(tidyverse)

#set newspaper location
#for links
loc_links='E://data/protest202101/data/news_articles/links'
if(dir.exists(loc_links)==FALSE){dir.create(loc_links)}
if(dir.exists(file.path(loc_links,newspaper))==FALSE){dir.create(file.path(loc_links,newspaper))}
#for news content (to be used later)
loc_content='E://data/protest202101/data/news_articles/content'
if(dir.exists(loc_content)==FALSE){dir.create(loc_content)}
if(dir.exists(file.path(loc_content,newspaper))==FALSE){dir.create(file.path(loc_content,newspaper))}

#CHECK WHETHER THERE ARE ANY FOLDERS SAVED. IF SO, CHOOSE THE LATEST DATE-1
#AS THE NEWS ARTICLE LIMIT
collected=dir(file.path(loc_content,newspaper))
if(length(collected)>0){
  trim_date=as.character(as.Date(collected[length(collected)])-1)
}else{
  trim_date=start_on
}

#set export location and folder name
date=Sys.time()
date=as.character(as.Date(date))
loc_export=file.path(loc_links,newspaper,date)
if(dir.exists(loc_export)==FALSE){dir.create(loc_export)}


dir(file.path(loc_links,newspaper))


#1. create function (also loads required packages)
#write function
scrape_TRThaber=function(link){
  
  #install.packages("rvest")
  require(rvest)
  require(V8)
  
  #read the page
  page=read_html(link)
  
  
  #get the titles
  title= page %>%
    html_nodes(".gs-title")%>% 
    html_text()
  ct=v8()
  read_html(ct$eval(title))%>% 
    html_text()
  
  if(length(title)==0){stop('page empty.')}
  
  #get the links
  link=  page %>%
    html_nodes(".gs-title")%>% 
    html_attr('href')
  link=paste0(bucket_url,link)
  
  #get the short text
  text_short= page %>%
    html_nodes(".news__titles") %>%
    html_text()
  
  #get the date
  date= page %>%
    html_nodes(".news__date") %>% 
    html_text()
  
  date = format(as.POSIXct(strptime(date, "%d.%m.%Y")),'%Y-%m-%d')
  
  #create df
  result=tibble(title=title,link=link,text_short=text_short,date=date)
  
  result
  
}

#2. collect data
datalist=list()
for ( i in 1:15){
  print(i)
  flush.console()
  #set the page number
  page_url=paste0(url,'?page=',i)
  datalist[[i]] = scrape_milliyet(page_url)
}

df=rbindlist(datalist)
#trim the news that are before the trim date
if(is.null(trim_date)==FALSE){
  df=df[date>trim_date]
}


#3. save data
write_csv(df,file.path(loc_export,paste0(newspaper,'_links_collected_on_',date,'.csv')))
