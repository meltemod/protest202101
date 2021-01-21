#-----------------------------
#
# Select the next round of query terms based on pilot data
#
#
#-----------------------------

#language
#"" for default
#"Turkish" for Turkish on Windows
#"tr" for Turkish on Linux
lang="Turkish" 
Sys.setlocale(category = "LC_ALL", locale = lang)
#define query
query=c("#KayyumRektörİstemiyoruz","#KabulEtmiyoruzVazgeçmiyoruz")

computers=c('home_desktop','carbonate')
co=1 #which computer?

#data locations
load(paste0(computers[co],'_data_folder_structure.RData'))
#define 4 new folders
loc_query=file.path(loc_search,'query')
loc_tpilot=file.path(loc_search,'tpilot')
loc_qpilot=file.path(loc_search,'qpilot')
loc_tweet=file.path(loc_search,'tweet')

#load libraries
library(tidyverse)

#open the most recent pilot file
files=list.files(loc_pilot)
loadfile=max(file)
tweets = read_csv(file.path(loc_pilot,loadfile))

#retrieve a list of all hashtags
hashtags= tibble(hashtags=unlist(tweets$hashtags))
hashtags = hashtags %>%
  count(hashtags)

#save data

filename = gsub('tpilot','qpilot',loadfile)
write_csv(tweets,file.path(loc_qpilot,filename))




