### define repository folder structure

#define bucket
bucket <- '/N/project/c19/protest202101'
if(dir.exists(bucket)==FALSE){dir.create(bucket)} #create bucket loc if does not exist
#open data location
loc = file.path(bucket,'data')
if(dir.exists(loc_data)==FALSE){dir.create(loc)} #create data_loc if does not exist
#open workflow location
loc_wf = file.path(bucket,'workflow')
if(dir.exists(loc_wf)==FALSE){dir.create(loc_wf)} #create data_loc if does not exist
save.image('00_repo_folder_structure.RData')
