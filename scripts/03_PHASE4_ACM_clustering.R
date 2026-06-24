# ==============================================================================
# METRICX — Show Your Research 2026 — ENSAE Dakar
# PHASE 4 : ACM + CAH + K-MEANS (Version Finale Labellisée - 3 Clusters)
# Auteur   : Membre 1 (Data & Analyses statistiques)
# ==============================================================================

library(FactoMineR)
library(factoextra)
library(cluster)
library(tidyverse)
library(janitor)
library(vcd) # Requis pour le graphique en mosaïque

PROJET_ROOT <- "C:/Users/CFAC/Desktop/SS"
PARAMS      <- readRDS(file.path(PROJET_ROOT, "docs", "params_projet.rds"))

CLEAN <- PARAMS$path_clean
TABS  <- PARAMS$path_tabs
FIGS  <- PARAMS$path_figs
set.seed(PARAMS$seed)

# S'assurer que le dossier des figures existe
dir.create(FIGS, recursive = TRUE, showWarnings = FALSE)

# ── 1. CHARGEMENT ET TRAITEMENT DES NA ────────────────────────────────────────

base <- readRDS(file.path(CLEAN, "base_analytique_finale.rds"))

base_acm <- base %>%
  mutate(
    # Recodages avec gestion explicite des NA pour ne perdre aucune observation
    toilet_grp = case_when(
      toilet %in% c(1, 2) ~ "Chasse_eau",
      toilet %in% c(3, 4) ~ "Latrine",
      toilet %in% c(5, 6) ~ "Precaire",
      TRUE                 ~ "Non_renseigne"
    ) %>% factor(),
    
    mur_grp = case_when(
      mur %in% c(1, 2) ~ "Dur",
      mur %in% c(3, 4) ~ "Semi_dur",
      mur %in% c(5, 6) ~ "Precaire",
      TRUE              ~ "Non_renseigne"
    ) %>% factor(),
    
    hmstat_grp = case_when(
      hmstat == 1             ~ "Marie_mono",
      hmstat == 2             ~ "Marie_poly",
      hmstat %in% c(3, 4, 5)  ~ "Autre",
      TRUE                    ~ "Non_renseigne"
    ) %>% factor(),
    
    # Transformation des binaires en facteurs avec conservation des NA
    elec_ac_f    = fct_explicit_na(factor(elec_ac, levels = c(0,1), labels = c("Non","Oui")), "Manquant"),
    eauboi_sp_f  = fct_explicit_na(factor(eauboi_sp, levels = c(0,1), labels = c("Non","Oui")), "Manquant"),
    halfa_f      = fct_explicit_na(factor(halfa_bin, levels = c(0,1), labels = c("Non","Oui")), "Manquant"),
    cm_actif_f   = fct_explicit_na(factor(cm_actif, levels = c(0,1), labels = c("Non","Oui")), "Manquant"),
    actif_agri_f = fct_explicit_na(factor(actif_agri, levels = c(0,1), labels = c("Non","Oui")), "Manquant"),
    choc_bin_f   = fct_explicit_na(factor(choc_bin, levels = c(0,1), labels = c("Non","Oui")), "Manquant"),
    sh_co_eco_f  = fct_explicit_na(factor(sh_co_eco, levels = c(0,1), labels = c("Non","Oui")), "Manquant"),
    sh_co_natu_f = fct_explicit_na(factor(sh_co_natu, levels = c(0,1), labels = c("Non","Oui")), "Manquant"),
    cm_femme_f   = fct_explicit_na(factor(cm_femme, levels = c(0,1), labels = c("Homme","Femme")), "Manquant"),
    milieu_f     = fct_explicit_na(factor(milieu_f), "Manquant"),
    heduc_grp    = fct_explicit_na(factor(heduc_grp), "Manquant"),
    
    vuln_alim_f  = factor(vuln_alim, levels = c(0,1), labels = c("Non_vuln","Vuln")),
    pauvre_f     = factor(pauvre, levels = c(0,1), labels = c("Non_pauvre","Pauvre"))
  )

vars_acp_actives <- c(
  "milieu_f", "elec_ac_f", "eauboi_sp_f", "toilet_grp", "mur_grp",
  "heduc_grp", "halfa_f", "cm_actif_f", "cm_femme_f", "hmstat_grp",
  "actif_agri_f", "choc_bin_f", "sh_co_eco_f", "sh_co_natu_f"
)
vars_illus_quali <- c("vuln_alim_f", "pauvre_f", "region_f")

df_acm <- base_acm %>% 
  select(hhid, all_of(vars_acp_actives), all_of(vars_illus_quali), 
         part_alim, vuln_alim, pauvre, hhweight, hhsize) %>%
  drop_na(all_of(vars_illus_quali)) # Garder les individus ayant les indicateurs cibles

# ── 2. ACM & K-MEANS FORCÉ À K = 3 ────────────────────────────────────────────

df_actif <- as.data.frame(df_acm %>% select(all_of(vars_acp_actives)))
df_illus <- as.data.frame(df_acm %>% select(all_of(vars_illus_quali)))
df_pour_mca <- cbind(df_actif, df_illus)

res_mca <- MCA(df_pour_mca, ncp = 5, quali.sup = (length(vars_acp_actives)+1):ncol(df_pour_mca), graph = FALSE)

# Coordonnées des individus sur les 5 axes
coord_cah <- as.data.frame(res_mca$ind$coord)

# Exécution directe du K-means à 3 clusters sur les coordonnées factorielles
K <- 3
res_kmeans <- kmeans(coord_cah, centers = K, iter.max = 100, nstart = 25)

df_acm$cluster <- factor(res_kmeans$cluster)
base_avec_cluster <- base %>% left_join(df_acm %>% select(hhid, cluster), by = "hhid")

# ── 3. VISUALISATIONS GRAPHIQUES ────────────────────────────────────── ─

cat("── Étape 3 : Génération et sauvegarde des visualisations ──\n")

# Graphique 1 : Éboulis des valeurs propres (Variance expliquée)
p_eig <- fviz_eig(res_mca, addlabels = TRUE, barfill = "#2c3e50", barcolor = "#2c3e50") +
  theme_minimal() +
  labs(title = "METRICX — Variance expliquée par axe ACM", x = "Axes", y = "% de variance")
ggsave(file.path(FIGS, "01_acm_eboulis.png"), plot = p_eig, width = 8, height = 5)

# Graphique 2 : Nuage des individus coloré par les 3 clusters
p_ind <- fviz_mca_ind(res_mca, 
                      label = "none", 
                      habillage = df_acm$cluster,
                      palette = c("#1abc9c", "#d35400", "#2980b9"),
                      addEllipses = TRUE, 
                      ellipse.type = "confidence",
                      ggtheme = theme_minimal()) +
  labs(title = "METRICX — Typologie des ménages (3 Clusters distincts)",
       x = "Dimension 1", y = "Dimension 2", color = "Clusters")
ggsave(file.path(FIGS, "02_clusters_premier_plan.png"), plot = p_ind, width = 9, height = 6)

# Graphique 3 : Profil des clusters (Pauvreté, Vulnérabilité, Milieu Rural)
profil_plot_data <- df_acm %>%
  group_by(cluster) %>%
  summarise(
    `Pauvreté monétaire` = mean(pauvre == 1, na.rm = TRUE) * 100,
    `Vulnérabilité alim.` = mean(vuln_alim == 1, na.rm = TRUE) * 100,
    `Milieu Rural` = mean(milieu_f == "Rural", na.rm = TRUE) * 100
  ) %>%
  pivot_longer(-cluster, names_to = "Indicateur", values_to = "Pourcentage")

p_profil <- ggplot(profil_plot_data, aes(x = cluster, y = Pourcentage, fill = cluster)) +
  geom_bar(stat = "identity", position = "dodge", alpha = 0.85, color = "black", width = 0.6) +
  facet_wrap(~Indicateur, scales = "free_y") +
  scale_fill_manual(values = c("#1abc9c", "#d35400", "#2980b9")) +
  theme_bw() +
  labs(title = "METRICX — Profil comparatif des 3 clusters", x = "Cluster", y = "Pourcentage (%)") +
  theme(legend.position = "none", strip.background = element_rect(fill = "#ecf0f1"))
ggsave(file.path(FIGS, "03_profils_comparatifs.png"), plot = p_profil, width = 10, height = 5)

# Graphique 4 : Mosaïque des liaisons modalités / clusters
png(file.path(FIGS, "04_mosaique_cluster_milieu.png"), width = 800, height = 600)
mosaic(~ cluster + milieu_f, data = df_acm, shade = TRUE, legend = TRUE,
       main = "Répartition du Milieu de vie par Cluster (Résidus standardisés)")
dev.off()

# Graphique 5 : Boxplot de la taille du ménage par cluster
p_box_size <- ggplot(base_avec_cluster %>% filter(!is.na(cluster)), 
                     aes(x = cluster, y = hhsize, fill = cluster)) +
  geom_boxplot(alpha = 0.7, outlier.colour = "red", outlier.shape = 1) +
  scale_fill_manual(values = c("#1abc9c", "#d35400", "#2980b9")) +
  theme_minimal() +
  labs(title = "METRICX — Taille du ménage selon le cluster retenu",
       x = "Cluster", y = "Nombre de personnes dans le ménage") +
  theme(legend.position = "none")
ggsave(file.path(FIGS, "05_boxplot_taille_menage.png"), plot = p_box_size, width = 8, height = 5)


# ── 4. PROFILAGE AUTOMATISÉ ET EXPORT ─────────────────────────────────────────

profil_qual <- df_acm %>%
  group_by(cluster) %>%
  summarise(
    pct_rural     = round(mean(milieu_f == "Rural", na.rm=TRUE)*100, 1),
    pct_agri      = round(mean(actif_agri_f == "Oui", na.rm=TRUE)*100, 1),
    pct_vuln      = round(mean(vuln_alim == 1, na.rm=TRUE)*100, 1),
    pct_pauvre    = round(mean(pauvre == 1, na.rm=TRUE)*100, 1),
    pct_elec      = round(mean(elec_ac_f == "Oui", na.rm=TRUE)*100, 1),
    n_obs         = n()
  )

# Attribution finale et calibrée des labels basée sur tes résultats réels
labels_3_clusters <- profil_qual %>%
  mutate(
    nom_cluster = case_when(
      # Cluster 3 : Structurellement rural (84.5%) et pauvre (56.6%)
      pct_rural > 60                               ~ "Ménages Ruraux Agricoles Précaires",
      
      # Cluster 2 : Très forte électricité (93.1%) et pauvreté plus basse (16.0%)
      pct_elec > 90 & pct_pauvre < 18              ~ "Ménages Urbains Aisés et Résilients",
      
      # Cluster 1 : Milieu urbain/périurbain mais pauvreté et vulnérabilité plus marquées
      pct_elec <= 90 | (pct_pauvre >= 18 & pct_pauvre < 30) ~ "Ménages Urbains et Périurbains Vulnérables",
      
      TRUE                                         ~ paste0("Ménages Intermédiaires - Groupe ", cluster)
    )
  ) %>%
  select(cluster, nom_cluster, n_obs)

print(labels_3_clusters)

# Sauvegarde des objets et tables finaux pour Membre 2
saveRDS(base_avec_cluster, file.path(CLEAN, "base_avec_cluster_3k.rds"))
write_csv(labels_3_clusters, file.path(TABS, "clusters_3k_noms.csv"))

cat("\n Conduite de l'analyse terminée. Les graphiques et rapports ont été actualisés dans :", FIGS, "\n")