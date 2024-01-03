get_roads_shp <- function(parks){
  
  roads_shp <- download_shp('https://donnees.montreal.ca/dataset/0acbc6c8-bbfc-4aae-a0fa-ec74ba0686c6/resource/102dd6af-836d-443e-9bee-bfdd2f525fb8/download/voi_voirie_s_v22_shp.zip', 'input/roads_shp.zip')
  
  # select roads, alleys, and sidewalks
  
  asphalte <- roads_shp %>% 
    filter(MATERIAUCH == "Asphalte" | MATERIAUCH == "Asphalte et béton" | MATERIAUCH == "Asphalte et pavé" |
             MATERIAUCH == "Béton" | MATERIAUCH == "Béton et pavé" | MATERIAUCH == "Pavé" | 
             TYPEINTERS == "Intersection de rues") %>%
    select(geometry)
    
  
  # create 100 m buffer surrounding parks 
  buff <- st_buffer(st_transform(parks, st_crs(asphalte)), 100) 
  
  # intersect impervious surfaces with buffer
  imp_buff <- st_intersection(asphalte, buff) %>% 
    group_by(Site.Id, Date) %>% 
    summarize(geometry = st_union(geometry)) %>% 
    mutate(road_area_m2 = st_area(geometry),
           road_area_km2 = set_units(road_area_m2, km^2)) %>% 
    mutate(road_area_m2 = drop_units(road_area_m2),
           road_area_km2 = drop_units(road_area_km2))
  
}