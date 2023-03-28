library('move')
library(amt)
library(ggplot2)
library(dplyr)
library(sf)

## the step-selection function will largely be based on the functions from the amt package 

RFunction = function(data, type = "population") {
  data_df <-as.data.frame(data)
   
  
  trck <- data_df %>%    make_track(.,
      .x = location.long,       .y = location.lat,
      .t = timestamp,      crs = st_crs(4326),
      id = trackId
    )
  
  ssfdat <- trck %>% nest(data = -id) %>%
    mutate(data = map(data,
      ~ .x %>%  steps(lonlat=T))) %>%
    unnest(cols = data) %>%
    random_steps() %>%
    #extract_covariates(dst_edge, where = "end") %>%
    #extract_covariates(reefclass, where = "both") %>%
    mutate(
      log_sl_ = log(sl_),
      cos_ta_ = cos(ta_),
      speed = sl_ / (as.numeric(dt_, units = "hours")),
      step_id = paste(id, step_id_, sep = "_")
    )
  
  ssfreg <-fit_issf(case_ ~ sl_ + log_sl_ + cos_ta_ + strata(step_id), data = ssfdat)
  
  coef_table <- as.data.frame(summary(ssfreg)$coefficients)
  
  coef_plot <-  ggplot(coef_table)+
    geom_point(aes(x= row.names(coef_table), y= coef))+
    geom_linerange(aes(x = row.names(coef_table), 
                       ymin = coef - 1.96*`se(coef)`, 
                       ymax = coef +1.96*`se(coef)`))+
    labs(x= "Variables", y= "Coefficient_estimate")+
    theme_bw()
  
  ggsave(coef_plot, filename = "coefficient_plot.jpeg", height = 6, width = 9, units = "in", dpi = 300)
}
