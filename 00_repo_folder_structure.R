### define repository folder structure

#define bucket
bucket = 'E:\\data\\protest202101'
#if on carbonate
#bucket <- '/N/project/c19/protest202101'
#open data location
loc_data = file.path(bucket,'data')
if(dir.exists(loc_data)==FALSE){dir.create(loc)} #create loc_data if does not exist
#open workflow location
loc_wf = file.path(bucket,'workflow')
if(dir.exists(loc_wf)==FALSE){dir.create(loc_wf)} #create loc_wf if does not exist
save.image('00_repo_folder_structure.RData')
#open key location
loc_key = file.path(bucket,'key')
if(dir.exists(loc_key)==FALSE){dir.create(loc_key)} #create loc_key if does not exist
#open log location (task schedluer logs will be saved here)
loc_log = file.path(bucket,'log')
if(dir.exists(loc_log)==FALSE){dir.create(loc_log)} #create loc_log if does not exist
save.image('00_repo_folder_structure.RData')


