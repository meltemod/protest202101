#milliyet-news-search
newspaper='milliyet'

#0. prep
bucket_url="https://www.milliyet.com.tr"
url='https://www.milliyet.com.tr/haberler/bogazici-universitesi'

#set language
lang="Turkish" 
Sys.setlocale(category = "LC_ALL", locale = lang)

#load libraries
library(data.table)
library(tidyverse)

#set export location
loc_news='E://data/protest202101/data/news_articles'
if(dir.exists(loc_news)==FALSE){dir.create(loc_news)}
if(dir.exists(file.path(loc_news,newspaper))==FALSE){dir.create(file.path(loc_news,newspaper))}
date=Sys.time()
date=as.character(as.Date(date))
loc_export=file.path(loc_news,newspaper,date)
if(dir.exists(loc_export)==FALSE){dir.create(loc_export)}


#1. create function (also loads required packages)
#write function
scrape_milliyet=function(link){
  
  #install.packages("rvest")
  require(rvest)
  
  #read the page
  page=read_html(link)
  
  
  #get the titles
  title= page %>%
    html_nodes(".news__item > a")%>% 
    html_attr('title')
  
  if(length(title)==0){stop('page empty.')}
  
  #get the links
  link=  page %>%
    html_nodes(".news__item > a")%>% 
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
  
  date = format(as.POSIXct(strptime(date, "%d.%m.%Y")),'%Y%m%d')
  
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
df[,date:=as.numeric(date)]
df=df[date>20201231]

#3. save data
fwrite(df,file.path(loc_export,paste0(newspaper,'_collected_on_',date,'.csv')))
