## plot.random.sample.results.R
## see random.sample.vars.R for model runs to output the data plotted and
## summarized here

library(ggplot2)
library(ggpubr)
library(readr)
library(tidyverse)
library(dplyr)
library(randomcoloR)
pal11<-distinctColorPalette(32)

## latest 
d<-read_csv("./data/results_texture.csv", col_names=FALSE)
names(d)<-c("variable", "pvalue", "season", "winsize", "run_num")
count_df<-d %>% group_by(variable) %>% count() %>% arrange(-n)  ## 22 out of 32 vars
write_csv(count_df, "./data/varcount1ksim_all.csv")
dmid1<-d %>% dplyr::filter(season=="mid", winsize==1) #%>% arrange(variable, max(pvalue))
dpre1<-d %>% dplyr::filter(season=="pre", winsize==1)
dmid2<-d %>% dplyr::filter(season=="mid", winsize==2) #%>% arrange(variable, max(pvalue))
dpre2<-d %>% dplyr::filter(season=="pre", winsize==2)
## plot
p<-ggboxplot(dmid1, x="variable", y="pvalue", orientation="horiz", 
             color="variable", add=c("mean_se"), add.params=list(color="black"),
          fill="variable", legend="none", xlab="", ylab="p-value", palette=pal11) + 
  geom_hline(yintercept=0.05) + geom_hline(yintercept=0.1)
ggpar(p, font.x=c(size=13), yticks.by=0.05, font.title=12, 
      #font.xtickslab=c(size=9), 
     # x.text.angle=90,
      main="p-values for mid-monsoon texture metrics, 3 x 3 window size\n1,000 model runs with 8 randomly selected predictors in each model")
ggsave("./plots/mid1px1kruns.png", width=11, height=10)

p<-ggboxplot(dpre1, x="variable", y="pvalue", orientation="horiz", 
             color="variable", add=c("mean_se"), add.params=list(color="black"),
          fill="variable", legend="none", xlab="", ylab="p-value", palette=pal11) + 
  geom_hline(yintercept=0.05) + geom_hline(yintercept=0.1)
ggpar(p, font.x=c(size=13), yticks.by=0.05, font.title=12, 
      #font.xtickslab=c(size=9), 
     # x.text.angle=90,
      main="p-values for pre-monsoon texture metrics, 3 x 3 window size\n1,000 model runs with 8 randomly selected predictors in each model")
ggsave("./plots/pre1px1kruns.png", width=11, height=10)

p<-ggboxplot(dmid2, x="variable", y="pvalue", orientation="horiz", 
             color="variable", add=c("mean_se"), add.params=list(color="black"),
          fill="variable", legend="none", xlab="", ylab="p-value", palette=pal11) + 
  geom_hline(yintercept=0.05) + geom_hline(yintercept=0.1)
ggpar(p, font.x=c(size=13), yticks.by=0.05, font.title=12, 
      #font.xtickslab=c(size=9), 
     # x.text.angle=90,
      main="p-values for mid-monsoon texture metrics, 5 x 5 window size\n1,000 model runs with 8 randomly selected predictors in each model")
ggsave("./plots/mid2px1kruns.png", width=11, height=10)

p<-ggboxplot(dpre2, x="variable", y="pvalue", orientation="horiz", 
             color="variable", add=c("mean_se"), add.params=list(color="black"),
          fill="variable", legend="none", xlab="", ylab="p-value", palette=pal11) + 
  geom_hline(yintercept=0.05) + geom_hline(yintercept=0.1)
ggpar(p, font.x=c(size=13), yticks.by=0.05, font.title=12, 
      #font.xtickslab=c(size=9), 
     # x.text.angle=90,
      main="p-values for pre-monsoon texture metrics, 5 x 5 window size\n1,000 model runs with 8 randomly selected predictors in each model")

ggsave("./plots/pre2px1kruns.png", width=11, height=10)

#####################
ggbarplot(count_df, x="variable", y="n", orientation="horiz", color="variable",
          fill="variable",legend="none", xlab="", ylab="p < 0.001 (times per 1,000 model runs)")
ggsave("./plots/mid1px1kruns.png")

ggbarplot(count_df, x="variable", y="n", orientation="horiz", color="variable",
          fill="variable",legend="none", xlab="", ylab="p < 0.001 (times per 1,000 model runs)")


