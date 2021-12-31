# loading required libraries

library(tidyverse)
library(ggstatsplot)
library(ggplot2)
library(maptools)
library(rgeos)
library(ggmap)
library(scales)
library(gdistance)
library(raster)
library(sf)
library(sp)
library(units)
library(smoothr)
library(tmap)
library(pastecs)
library(stars)
library(rgdal)
library(exactextractr)
library(DescTools)
library(ggrepel)

# loading raster with population
rast_pop = read_stars("ind_ppp_2020_1km_Aggregated_UNadj.tif", proxy = F)
plot(rast_pop)

# loading rural-urban catchment
urca_raster = read_stars("URCA.tif", proxy = T)
names(urca_raster) = "urca"
plot(urca_raster)

# getting national, state and district boundaries 
ind_shp = st_as_sf(getData('GADM', country ='IND', level = 0)) # for country
ind_st_shp = st_as_sf(getData('GADM', country ='IND', level = 1))  #for states boundary
ind_dis_shp = st_as_sf(getData('GADM', country = 'IND', level = 2)) # for district boundary

plot(ind_dis_shp)

# cropping India from global raster
ind_urca = st_crop(urca_raster, ind_shp)


# dividing on the basis of rural and urban
ind_rur = ind_urca > 7
ind_urb = ind_urca <= 7 
ind_rur_star = st_as_stars(ind_rur)
ind_urb_star = st_as_stars(ind_urb)

plot(ind_rur_star)
plot(ind_urb_star)

# converting logical values to numeric for further analysis
ind_rur_star$urca = as.numeric(ind_rur_star$urca)
ind_urb_star$urca = as.numeric(ind_urb_star$urca)

# writing rasters
write_stars(ind_rur_star, "ind_rural_areas.tif", layer = 1)
write_stars(ind_urb_star, 'ind_urban_areas.tif', layer = 1)
