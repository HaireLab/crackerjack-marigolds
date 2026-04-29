## random.sample.vars.R
## see which texture metrics / 'best' indices combos are the best predictors
## of basal area
## use a common global smoother
## see: Pederson et al. 2019, https://peerj.com/articles/6876/
## 1/18/2023
##
library(sf)
library(tidyr)
library(dplyr)
library(readr)
library(magrittr)
library(mgcv)
library(gratia)
library(ggplot2)
library(ggpubr)
library(tictoc)

## load the RData
load("~/Rfiles/rsmodels/processed_glcm_dataset_nbr_fixed.RData")

## variables
##indices that go w texture metrics--these were the best predictors from index models
preind = c("nbr", "nbr2", "ndwi")
midind = c("ndwi", "nbr2", "green", "sr")
allbest<-c("nbr", "nbr2", "ndwi", "green", "sr")
## texture metrics
metrics8 <- c("asm", "contrast", "corr", "diss", "ent", "idm", "savg", "var")
## thx Jess :)
tnames.mid <-levels(interaction(midind, metrics8, sep='_'))

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

#################### start w 1 pix, mid mon
mdat1mid <- df_wide %>% 
  dplyr::select(id, sample, monsoon_period, radius_px, all_of(tnames.mid), TPH, BA) %>% 
  filter(radius_px==1, sample=="yr1", monsoon_period=="mid") %>% 
   droplevels() 

## make a variable (col) for mid monsoon
x1<-pivot_wider(mdat1mid, names_from=monsoon_period, values_from=all_of(tnames.mid)) 
names(x1)[1]<-c("unique_id")

## join with field data
j1<-inner_join(newpt_df, x1, by=c("unique_id"))  #%>% 
  #dplyr:: select(c(1, 9,10,17:27)) ## 919 rows

## un-order 
j1$Com_Des<-as.factor(j1$Com_Des)
j1 <- transform(j1, Com_DesUO=factor(Com_Des, ordered=FALSE))
## all the variables
midvars<-names(j1[18:49])
#"re" # random effects smoother, k is always equal to factor levels
randeff="re" # this works w paste in formula
## run gam select=TRUE
## model 1: common global smoother
## levels=5 so k=5 for com_des
############################################
## loop to run multiple gams with different variable combos
tic()
for(i in 101:1000) {
## randomly select 10 vars from the 32 
vars10<-sample(midvars, 10)
## 
f1=as.formula(paste0("BA~",paste0("s(",vars10,")", 
 collapse="+"), " + s(Com_DesUO, k=5, bs=randeff)"))

m1<-gam(formula=f1, data=j1, method="REML", select=TRUE, family="gaussian")
#draw(m1)
sum1<-summary(m1)
 
## get the var names with pvals < 0.001 for each model
sumvals<-as_tibble(sum1$s.pv[1:10]); names(sumvals)<-"pvalue"
varnames<-as_tibble(vars10); names(varnames)<-"index"
pv<-bind_cols(varnames, sumvals) 
pv0<-pv[pv$pvalue < 0.001,]
pv0$id=paste("run", i, sep="")
write_csv(pv0, "./data/results_mid_1px.csv", append=TRUE)
print(i)
}
toc() # 4365 sec for 900 iterations



############ example
  data<- #yours data
use<-c(3:6,9:10)
dontuse<-c(1:2,7:8)
form<-as.formula(
 paste0("y~",paste0("s(x",use,")",collapse="+"),
        "+",paste0("x",dontuse,collapse="+"),collapse=""))
## see https://www.r-bloggers.com/2019/07/many-similar-models-part-2-automate-model-fitting-with-purrrmap-loops/

