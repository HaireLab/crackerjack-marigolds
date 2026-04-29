## crackerjack-marigolds
### Remote sensing of post-fire change: establishing relationships between field and remotely sensed indices

### Code and data for analysis done in this manuscript (currently in prep): The Phoenix Index: A Remote Sensing Indicator of Post-Fire Landscape Change for Avian Communities 
Authors: Walker, J.J., Villarreal, M.L., Haire, S.L., Flesch, A.D., Sanderlin, J.S., Iniguez, J.M., Romo-Leon,  J.R., and C. Cortes-Montano 

## 1. Evaluate texture metrics in relation to field metrics
random.sample.vars.R: Conduct a simulation to evaluate a subset of texture metrics in relation to Basal Area 

plot.random.sample.results.R: Plot the results

## 2. Loess models of bird trait groups ~ rs index
birds_traits_models_loess01.Rmd (and .docx output): Purpose: identify trends in response of bird trait groups/habitat affinities across the Phoenix Index

phix05_newpts.csv: input datafile for birds_traits_models_loess01.Rmd 


## Formerly done but not included in the manuscript
### The following graphical analyses were done for a project looking at change in vegetation between two time periods in US sky islands (1996, 2015) and results are posted here for our purpose of linking the field measures to remotely sensed indices.
1. Describe topography at the field plot locations and present a simple conceptual model of how topography influences change in vegetation. [ggterain+conceptual.docx]
2. Look at change in field measures in the two time periods. [compare.distributions.docx]

### Recently added:
1. Fire history at the field plot locations [ggfire.html]
2. Plots of climate variability [ggclimate.html] 
3. Plots of predictor variables including ndvi_diss_yr20 and response (Trees per ha) [xy_scatterplots.html]

## Earlier analyses
### Mixed model using lmer (R package lme4)

I'm starting with a model that allows for Random effects intercepts for each level of covertype as they deviate from a global intercept, and a global slope. So far, this looks like the model we need to understand the relationship of field measure to remotely sensed metric given effects of covertype and other categorical variables. 

Printing one example model for now. [lmer_example.docx]

### Scripts for next steps

glmm.test_v1.R : assemble data in a list; map lmer and output stats.

glmm.test_v2.R : more code for glmms, this time using us and mx data.
