### define repository folder structure

#define bucket
bucket <- '/N/project/c19/protest202101'
if(dir.exists(bucket)==FALSE){dir.create(bucket)} #create bucket loc if does not exist
#open data location
loc_data = file.path(bucket,'data')
if(dir.exists(loc_data)==FALSE){dir.create(loc_data)} #create data_loc if does not exist
save.image('00_repository_folder_structure.RData')
