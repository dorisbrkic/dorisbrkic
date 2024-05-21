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

#imputed
imp_nov <- readxl::read_xlsx("192_patients_continuous_imputed_november.xlsx", sheet = "cont_imputed")

dodatne_hl <- readxl::read_xlsx("all_patients_continuous_imputed_november.xlsx", sheet = "general") %>% 
  as_tibble() %>% 
  dplyr::select(IID, severity.nov.coded3) %>% 
  filter(IID %in% imp_nov$IID)

cont <- full_join(dodatne_hl, imp_nov) %>% 
  na.omit() %>% 
  mutate(Severity=case_when(severity.nov.coded3==1 ~ "Moderate",
                            severity.nov.coded3==2 ~ "Severe",
                            severity.nov.coded3==3 ~ "Critical"),
         Severity=factor(Severity, levels=c("Moderate", "Severe", "Critical"))) %>% 
  dplyr::select(-severity.nov.coded3, -IID, -PR) %>% 
  rename("ALP"="ALP_U/L", "ALT"="ALT_U/L", 
        "APTV"="APTV_s", "AST"="AST_U/L", 
        "Albumin"="Albumin_g/L",
        "Antithrombin"="Antitrombin_%",
        "BE"="BE_µmol/L",
        "Basophils (proportion)"="Bazofilni_granulociti_%", "Basophils (count)"="Bazofilni_granulociti_x10^9/L", 
        "Bilirubin (conjugated)"="Bilirubin_k_µmol/L", "Bilirubin (total)"="Bilirubin_uk_µmol/L", 
        "C3"="C3_g/L", "C4"="C4_g/L", 
        "CRP"="CRP_mg/L", "Ca (total)"="Ca_uk_µmol/L", 
        "Cl"="Cl_µmol/L", "D-dimer"="D_dimeri_µg/L_FEU", 
        "Erythrocyte (count)"="Eritrociti_x10^12/L", "Fe"="Fe_µmol/L", 
        "Ferritin"="Feritin_µg/L", "Fibrinogen"="Fibrinogen_g/L", 
        "GGT"="GGT_U/L", "Glucose"="Glukoza_µmol/L", 
        "HCO3"="HCO3_µmol/L", "HDL"="HDL_µmol/L", 
        "HbA1c"="HbA1c_%", "Hematocrit"="Hematokrit_L/L", 
        "Hemoglobin"="Hemoglobin_g/L", "IL-6"="IL-6_pg/mL", 
        "IgA"="IgA_g/L", "IgG"="IgG_g/L", 
        "IgM"="IgM_g/L", "K"="K_µmol/L", 
        "Creatinine"="Kreatinin_µmol/L", "LDL"="LDL_µmol/L","LD"="LD_U/L", 
        "Leukocytes (count)"="Leukociti_x10^9/L", "Lymphocytes (count)"="Limfociti_x10^9/L", 
        "MCHC"="MCHC_g/L", "MCH"="MCH_pg", 
        "MCV"="MCV_fL", "MGF"="MGF_mol/L", 
        "MPV"="MPV_fL", "Na"="Na_µmol/L", 
        "Neutrophils/Lymphocytes"="Neutro/Limfo", "Neutrophils (count)"="Neutrofilni_granulociti_x10^9/L", 
        "O2 (saturation)"="O2_%", "PCT"="PCT_µg/L", 
        "PV"="PV_%", "RDW"="RDW_%", "RF"="RF_IU/mL", "TIBC"="TIBC_µmol/L", 
        "TSH"="TSH_mU/L", "Triglycerides"="Trigliceridi_µmol/L", "Thrombocytes (count)"="Trombociti_x10^9/L", 
        "Troponin I"="Troponin_I_ng/L", "UIBC"="UIBC_µmol/L", 
        "Proteins (total)"="Ukupni_proteini_g/L", "Urate"="Urati_µmol/L", 
        "Urea"="Urea_µmol/L", "Pulse frequency"="fren.pulsa", 
        "pCO2"="pCO2_kPa", "pH"="pH", 
        "pO2"="pO2_kPa", "Protein C"="protein_C_%",
        "Protein S"="protein_S_%",
        "NT-proBNP"="NT-proBNP_pg/mL")


#referentni intervali
ref <- readxl::read_xlsx("referentni_intervali.xlsx") %>% 
  as_tibble() %>% 
  relocate(max_L, .before = min_H) %>% 
  na.omit() %>% 
  unite("Reference interval", c("max_L", "min_H"), sep="-")


a1 <- readxl::read_xlsx("imena_referentni_intervali.xlsx")

table2 <- full_join(ref, a1) %>% 
  dplyr::select(Characteristic, `Measuring unit`, `Reference interval`) %>% 
  rename(variable =Characteristic)

table1 <- cont %>% 
  gtsummary::tbl_summary(by=Severity) %>% 
  modify_table_body(
      ~ .x %>%        
        full_join(., table2, by="variable")) %>% 
  modify_column_unhide(c("Reference interval", "Measuring unit")) %>% 
  modify_table_body(~.x %>% dplyr::relocate("Measuring unit", .after = label) %>% 
                      arrange(label)) %>% 
  modify_header(label="Biochemical measurement") %>% 
  modify_spanning_header(all_stat_cols() ~ "Severity")
 
table1 %>% 
  as_gt() %>% 
  gt::gtsave("biochemistry_intervals_methods.docx")
