# ==============================================================================
# METRICX — Show Your Research 2026 — ENSAE Dakar
# PHASE 1 : CADRAGE & ARCHITECTURE DES DONNÉES
# Auteur   : Membre 1 (Data & Analyses statistiques)
# Date     : J1 → J2
# ==============================================================================

# ── 0. PACKAGES ───────────────────────────────────────────────────────────────

library(haven)
library(tidyverse)
library(janitor)
library(skimr)
library(labelled)


# ── 1. ARCHITECTURE DES RÉPERTOIRES ───────────────────────────────────────────

PROJET_ROOT <- "./"

dirs <- c("data/raw", "data/clean", "outputs/tables",
          "outputs/figures", "outputs/maps", "scripts", "documenation","docs")

for (d in dirs) {
  path <- file.path(PROJET_ROOT, d)
  if (!dir.exists(path)) dir.create(path, recursive = TRUE)
  cat("✔", d, "\n")
}
cat("\nArchitecture des dossiers créée.\n")


# ── 2. CHEMINS DES BASES EHCVM 2021 ───────────────────────────────────────────

PATH_RAW <- file.path(PROJET_ROOT, "data/raw")

noms_bases <- c(
  welfare  = "ehcvm_welfare_SEN2021.dta",
  menage   = "ehcvm_menage_SEN2021.dta",
  individu = "ehcvm_individu_SEN2021.dta",
  conso    = "ehcvm_conso_SEN2021.dta", 
  ponderations = "ehcvm_ponderations_SEN2021.dta"
)


# ── 3. DICTIONNAIRE DES VARIABLES RETENUES ────────────────────────────────────

variables_projet <- tribble(
  ~bloc,            ~variable,     ~base,       ~label_fr,                                  ~type,

  # Identifiants / Géographie
  "ID",             "hhid",        "welfare",   "Identifiant ménage",                       "ID",
  "ID",             "region",      "welfare",   "Région (1–14)",                            "categ",
  "ID",             "milieu",      "welfare",   "Milieu (1=Urbain / 2=Rural)",              "categ",

  # Variable dépendante
  "Dépendante",     "dali",        "welfare",   "Dépenses alimentaires (FCFA)",             "continue",
  "Dépendante",     "dtot",        "welfare",   "Dépenses totales (FCFA)",                  "continue",
  "Dépendante",     "pcexp",       "welfare",   "Dépenses per capita (FCFA)",               "continue",

  # Démographie CM
  "Démographie",    "hhsize",      "welfare",   "Taille du ménage",                         "continue",
  "Démographie",    "hgender",     "welfare",   "Sexe du CM (1=Homme / 2=Femme)",           "categ",
  "Démographie",    "hage",        "welfare",   "Âge du CM",                                "continue",
  "Démographie",    "hmstat",      "welfare",   "Situation matrimoniale CM",                "categ",

  # Capital humain CM
  "Capital humain", "heduc",       "welfare",   "Niveau scolaire CM",                       "categ",
  "Capital humain", "hdiploma",    "welfare",   "Diplôme le plus élevé CM",                "categ",
  "Capital humain", "halfa",       "welfare",   "Alphabétisation CM (1=Oui)",               "binaire",

  # Activité économique CM
  "Économique",     "hactiv7j",    "welfare",   "Statut activité CM (7 derniers jours)",    "categ",
  "Économique",     "hactiv12m",   "welfare",   "Statut activité CM (12 derniers mois)",    "categ",
  "Économique",     "hbranch",     "welfare",   "Branche d'activité CM",                    "categ",
  "Économique",     "hcsp",        "welfare",   "CSP du CM",                                "categ",

  # Conditions de vie (base ménage)
  "Conditions vie", "elec_ac",     "menage",    "Accès électricité (1=Oui)",                "binaire",
  "Conditions vie", "eauboi_sp",   "menage",    "Eau potable saison sèche (1=Oui)",         "binaire",
  "Conditions vie", "eauboi_ss",   "menage",    "Eau potable saison pluies (1=Oui)",        "binaire",
  "Conditions vie", "toilet",      "menage",    "Type de toilettes",                        "categ",
  "Conditions vie", "mur",         "menage",    "Matériau des murs",                        "categ",
  "Conditions vie", "toit",        "menage",    "Matériau du toit",                         "categ",
  "Conditions vie", "sol",         "menage",    "Matériau du sol",                          "categ",
  "Conditions vie", "logem",       "menage",    "Type de logement",                         "categ",
  "Conditions vie", "ordure",      "menage",    "Mode d'évacuation des ordures",            "categ",

  # Équipements ménage
  "Équipements",    "tv",          "menage",    "Possession télévision (1=Oui)",            "binaire",
  "Équipements",    "frigo",       "menage",    "Possession réfrigérateur (1=Oui)",         "binaire",
  "Équipements",    "ordin",       "menage",    "Possession ordinateur (1=Oui)",            "binaire",

  # Agriculture (base ménage)
  "Agriculture",    "superf",      "menage",    "Superficie agricole cultivée (ha)",        "continue",
  "Agriculture",    "grosrum",     "menage",    "Nombre de gros ruminants",                 "continue",
  "Agriculture",    "petitrum",    "menage",    "Nombre de petits ruminants",               "continue",
  "Agriculture",    "volail",      "menage",    "Nombre de volailles",                      "continue",
  "Agriculture",    "porc",        "menage",    "Nombre de porcs",                          "continue",
  "Agriculture",    "lapin",       "menage",    "Nombre de lapins",                         "continue",

  # Chocs (base ménage)
  "Chocs",          "sh_co_eco",   "menage",    "Choc économique communautaire (1=Oui)",    "binaire",
  "Chocs",          "sh_co_natu",  "menage",    "Choc naturel communautaire (1=Oui)",       "binaire",
  "Chocs",          "sh_co_vio",   "menage",    "Choc violence communautaire (1=Oui)",      "binaire",
  "Chocs",          "sh_co_oth",   "menage",    "Autre choc communautaire (1=Oui)",         "binaire",
  "Chocs",          "sh_id_eco",   "menage",    "Choc économique idiosyncrasique (1=Oui)",  "binaire",
  "Chocs",          "sh_id_demo",  "menage",    "Choc démographique idiosyncrasique (1=Oui)","binaire",

  # Capital humain (base individu — agrégé ménage)
  "Individu",       "internet",    "individu",  "Accès internet individu (1=Oui)",          "binaire",
  "Individu",       "telpor",      "individu",  "Possession téléphone portable (1=Oui)",    "binaire",
  "Individu",       "age",         "individu",  "Âge de l'individu",                        "continue",
  "Individu",       "sexe",        "individu",  "Sexe de l'individu",                       "categ",
  "Individu",       "educ_hi",     "individu",  "Niveau scolaire le plus élevé",            "categ",
  "Individu",       "scol",        "individu",  "Actuellement scolarisé (1=Oui)",           "binaire",
  "Individu",       "alfa",        "individu",  "Alphabétisation individu (1=Oui)",         "binaire",

  # Consommation (base conso)
  "Consommation",   "codpr",       "conso",     "Code produit alimentaire",                 "categ",
  "Consommation",   "modep",       "conso",     "Mode d'acquisition du produit",            "categ",
  "Consommation",   "depan",       "conso",     "Dépense annuelle pour le produit (FCFA)",  "continue"
)

cat("\n── Variables du projet (", nrow(variables_projet), "variables) ──\n")
print(variables_projet %>% select(bloc, variable, base, label_fr))

write_csv(variables_projet,
          file.path(PROJET_ROOT, "docs", "dictionnaire_variables_v1.csv"))
cat("\n✅ Dictionnaire exporté → docs/dictionnaire_variables_v1.csv\n")


# ── 4. PIPELINE ANALYTIQUE ────────────────────────────────────────────────────

pipeline <- tribble(
  ~phase,    ~etape,                          ~script,                         ~livrable,
  "Phase 2", "Nettoyage & fusion",            "01_PHASE2_data_management.R",   "base_analytique_finale.rds",
  "Phase 3", "Analyse descriptive",           "02_PHASE3_analyse_descriptive.R","tableaux + figures V1",
  "Phase 4", "ACP & indice IVSA",             "03_PHASE4_acp_ivsa.R",          "scores IVSA + cercle corr.",
  "Phase 4", "Clustering",                    "04_PHASE4_clustering.R",        "profils clusters",
  "Phase 5", "Régression logistique",         "05_PHASE5_logit.R",             "odds ratios + forest plot",
  "Phase 6", "Cartographie",                  "06_PHASE6_cartographie.R",      "cartes HD"
)

write_csv(pipeline,
          file.path(PROJET_ROOT, "docs", "pipeline_analytique.csv"))
cat("✅ Pipeline exporté → docs/pipeline_analytique.csv\n")


# ── 5. PARAMÈTRES GLOBAUX ─────────────────────────────────────────────────────
# Chargés par tous les scripts via readRDS()

PARAMS <- list(
  # Chemins
  projet_root = PROJET_ROOT,
  path_raw    = file.path(PROJET_ROOT, "data/raw"),
  path_clean  = file.path(PROJET_ROOT, "data/clean"),
  path_figs   = file.path(PROJET_ROOT, "output/figures"),
  path_tabs   = file.path(PROJET_ROOT, "output/tables"),
  path_maps   = file.path(PROJET_ROOT, "output/maps"),

  # Clé de fusion
  id_fusion   = "hhid",

  # Variable dépendante construite
  var_dep     = "part_alim",

  # Seuil de vulnérabilité alimentaire
  seuil_vuln  = 0.60,

  # Nombre de clusters
  k_clusters  = 4,

  # Graine aléatoire (reproductibilité)
  seed        = 2026,

  # Palette METRICX (cohérente poster)
  couleurs    = c(
    primaire = "#1A3C5E",
    accent   = "#E8A020",
    vert     = "#2E7D52",
    rouge    = "#B03020",
    violet   = "#7B3F9E",
    gris     = "#6B7E8F"
  ),

  # Labels régions Sénégal (codes 1–14)
  regions     = c(
    "1"  = "Dakar",       "2"  = "Ziguinchor",
    "3"  = "Diourbel",    "4"  = "Saint-Louis",
    "5"  = "Tambacounda", "6"  = "Kaolack",
    "7"  = "Thiès",       "8"  = "Louga",
    "9"  = "Fatick",      "10" = "Kolda",
    "11" = "Matam",       "12" = "Kaffrine",
    "13" = "Kédougou",    "14" = "Sédhiou"
  )
)

saveRDS(PARAMS, file.path(PROJET_ROOT, "docs", "params_projet.rds"))
cat("✅ Paramètres globaux sauvegardés → docs/params_projet.rds\n")

cat("\n", strrep("=", 60), "\n")
cat("✅ PHASE 1 TERMINÉE\n")
cat("→ Lancer ensuite : 01_PHASE2_data_management.R\n")
cat(strrep("=", 60), "\n")

