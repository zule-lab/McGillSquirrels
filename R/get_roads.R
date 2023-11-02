get_roads <- function(parks){
  
  roads_raw <- download_shp('https://www12.statcan.gc.ca/census-recensement/2021/geo/sip-pis/RNF-FRR/files-fichiers/lrnf000r21a_e.zip', 'input/roads.zip')
  
  # select major roads 
  # ranking system is: 
  # 1 	Trans-Canada Highway
  # 2 	National Highway System (not rank 1)
  # 3 	Major Highway (not rank 1 or 2)
  # 4 	Secondary Highway, Major Street (not rank 1, 2, or 3)
  # 5 	All other streets (not rank 1, 2, 3, or 4)
  # we will select rank 1-4 
  
  roads_maj <- roads_raw %>% 
    filter(RANK == 1 | RANK == 2 | RANK == 3 | RANK == 4) %>%
    rownames_to_column(., 'index') %>%
    select(geometry)
  
  # calculate nearest feature for each park
  nearest <- st_nearest_feature(st_transform(parks, st_crs(roads_maj)), roads_maj) 
  
  #roads_min <- inner_join(roads_maj, nearest, by = c('index' = 'value'))
  
  # calculate distance to nearest feature for each park 
  distance_mat <- st_distance(st_transform(parks, st_crs(roads_maj)), roads_maj[nearest,], by_element = T) %>% 
    as_tibble() %>% 
    mutate(min_dist_m = drop_units(value), 
           min_dist_km = min_dist_m/1000) 
  
  distance_mat$Site.Id = parks$Site.Id
  
  distance_mat <- distance_mat %>% 
    select(c(Site.Id, min_dist_m, min_dist_km))
  
}