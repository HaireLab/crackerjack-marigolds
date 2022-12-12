## hgam.select_v1.R
## try gam model selection first with all indices (n=11)
## and a common global smoother
## see: Pederson et al. 2019, https://peerj.com/articles/6876/
## 12 dec 2022

library(sf)
library(tidyr)
library(dplyr)
library(readr)
library(mgcv)
library(gratia)
library(ggplot2)
library(ggpubr)

## load the RData
load("~/Rfiles/rsmodels/processed_glcm_dataset.RData")

## variables
## all the rs indices
allindices = c("red", "green", "nir", "evi", "kndvi", "nbr", "nbr2", "ndvi", "ndwi", "nirv", "sr")
## types exclude desert and mountain scrub, riparian, deciduous and oak savannah
types5=c("Pine oak woodland", "Oak woodland", "Pine forest", "Mixed conifer forest", "Pinyon juniper woodland")
#types3=c("Pine oak woodland",  "Pine forest", "Pinyon juniper woodland")

## data to add to indices etc.
## us-mx data updated from miguel 11/15/22
edpts<-read_sf("./data/fieldpts_edited.shp") # 1111
names(edpts)[1]<-c("unique_id")
## this df has fire data 100 m buffer
preds<-read_csv("./data/predictors_v1.csv") # 1681
# KEEP  Country, isl_fld, Com_Cl, Com_Des, unique_id, focal.count.max, 
## years.since, fire1.focalmean.dnbr, 
preds2 <- preds %>% dplyr::select(c(1,3,9,10,11,13,16,18))
## delete rincon pts (isl_field=NA) and keep forest and woodland types only
newpt_df<-left_join(edpts, preds2, by="unique_id") %>% st_drop_geometry() %>%
  filter(!is.na(isl_field) ) %>% filter(Com_Des %in% types5) # 919 
## table of sample size for each type
newpt_df %>% group_by(Com_Des) %>% count() %>% arrange(-n)
# Com_Des                     n
#  <chr>                   <int>
#1 Oak woodland              412
#2 Pine oak woodland         273
#3 Pine forest               102
#4 Mixed conifer forest       76
#5 Pinyon juniper woodland    56

## put all the indices in one df
mdat <- df_wide %>% 
  dplyr::select(id, sample, monsoon_period, radius_px, all_of(allindices), TPH, BA) %>% 
  filter(radius_px=="1", sample=="yr1") %>% 
   droplevels() 

## make a variable (col) for both pre and mid monsoon
mdatwide<-pivot_wider(mdat, names_from=monsoon_period, values_from=all_of(allindices)) 
names(mdatwide)[1]<-c("unique_id")

## join with field data
j1<-inner_join(newpt_df, mdatwide, by=c("unique_id"))  %>% 
  dplyr:: select(c(1, 7:39)) ## 919 rows

## un-order 
j1$Com_Des<-as.factor(j1$Com_Des)
j1 <- transform(j1, Com_DesUO=factor(Com_Des, ordered=FALSE))

## run gam select=TRUE
## model 1: common global smoother
## levels=5 so k=5 for com_des

mg<-gam(BA~s(red_pre ) + s(green_pre ) + s(nir_pre ) + s(evi_pre ) +
          s(kndvi_pre ) + s(nbr_pre ) + s(nbr2_pre ) +
          s(ndvi_pre ) + s(ndwi_pre ) + s(nirv_pre ) + s(sr_pre ) +
         s(Com_DesUO, k=5, bs="re"),
        data=j1, method="REML", select=TRUE, family="gaussian")

draw(mg)
spre<-summary(mg) ## best preds sr, ndwi, nbr2, nbr, nir
gam.check(mg)

mgmid<-gam(BA~s(red_mid ) + s(green_mid ) + s(nir_mid ) + s(evi_mid ) +
          s(kndvi_mid ) + s(nbr_mid ) + s(nbr2_mid ) +
          s(ndvi_mid ) + s(ndwi_mid ) + s(nirv_mid ) + s(sr_mid ) +
         s(Com_DesUO, k=5, bs="re"),
        data=j1, method="REML", select=TRUE, family="gaussian")

draw(mgmid)
smid<-summary(mgmid) ## best preds sr, ndvi, nbr2, nbr, nir
gam.check(mgmid)

## get the pvals for each model
names(smid)
midpv<-bind_cols(allindices, smid$s.pv[1:11]) #12 is com_des
names(midpv)<-c("index", "pvalue")
midpv$group<-"p < 0.001"
midpv[midpv$pvalue > 0.001, 3]<-"p > 0.001"

prepv<-bind_cols(allindices, spre$s.pv[1:11])
names(prepv)<-c("index", "pvalue")
prepv$group<-"p < 0.001"
prepv[prepv$pvalue > 0.001, 3]<-"p > 0.001"

## plot 
library(randomcoloR)
pal11<-distinctColorPalette(11)
ggscatter(midpv, x="index", y="pvalue", color="index",size=4, label="index", 
          palette=pal11,font.label=c(14, "black"), repel=TRUE, facet.by="group",
          xlab="", ylab="p-value", legend="none", 
          title="Mid-monsoon model: Common global smoother") + 
  theme(axis.text.x=element_blank(), 
        axis.ticks.x=element_blank()) +
  theme(strip.text.x = element_text(colour = "black", face = "bold", size=14))
#  ggpar(p, legend="none", legend.title="", xlab="", ylab="p-value",
 #     title="Mid-monsoon Model: Common global smoother")
ggsave("./plots/pvals_midmongam1.png")

ggscatter(prepv, x="index", y="pvalue", color="index",size=4, label="index", 
          palette=pal11,font.label=c(14, "black"), repel=TRUE, facet.by="group",
          xlab="", ylab="p-value", legend="none", 
          title="Pre-monsoon model: Common global smoother") + 
  theme(axis.text.x=element_blank(), 
        axis.ticks.x=element_blank()) +
  theme(strip.text.x = element_text(colour = "black", face = "bold", size=14))
#  ggpar(p, legend="none", legend.title="", xlab="", ylab="p-value",
 #     title="Mid-monsoon Model: Common global smoother")
ggsave("./plots/pvals_premongam1.png")
