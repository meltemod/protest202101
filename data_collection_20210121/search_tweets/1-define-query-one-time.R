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
export_loc='data/search_tweets_20210121'
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

query= c('KayyumRektörİstemiyoruz',        #most popular
         'BoğaziçiRektörSeçimiİstiyor',    #most popular
         'KabulEtmiyoruzVazgeçmiyoruz',    #most popular
         'WeDoNotAcceptWeDoNotGiveUp',     #most popular in English
         'İstenmiyorsunBulu',              #most popular including rector's name
         'BoğaziçiDireniyor',              #most popular about resistance/protest
         'DirenBoğaziçi',                  #most popular about resistance/protest
         'MelihBulu',                      #formal name of rector for general opinion gathering
         'BoğaziçiÜniversitesi',           #formal name of the university for general opinion gathering
         'BogaziciUniversity',             #formal name of the university for general opinion gathering, in English
         'ÜniversitenİçinSözSende',        #added on 24 Jan, people share their demands under this hashtag.   
         'KabulEdemem',                    #added on 26 Jan, people share their answer to "what the don't accept" under this hashtag.
         "BoğaziçiSusmayacak",             #added on 29 Jan, people share their concerns as a response to detentions
         "BoğaziçiTeslimolmayacak",        #added on 29 Jan, people share their concerns as a response to detentions
         "BundanSonrasıBizde",             #added on 31 Jan, people share their concerns as a response to the arrest of two LGBTQI+ students
         "BoğaziçiAblukada",              #added on 1 Feb, hashtag refers to police presence around the campus
         "AşağıBakmayacağız",             #added on 1 Feb, hashtag refers to police presence around the campus
         "Arkadaşlarımızıİstiyoruz",      #added on 3 Feb, requestıng the release of detained friends
         "Öğrencilerimiziİstiyoruz",      #added on 3 Feb, requestıng the release of detained students
         "iStand4Bogazici",               #added on 12 Feb, graduate student solidarity (in eng)
         "BoğaziçiBenim")                 #added on 12 Feb, graduate student solidarity (in tr)
         
query_date=c(
  rep('2020-01-21',10),'2020-01-24','2020-01-26s',
  '2020-01-29','2020-01-29','2020-01-31','2020-02-01','2020-02-01','2020-02-03','2020-02-03',
  '2020-02-12','2020-02-12'
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


