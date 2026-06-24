# ==============================================================================
# METRICX — Show Your Research 2026 — ENSAE Dakar
# PHASE 2 : DATA MANAGEMENT — Nettoyage, Fusion, Construction des indicateurs
# Auteur   : Membre 1 (Data & Analyses statistiques)
# Date     : J3 → J6
# ==============================================================================
# Variables vérifiées sur les vraies bases EHCVM 2021 Sénégal
# ==============================================================================


# ── 0. SETUP ──────────────────────────────────────────────────────────────────

library(haven)
library(tidyverse)
library(janitor)
library(skimr)
library(labelled)

# Charger les paramètres globaux (créés en Phase 1)
PROJET_ROOT <- "./"
PARAMS      <- readRDS(file.path(PROJET_ROOT, "docs", "params_projet.rds"))

RAW   <- PARAMS$path_raw
CLEAN <- PARAMS$path_clean
TABS  <- PARAMS$path_tabs
set.seed(PARAMS$seed)

cat("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
cat("  METRICX — PHASE 2 : DATA MANAGEMENT\n")
cat("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n")


# ── 1. IMPORT DES BASES ───────────────────────────────────────────────────────

cat("── Étape 1 : Import ──\n")

import_base <- function(chemin, nom) {
  cat("  Lecture :", nom, "...")
  if (!file.exists(chemin)) stop("\n  ✘ Fichier introuvable : ", chemin)
  df <- read_dta(chemin) %>% clean_names()
  cat(" OK —", format(nrow(df), big.mark = " "), "obs ×", ncol(df), "vars\n")
  df
}

welfare  <- import_base(file.path(RAW, "ehcvm_welfare_SEN2021.dta"),  "welfare")
menage   <- import_base(file.path(RAW, "ehcvm_menage_SEN2021.dta"),   "menage")
individu <- import_base(file.path(RAW, "ehcvm_individu_SEN2021.dta"), "individu")
conso    <- import_base(file.path(RAW, "ehcvm_conso_SEN2021.dta"),    "conso")


# ── 2. NETTOYAGE BASE WELFARE ─────────────────────────────────────────────────
# Variables disponibles :
# country, dali, dnal, dtot, grappe, hactiv7j, hactiv12m, hage, halfa, halfa2,
# hbranch, hcsp, hdiploma, heduc, hgender, hhandig, hhid, hhsize, hhweight,
# hmstat, hnation, hreligion, hsectins, menage, milieu, pcexp, region, vague,
# year, zref

cat("\n── Étape 2 : Nettoyage welfare ──\n")

welfare_clean <- welfare %>%

  select(
    hhid, region, milieu, hhsize, hhweight,
    hgender, hage, hmstat,
    heduc, hdiploma, halfa, halfa2,
    hactiv7j, hactiv12m, hbranch, hcsp, hsectins,
    dali, dtot, dnal, pcexp, zref
  ) %>%

  distinct(hhid, .keep_all = TRUE) %>%

  mutate(
    # ── Milieu
    milieu_f = factor(milieu, levels = c(1, 2), labels = c("Urbain", "Rural")),

    # ── Sexe CM
    hgender_f = factor(hgender, levels = c(1, 2), labels = c("Homme", "Femme")),
    cm_femme  = as.integer(hgender == 2),

    # ── Éducation CM (regroupement en 4 niveaux)
    # heduc : 0=Aucun, 1=Préscolaire, 2=Primaire, 3=Secondaire 1er,
    #         4=Secondaire 2nd, 5=Supérieur  (vérifier dans le dico officiel)
    heduc_grp = case_when(
      heduc == 0            ~ "Aucun",
      heduc %in% c(1, 2)   ~ "Primaire",
      heduc %in% c(3, 4)   ~ "Secondaire",
      heduc >= 5            ~ "Supérieur",
      TRUE                  ~ NA_character_
    ),
    heduc_grp  = factor(heduc_grp,
                        levels = c("Aucun", "Primaire", "Secondaire", "Supérieur")),
    score_educ = as.integer(heduc_grp) - 1L,   # 0, 1, 2, 3

    # ── Alphabétisation (binaire propre)
    halfa_bin = as.integer(halfa == 1),

    # ── Activité CM : actif (occupé) vs non-actif
    # hactiv7j : 1=Occupe, 2=Chômeur cherche emploi, 3=Chômeur découragement,
    #            4=Inactif élève, 5=Retraité, 6=Femme au foyer, 7=Autre inactif
    cm_actif = as.integer(hactiv7j == 1),

    # ── Correction valeurs aberrantes dépenses
    dali  = if_else(dali  <= 0,               NA_real_, as.numeric(dali)),
    dtot  = if_else(dtot  <= 0 | dtot < dali, NA_real_, as.numeric(dtot)),
    pcexp = if_else(pcexp <= 0,               NA_real_, as.numeric(pcexp)),

    # ── VARIABLE DÉPENDANTE PRINCIPALE : part alimentaire
    part_alim = dali / dtot,
    part_alim = if_else(part_alim > 1 | part_alim < 0, NA_real_, part_alim),

    # ── Indicateur de vulnérabilité (seuil 60%)
    vuln_alim = as.integer(part_alim > PARAMS$seuil_vuln),

    # ── Pauvreté monétaire (zref = seuil de pauvreté officiel)
    pauvre = as.integer(pcexp < zref),

    # ── Log dépenses (réduire asymétrie pour l'ACP)
    log_pcexp = log1p(pcexp),
    log_dtot  = log1p(dtot),

    # ── Taille ménage winsorisée (plafond 99e percentile)
    hhsize_w = pmin(hhsize, quantile(hhsize, 0.99, na.rm = TRUE))
  ) %>%

  filter(!is.na(hhid), !is.na(part_alim))

cat("  welfare_clean :", nrow(welfare_clean), "obs\n")
cat("  Part alim — moyenne :",
    round(mean(welfare_clean$part_alim, na.rm = TRUE) * 100, 1), "%\n")
cat("  Vulnérabilité (> 60%) :",
    round(mean(welfare_clean$vuln_alim, na.rm = TRUE) * 100, 1), "%\n")
cat("  Pauvreté monétaire    :",
    round(mean(welfare_clean$pauvre, na.rm = TRUE) * 100, 1), "%\n")


# ── 3. NETTOYAGE BASE MENAGE ──────────────────────────────────────────────────
# Variables disponibles confirmées :
# car, country, cuisin, decod, eauboi_sp, eauboi_ss, elec_ac, elec_ua, elec_ur,
# eva_eau, eva_toi, fer, frigo, grappe, grosrum, hhid, lapin, logem, menage,
# mur, ordin, ordure, petitrum, porc, sh_co_eco, sh_co_natu, sh_co_oth,
# sh_co_vio, sh_id_demo, sh_id_eco, sol, superf, toilet, toit, tv, vague,
# volail, year

cat("\n── Étape 3 : Nettoyage menage ──\n")

menage_clean <- menage %>%

  select(
    hhid,
    # Conditions de vie
    elec_ac, eauboi_sp, eauboi_ss, toilet, mur, toit, sol, logem,
    ordure, eva_eau, eva_toi,
    # Équipements
    tv, frigo, ordin, fer, car,
    # Agriculture
    superf, grosrum, petitrum, volail, porc, lapin,
    # Chocs
    sh_co_eco, sh_co_natu, sh_co_vio, sh_co_oth,
    sh_id_eco, sh_id_demo
  ) %>%

  distinct(hhid, .keep_all = TRUE) %>%

  mutate(
    # ── Binaires conditions de vie (1=Oui déjà dans les bases)
    elec_ac   = as.integer(elec_ac   == 1),
    eauboi_sp = as.integer(eauboi_sp == 1),
    eauboi_ss = as.integer(eauboi_ss == 1),

    # ── Équipements (binaires)
    tv    = as.integer(tv    == 1),
    frigo = as.integer(frigo == 1),
    ordin = as.integer(ordin == 1),
    car   = as.integer(car   == 1),

    # ── Index de conditions de vie (0–5 : élec + eau_sp + eau_ss + tv + frigo)
    index_vie = elec_ac + eauboi_sp + eauboi_ss + tv + frigo,

    # ── Superficie : corriger valeurs aberrantes (> 200 ha improbable)
    superf = if_else(superf > 200, NA_real_, as.numeric(superf)),
    # Superficie 0 pour ménages non-agricoles
    superf_c = replace_na(superf, 0),

    # ── Bétail : NA → 0 (ménage sans animaux)
    grosrum  = replace_na(as.numeric(grosrum),  0),
    petitrum = replace_na(as.numeric(petitrum), 0),
    volail   = replace_na(as.numeric(volail),   0),
    porc     = replace_na(as.numeric(porc),     0),
    lapin    = replace_na(as.numeric(lapin),    0),

    # ── Score de capital animal (UBT simplifié)
    # 1 gros ruminant = 1 UBT, 1 petit rum = 0.1, 1 volaille = 0.01
    ubt = grosrum * 1 + petitrum * 0.1 + volail * 0.01,

    # ── Ménage agricole : cultive OU possède du bétail
    actif_agri = as.integer(superf_c > 0 | grosrum > 0 |
                              petitrum > 0 | volail > 0),

    # ── Chocs : binaires propres
    across(c(sh_co_eco, sh_co_natu, sh_co_vio, sh_co_oth,
             sh_id_eco, sh_id_demo),
           ~as.integer(. == 1)),

    # ── Nombre total de chocs subis (0–6)
    nb_chocs = sh_co_eco + sh_co_natu + sh_co_vio + sh_co_oth +
               sh_id_eco + sh_id_demo,
    choc_bin = as.integer(nb_chocs > 0)
  ) %>%

  filter(!is.na(hhid))

cat("  menage_clean :", nrow(menage_clean), "obs\n")
cat("  Ménages agricoles :",
    round(mean(menage_clean$actif_agri) * 100, 1), "%\n")
cat("  Ménages avec au moins un choc :",
    round(mean(menage_clean$choc_bin) * 100, 1), "%\n")


# ── 4. NETTOYAGE BASE INDIVIDU → AGRÉGATION MÉNAGE ───────────────────────────
# Variables disponibles confirmées :
# activ7j, activ12m, aff30j, age, agemar, alfa, alfa2, arrmal, bank, branch,
# con30j, country, couvmal, csp, csp_sec, diplome, durarr, educ_hi, educ_scol,
# grappe, handig, handit, hhid, hhweight, hos12m, internet, lien, mal30j,
# menage, milieu, moustiq, mstat, nation, numind, persconsult, region, salaire,
# salaire_sec, scol, sectins, sectins_sec, serviceconsult, sexe, telpor,
# vague, volhor, volhor_sec, year, resid

cat("\n── Étape 4 : Nettoyage & agrégation individu ──\n")

individu_agg <- individu %>%

  select(hhid, age, sexe, lien, educ_hi, scol, alfa,
         internet, telpor, activ7j, bank, handig) %>%

  group_by(hhid) %>%
  summarise(
    # Taille réelle depuis individu (vérification)
    n_membres     = n(),

    # Ratio de dépendance : (< 15 ans + > 64 ans) / (15–64 ans)
    n_dep         = sum(age < 15 | age > 64, na.rm = TRUE),
    n_actifs_age  = sum(age >= 15 & age <= 64, na.rm = TRUE),
    ratio_dep     = if_else(n_actifs_age > 0,
                            n_dep / n_actifs_age, NA_real_),

    # Nombre d'enfants < 5 ans
    nb_enf5       = sum(age < 5, na.rm = TRUE),

    # Présence de personnes âgées (> 64 ans)
    presences_pa  = as.integer(any(age > 64, na.rm = TRUE)),

    # Part de membres alphabétisés
    pct_alfa      = mean(replace_na(as.integer(alfa == 1), 0),
                         na.rm = TRUE),

    # Part de membres scolarisés (enfants)
    pct_scol      = mean(replace_na(as.integer(scol == 1), 0),
                         na.rm = TRUE),

    # Part avec accès internet
    pct_internet  = mean(replace_na(as.integer(internet == 1), 0),
                         na.rm = TRUE),

    # Part avec téléphone portable
    pct_telpor    = mean(replace_na(as.integer(telpor == 1), 0),
                         na.rm = TRUE),

    # Part avec compte bancaire
    pct_bank      = mean(replace_na(as.integer(bank == 1), 0),
                         na.rm = TRUE),

    # Présence d'un handicapé dans le ménage
    presence_handig = as.integer(any(handig == 1, na.rm = TRUE)),

    .groups = "drop"
  ) %>%
  filter(!is.na(hhid))

cat("  individu_agg :", nrow(individu_agg), "ménages\n")
cat("  Ratio dépendance moyen :",
    round(mean(individu_agg$ratio_dep, na.rm = TRUE), 2), "\n")


# ── 5. NETTOYAGE BASE CONSO → SCORE DIVERSITÉ ALIMENTAIRE ────────────────────
# Variables disponibles confirmées :
# country, year, hhid, vague, grappe, menage, region, milieu,
# hhweight, codpr, modep, depan
#
# codpr = code produit (ex : 1=céréales, 2=viandes, etc.)
# depan = dépense annuelle pour ce produit
# On construit le Score de Diversité Alimentaire (SDA) selon les groupes HDDS

cat("\n── Étape 5 : Score de diversité alimentaire (conso) ──\n")

# Regroupement des codes produits en groupes alimentaires HDDS
# ⚠ Ces intervalles sont indicatifs — à ajuster selon le dico EHCVM officiel
conso_clean <- conso %>%

  filter(!is.na(hhid), !is.na(codpr), depan > 0) %>%

  mutate(
    groupe_alim = case_when(
      codpr %in% 1:20   ~ "cereales",      # Céréales, racines, tubercules
      codpr %in% 21:40  ~ "legumineuses",  # Légumineuses, noix
      codpr %in% 41:60  ~ "legumes",       # Légumes
      codpr %in% 61:80  ~ "fruits",        # Fruits
      codpr %in% 81:100 ~ "viande",        # Viandes, abats
      codpr %in% 101:120~ "poisson",       # Poissons, fruits de mer
      codpr %in% 121:140~ "lait",          # Lait, produits laitiers
      codpr %in% 141:150~ "oeufs",         # Œufs
      codpr %in% 151:170~ "huile",         # Huiles, graisses
      codpr %in% 171:190~ "sucre",         # Sucres, confiseries
      codpr %in% 191:210~ "condiments",    # Condiments, épices
      TRUE               ~ "autres"
    )
  ) %>%

  # Agrégation : dépense totale par ménage et groupe
  group_by(hhid, groupe_alim) %>%
  summarise(dep_groupe = sum(depan, na.rm = TRUE), .groups = "drop") %>%

  # Pivot : 1 ligne par ménage, 1 colonne par groupe
  pivot_wider(
    names_from  = groupe_alim,
    values_from = dep_groupe,
    values_fill = 0,
    names_prefix = "dep_"
  ) %>%

  # SDA : nombre de groupes avec dépense > 0
  mutate(
    across(starts_with("dep_"), ~as.integer(. > 0), .names = "bin_{.col}"),
    SDA = rowSums(across(starts_with("bin_dep_")), na.rm = TRUE),

    # Dépense alimentaire totale reconstituée depuis conso
    dep_alim_conso = rowSums(across(starts_with("dep_")), na.rm = TRUE)
  ) %>%

  select(hhid, SDA, dep_alim_conso, starts_with("bin_dep_")) %>%
  filter(!is.na(hhid))

cat("  conso_clean :", nrow(conso_clean), "ménages\n")
cat("  SDA — moyenne :", round(mean(conso_clean$SDA, na.rm = TRUE), 1),
    "/ étendue :", min(conso_clean$SDA), "–", max(conso_clean$SDA), "\n")


# ── 6. FUSION DES 4 BASES ────────────────────────────────────────────────────

cat("\n── Étape 6 : Fusion ──\n")

base_fusion <- welfare_clean %>%
  left_join(menage_clean,   by = "hhid") %>%
  left_join(individu_agg,   by = "hhid") %>%
  left_join(conso_clean,    by = "hhid")

cat("  Base fusionnée :", nrow(base_fusion), "obs ×",
    ncol(base_fusion), "vars\n")

# Contrôle doublons
n_dup <- sum(duplicated(base_fusion$hhid))
if (n_dup > 0) warning("⚠ ", n_dup, " doublons sur hhid !")
    else cat("  ✔ Aucun doublon sur hhid\n")


# ── 7. VARIABLES FINALES POUR L'ACP / LOGIT ──────────────────────────────────

cat("\n── Étape 7 : Variables finales ACP & modélisation ──\n")

base_analytique <- base_fusion %>%

  mutate(
    # Région labelisée
    region_f = factor(region,
                      levels = 1:14,
                      labels = unname(PARAMS$regions)),

    # ── Variables ACP (toutes continues ou binaires)
    # Déjà construites : log_pcexp, hhsize_w, score_educ, elec_ac,
    #                    eauboi_sp, superf_c, sh_co_eco, sh_co_natu

    # ── Pondération (utiliser pour stats descriptives pondérées)
    poids = hhweight
  )

# Vérification des variables ACP
vars_acp <- c("log_pcexp", "hhsize_w", "score_educ",
              "elec_ac", "eauboi_sp",
              "superf_c", "sh_co_eco", "sh_co_natu",
              "index_vie", "nb_chocs", "pct_internet",
              "ratio_dep", "ubt")

vars_acp_ok <- intersect(vars_acp, names(base_analytique))
vars_acp_manq <- setdiff(vars_acp, names(base_analytique))

cat("  Variables ACP disponibles :", length(vars_acp_ok), "/",
    length(vars_acp), "\n")
if (length(vars_acp_manq) > 0)
  cat("  ⚠ Manquantes :", paste(vars_acp_manq, collapse = ", "), "\n")


# ── 8. RAPPORT QUALITÉ ────────────────────────────────────────────────────────

cat("\n── Étape 8 : Rapport qualité ──\n")

vars_cles <- c("part_alim", "vuln_alim", "pauvre",
               vars_acp_ok, "SDA", "actif_agri", "milieu")

qualite <- base_analytique %>%
  select(any_of(vars_cles)) %>%
  summarise(across(everything(),
    list(
      n_obs      = ~sum(!is.na(.)),
      pct_complet = ~round(mean(!is.na(.)) * 100, 1),
      pct_na      = ~round(mean( is.na(.)) * 100, 1)
    ),
    .names = "{.col}__{.fn}"
  )) %>%
  pivot_longer(everything(),
               names_to  = c("variable", "stat"),
               names_sep = "__",
               values_to = "valeur") %>%
  pivot_wider(names_from = stat, values_from = valeur) %>%
  arrange(desc(pct_na))

cat("\n  Taux de complétude (variables clés) :\n")
print(qualite, n = 20)

write_csv(qualite, file.path(TABS, "rapport_qualite.csv"))

# Obs complètes pour l'ACP
n_complet <- base_analytique %>%
  select(all_of(vars_acp_ok)) %>%
  complete.cases() %>%
  sum()
cat("\n  Obs complètes pour ACP :", n_complet, "/", nrow(base_analytique),
    "(", round(n_complet / nrow(base_analytique) * 100, 1), "%)\n")


# ── 9. EXPORT ─────────────────────────────────────────────────────────────────

cat("\n── Étape 9 : Export ──\n")

# Base complète
saveRDS(base_analytique,
        file.path(CLEAN, "base_analytique_finale.rds"))
write_csv(base_analytique,
          file.path(CLEAN, "base_analytique_finale.csv"))

# Base ACP (sans NA sur variables ACP)
base_acp <- base_analytique %>%
  select(hhid, region, region_f, milieu, milieu_f, poids,
         part_alim, vuln_alim, pauvre,
         all_of(vars_acp_ok),
         actif_agri, choc_bin, nb_chocs,
         any_of(c("SDA", "score_educ", "index_vie", "cm_femme"))) %>%
  drop_na(all_of(vars_acp_ok))

saveRDS(base_acp, file.path(CLEAN, "base_acp_complete.rds"))

# Dictionnaire final
variables_finales <- tribble(
  ~variable,       ~label,                                       ~type,       ~usage,
  "hhid",          "Identifiant ménage",                         "ID",        "Fusion",
  "region",        "Code région (1–14)",                         "categ",     "Carte",
  "region_f",      "Libellé région",                             "categ",     "Carte",
  "milieu",        "Milieu (1=Urbain / 2=Rural)",                "categ",     "Analyse",
  "milieu_f",      "Milieu (Urbain / Rural)",                    "categ",     "Analyse",
  "hhsize",        "Taille du ménage",                           "continue",  "Descriptif",
  "hhsize_w",      "Taille ménage winsorisée",                   "continue",  "ACP",
  "hgender_f",     "Sexe CM",                                    "categ",     "Descriptif",
  "cm_femme",      "CM femme (0/1)",                             "binaire",   "Logit",
  "hage",          "Âge CM",                                     "continue",  "Descriptif",
  "heduc_grp",     "Niveau éducation CM (4 classes)",           "categ",     "Analyse",
  "score_educ",    "Score éducation CM (0–3)",                  "continue",  "ACP/Logit",
  "halfa_bin",     "Alphabétisation CM (0/1)",                  "binaire",   "Logit",
  "cm_actif",      "CM actif occupé (0/1)",                     "binaire",   "Logit",
  "pcexp",         "Dépenses per capita (FCFA)",                "continue",  "Descriptif",
  "log_pcexp",     "Log(dépenses per capita)",                  "continue",  "ACP/Logit",
  "pauvre",        "Ménage pauvre (pcexp < zref) (0/1)",        "binaire",   "Analyse",
  "dali",          "Dépenses alimentaires (FCFA)",              "continue",  "Descriptif",
  "dtot",          "Dépenses totales (FCFA)",                   "continue",  "Descriptif",
  "part_alim",     "Part dépenses alimentaires (0–1)",          "continue",  "VAR DEP",
  "vuln_alim",     "Vulnérable (part_alim > 60%) (0/1)",       "binaire",   "VAR DEP logit",
  "elec_ac",       "Accès électricité (0/1)",                   "binaire",   "ACP/Logit",
  "eauboi_sp",     "Eau potable saison sèche (0/1)",            "binaire",   "ACP/Logit",
  "eauboi_ss",     "Eau potable saison pluies (0/1)",           "binaire",   "Logit",
  "index_vie",     "Indice conditions de vie (0–5)",            "continue",  "ACP/Logit",
  "tv",            "Possession TV (0/1)",                       "binaire",   "Descriptif",
  "frigo",         "Possession frigo (0/1)",                    "binaire",   "Descriptif",
  "superf",        "Superficie agricole brute (ha)",            "continue",  "Descriptif",
  "superf_c",      "Superficie agri (0 si non-agri)",          "continue",  "ACP",
  "actif_agri",    "Ménage agricole (0/1)",                     "binaire",   "Logit",
  "ubt",           "Unités bétail tropical (score)",           "continue",  "ACP",
  "grosrum",       "Nb gros ruminants",                         "continue",  "Descriptif",
  "petitrum",      "Nb petits ruminants",                       "continue",  "Descriptif",
  "volail",        "Nb volailles",                              "continue",  "Descriptif",
  "sh_co_eco",     "Choc éco communautaire (0/1)",              "binaire",   "ACP",
  "sh_co_natu",    "Choc naturel communautaire (0/1)",          "binaire",   "ACP",
  "sh_id_eco",     "Choc éco idiosyncrasique (0/1)",            "binaire",   "Logit",
  "nb_chocs",      "Nombre total de chocs (0–6)",              "continue",  "ACP/Logit",
  "choc_bin",      "Au moins un choc subi (0/1)",               "binaire",   "Logit",
  "ratio_dep",     "Ratio de dépendance démographique",        "continue",  "ACP",
  "nb_enf5",       "Nb enfants < 5 ans",                        "continue",  "Descriptif",
  "pct_internet",  "% membres avec internet",                  "continue",  "Capital humain",
  "pct_telpor",    "% membres avec téléphone portable",        "continue",  "Descriptif",
  "pct_bank",      "% membres avec compte bancaire",           "continue",  "Descriptif",
  "SDA",           "Score de diversité alimentaire (0–12)",    "continue",  "Alt. var dep"
)

write_csv(variables_finales,
          file.path(PROJET_ROOT, "docs", "dictionnaire_variables_final.csv"))

cat("  ✔ base_analytique_finale.rds  —", nrow(base_analytique), "obs\n")
cat("  ✔ base_analytique_finale.csv\n")
cat("  ✔ base_acp_complete.rds       —", nrow(base_acp), "obs\n")
cat("  ✔ rapport_qualite.csv\n")
cat("  ✔ dictionnaire_variables_final.csv —",
    nrow(variables_finales), "variables\n")


# ── RÉCAPITULATIF ─────────────────────────────────────────────────────────────

cat("\n", strrep("━", 60), "\n")
cat("✅ PHASE 2 TERMINÉE\n\n")
cat("  Observations finales  :", nrow(base_analytique), "\n")
cat("  Variables             :", ncol(base_analytique), "\n")
cat("  Part alim. moyenne    :",
    round(mean(base_analytique$part_alim, na.rm = TRUE) * 100, 1), "%\n")
cat("  Vulnérabilité alim.   :",
    round(mean(base_analytique$vuln_alim, na.rm = TRUE) * 100, 1), "%\n")
cat("  Ménages pauvres       :",
    round(mean(base_analytique$pauvre, na.rm = TRUE) * 100, 1), "%\n\n")
cat("  ➡ Transmettre à Membre 2 :\n")
cat("     • data/clean/base_analytique_finale.csv\n")
cat("     • docs/dictionnaire_variables_final.csv\n\n")
cat("  ➡ Lancer ensuite : 02_PHASE3_analyse_descriptive.R\n")
cat(strrep("━", 60), "\n")


