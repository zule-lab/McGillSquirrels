combine_canopy <- function(can_cov_parks, parks){
  
  # rename columns in dataframes so that all canopy columns match
  # drop rows where there is no value for canopy cover 
  cols <- lapply(can_cov_parks, function(x){
  
  names(x)[1] <- 'can_cov_per'
  
  x_na <- x %>% 
    drop_na(can_cov_per)
  })
  
  # bind all dataframes together 
  full_can <- do.call("rbind", cols)
  
  # spatial join back together with park dataframe
  can <- st_join(full_can, st_transform(parks, st_crs(full_can)))
  
  can_filt <- can %>% 
    filter(can_cov_per > 0) %>% 
    distinct() %>% 
    # remove tiny portion of Transterrebonne that fell in different region
    filter(Site.Id != 'Transterrebonne' | can_cov_per < 0.60) %>%
    # remove sites in Kanahawka because not truly included in canopy cover dataset
    filter(Site.Id != 'Tekakwitha' & Site.Id != 'Fitness Park') 
  
}
