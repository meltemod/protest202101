#milliyet-news-content-collection
newspaper='milliyet'

#set language
lang="Turkish" 
Sys.setlocale(category = "LC_ALL", locale = lang)

#load libraries
library(data.table)
library(tidyverse)

#set import location
loc_import=file.path('E://data/protest202101/data/news_articles/links',newspaper)
#get folder names from import location (i.e. collection dates)
link_folders=dir(loc_import)

#set export location
loc_tmp=file.path('E://data/protest202101/data/news_articles/content')
if(dir.exists(loc_tmp)==FALSE){dir.create(loc_tmp)}
loc_export=file.path(loc_tmp,newspaper)
if(dir.exists(loc_export)==FALSE){dir.create(loc_export)}
content_folders=dir(loc_export)

#find the folders that are not in the content folders
`%notin%`=Negate(`%in%`)
folders = link_folders[link_folders %notin% content_folders]

#write function for content collection

#1.get links
get_links=function(data){
  links=data$link
}
#2. get content from links
get_content=function(link){
  #install.packages("rvest")
  require(rvest)
  
  #read the page
  page=read_html(link)
  
  #publication date
  pd= page %>%
    html_nodes(".nd-article__info-block")%>% 
    html_text()
  # dates=unlist(str_extract_all(pd,'\\d{2}\\.\\d{2}\\.\\d{4}'))
  # times=unlist(str_extract_all(pd,'\\d{2}\\:\\d{2}'))
  publication_date=str_extract(pd,'\\d{2}\\.\\d{2}\\.\\d{4} - \\d{2}\\:\\d{2}')
  publication_date=gsub(' - ',' ',publication_date)
  last_update=str_extract(pd,'Son Güncellenme: \\d{2}\\.\\d{2}\\.\\d{4} - \\d{2}\\:\\d{2}')
  last_update=gsub('Son Güncellenme: ','',last_update)
  last_update=gsub(' - ',' ',last_update)
  update=str_extract(pd,'Güncelleme: \\d{2}\\.\\d{2}\\.\\d{4} - \\d{2}\\:\\d{2}')
  update=gsub('Güncelleme: ','',update)
  update=gsub(' - ',' ',update)
  if(length(publication_date)==0){publication_date=''}
  if(length(last_update)==0){last_update=''}
  if(length(update)==0){update=''}

  #title
  title= page %>%
    html_nodes(".nd-article__title")%>% 
    html_text()
  if(length(title)==0){title=''}
  #abstract
  abstract= page %>%
    html_nodes(".nd-article__spot")%>% 
    html_text()
  if(length(abstract)==0){abstract=''}
  #image-link
  image_link = page %>%
    html_nodes(".nd-article__spot-img > img")%>% 
    html_attr('src')
  if(length(image_link)==0){image_link=''}
  #text
  text= page %>%
    html_nodes(".nd-content-column > p")%>% 
    html_text()                            #each paragraph as vector element
  text_flat <- paste(text, collapse = "\n")
  if(length(text_flat)==0){text_flat=''}
  
  
  result= data.frame(link=link,
                     publication_date=publication_date,
                     last_update=last_update,
                     update=update,
                     title=title,
                     abstract=abstract,
                     text=text_flat,
                     image_link=image_link)
  result
}


for(f in folders){
  print(paste('folder:',f,'. ',match(f,folders),'out of',length(folders),'folders.'))
  flush.console()
  #get the data from folder
  data=fread(file.path(loc_import,f,paste0(newspaper,'_links_collected_on_',f,'.csv')))
  #get the links from data
  links=get_links(data)
  #get the content from each link and rbind the results
  list_content=list()
  a=1
  for (l in links){
    if(a%%5==0){
      print(paste(a,'articles collected.'))
    }
    list_content[[a]]=get_content(l)
    a=a+1
  }
  df_content=rbindlist(list_content)
  #create folder to save data
  if(dir.exists(file.path(loc_export,f))==FALSE){dir.create(file.path(loc_export,f))}
  #save the data
  print(paste('saving data for folder ',f,'...'))
  flush.console()
  write_csv(df_content,file.path(loc_export,f,paste0(newspaper,'_content_collected_on_',f,'.csv')))
  print('done.')
  flush.console()
  
}
  
