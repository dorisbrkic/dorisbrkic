library(readxl)
library(tidyverse)
library(data.table)
library(ggplot2)
library(stringr)
library(magrittr)
library(gridExtra)
library(gtsummary)
library(gt)

setwd("path")
######################
imp_nov <- readxl::read_xlsx("192_patients_continuous_imputed_november.xlsx", sheet = "cont_imputed")

dodatne_hl <- readxl::read_xlsx("all_patients_continuous_imputed_november.xlsx", sheet = "general") %>% 
  as_tibble() %>% 
  filter(IID %in% imp_nov$IID) %>% 
  dplyr::select(IID, severity.nov.coded3, outcome, pneumonia, fren_disanja, pulmonary_distress_failure, sepsis, respirator)

sever <- full_join(dodatne_hl, imp_nov %>% dplyr::select(IID, `O2_%`)) %>% 
  na.omit() %>% 
  mutate(Severity=case_when(severity.nov.coded3==1 ~ "Moderate",
                            severity.nov.coded3==2 ~ "Severe",
                            severity.nov.coded3==3 ~ "Critical"),
         Severity=factor(Severity, levels=c("Moderate", "Severe", "Critical")),
         fren_disanja=str_replace(fren_disanja, "3", "1"),
         "Breathing frequency - high"=as.numeric(fren_disanja),
         "Outcome - died"=case_when(outcome == 1 ~ 0,
                                    outcome == 0 ~ 1)) %>% 
  dplyr::select(-severity.nov.coded3, -IID, -fren_disanja, -outcome) %>% 
  rename("Pneumonia - yes"=pneumonia, "Pulmonary distress failure - yes"=pulmonary_distress_failure, "Sepsis - yes" = sepsis, "Respirator - yes"=respirator, "O2 saturation (%)"="O2_%")

sever %>% 
  tbl_summary(by=Severity) %>% 
  as_gt %>% 
  gt::gtsave("severity_variables.png")
