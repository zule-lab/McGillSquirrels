get_impervious <- function(canopy_files, parks){
  
  # list regions with canopy cover data we need 
  # https://observatoire.cmm.qc.ca/produits/donnees-georeferencees/#indice_canopee
  
  canopy_files <- read_stars(canopy_files, proxy = T)
  parks_t <- st_transform(parks, st_crs(canopy_files))
  
  bb <- st_bbox(canopy_files, crs = st_crs(canopy_files)) %>% 
    st_as_sfc(.)
  
  relevant_parks <- st_intersection(parks_t, bb)
  
  cancov <- aggregate(canopy_files, st_transform(relevant_parks, st_crs(canopy_files)), FUN = function(x) (sum(x == 1, na.rm = T) + sum(x == 2, na.rm = T))/length(x)) %>% 
    st_as_sf()
  
  # rename columns?
}