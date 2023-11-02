get_parks <- function(x){
  
  # download parks data from city of Montreal
  mtl_parks <- download_shp('https://donnees.montreal.ca/dataset/2e9e4d2f-173a-4c3d-a5e3-565d79baa27d/resource/c57baaf4-0fa8-4aa4-9358-61eb7457b650/download/shapefile.zip', 'input/mtl_parks.zip') %>%
    st_cast("POLYGON")
  
  # convert dataset into spatial
  x_sf <- st_as_sf(x, coords = c('Longitude', 'Latitude'), crs = 4326)
  x_t <- st_transform(x_sf, crs = st_crs(mtl_parks))
  
  # set bbox of Montreal
  bbox <- c(xmin = -74.07169,
            ymin = 45.33291,
            xmax = -73.36445,
            ymax = 45.80015)
  
  # intersect study parks with polygons
  mtl_int <- st_intersection(x_t, mtl_parks) %>% 
    st_set_geometry(NULL) %>% 
    inner_join(., mtl_parks, by = 'OBJECTID') %>% 
    select(c(Site.Id, geometry)) %>%
    group_by(Site.Id) %>%
    summarize(geometry = st_union(geometry)) %>%
    st_as_sf()
  
  # find the sites that are not present in the mtl dataset
  non_mtl <- anti_join(x_t, st_set_geometry(mtl_int, NULL))
  
  # for sites not present in mtl dataset, use osmdata:

  ## Download park polygons from osm
  # download island boundary in bbox
  greenspaces <- opq(bbox, timeout = 100) %>%
    add_osm_features(features = c("\"leisure\"=\"park\"",
                                  "\"leisure\"=\"nature_reserve\"",
                                  "\"natural\"=\"wetland\"",
                                  "\"natural\"=\"wood\"",
                                  "\"landuse\"=\"grass\"",
                                  "\"amenity\"=\"university\"",
                                  "\"amenity\"=\"school\"")) %>% 
    osmdata_sf()
  
  # missing island 
  
  # grab multipolygons (large greenspaces)
  mpolys <- st_make_valid(st_cast(greenspaces$osm_multipolygons, "POLYGON"))
  # grab polygons (smaller greenspaces)
  polys <- st_make_valid(greenspaces$osm_polygons)

  # find what multipolygons intersect with study points and extract them
  osm_int_multi <- polygon_intersection(non_mtl, mpolys)
  
  # find what polygons intersect with study points and extract them
  osm_int_poly <- polygon_intersection(non_mtl, polys)
  
  # want to prioritize polygons over multipolygons,
  # select multipolygons only when they are not present in polygon dataset
  park_mpolys <- anti_join(osm_int_multi, st_set_geometry(osm_int_poly, NULL), by = 'Site.Id')
  
  # combine all park polygons together
  park_geom <- rbind(st_transform(mtl_int, 4326), osm_int_poly, park_mpolys)
  
  # who are we still missing? 6 parks
  # add 10 m buffer and then intersect 
  missing <- x_t %>% 
    # group study sites by name
    group_by(Site.Id) %>% 
    summarise() %>% 
    # remove geometry
    st_set_geometry(NULL) %>%
    # anti join with completed parks so we can see what is missing 
    anti_join(park_geom) %>% 
    # join back with original dataset to have geometry
    inner_join(x_t) %>% 
    st_as_sf() %>%
    # add 30 m buffers because most points are outside of parks 
    st_buffer(30) %>%
    # transform to WGS 84
    st_transform(4326) %>%
    # intersect buffers with osmdata
    polygon_intersection(., polys)
  
  # add to parks 
  park_geom_buff <- rbind(park_geom, missing)
  
  # add manually drawn polygon for Ile Tekakwitha
  it <- read_sf('input/Ile-Tekakwitha.gpkg') %>% 
    mutate(Site.Id = 'Tekakwitha') %>% 
    select(c(Site.Id, geometry))
  
  # combine all parks 
  all <- rbind(park_geom_buff, it)
  
  all_data <- full_join(all, x)

}


polygon_intersection <- function(layer1, layer2){
  
  st_intersection(st_transform(layer1, 4326), st_transform(layer2, 4326)) %>% 
    st_set_geometry(NULL) %>% 
    inner_join(., layer2, by = 'osm_id') %>% 
    select(c(Site.Id, geometry)) %>%
    group_by(Site.Id) %>%
    summarize(geometry = st_union(geometry)) %>%
    st_as_sf()
  
  
}
