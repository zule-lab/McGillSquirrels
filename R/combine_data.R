combine_data <- function(parks, canopy, impervious, roads, roads_shp, building_dens, building_height){
  
  parks_t <- st_transform(parks, 3347)
  
  # join all datasets together and clean column names for readability
  parks_full <- parks_t %>% 
    mutate(park_area_m2 = drop_units(st_area(geometry))) %>% 
    left_join(., st_set_geometry(canopy, NULL)) %>% 
    left_join(., st_set_geometry(impervious, NULL)) %>% 
    left_join(., roads) %>% 
    left_join(., st_set_geometry(building_dens, NULL)) %>% 
    left_join(., building_height) %>% 
    left_join(., st_set_geometry(roads_shp, NULL)) %>%
    distinct() %>% 
    rename(min_road_dist_m = min_dist_m,
           min_road_dist_km = min_dist_km,
           no_buildings = centroids,
           building_area_km2 = build_area,
           no_buildings_perkm = centroid_den,
           building_area_perkm = area_den,
           mean_bldhgt_m = mean_bldhgt) %>% 
    mutate(building_area_km2 = drop_units(building_area_km2)) %>% 
    select(-park_buff_area)
  
  write_sf(parks_full, 'output/full-dataset.gpkg')
  write.csv(st_set_geometry(parks_full, NULL), 'output/full-dataset.csv')

  return(parks_full)
  
}