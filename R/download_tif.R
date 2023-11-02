download_tif <- function(url, dest){
  temp <- tempfile()
  download.file(url, dest, mode = "wb")
  star <- read_stars(file.path("/vsizip", dest), proxy = TRUE)
  return(star)
}
