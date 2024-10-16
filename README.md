# Step Selection Analysis

MoveApps

Github repository: *https://github.com/nilanjanchatterjee/Step_selection_Analysis* 

## Description
The App models *observed steps* with the *randomly generated steps* using the same distribution estimated from the observed steps. Currently the app accepts user provided raster files and a fallback file of `Distance to road` is provided for the **Yellowstone to Yukon** region with a resolution of 0.01 degree.

## Documentation
The app models steps *observed* from collected location fixes with the *generated steps* created by the step-length and turn-angle distribution generated from the observed steps. The regression model fits a conditional logistic regression with the observed steps and respective randomly generated steps. The generated artefact shows the regression output (coefficient, exp(coefficient), standard-error, z-statistic and p value) and the coefficient plot.

### Input data

 Movement data in **Move2** format   
 Environmental covariate data in raster file (format .tif, .img etc.)

### Output data

 Movement data in **Move2** format
 
### Artefacts

*SSF_Coef_table.csv* with the regression coefficients   
*SSF_coef_plot.jpeg* with the coefficient plot   
*Step_length_distribution.jpeg* shows the distribution of the step-length     
*Turn_angle_distribution.jpeg* shows the distribution of the turn-angle

### Settings 

`Raster files`: You can upload your own raster file for running the resource selection function analysis. Make sure that they overlap with the tracking data set and are in WGS 84 projection! You can only upload one file, but this one .tif file can contain multiple layers. Note that if you do not upload a file, a fallback raster file of distance to roads in Y2Y region is provided.

`Type`: Specify how you want to perform the step selection analysis. Type `population` will generate the random steps based on step-length and turn-angle distribution of all the individuals and type `individual` will generate random steps based on step-length and turn-angle distribution separately for all the individuals, default is `population`.

