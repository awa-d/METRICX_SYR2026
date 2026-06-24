#==================================================
# METRICX - SYR 2026
# Phase 00 : Préparation des données
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
#--------------------------------------------------
# 2. Chemins
#--------------------------------------------------

RAW <- "./data/raw"
OUT <- "./data/clean"

#--------------------------------------------------
# 3. Fonction : convertir les codes en labels
#--------------------------------------------------

to_labels <- function(df){
  
  df %>%
    mutate(
      across(
        where(is.labelled),
        ~ as_factor(.x)
      )
    )
  
}

#==================================================
# 4. IMPORTATION
#==================================================

welfare  <- read_dta(file.path(RAW, "ehcvm_welfare_SEN2021.dta"))
menage   <- read_dta(file.path(RAW, "ehcvm_menage_SEN2021.dta"))
individu <- read_dta(file.path(RAW, "ehcvm_individu_SEN2021.dta"))
conso    <- read_dta(file.path(RAW, "ehcvm_conso_SEN2021.dta"))

#==================================================
# 5. SELECTION VARIABLES - WELFARE
#==================================================

welfare_keep <- welfare %>%
  select(
    
    hhid,
    hhweight,
    region,
    milieu,
    
    "nationalite_cm"=hnation,
    "age_cm"=hage,
    "sexe_cm"=hgender,
    "situation_matri_cm"=hmstat,
    "taille_men"=hhsize,
    
    "niv_edu_cm"=heduc,
    "plus_haut_diplome_cm"=hdiploma,
    "alphabetise_cm"=halfa,
    "alphabetise_comp_cm"=halfa2,
    
    "activ_7j_cm"=hactiv7j,
    "activ_12m_cm"=hactiv12m,
    "branche_activ_cm"=hbranch,
    "csp_cm"=hcsp,
    "sect_inst_cm"=hsectins,
    
    dali,
    dnal,
    dtot,
    pcexp,
    zref
    
  ) %>%
  to_labels()
welfare_keep
#==================================================
# 6. SELECTION VARIABLES - MENAGE
#==================================================

menage_keep <- menage %>%
  select(
    
    hhid,
    
    # Actifs
    frigo,
    tv,
    ordin,
    car,
    fer,
    decod,
    cuisin,
    
    # Agriculture / élevage
    lapin,
    grosrum,
    petitrum,
    volail,
    porc,
    superf,
    
    # Logement
    mur,
    toit,
    sol,
    logem,
    
    # Services
    elec_ac,
    elec_ua,
    elec_ur,
    
    eauboi_sp,
    eauboi_ss,
    
    toilet,
    eva_eau,
    eva_toi,
    ordure,
    
    # Chocs
    sh_co_natu,
    sh_co_eco,
    sh_co_vio,
    sh_co_oth,
    sh_id_demo,
    sh_id_eco
    
  ) %>%
  to_labels()

#==================================================
# 7. SELECTION VARIABLES - INDIVIDU
#==================================================

individu_keep <- individu %>%
  select(
    
    hhid,
    
    bank,
    internet,
    telpor,
    
    handig,
    mal30j,
    hos12m
    
  ) %>%
  to_labels()

#==================================================
# 8. AGREGER AU NIVEAU MENAGE
#==================================================

indiv_hh <- individu_keep %>%
  group_by(hhid) %>%
  summarise(
    
    bank =
      ifelse(
        any(bank == "Oui", na.rm = TRUE),
        "Oui",
        "Non"
      ),
    
    internet =
      ifelse(
        any(internet == "Oui", na.rm = TRUE),
        "Oui",
        "Non"
      ),
    
    telpor =
      ifelse(
        any(telpor == "Oui", na.rm = TRUE),
        "Oui",
        "Non"
      ),
    
    nb_handicap_maj =
      sum(handig == "Oui", na.rm = TRUE),
    
    nb_malades_30j =
      sum(mal30j == "Oui", na.rm = TRUE),
    
    nb_hospitalisation_12m =
      sum(hos12m == "Oui", na.rm = TRUE),
    
    .groups = "drop"
    
  )

#==================================================
# 9. CONSOMMATION
#==================================================

conso_keep <- conso %>%
  select(
    
    hhid,
    codpr,
    modep,
    depan
    
  ) %>%
  to_labels()

table_conv <- read_excel("./outputs/tables/codpr_modalites.xlsx")

conso_poste <- conso_keep %>%
  left_join(table_conv, by = "codpr")

# vérifier les produits non classés
conso_poste %>%
  filter(is.na(poste_depense)) %>%
  distinct(codpr)

# agrégation
conso_wide <- conso_poste %>%
  group_by(hhid, poste_depense) %>%
  summarise(depense = sum(depan, na.rm = TRUE),
            .groups = "drop") %>%
  pivot_wider(
    names_from = poste_depense,
    values_from = depense,
    values_fill = 0 # les postes n'ayant pas fait objet de depense
  )
#==================================================
# 10. SAUVEGARDE DES BASES INTERMEDIAIRES
#==================================================

write_xlsx(
  welfare_keep,
  file.path(OUT, "welfare_keep.xlsx")
)

write_xlsx(
  menage_keep,
  file.path(OUT, "menage_keep.xlsx")
)

write_xlsx(
  indiv_hh,
  file.path(OUT, "indiv_keep.xlsx")
)

write_xlsx(
  conso_wide,
  file.path(OUT, "conso_keep.xlsx")
)

#==================================================
# 11. CONTROLE RAPIDE
#==================================================

cat("\n")
cat("=====================================\n")
cat("BASES PREPAREES\n")
cat("=====================================\n")

cat("Welfare :", nrow(welfare_keep), "ménages\n")
cat("Menage  :", nrow(menage_keep), "ménages\n")
cat("IndivHH :", nrow(indiv_hh), "ménages\n")
cat("Conso   :", nrow(conso_wide), "lignes\n")

cat("=====================================\n")