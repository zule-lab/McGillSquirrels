// PART 1: CALCULATING LST // 

/*
Author: Sofia Ermida (sofia.ermida@ipma.pt; @ermida_sofia)
This code is free and open. 
By using this code and any data derived with it, 
you agree to cite the following reference 
in any publications derived from them:
Ermida, S.L., Soares, P., Mantas, V., Göttsche, F.-M., Trigo, I.F., 2020. 
    Google Earth Engine open-source code for Land Surface Temperature estimation from the Landsat series.
    Remote Sensing, 12 (9), 1471; https://doi.org/10.3390/rs12091471
Example 1:
  This example shows how to compute Landsat LST from Landsat-8 over Coimbra
  This corresponds to the example images shown in Ermida et al. (2020)
    
*/

// link to the code that computes the Landsat LST
var LandsatLST = require('users/sofiaermida/landsat_smw_lst:modules/Landsat_LST.js')

// select region of interest, date range, and landsat satellite
var geometry = parks;
var satellite = 'L8';
var date_start = '2022-01-01';
var date_end = '2022-12-31';
var use_ndvi = true;

// get landsat collection with added variables: NDVI, FVC, TPW, EM, LST
// clip image collection to city bounds
var LST = LandsatLST.collection(satellite, date_start, date_end, geometry, use_ndvi).map(function(image){return image.clip(parks)});

// convert to Celsius for easier analysis 
var LSTc = LST.select('LST').map(function(image) {
  return image
    .subtract(273.15) // multiply by band scale for true value? 2.75e-05 
    .set('system:time_start', image.date().millis()) // add timestamp column 
});


// PART 2: EXTRACTING LST // 
// want to extract LST values at various scales in each city
// all assets were cleaned and produced in R - check github.com/icrichmond/cross-city-es for code 

// 1. Monthly Mean
// Get mean of each pixel for the summer
var monthList = ee.List.sequence(1, 12);
var aggregate = ee.ImageCollection.fromImages(monthList.map(function(month){
  return LSTc.filter(ee.Filter.calendarRange(month, month, 'month'))
  .mean()
  .addBands(ee.Image.constant(month).rename('month')) // add month argument in new collection
  
}))

// 2. Park Scale 
// extract mean LST value at each image in the image collection for each city 
var reducer = ee.Reducer.mean()
.combine({reducer2: ee.Reducer.stdDev(), outputPrefix: null, sharedInputs: true})
.combine({reducer2: ee.Reducer.count(), outputPrefix: null, sharedInputs: true});


var parkLST = aggregate.map(function(image){
  return image.reduceRegions({
  'reducer': reducer,
  'scale': 30,
  'collection': parks})
}).flatten()

// Explicitly select output variables in the export (redundant with filter lines 56-57)
parkLST = parkLST.select(['Site_Id', 'Date', 'Gray', 'Melanic', 'LST_mean', 'LST_stdDev', 'LST_count', 'month_mean'])


// Export
Export.table.toDrive({
  collection: parkLST,
  description: 'parks'
});
