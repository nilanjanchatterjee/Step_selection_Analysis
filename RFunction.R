library('move2')
library(amt)
library(ggplot2)
library(dplyr)
library(sf)
library(raster)
library(units)

## the step-selection function will largely be based on the functions from the amt and survival package 

rFunction = function(data, env_layer = NULL, type = "indv") {
  
  ##a small function to calculate the distance between lat-long points in meters
  hav.dist <- function(x1, y1, x2, y2) {
    R <- 6378137 #radius of the earth
    diff.long <- (x2 - x1)
    diff.lat <- (y2 - y1)
    a <- sin(diff.lat/2)^2 + cos(y1) * cos(y2) * sin(diff.long/2)^2
    d = R * 2 * asin(pmin(1, sqrt(a))) 
    return(d)
  }
  data <- data |> mutate(location.long = sf::st_coordinates(data)[,1],
                         location.lat = sf::st_coordinates(data)[,2],
                         trackId = mt_track_id(data))
  data_df <-as.data.frame(data)
  
  units_options(allow_mixed = TRUE)
  
  ###creating tracks from the telemetry data
  trck <- data_df %>%    
    make_track(., .x = location.long, .y = location.lat,
               .t = timestamp,      crs = st_crs(4326),
               id = trackId  )
  
  ### Load the raster data
  raster <- rast(paste0(getAppFilePath("env_layer"),"raster.tif"))
  #raster <-raster("./data/raw/raster.tif")
  
  ### prepare data according to the ssf 
  ssfdat <- trck %>% nest(data = -id) %>%
    mutate(data = map(data,
                      ~ .x %>%  steps())) %>%
    unnest(cols = data) %>%
    random_steps() %>%
    extract_covariates(raster, where = "end") %>%
    mutate(
      step_len = hav.dist(x1_, y1_, x2_, y2_),
      log_sl_ = log(step_len),
      cos_ta_ = cos(ta_),
      speed = step_len / (as.numeric(dt_, units = "hours")),
      step_id = paste(id, step_id_, sep = "_")) %>%
    filter(is.finite(log_sl_))
  
  ### Plot the step-length and turn-angle
  slplot <- ssfdat %>% dplyr::filter(case_ ==TRUE) %>%
    dplyr::select(id, step_len) %>%  
    unnest(cols = step_len) %>% 
    ggplot(aes(step_len, fill = factor(id))) + 
    geom_density(alpha = 0.4)+facet_wrap(~id, scales="free")+
    labs(x= "Step-length (mtr)", fill = "Individual\nId")+
    theme_bw() +xlim(0,50000)  
  
  taplot <- ssfdat %>% dplyr::filter(case_ ==TRUE) %>%
    dplyr::select(id, ta_) %>%  unnest(cols = ta_) %>% 
    ggplot(aes(ta_, fill = factor(id))) + 
    geom_density(alpha = 0.4)+facet_wrap(~id, scales="free")+
    labs(x= "Turn angle (radian)", fill = "Individual\nId")+
    theme_bw()  
  
  ### regression using clogit from the survival package 
  ssfreg <-fit_issf(case_ ~ step_len + log_sl_ + cos_ta_ + raster + strata(step_id), data = ssfdat)
  
  coefssf <- cbind(var= rownames(summary(ssfreg)$coefficients),
                   as.data.frame(summary(ssfreg)$coefficients))
  
  ### Coefficient plot using ggplot
     coef_plot <-  ggplot(coefssf)+
         geom_point(aes(x= var, y= coef))+
         geom_linerange(aes(x = var, 
                            ymin = coef - 1.96*`se(coef)`, 
                            ymax = coef +1.96*`se(coef)`))+
         labs(x= "Variables", y= "Coefficient_estimate")+
         theme_bw()
  
  if(type != "population")
  {
    ssfdat <- trck %>% nest(data = -id) %>%
      mutate(data = map(data,
                        ~ .x %>%  steps() %>%
                          random_steps())) %>%
      unnest(cols = data) %>%
      extract_covariates(raster, where = "end") %>%
        mutate(
        step_len = hav.dist(x1_, y1_, x2_, y2_),
        log_sl_ = log(step_len),
        cos_ta_ = cos(ta_),
        speed = step_len / (as.numeric(dt_, units = "hours")),
        step_id = paste(id, step_id_, sep = "_")
      ) %>%
      filter(is.finite(log_sl_))
    
      ##Equation
    ssffits <- ssfdat %>% nest(data=-id) %>% 
      mutate(
        mod = map(data, 
                  function(x) (try(fit_issf(case_ ~ scale(step_len) + log_sl_ + cos_ta_ + raster + strata(step_id), data = x)))))
    
    ### Coefficient 
    coefssf<-NULL
    
    for(i in 1:length(unique(trck$id))){
      if(attr(ssffits$mod[[i]], "class")[1] !="try-error"){
        coefssf<-rbind(coefssf, cbind(id=ssffits$id[[i]],  var= rownames(summary(ssffits$mod[[i]])$coefficients),
                                      as.data.frame(summary(ssffits$mod[[i]])$coefficients)))
      }                  
    }
    
    ### Coefficient plot using ggplot
    coef_plot <-  ggplot(coefssf, aes(col = id))+
      geom_point(aes(x= var, y= coef), position = position_dodge(width = 0.15))+
      geom_linerange(aes(x = var, 
                         ymin = coef - 1.96*`se(coef)`, 
                         ymax = coef +1.96*`se(coef)`),
                     position = position_dodge(width = 0.15))+
      labs(x= "Variables", y= "Coefficient_estimate", col ="Individual_id")+
      theme_bw()
   }
  
  ## Save the output in csv and jpeg 
  ggsave(coef_plot, filename = paste0(Sys.getenv(x = "APP_ARTIFACTS_DIR", "/tmp/"),"SSF_coef_plot.jpeg"), 
         height = 6, width = 9, units = "in", dpi = 200)
  ggsave(slplot, filename = paste0(Sys.getenv(x = "APP_ARTIFACTS_DIR", "/tmp/"),"Step_length_distribution.jpeg"), 
         height = 6, width = 9, units = "in", dpi = 200)
  ggsave(taplot, filename = paste0(Sys.getenv(x = "APP_ARTIFACTS_DIR", "/tmp/"),"Turn_angle_distribution.jpeg"), 
         height = 6, width = 9, units = "in", dpi = 200)
  
  write.csv(coefssf, file = paste0(Sys.getenv(x = "APP_ARTIFACTS_DIR", "/tmp/"),"SSF_Coef_table.csv"))
  return(data)
}

