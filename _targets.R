# === Targets -------------------------------------------------------------


# Source ------------------------------------------------------------------
library(targets)
tar_source('R')



# Options -----------------------------------------------------------------
# Targets
tar_option_set(format = 'qs')
options(timeout=500)

# Renv --------------------------------------------------------------------
activate()
snapshot()
restore()


# Variables ---------------------------------------------------------------


# Scripts -----------------------------------------------------------------
tar_source('R')


# Targets: all ------------------------------------------------------------

# land surface temperature, canopy cover, building density, building height, proximity to major road   

c(
  
  tar_file_read(
    raw_squirrel,
    'input/SquirrelData_v1.csv',
    read.csv(!!.x, encoding = 'UTF-8')
    ),
  
  tar_files(
    canopy_files,
    dir('input/canopy', full.names = TRUE)
  ),
  
  tar_file_read(
    building_heights_raw,
    'input/building-heights.csv',
    read.csv(!!.x, encoding = 'UTF-8')
  ),
  
  # TODO: add temp target here
  
  tar_target(
    parks,
    get_parks(raw_squirrel)
  ),
  
  tar_target(
    can_cov_parks, 
    get_canopy(canopy_files, parks),
    pattern = map(canopy_files),
    iteration = 'list'
  ),
  
  tar_target(
    canopy,
    combine_canopy(can_cov_parks, parks)
  ),
  
  tar_target(
    roads,
    get_roads(parks)
  ),
  
  tar_target(
    building_height,
    building_heights_raw %>% 
      select(-c(system.index, .geo)) %>% 
      distinct() %>% 
      # there are some holes in the DEM data so there are zeroes in the dataset
      filter(mean > 0) %>%
      drop_na(mean) %>% 
      mutate(Site.Id = Site_Id,
             mean_bldhgt = mean,
             stdDev_bldhgt = stdDev) %>% 
      select(c(Site.Id, mean_bldhgt, stdDev_bldhgt))
  ),
  
  tar_target(
    building_dens,
    get_buildings(parks)
  ),
  
  tar_target(
    full_data,
    combine_data(parks, canopy, roads, building_dens, building_height)
    #TODO: add temperature 
  )
  
  
  
)