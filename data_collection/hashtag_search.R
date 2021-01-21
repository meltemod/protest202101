#------------------------------
#   Tweet collect by hashtag, back in time (~5-7 days)
#
#
#--------------------------------

Sys.setlocale(category = "LC_ALL", locale = "Turkish") #use this while working with Turkish tweets While working on Windows

#setwd
wd="E:/code/github/protest202101"
#load data locs
load(file.path(wd,'00_repo_folder_structure.RData'))


#load packages
library(rtweet)
library(tidyverse)
library(data.table)
#load your own functions
load(file.path(loc_func,'functions.RData'))

# load keys
key = read_csv(file.path(loc_key,"meltem_key.csv"))
#define twitter app keys
twitter_token <- create_token(
  app = 'meltemsapp',
  consumer_key = key$value[1],
  consumer_secret = key$value[2],
  access_token = key$value[3],
  access_secret = key$value[4])

#-------------------------------------------
#first, set the query term
query =c('AkademiBiatEtmez',
         "BenimRektörümDeğil",
         "BizimRektörümüzDeğil",
         "AnnemAnladıSenAnlamadın",
         "ArkadaslarımızNerede",
         "AynıGemideDeğiliz",
         "Boğaziçi",
         "BoğaziçiBizim",
         "BoğaziçiDirenişi",
         "BoğaziçiDireniyor",
         "BoğazİçiDireniyor",
         "BoğaziçiRektörSeçimiİstiyor",
         "BoğaziçiSeçimİstiyor",
         "BoğaziçiSusma",
         "BoğaziçiÜniversitesi",
         "BoğaziçiYalnızDeğildir",
         "BOUN",
         "ÇıplakAramayaSessizKalma",
         "DirenBoğaziçi",
         "GözaltındaCinselŞiddetVar",
         "İntihalciRektörİstemiyoruz",
         "İstenmiyorsunBulu",
         "KabulEtmiyoruzVazgeçmiyoruz",
         "KayyumaGeçitYok",
         "KayyumRektöreHayır",
         "KayyumRektörİstemiyoruz",
         "MelihBuluBoğaziçineRektörOlamaz",
         "ÖgrencilerimizDerhalSerbestBırakılsın",
         "ÖgrencilerDerhalSerbestBırakılsın",
         "ÖğrencimeDokunma",
         "PolisimeDokunma",
         "PolisiminYanımdayım",
         "PolisiminYanındayız",
         "ÜniversitelerBizimdir",
         "WeDoNotAcceptWeDoNotGiveUp",
         "YaHepBeraberYaHiçbirimiz",
         "BOĞAZİÇİ",
         "Boğaziçi",
         "BoğazİçiDireniyor",
         "BoğaziçiRektörSeçimiİstiyor",
         "BoğazİçiSeçimİstiyor",
         "BoğaziçiÜniversitesi",
         "BogaziciUniversity",
         "DirenBoğazİçi",
         "DirenBoğaziçi",
         "GözaltındaCinselŞiddetVar",
         "Kelepçe",
         "KabulEtmiyoruzVazgeçmiyoruz",
         "KayyumaGeçitYok",
         "KayyumRektörİstemiyoruz",
         "MelihBuluBoğaziçineRektörOlamaz",
         "MelihBuluİstifa",
         "MelihBuluKapıKulu",
         "ODTÜBoğaziçininYanında",
         "ÖğrencimeDokunma",
         "PolisiminYanındayım",
         "ÜniversitelereKelepçeVuramazsınız",
         "ÜniversiteyeKELEPÇE",
         "ÜniversiteyeKelepçe",
         "YaHepBeraberYaHiçBirimiz")
query=gsub("#","",query)
query=gsub("[[:space:]]","",query)
print(query)

#get upper/lower case and non-turkish letter versions of the query
query = c(query, tolower(query),tureng(query),turtwit(query),
          tolower(tureng(query)),tolower(turtwit(query)),
          tureng(turtwit(query)),tolower(tureng(turtwit(query))))
query = unique(query)
query = paste0('#',query)
query2 = paste(query,collapse = ', ')


#create datetime item for data saving purposes
datetime=create_datetime()


#set file save location
loc_export = file.path(loc_search,paste0('search_datetime_',datetime))
if(dir.exists(loc_export)==F){dir.create(loc_export)}

#write query file
write.table(query2, file = file.path(loc_export,"query.txt"), sep = ",")


#do search and write search data tables
n_search <- 18000
rt <- FALSE #do not include retweets in our search
maxid <- NULL #for the first round, set maxid to null, which will let us collect the newest tweets.
round_total <-100

parameters = data.frame(parameter=c('n_search',
                                    'rt',
                                    'maxid',
                                    'round_total'),
                        value= c(n_search,
                                 rt,
                                 maxid,
                                 round_total))
write_csv(parameters, file = file.path(loc_export,"parameters.csv"), sep = ",")

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


