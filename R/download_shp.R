download_shp <- function(url, dest){
  temp <- tempfile()
  download.file(url, dest, mode = "wb")
  shp <- st_read(file.path("/vsizip", dest))
  return(shp)
}
