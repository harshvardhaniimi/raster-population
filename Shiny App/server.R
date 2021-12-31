library(shiny)
library(raster)
library(sf)
library(exactextractr)

pop_20 = raster("ind_ppp_2020_1km_Aggregated_UNadj.tif")
urca = raster("URCA.tif")

ind_sf = st_as_sf(getData('GADM', country = 'IND', level = 0)) # for country
ind_st_sf = st_as_sf(getData('GADM', country = 'IND', level = 1))  #for states boundary
ind_dis_sf = st_as_sf(getData('GADM', country = 'IND', level = 2)) # for district boundary


sl_fun = function(x)
{
    # dividing on the basis of rural and urban
    urca_rural = urca > x
    urca_urban = urca <= x
    
    # cropping rural and urban from India population raster (for differing extents, it will multiply         # and crop by default )
    pop_20_rural = pop_20 * urca_rural
    pop_20_urban = pop_20 * urca_urban
    
    # creating CSV from raster files
    ## for states - rural
    st_pop_tb_rural = data.frame(
        "Country" = ind_st_sf$NAME_0,
        "State" = ind_st_sf$NAME_1,
        "Population" = exact_extract(pop_20_rural, ind_st_sf, fun = "sum")
    )
    ## for states - urban
    st_pop_tb_urban = data.frame(
        "Country" = ind_st_sf$NAME_0,
        "State" = ind_st_sf$NAME_1,
        "Population" = exact_extract(pop_20_urban, ind_st_sf, fun = "sum")
    )
    
    ## for districts - rural
    dis_pop_tb_rural = data.frame(
        "Country" = ind_dis_sf$NAME_0,
        "State" = ind_dis_sf$NAME_1,
        "District" = ind_dis_sf$NAME_2,
        "Population" = exact_extract(pop_20_rural, ind_dis_sf, fun = "sum")
    )
    ## for districts - rural
    dis_pop_tb_urban = data.frame(
        "Country" = ind_dis_sf$NAME_0,
        "State" = ind_dis_sf$NAME_1,
        "District" = ind_dis_sf$NAME_2,
        "Population" = exact_extract(pop_20_urban, ind_dis_sf, fun = "sum")
    )
    
    l = list(
        pop_20_rural,
        pop_20_urban,
        st_pop_tb_rural,
        st_pop_tb_urban,
        dis_pop_tb_rural,
        dis_pop_tb_urban
    )
    
    return(l)
}

sl_fun_ac = function(x, ct)
{
    ac_iso = getData("ISO3")$ISO3[which(getData("ISO3")$NAME == ct)]
    
    dest = paste0(tolower(ac_iso), "_ppp_2020_1km_Aggregated_UNadj.tif")
    
    # download population only if not already downloaded
    if (!file.exists(dest)) {
        url = paste0(
            "https://data.worldpop.org/GIS/Population/Global_2000_2020_1km_UNadj/2020/",
            ac_iso,
            "/",
            tolower(ac_iso),
            "_ppp_2020_1km_Aggregated_UNadj.tif"
        )
        dl_file = download.file(url, dest)
    }
    
    ac_pop_20 = raster(dest)
    ac_sf = st_as_sf(getData('GADM', country = ac_iso, level = 0)) # for country
    ac_st_sf = st_as_sf(getData('GADM', country = ac_iso, level = 1))  #for states boundary
    ac_dis_sf = st_as_sf(getData('GADM', country = ac_iso, level = 2)) # for district boundary
    
    
    # dividing on the basis of rural and urban
    urca_rural = urca > x
    urca_urban = urca <= x
    
    # cropping rural and urban from the country's population raster (for differing extents, it will multiply and crop by default )
    pop_20_rural = ac_pop_20 * urca_rural
    pop_20_urban = ac_pop_20 * urca_urban
    
    # creating CSV from raster files
    ## for states - rural
    st_pop_tb_rural = data.frame(
        "Country" = ac_st_sf$NAME_0,
        "State" = ac_st_sf$NAME_1,
        "Population" = exact_extract(pop_20_rural, ac_st_sf, fun = "sum")
    )
    ## for states - urban
    st_pop_tb_urban = data.frame(
        "Country" = ac_st_sf$NAME_0,
        "State" = ac_st_sf$NAME_1,
        "Population" = exact_extract(pop_20_urban, ac_st_sf, fun = "sum")
    )
    
    ## for districts - rural
    dis_pop_tb_rural = data.frame(
        "Country" = ac_dis_sf$NAME_0,
        "State" = ac_dis_sf$NAME_1,
        "District" = ac_dis_sf$NAME_2,
        "Population" = exact_extract(pop_20_rural, ac_dis_sf, fun = "sum")
    )
    ## for districts - rural
    dis_pop_tb_urban = data.frame(
        "Country" = ac_dis_sf$NAME_0,
        "State" = ac_dis_sf$NAME_1,
        "District" = ac_dis_sf$NAME_2,
        "Population" = exact_extract(pop_20_urban, ac_dis_sf, fun = "sum")
    )
    
    l = list(
        pop_20_rural,
        pop_20_urban,
        st_pop_tb_rural,
        st_pop_tb_urban,
        dis_pop_tb_rural,
        dis_pop_tb_urban,
        ac_pop_20
    )
    
    return(l)
}

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
    div_ru = reactive({
        input$divider
    })
    
    ct = reactive({
        input$country
    })
    
    out = reactive({
        sl_fun(div_ru())
    })
    
    out_ac = reactive({
        sl_fun_ac(div_ru(), ct())
    })
    
    output$pl = renderPlot({
        plot(pop_20)
    })
    
    output$pl_ac = renderPlot({
        plot(out_ac()[[7]])
    })
    
    output$download1 = downloadHandler(
        filename = function() {
            paste0("ind_state_rural_", div_ru(), ".csv")
        },
        content = function(file) {
            withProgress(message = "Working on State Rural Population", value = 0,
                         {
                             write.csv(out()[[3]], file, row.names = F)
                         })
        }
    )
    output$download2 = downloadHandler(
        filename = function() {
            paste0("ind_state_urban_", div_ru(), ".csv")
        },
        content = function(file) {
            withProgress(message = "Working on State Urban Population", value = 0, {
                write.csv(out()[[4]], file, row.names = F)
            })
        }
    )
    output$download3 = downloadHandler(
        filename = function() {
            paste0("ind_district_rural_", div_ru(), ".csv")
        },
        content = function(file) {
            withProgress(message = "Working on District Rural Population", value = 0, {
                write.csv(out()[[5]], file, row.names = F)
            })
        }
    )
    output$download4 = downloadHandler(
        filename = function() {
            paste0("ind_district_urban_", div_ru(), ".csv")
        },
        content = function(file) {
            withProgress(message = "Working on District Urban Population", value = 0, {
                write.csv(out()[[6]], file, row.names = F)
            })
        }
    )
    output$download1_ac = downloadHandler(
        filename = function() {
            paste0(input$country, "_state_rural_", div_ru(), ".csv")
        },
        content = function(file) {
            withProgress(message = "Working on State Rural Population", value = 0, {
                write.csv(out_ac()[[3]], file, row.names = F)
            })
        }
    )
    output$download2_ac = downloadHandler(
        filename = function() {
            paste0(input$country, "_state_urban_", div_ru(), ".csv")
        },
        content = function(file) {
            withProgress(message = "Working on State Urban Population", value = 0, {
                write.csv(out_ac()[[4]], file, row.names = F)
            })
        }
    )
    output$download3_ac = downloadHandler(
        filename = function() {
            paste0(input$country, "_district_rural_", div_ru(), ".csv")
        },
        content = function(file) {
            withProgress(message = "Working on District Rural Population", value = 0, {
                write.csv(out_ac()[[5]], file, row.names = F)
            })
        }
    )
    output$download4_ac = downloadHandler(
        filename = function() {
            paste0(input$country, "_district_urban_", div_ru(), ".csv")
        },
        content = function(file) {
            withProgress(message = "Working on District Urban Population", value = 0, {
                write.csv(out_ac()[[6]], file, row.names = F)
            })
        }
    )
})
