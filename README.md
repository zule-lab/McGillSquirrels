# McGill Squirrel Project 

This project was created to assist an undergraduate student in Dr. Hendry's lab at McGill acquire spatial data for an analysis he is doing on coat colour. 

To run this project, cone this repository, install all necessary packages, open the project and run `targets::tar_make()`. 

**IMPORTANT NOTE**

This repository is currently missing most of the data in the `input/` folder. This is because a) the data are too big to push to Git, or b) I do not have permission to share privately collected field data. In the case of a) :

1. Canopy cover rasters for relevant spatial areas were downloaded from the [CMM database]([https://observatoire.cmm.qc.ca/produits/donnees-georeferencees/#orthophotographies](https://observatoire.cmm.qc.ca/produits/donnees-georeferencees/#indice_canopee)https://observatoire.cmm.qc.ca/produits/donnees-georeferencees/#indice_canopee). Zipped download files were unzipped, the first TIFF file was selected (most broad spatial coverage), and then TIFFs were stored in a folder `input/canopy/`.

2. All other relevant files spatial files are either included in the `input/` folder now, or are downloaded using the code provided.

In the case of b) : 

The input file SquirrelData_v1.csv that is referenced in the code is field data collected by Francis Dinh. The original file contains park names, latitude and longitude of sampling points, city/locale of the park, date of sampling, number of melanic squirrels observed, and number of gray squirrels observed. To have this repository run without the original file, you can simulate the data or format your data so that the code runs successfully. 

At bare minimum, this requires a CSV file that contains columns of Site.ID (park name), Longitude, and Latitude with coordinates projected using WGS 84 (epsg 4326). Example: 

```{r}
library(tibble)

raw_squirrel <- tibble(Site.ID = c('Park1', 'Park2'), Latitude = c(45.52139, 45.52519), Longitude = c(-73.67197, -73.67534))
```
