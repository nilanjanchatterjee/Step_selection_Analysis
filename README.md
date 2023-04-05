# Step Selection Analysis

MoveApps

Github repository: *https://github.com/nilanjanchatterjee/Step_selection_Analysis* 

## Description
The App models *observed steps* with the *randomly generated steps* using the same distribution estimated from the observed steps. Currently the app accepts user provided raster files 

## Documentation
*Enter here a detailed description of your App. What is it intended to be used for. Which steps of analyses are performed and how. Please be explicit about any detail that is important for use and understanding of the App and its outcomes.*

### Input data

 Move/MoveStack in Movebank format
 Covariate data in raster file (format .tif, .img etc.)

### Output data

 Move/MoveStack in Movebank format

### Artefacts

SSF_Coef_table.csv with the regression coefficients
SSF_coef_plot.jpeg with the coefficient plot

### Settings 
*Please list and define all settings/parameters that the App requires to be set by the App user, if necessary including their unit.*

*Example:* `Radius of resting site` (radius): Defined radius the animal has to stay in for a given duration of time for it to be considered resting site. Unit: `metres`.


### Null or error handling
*Please indicate for each setting as well as the input data which behaviour the App is supposed to show in case of errors or NULL values/input. Please also add notes of possible errors that can happen if settings/parameters are improperly set and any other important information that you find the user should be aware of.*

*Example:* **Setting `radius`:** If no radius AND no duration are given, the input data set is returned with a warning. If no radius is given (NULL), but a duration is defined then a default radius of 1000m = 1km is set. 
