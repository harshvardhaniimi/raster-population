##############
### Experimental code on how to make the entire operation faster
##############

dem = raster("ind_ppp_2020_1km_Aggregated_UNadj.tif")
dem

cellStats(dem, max)

dem@crs
hist(dem)
cellStats(dem, mean)

plot(dem, zlim = c(1,1000), col = terrain.colors(10))

crop1 = drawExtent()

urca = raster("URCA.tif")
urca
plot(urca)

urca_rural = urca<=7
urca_rural
plot(urca_rural)

dem$ind_ppp_2020_1km_Aggregated_UNadj * urca_rural

dem_rural = raster::crop(dem, urca_rural)
plot(dem_rural)

ind_sf <- st_as_sf(getData('GADM', country ='IND', level = 0)) # for country
ind_st_sf <- st_as_sf(getData('GADM', country ='IND', level = 1))  #for states boundary
ind_dis_sf <- st_as_sf(getData('GADM', country = 'IND', level = 2)) # for district boundary

# these ind_sf objects have to be used for exact_extract

dem_rural_st = exact_extract(dem_rural, ind_st_sf, fun = "sum")
dem_rural_st
write.csv(dem_rural_st, "something.csv")



####### For projecting to one CRS
# common.crs <- CRS(proj4string(file.a))
# file.b.reprojected <- spTransform(file.b, common.crs)

