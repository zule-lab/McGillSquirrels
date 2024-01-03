combine_impervious <- function(imp_parks, parks){
  
  # rename columns in dataframes so that all canopy columns match
  # drop rows where there is no value for canopy cover 
  colnames <- c('imp_per', 'geometry') 
  
  cols <- lapply(imp_parks, setNames, colnames)
  
  nas <- lapply(cols, function(x){
    
    x_na <- x %>% 
      drop_na(imp_per)
  })
  
  # bind all dataframes together 
  full_imp <- do.call("rbind", nas)
  
  # spatial join back together with park dataframe
  imp <- st_join(full_imp, st_transform(parks, st_crs(full_imp)))
  
  imp_filt <- imp %>% 
    filter(imp_per > 0) %>% 
    distinct() %>%  
    # remove smaller portion of Transterrebonne that is captured by other segment
    filter(Site.Id != 'Transterrebonne' | imp_per < 0.02) %>%
    # remove sites in Kanahawka because not truly included in canopy cover dataset
    filter(Site.Id != 'Tekakwitha' & Site.Id != 'Fitness Park') 
  
}
