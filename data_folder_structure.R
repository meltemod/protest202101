### define repository folder structure
rm(list=ls())

#which computer?
co=1

computers=c('home_desktop','carbonate')
buckets=c('E:\\data\\protest202101',
          '/N/project/c19/protest202101')
working_directories=c("E:/code/github/protest202101",
                      "/geode2/home/u060/modabas/Carbonate/Projects/protest202101")
filenames=paste0(computers,'_data_folder_structure.RData')

bucket=buckets[co]
wd=working_directories[co]
filename=filenames[co]


loc_data = file.path(bucket,'data')
if(dir.exists(loc_data)==FALSE){dir.create(loc_data)} #create loc_data if does not exist
#open search_tweets data location
loc_search=file.path(loc_data,'search_tweets')
if(dir.exists(loc_search)==FALSE){dir.create(loc_search)} #create loc_search if does not exist
#open trending topics data location
loc_tt=file.path(loc_data,'trending_topic')
if(dir.exists(loc_tt)==FALSE){dir.create(loc_tt)} #create loc_tt if does not exist
#open workflow location
loc_wf = file.path(bucket,'workflow')
if(dir.exists(loc_wf)==FALSE){dir.create(loc_wf)} #create loc_wf if does not exist
save.image('00_repo_folder_structure.RData')
#open key location
loc_key = file.path(bucket,'key')
if(dir.exists(loc_key)==FALSE){dir.create(loc_key)} #create loc_key if does not exist
#open log location (task scheduler logs will be saved here)
loc_log = file.path(bucket,'log')
if(dir.exists(loc_log)==FALSE){dir.create(loc_log)} #create loc_log if does not exist
#open function location (grab your functions from this location)
loc_func = file.path(wd,'functions')
if(dir.exists(loc_func)==FALSE){dir.create(loc_func)} #create loc_func if does not exist

save.image(file.path(wd,filename))



