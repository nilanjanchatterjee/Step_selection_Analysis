# Step Selection Analysis

MoveApps

Github repository: *https://github.com/nilanjanchatterjee/Step_selection_Analysis* 

## Description
The App models *observed steps* with the *randomly generated steps* using the same distribution estimated from the observed steps. Currently the app accepts user provided raster files 

## Documentation
The app models steps *observed* from collected location fixes with the *generated steps* created by the step-length and turn-angle distribution generated from the observed steps. The regression model fits a conditional logistic regression with the observed steps and respective randomly generated steps. The generated artefact shows the regression output (coefficient, exp(coefficient), standard-error, z-statistic and p value) and the coefficient plot.

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

