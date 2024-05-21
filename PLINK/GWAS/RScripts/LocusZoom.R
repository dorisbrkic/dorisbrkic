library(tidyverse)
library(magrittr)
library(stringr)
library(ggplot2)
library(topr)
library(viridis) 
library(harrypotter)
library(writexl)
library(clusterProfiler)
library(data.table)

setwd("path")

results<-as.data.frame(fread("sev3_nohet_maf005_linear_results.assoc.linear", 
                             header=T, 
                             sep=" ", 
                             stringsAsFactors=FALSE))

#chr 1
ld_1 <- read.table("chr1_sev3_nohet_highLD.ld", 
                   header = T)

chr1 <- results %>%
  filter(CHR == 1) %>% 
  mutate(logP=log10(P)*(-1)) %>% 
  separate(SNP, c("dbSNP", "ClinVar"), ";")

joined_ld1 <- right_join(chr1, ld_1, 
                         by=c("BP"="BP_B")) %>% 
  dplyr::select(-c(CHR_A:SNP_B))

zoom1 <- locuszoom(joined_ld1, 
                   show_exons = T,
                   sign_thresh=10^(-5))
