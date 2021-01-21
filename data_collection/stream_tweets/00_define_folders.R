#define folders


#which computer?
co=1

computers=c('home_desktop','carbonate')
working_directories=c("E:/code/github/protest202101",
                      "/geode2/home/u060/modabas/Carbonate/Projects/protest202101")



#data locations
load(paste0(computers[co],'_data_folder_structure.RData'))
#define 2 new folders
loc_query=file.path(loc_search,'query')
loc_tpilot=file.path(loc_search,'tpilot')
loc_qpilot=file.path(loc_search,'qpilot')
loc_tweet=file.path(loc_search,'tweet')

#create these folders if do not exist
if(dir.exists(loc_query)==FALSE){dir.create(loc_query)}  #where queries are saved
if(dir.exists(loc_tpilot)==FALSE){dir.create(loc_tpilot)}#where occasional searches are saved
if(dir.exists(loc_qpilot)==FALSE){dir.create(loc_qpilot)}#where hashtag data tables from occasional searches are saved
if(dir.exists(loc_tweet)==FALSE){dir.create(loc_tweet)} #where collected tweets are saved
