library('move')
library(amt)
library(ggplot2)
library(dplyr)
library(sf)
library(raster)

## the step-selection function will largely be based on the functions from the amt package 

rFunction = function(data, env_layer = NULL, type = "indv") {
  data_df <-as.data.frame(data)
   
  
  trck <- data_df %>%    
    make_track(., .x = location.long, .y = location.lat,
      .t = timestamp,      crs = st_crs(4326),
      id = trackId  )
  
  ### Load the raster data
  raster <- raster(paste0(getAppFilePath("env_layer"),"raster.tif"))
  
  ### prepare data according to the ssf 
  ssfdat <- trck %>% nest(data = -id) %>%
    mutate(data = map(data,
      ~ .x %>%  steps(lonlat=T))) %>%
    unnest(cols = data) %>%
    random_steps() %>%
    extract_covariates(raster, where = "end") %>%
    mutate(
      log_sl_ = log(sl_),
      cos_ta_ = cos(ta_),
      speed = sl_ / (as.numeric(dt_, units = "hours")),
      step_id = paste(id, step_id_, sep = "_")
    )
  
  if(type != "population")
  {
    ssfdat <- trck %>% nest(data = -id) %>%
      mutate(data = map(data,
                        ~ .x %>%  steps(lonlat=T) %>%
      random_steps())) %>%
      unnest(cols = data) %>%
      extract_covariates(raster, where = "end") %>%
      mutate(
        log_sl_ = log(sl_),
        cos_ta_ = cos(ta_),
        speed = sl_ / (as.numeric(dt_, units = "hours")),
        step_id = paste(id, step_id_, sep = "_")
      )
  }
  ### regression using clogit from the survival package 
  ssfreg <-fit_issf(case_ ~ sl_ + log_sl_ + cos_ta_ + raster + strata(step_id), data = ssfdat)
  
  coef_table <- as.data.frame(summary(ssfreg)$coefficients)
  
  ### Coefficient plot using ggplot
  coef_plot <-  ggplot(coef_table)+
    geom_point(aes(x= row.names(coef_table), y= coef))+
    geom_linerange(aes(x = row.names(coef_table), 
                       ymin = coef - 1.96*`se(coef)`, 
                       ymax = coef +1.96*`se(coef)`))+
    labs(x= "Variables", y= "Coefficient_estimate")+
    theme_bw()
  
  ## Save the output in csv and jpeg 
  ggsave(coef_plot, filename = paste0(Sys.getenv(x = "APP_ARTIFACTS_DIR", "/tmp/"),"SSF_coef_plot.jpeg"), 
         height = 6, width = 9, units = "in", dpi = 300)
  write.csv(coef_table, file = paste0(Sys.getenv(x = "APP_ARTIFACTS_DIR", "/tmp/"),"SSF_Coef_table.csv"))
  return(data)
}


