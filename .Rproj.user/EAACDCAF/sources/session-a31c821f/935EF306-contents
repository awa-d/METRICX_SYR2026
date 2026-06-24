#==================================================
# METRICX - SYR 2026
# Phase 01 : nettoyage et fusion des données
# EHCVM Sénégal 2021
# Ménages, chocs et résilience : une lecture multidimensionnelle du Sénégal
#==================================================

#--------------------------------------------------
# 1. Packages
#--------------------------------------------------

library(haven)
library(dplyr)
library(labelled)
library(stringr)
library(purrr)
library(readr)
library(writexl)
library(readxl)
library(tidyr)
library(janitor)

#--------------------------------------------------
# 2. Chemins
#--------------------------------------------------

OUT <- "./data/clean"

#--------------------------------------------------
# 3. Import des bases
#--------------------------------------------------

welfare  <- read_xlsx(file.path(OUT, "welfare_keep.xlsx")) %>% clean_names()
menage   <- read_xlsx(file.path(OUT, "menage_keep.xlsx")) %>% clean_names()
indiv    <- read_xlsx(file.path(OUT, "indiv_keep.xlsx")) %>% clean_names()
conso    <- read_xlsx(file.path(OUT, "conso_keep.xlsx")) %>% clean_names()

#--------------------------------------------------
# 4. Vérification rapide des dimensions
#--------------------------------------------------

list(
  welfare = nrow(welfare),
  menage  = nrow(menage),
  indiv   = nrow(indiv),
  conso   = nrow(conso)
)

#--------------------------------------------------
# 5. Standardisation clé de fusion
#--------------------------------------------------

welfare <- welfare %>% mutate(hhid = as.character(hhid))
menage  <- menage %>% mutate(hhid = as.character(hhid))
indiv   <- indiv %>% mutate(hhid = as.character(hhid))
conso   <- conso %>% mutate(hhid = as.character(hhid))

#--------------------------------------------------
# 6. Diagnostic des NA par variable
#--------------------------------------------------

na_report <- function(df, name){
  data.frame(
    dataset = name,
    variable = names(df),
    nb_na = map_int(df, ~sum(is.na(.)))
  )
}

na_summary <- bind_rows(
  na_report(welfare, "welfare"),
  na_report(menage, "menage"),
  na_report(indiv, "indiv"),
  na_report(conso, "conso")
)

print(na_summary)

#--------------------------------------------------
# 7. Fusion sur hhid
#--------------------------------------------------

base_finale <- welfare %>%
  left_join(menage, by = "hhid") %>%
  left_join(indiv,  by = "hhid") %>%
  left_join(conso,  by = "hhid")


#--------------------------------------------------
# 8. IMPUTATION DES VARIABLES MANQUANTES
#--------------------------------------------------

base_finale <- base_finale %>%
  
  #------------------------------------------------
# SUPERFICIE : ménages non agricoles => 0
# (NA = menages non agricoles)
#------------------------------------------------
mutate(
  superf = ifelse(is.na(superf), 0, superf)
) %>%
  
  #------------------------------------------------
# RANCH_ACTIV_CM, CSP_CM, SECT_INST_CM
# NA = "non occupe"
# cohérent avec activ_12m_cm = "non occupe"
#------------------------------------------------
mutate(
  branche_activ_cm = ifelse(is.na(branche_activ_cm), "Non occupe", branche_activ_cm),
  csp_cm           = ifelse(is.na(csp_cm), "Non occupe", csp_cm),
  sect_inst_cm     = ifelse(is.na(sect_inst_cm), "Non occupe", sect_inst_cm)
)

#--------------------------------------------------
# 9. CONTROLE APRES IMPUTATION
#--------------------------------------------------

na_after_impute <- base_finale %>%
  summarise(across(everything(), ~sum(is.na(.)))) %>%
  tidyr::pivot_longer(cols = everything(),
                      names_to = "variable",
                      values_to = "nb_na") %>%
  arrange(desc(nb_na))


#--------------------------------------------------
# 10. Vérification après fusion
#--------------------------------------------------

cat("Dimensions base finale :\n")
print(dim(base_finale))

cat("\nNA globaux :\n")
print(colSums(is.na(base_finale)))

#--------------------------------------------------
# 11. Export
#--------------------------------------------------

write_xlsx(base_finale, file.path(OUT, "base_finale_metricx.xlsx"))
