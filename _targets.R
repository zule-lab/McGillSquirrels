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
  
  tar_file_read(
    lst_raw,
    'input/land-surface-temperature.csv',
    read.csv(!!.x, encoding = 'UTF-8')
  ),
  
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
    imp_parks, 
    get_impervious(canopy_files, parks),
    pattern = map(canopy_files),
    iteration = 'list'
  ),
  
  tar_target(
    impervious,
    combine_impervious(imp_parks, parks)
  ),
  
  tar_target(
    roads,
    get_roads(parks)
  ),
  
  tar_target(
    roads_shp, 
    get_roads_shp(parks)
  ),
  
  tar_target(
    building_height,
    building_heights_raw %>% 
      select(-c(system.index, .geo)) %>% 
      distinct() %>% 
      filter(mean > 0) %>%
      drop_na(mean) %>% 
      mutate(Site.Id = Site_Id,
             mean_bldhgt = mean,
             stdDev_bldhgt = stdDev) %>% 
      select(c(Site.Id, mean_bldhgt, stdDev_bldhgt))
  ),
  
  tar_target(
    lst,
    lst_raw %>% 
      select(c(Site_Id, Date, Gray, Melanic, LST_mean, LST_stdDev, LST_count, month_mean)) %>% 
      rename(Site.Id = Site_Id, month = month_mean) %>% 
      mutate(month = case_when(month == 1 ~ 'Jan',
                               month == 2 ~ 'Feb',
                               month == 3 ~ 'Mar',
                               month == 4 ~ 'Apr', 
                               month == 5 ~ 'May', 
                               month == 6 ~ 'Jun', 
                               month == 7 ~ 'Jul',
                               month == 8 ~ 'Aug',
                               month == 9 ~ 'Sep',
                               month == 10 ~ 'Oct', 
                               month == 11 ~ 'Nov', 
                               month == 12 ~ 'Dec')) %>% 
      write.csv(., 'output/temperature-dataset.csv')
  ),
  
  tar_target(
    building_dens,
    get_buildings(parks)
  ),
  
  tar_target(
    full_data,
    combine_data(parks, canopy, impervious, roads, roads_shp, building_dens, building_height)
  )
  
)