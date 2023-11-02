get_buildings <- function(parks){
  
  parks_t <- st_transform(parks, 3347)
  
  # save for building height in GEE
  st_write(parks_t, 'output/parks.gpkg', delete_layer = T)
  
  # make 100 m buffer surrounding parks
  parks_b <- st_buffer(parks_t, 100)
  
  # download building file and clip buildings to park buffers
  builds <- building_sf('https://usbuildingdata.blob.core.windows.net/canadian-buildings-v2/Quebec.zip', 'input/Quebec_Buildings.zip', parks_b)
  
  # calculate area and centroid coordinates for buildings 
  build_m <- builds %>%
    mutate(build_area = st_area(x),
           centroid = st_centroid(x)) %>%
    st_drop_geometry()
  
  build_m$centroid <- substr(build_m$centroid,3,nchar(build_m$centroid)-1)
  build_c <- separate(data = build_m, col = centroid, into = c("lat", "long"), sep = "\\, ")
  build_d <- st_as_sf(x = build_c, coords = c("lat","long"), crs = 3347, na.fail = FALSE, remove = TRUE)
  
  # calculate area of parks 
  park_buff_area <- parks_b %>%
    mutate(park_buff_area = st_area(.))
  
  build_parks <- st_join(build_d, park_buff_area)
  
  build_parks_km <-  build_parks %>%
    mutate(build_area = set_units(build_area, km^2),
           park_buff_area = set_units(park_buff_area, km^2))
  
  
  build_parks_dens <- build_parks_km %>%
    group_by(Site.Id) %>%
    mutate(centroids=n(), 
           build_area = sum(build_area),
           centroid_den = as.numeric(centroids/park_buff_area),
           area_den = as.numeric(build_area/park_buff_area)) %>%
    distinct(Site.Id, .keep_all = TRUE) %>%
    select(Site.Id, park_buff_area, centroids, build_area, centroid_den, area_den)
  
  build_parks_filt <- build_parks_dens %>% 
    drop_na(Site.Id)
  
  
}


building_sf <- function(dl_link, dl_path, parks){
  
  download.file(dl_link, dl_path)
  
  unzip(dl_path, exdir = sans_ext(dl_path))
  
  path <- unzip(dl_path, exdir = sans_ext(dl_path))
  
  gjson <- geojson_read(file.path(path), what = "sp")
  
  geo_sf <- building_cleanup(gjson, parks)
  
  return(geo_sf)
  
}

building_cleanup <- function(g, parks){
  geo <- st_as_sfc(g, GeoJson = TRUE)
  geo_sf <- st_as_sf(geo)
  geo_t <- st_transform(geo_sf, crs = 3347)
  geo_c <- geo_t %>% mutate(city = c("Montreal"))
  geo_build <- geo_c[parks,]
  
  return(geo_build)
  
}
