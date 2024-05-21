library(tidyverse)
library(data.table)
library(magrittr)
library(stringr)
library(ggplot2)
library(writexl)
library(vcfR)
library(nnet)
library(broom)
library(car)
library(purrr)
library(readxl)
library(gtsummary)
library(RVAideMemoire)
library(gt)
library(survival)
library(dplyr)
library(forcats)
library(tidyr)
library(ggpubr)

setwd("path")

#191 osoba
indiv<- fread("rows191_cols_covsnps26971.csv") %>% as_tibble() %>% dplyr::select(1,2)

#general
general <- read_xlsx("master_table.xlsx", sheet = 2, range = "A1:P259") %>% 
  as_tibble() %>%  
  left_join(indiv, .) %>% 
  dplyr::select(1,5:12) 

#general + comorbidities
general_comorb <- read_xlsx("C:/Users/Doris/OneDrive - Prirodoslovno-matematički fakultet/COV_HOST_SEQ/master_table.xlsx", sheet = "comorbidities", range = "A1:P193") %>% 
  as_tibble() %>% 
  left_join(general, .) %>% 
  mutate(Cardiovascular=hypertension + vascular_disease,
         Respiratory=pulmonary_disease,
         Metabolic= diabetes + thyroid_disease + anemia,
         Other = kidney_disease + digestive_disease + cancer) %>% 
  dplyr::select(1,8,7,3,6, 25:28)

#severity
severity_table <- general_comorb %>% 
  tbl_summary(by=Severity) %>% 
  add_overall() %>% 
  add_p() %>% 
  tbl_stack()
  as_gt %>% 
  gt::gtsave("severity_table_stat.png")

#########################################
#plots
ggplot(general, aes(x=Severity, fill=Sex)) + 
  geom_bar(position = "dodge") +
  geom_text(stat='count', aes(label = ..count..), vjust = -0.2, position = position_dodge(.9)) +
  facet_grid(.~Outcome) +
  xlab("") +
  theme_pubr() +
  scale_fill_manual(values = c("#dd8b8b", "#202c8d"))

my_comparisons <- list( c("Moderate", "Severe"), c("Severe", "Critical"), c("Moderate", "Critical") )
ggplot(general, aes(y=Age, x=Severity, fill=Severity)) + 
  geom_boxplot() +
  stat_compare_means(comparisons = my_comparisons)+ # Add pairwise comparisons p-value
  stat_compare_means(label.y = 100) +
  facet_grid(.~Sex) +
  xlab("") +
  theme_pubr() +
  guides(fill=F) +
  scale_fill_manual(values = c("#fcc826", "#e87056", "#d44842"))+
  theme(strip.text = element_text(face = "bold"),
        strip.background = element_rect(fill = c("#d1d492")))

ggplot(general, aes(y=days.in.hospital, x=Severity, fill=Severity)) + 
  geom_boxplot() +
  stat_compare_means(comparisons = my_comparisons)+ # Add pairwise comparisons p-value
  stat_compare_means(label.y = 115)  +
  facet_grid(.~Sex) +
  ylab("Days in hospital") +
  xlab("") +
  theme_pubr() +
  guides(fill=F) +
  scale_fill_manual(values = c("#fcc826", "#e87056", "#d44842"))+
  theme(strip.text = element_text(face = "bold"),
        strip.background = element_rect(fill = c("#d1d492")))
