## glmm.test_v1.R
## develop methods for extracting dataframes for glmm analysis
## goal: put each dataframe in a list, run glmm and output statistics
## this script starts with 3 rs indices
##
## 10 nov 2022
## questions
## rs indices have missing 14 values for e.g., ndvi_yr20 in the final df

library(dplyr)
library(tidyr)
library(readr)
library(lme4)
library(lmerTest)
library(merTools)
library(arm)

## load the RData
load("~/Rfiles/rsmodels/processed_glcm_dataset.RData")

## a few variables
isl2<-c("RINCON", "PERILLA") # drop these from US islands
indices3 = c("nbr", "ndvi", "sr")# start w these 3
allindices = c("red", "green", "nir", "evi", "kndvi", "nbr", "nbr2", "ndvi", "ndwi", "nirv", "sr")
types<-c("Mixed Conifer Forest", "Broadleaf Evergreen Woodland",
                     "Ponderosa Pine Forest", "Conifer Woodland")
## data to add to indices etc.
## joining rs data with z narrows down the sample to locations that were sampled twice
## more data than we need (terrain, climate, etc. but keep for now)
z<-read_csv("../veg.fire.x2/data/allvars_v4.csv") # available on google drive
                                                 # in field data metrics folder

# Empty list
dat_list <- list()
###### this section can probably be shortened by combining some of the steps
## that are now separate
for(i in 1:length(indices3)){
## index i
  index=indices3[i]
## select the data for each model
isldat <- df_wide %>%
   filter(country=="USA" ) %>% 
  filter(!si_name %in% isl2) %>% droplevels()

idat <- isldat %>% select(id, sample, monsoon_period, radius_px, index) %>% 
  filter(monsoon_period=="mid", radius_px=="1") %>% 
   droplevels() # 613 rows

## 328 rows, 5 col
## 14 na yr 1 (2015), 43 na yr2 (1996)
idatwide<-pivot_wider(idat, names_from=sample, values_from=index)

## grab the data I have from the longitudinal study (ba, tph)
## sample size reduced bc not all us pts were sampled in the field twice
names(idatwide)<-c("unique_id", "monsoon_period", "radius_px", 
                   paste(index, "_yr20", sep=""), paste(index, "_yr19", sep=""))
j1<-left_join(z, idatwide, by=c("unique_id"))  %>% 
  filter(covertype %in% types) # %>% droplevels() not a factor 
# Add to list
    dat_list <- append(dat_list, list(j1))
}

######### next run the models and output stats
## use the map functions in purr

