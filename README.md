## crackerjack-marigolds
### Remote sensing of post-fire change: establishing relationships between field and remotely sensed indices

### The following graphical analyses were done for a project looking at change in vegetation between two time periods in US sky islands (1996, 2015) and results are posted here for our purpose of linking the field measures to remotely sensed indices.
1. Describe topography at the field plot locations and present a simple conceptual model of how topography influences change in vegetation. [ggterain+conceptual.docx]
2. Look at change in field measures in the two time periods. [compare.distributions.docx]

### Recently added:
1. Fire history at the field plot locations [ggfire.html]
2. Plots of climate variability [ggclimate.html] 
3. Plots of predictor variables including ndvi_diss_yr20 and response (Trees per ha) [xy_scatterplots.html]

### Mixed model using lmer (R package lme4)

I'm starting with a model that allows for Random effects intercepts for each level of covertype as they deviate from a global intercept, and a global slope. So far, this looks like the model we need to understand the relationship of field measure to remotely sensed metric given effects of covertype and other categorical variables. 

Printing one example model for now. [lmer_example.docx]

### Scripts for next steps

glmm.test_v1.R : assemble data in a list; map lmer and output stats.

glmm.test_v2.R : more code for glmms, this time using us and mx data.
