#-------------------------
#
# set hashtag search terms
#
# I look at the frequency of hashtags collected earlier and then select 10 terms.
#
#------------------------



# 0. prep work

# Load libraries
library(tidyverse)

#set folder locations
computers=c('home_desktop','carbonate')
co=1 #which computer?
buckets=c("E:\\data\\protest202101","/N/project/c19/protest202101")
bucket=buckets[co]
export_loc='data/search_tweets_20210121_de'
function_loc='functions'

if(dir.exists(file.path(bucket,export_loc))==FALSE){
  dir.create(file.path(bucket,export_loc))
}

#load functions
load(file.path(getwd(),function_loc,'functions.RData'))


#set language
#"" for default
#"Turkish" for Turkish on Windows
#"tr" for Turkish on Linux
lang="Turkish" 
Sys.setlocale(category = "LC_ALL", locale = lang)

# 1. list all the words you want to include with capilatized first letters and Turkish characters

query= c('ŞeymayaŞahidiz',       
         'BeyzayıSerbestBırakın',    
         'BeyzaSerbestBırakılsın',   
         'AnılveSilanaÖzgürlük',    
         'SıraDoğuveSeloda')
         
query_date=c(
  rep('2020-02-08',5)
)

#write hahstag list
hashtag=tibble(hashtag=query,added_to_query=query_date)
write_csv(hashtag,file.path(bucket,export_loc,'hashtags.csv'))

#get upper/lower case and non-turkish letter versions of the query
query = c(query, tolower(query),tureng(query),turtwit(query),
          tolower(tureng(query)),tolower(turtwit(query)),
          tureng(turtwit(query)),tolower(tureng(turtwit(query))))
query = unique(query)
query = paste0('#',query)
query=as_tibble(query)
write_csv(query,file.path(bucket,export_loc,'query.csv'))


