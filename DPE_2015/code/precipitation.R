#==============================================================================
# Script for aggregation precipitation data from GPCP V2.2
# Data made available in ASCII-format by David Bolvin from NASA GPCP
# Script written by Edwin de Jonge from Statistics Netherlands
# Original files can be found at https://github.com/edwindj/precipitation
# Required shape-files can be found at http://thematicmapping.org/downloads/world_borders.php
# In order to calculate yearly averages at the original grid-resolution
# simply comment out the following line:
# r.africa <- disaggregate(r.africa, fact=5)
#==============================================================================

library(raster)
library(sp)

# create a matrix of years vs months
years <- 1979:2010
months <- sprintf("%02d", 1:12)

m <- t(outer(years, months, paste, sep=""))

# create matrix of days per month
days <- matrix( diff(seq(as.Date("1979-01-01"), as.Date("2011-01-01"), by = "month"))
              , nrow=12
              , dimnames=list(months, years)
              )

frac <- days / rep(colSums(days), each=12)

# create list of files for yearmonth
files <- paste("gpcp_", m, ".ascii.gz", sep="")

# download data
DOWNLOADDATA <- readline("Download precipitation data from internet (y/n) ? : ")

if (DOWNLOADDATA=="y"){
  data.url <- "ftp://rsd.gsfc.nasa.gov/pub/912/bolvin/GPCP_ASCII/"
  require(RCurl)
  dir.create("data/NASA", recursive=TRUE)
  for (f in files){
    content <- getBinaryURL(paste(data.url, f, sep=""))
    writeBin(content, paste("data/NASA/", f, sep=""))
    cat("Retrieving ", f, "...\n")
  }
}

# create a reaster
r <- raster(nrows=72, ncols=144, xmn=-180, xmx=180, ymn=-90, ymx=90)

dir.create("data/africa",recursive=TRUE)
files.africa <- paste("data/africa/af_", m,".grd", sep="")
files <- paste("data/NASA/", files, sep="")

# clip raster to include Africa
ext.africa <- extent(c(-25, 60, -45,40))
for (i in seq_along(files)){
  tab <- read.table(gzfile(files[i]))
  values(r) <- as.matrix(tab)
  # rotate data and restrict to africa
  r.africa <- crop(rotate(r),ext.africa)
  r.africa <- disaggregate(r.africa, fact=5)
  writeRaster(r.africa, filename=files.africa[i], overwrite=TRUE)
  cat("Writing ", files.africa[i], "...[",i,"/",length(files),"]\n")
}

africa <- brick(stack(files.africa), filename="data/africa.grd", overwrite=TRUE)
africa.u <- mapply(unstack(africa),frac, FUN=`*`)
africa.m <- brick(stack(africa.u), filename="data/africa.m.grd", overwrite=TRUE)

# data per grid cell per year
africa_year <- stackApply( africa.m, indices=col(m), filename="data/africa_year.grd", overwrite=TRUE
                         , fun = sum
                         )
layerNames(africa_year) <- paste("Y", years, sep="")
library(maptools)
country <- readShapePoly("TM_WORLD_BORDERS-0.3/TM_WORLD_BORDERS-0.3.shp")
rcountry <- rasterize(country, africa_year)

# extract year data per country
cnts <- unique(values(rcountry))[-1]
names(cnts) <- country$NAME[cnts]
cntsCells <- t(sapply( cnts
                   , function(i) {
                       w <- which(rcountry[]==i)
                       m <- extract(africa_year, w)
                       if (is.matrix(m))
                         colMeans(m) 
                       else
                         m
                     }
                   ))

# write data to file
prec <- as.data.frame(cntsCells)
write.csv(prec, file="data/prec.csv")
