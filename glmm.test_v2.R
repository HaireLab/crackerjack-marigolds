## glmm.test_v2.R
## use the us-mx points
## 1. join with rs data
## 2. make a list of datasets for lme
## 3. apply the models to each dataset
## 4. output stats
### report results separately for us & mx; burned and unburned

library(dplyr)
library(tidyr)
library(readr)
library(lme4)
library(lmerTest)
library(merTools)
library(arm)
library(ggplot2)
library(ggpubr)
library(sf)

## load the RData
load("~/Rfiles/rsmodels/processed_glcm_dataset.RData")

## a few variables
isl2<-c("RINCON", "PERILLA") # drop these from US islands
indices3 = c("nbr", "ndvi", "sr")# start w these 3
allindices = c("red", "green", "nir", "evi", "kndvi", "nbr", "nbr2", "ndvi", "ndwi", "nirv", "sr")
types<-c("Mixed Conifer Forest", "Broadleaf Evergreen Woodland",
                     "Ponderosa Pine Forest", "Conifer Woodland")
## data to add to indices etc.
## us-mx data updated from miguel 11/15/22
edpts<-read_sf("./data/fieldpts_edited.shp") # 1111
names(edpts)[1]<-c("unique_id")
## this df has fire data 100 m buffer
preds<-read_csv("./data/predictors_v1.csv") # 1681
# KEEP  Country, isl_fld, Com_Cl, Com_Des, unique_id, focal.count.max, years.since, fire1.focalmean.dnbr, 
preds2 <- preds %>% dplyr::select(c(1,3,9,10,11,13,16,18))
newpt_df<-left_join(edpts, preds2, by="unique_id") %>% st_drop_geometry() %>%
  filter(!is.na(isl_field) )# 1053 (isl name na's=Rincons)

# Empty list
dat_list <- list()
###### this section can probably be shortened by combining some of the steps
## that are now separate
for(i in 1:length(indices3)){
## index i
  index=as.factor(indices3[i]) # removes quotes and makes acceptable to select()
## select the data for each model
mdat <- df_wide %>% 
  dplyr::select(id, sample, monsoon_period, radius_px, index, TPH, BA) %>% 
  filter(monsoon_period=="mid", radius_px=="1", sample=="yr1") %>% 
   droplevels() # 1958 rows

## 1673 rows, 5 col
mdatwide<-pivot_wider(mdat, names_from=sample, values_from=index) 

## get the data associated with new pts and sel cols to keep
## 1046 rows (keep all rows in x and y)
names(mdatwide)<-c("unique_id", "monsoon_period", "radius_px", "TPH", "BA",
                   paste(index, "_yr20", sep=""))
j1<-inner_join(newpt_df, mdatwide, by=c("unique_id"))  %>% 
  dplyr:: select(c(1, 7:18)) 
# Add to list
    dat_list <- append(dat_list, list(j1))
}

######### next run the models and output stats
## use the map functions in purr
## test data outside of list
x<-dat_list[[3]] # ndvi
mod1<-lmer(TPH ~ sr_yr20 + (1|Com_Cl), data=x)
display(mod1) 
summary(mod1)
coef(mod1)
anova(mod1)

mod1<-lmer(TPH ~ sr_yr20 + focal.count.max + (1|Com_Cl), data=x)
display(mod1) 
summary(mod1)
coef(mod1)
anova(mod1)
## US only
x2<-x[x$Country=="United States",] # 328
mod3<-lmer(TPH ~ sr_yr20 + focal.count.max + (1|Com_Cl), data=x2)
display(mod3) 
summary(mod3)
coef(mod3)
anova(mod3)
## MX only
x3<-x[x$Country=="Mexico",] # 718
mod4<-lmer(TPH ~ sr_yr20  + (1|Com_Cl), data=x2.unb)
display(mod4) 
summary(mod4)
coef(mod4)
anova(mod4)
### plots
x3.unb<-x3 %>% filter(focal.count.max==0) #408 unb in mx (over half)
x2.unb<-x2 %>% filter(focal.count.max==0) # 96 unb in us (~ 30 %)

x.burn<-x %>% filter(count.year>0) #127
ggscatter(x.burn, x="nbr_yr20", y="BA_time2", color="covertype", facet.by="covertype")

ggscatter(x, x="nbr_yr20", y="BA_time2", color="covertype", facet.by="covertype")
