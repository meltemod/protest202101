library(tidyverse)

Sys.setlocale(category = "LC_ALL", locale = 'Turkish')

#enter terms here
terms =c()


df=tibble(term=terms)
datetime=create_datetime()
filename=paste0('query_',datetime,'.csv')
write_csv(df,
          file.path(loc_query,filename))


