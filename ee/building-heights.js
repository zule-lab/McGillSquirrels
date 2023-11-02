// Script to calculate mean + std variation in building height at multiple scales

// Data ----------
// load parks
var parks = ee.FeatureCollection('users/icrichmond/mcgill-parks');
// create 100 m buffer
var addBuffer = function(feature) {
  return feature.buffer(100);
};

var parks_geom = parks.map(addBuffer)

// load Canadian buildings
var canBuildings = ee.FeatureCollection('projects/sat-io/open-datasets/MSBuildings/Canada')

// import heights
var dsm = ee.ImageCollection("projects/sat-io/open-datasets/OPEN-CANADA/CAN_ELV/HRDEM_1M_DSM")
var dtm = ee.ImageCollection("projects/sat-io/open-datasets/OPEN-CANADA/CAN_ELV/HRDEM_1M_DTM")

// calculate DEM
var dem = dsm.mosaic().subtract(dtm.mosaic());

// mask buildings
var building_mask = canBuildings.reduceToImage(['FID'], ee.Reducer.anyNonZero());

// mask DEM 
var dem_mask = dem.mask(building_mask);


// Extract Heights ----------

var park_dem = dem_mask.reduceRegions({collection: parks_geom,
                                      reducer: ee.Reducer.mean().combine({reducer2: ee.Reducer.stdDev(), outputPrefix: null, sharedInputs: true}),
                                      scale: 5
});


// Export ----------
Export.table.toDrive({
  collection: park_dem,
  description: "parks",
  fileFormat: "CSV"
});


