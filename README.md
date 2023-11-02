# McGill Squirrel Project 

This project was created to assist an undergraduate student in Dr. Hendry's lab at McGill acquire spatial data for an analysis he is doing on coat colour. 

To run this project, clone this repository, install all necessary packages, open the project and run `targets::tar_make()`. 

**IMPORTANT NOTE**

This repository is currently missing most of the data in the `input/` folder. This is because a) the data are too big to push to Git, or b) I do not have permission to share privately collected field data. In the case of a) :

1. Canopy cover rasters for relevant spatial areas were downloaded from the [CMM database]([https://observatoire.cmm.qc.ca/produits/donnees-georeferencees/#orthophotographies](https://observatoire.cmm.qc.ca/produits/donnees-georeferencees/#indice_canopee)https://observatoire.cmm.qc.ca/produits/donnees-georeferencees/#indice_canopee). Zipped download files were unzipped, the first TIFF file was selected (most broad spatial coverage), and then TIFFs were stored in a folder `input/canopy/`.

2. All other relevant files spatial files are either included in the `input/` folder now, or are downloaded using the code provided.

In the case of b) : 

The input file SquirrelData_v1.csv that is referenced in the code is field data collected by Francis Dinh. The original file contains park names, latitude and longitude of sampling points, city/locale of the park, date of sampling, number of melanic squirrels observed, and number of gray squirrels observed. To have this repository run without the original file, you can simulate the data or format your data so that the code runs successfully. 

At bare minimum, this requires a CSV file that contains columns of Site.Id (park name), Longitude, and Latitude with coordinates projected using WGS 84 (epsg 4326). Example: 

```{r}
library(tibble)

raw_squirrel <- tibble(Site.Id = c('Park1', 'Park2'), Latitude = c(45.52139, 45.52519), Longitude = c(-73.67197, -73.67534))
```

## Output 
The final output dataframe contains several columns. Here is a description of each: 

- Site.Id = park name
- geometry = the geometry of the park (polygon). Not present in CSV file output because it is a spatial column.
- Locale = city/neighbourhood park is located within 
- Latitude = latitude of park (WGS 84)
- Longitude = longitude of park (WGS 84)
- Date = date of field sampling
- Melanic = number of melanic squirrels observed
- Gray = number of gray squirrels observed 
- park_area_m2 = area of the park in m^2
- can_cov_per = percentage of park area with canopy cover
- min_road_dist_m = distance to closest major road in metres
- min_road_dist_km = distance to closest major road in kilometres 
- no_buildings = number of buildings within a 100 m radius of the park
- building_area_km2 = sum of area that buildings take up within a 100 m radius of the park (in km^2)
- no_buildings_perkm = number of buildings divided by buffer area (buffer that includes the park + 100 m radius surrounding the park)
- building_area_perkm = sum of building area divided by buffer area (buffer that includes the park + 100 m radius surrounding the park)
- mean_bldhgt_m = average building height of buildings contained within a 100 m radius of the park (in metres)
- stdDev_bldhgt = the standard deviation of building height of buildings within a 100 m radius of the park (in metres)

## Missing Data
After running the code, there will be missing data in some columns. 

- First, canopy cover for parks that are not contained within the datasets downloaded by the CMM will show as NA. For original dataset, this includes only the parks located in Kahnawake, as they are not included in any of the canopy cover datasets.
- Second, building density measures (i.e., no_buildings, building_area_km2, no_buildings_perkm, and building_area_perkm) will show as NA if there were no buildings completely within a 100 m radius. For the original dataset, this is true for three parks.
- Third, the DEM (digital elevation model) data used to calculate building height has some missing data. This results in NAs for mean_bldhgt_m and stdDev_bldhgt columns for some parks.
