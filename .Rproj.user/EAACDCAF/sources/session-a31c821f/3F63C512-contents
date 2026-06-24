#=========================================================
# METRICX - SYR 2026
# Clustering multidimensionnel des ménages
# EHCVM Sénégal 2021
# Thème : Ménages, chocs et résilience :
# une lecture multidimensionnelle du Sénégal
#=========================================================

#---------------------------------------------------------
# 0. PACKAGES
#---------------------------------------------------------

packages <- c(
  "tidyverse",
  "cluster",
  "factoextra",
  "NbClust",
  "data.table","e1071"
)

invisible(
  lapply(packages, function(p){
    if(!require(p, character.only = TRUE)){
      install.packages(p)
      library(p, character.only = TRUE)
    }
  })
)

set.seed(123)

#---------------------------------------------------------
# 1. VARIABLES DE CLUSTERING
#---------------------------------------------------------
IN <- "./data/clean"
OUT <- "./data/clean"

base_clustering  <- read_xlsx(file.path(IN, "base_clustering.xlsx"))
vars_cluster <- c(
  "precarite_structurelle_conditions_vie",
  "capital_humain_insertion_eco",
  "position_sociopro_emploiquali",
  "vuln_soc_fam",
  "depenses_globales",
  "structure_menage_vs_conso_par_tete"
)

data_cluster <- base_clustering %>%
  select(all_of(vars_cluster))

#---------------------------------------------------------
# 2. MATRICE DE CORRELATION
#---------------------------------------------------------

cor_mat <- cor(
  data_cluster,
  use = "pairwise.complete.obs"
)

print(round(cor_mat,3))

#---------------------------------------------------------
# 3. STANDARDISATION
#---------------------------------------------------------

X <- scale(data_cluster)

#---------------------------------------------------------
# 4. CHOIX DU NOMBRE DE CLUSTERS
#---------------------------------------------------------

# Elbow Method

fviz_nbclust(
  X,
  kmeans,
  method = "wss",
  k.max = 10
)

# Gap Statistic

set.seed(123)

gap_stat <- clusGap(
  X,
  FUN = kmeans,
  nstart = 25,
  K.max = 8,
  B = 30
)

fviz_gap_stat(gap_stat)

#---------------------------------------------------------
# 5. ENTRAINEMENT DE PLUSIEURS KMEANS
#---------------------------------------------------------

results_kmeans <- data.frame()

models_kmeans <- list()

for(k in 2:8){
  
  km <- kmeans(
    X,
    centers = k,
    nstart = 25,
    iter.max = 50
  )
  
  totss <- km$totss
  betweenss <- km$betweenss
  
  variance_expliquee <- betweenss / totss
  
  results_kmeans <- rbind(
    results_kmeans,
    data.frame(
      k = k,
      variance_expliquee = variance_expliquee,
      tot_withinss = km$tot.withinss
    )
  )
  
  models_kmeans[[paste0("k_", k)]] <- km
}

results_kmeans %>%
  arrange(desc(variance_expliquee))

print(results_kmeans)

#---------------------------------------------------------
# 6. CHOIX MANUEL DU K
#---------------------------------------------------------

# Après avoir examiné :
# - Elbow Plot
# - Gap Statistic
# - Variance expliquée, on trouve

best_k <- 5

#---------------------------------------------------------
# 7. MODELE FINAL
#---------------------------------------------------------

set.seed(123)

best_model <- kmeans(
  X,
  centers = best_k,
  nstart = 200,
  iter.max = 100
)

cluster_final <- best_model$cluster

base_clustering$cluster <- factor(cluster_final)
#---------------------------------------------------------
# 12. TAILLE DES CLUSTERS
#---------------------------------------------------------

table(base_clustering$cluster)

prop.table(
  table(base_clustering$cluster)
)

#---------------------------------------------------------
# 13. PROFIL SUR LES DIMENSIONS ACP + ACM
#---------------------------------------------------------

profil_dim <- base_clustering %>%
  group_by(cluster) %>%
  summarise(
    across(
      all_of(vars_cluster),
      mean,
      na.rm = TRUE
    )
  )

View(profil_dim)

#---------------------------------------------------------
# 14. PROFIL STANDARDISE (Z-SCORES)
#---------------------------------------------------------

X_df <- as.data.frame(X)

X_df$cluster <- factor(cluster_final)

profil_z <- X_df %>%
  group_by(cluster) %>%
  summarise(
    across(
      everything(),
      mean
    )
  )

print(profil_z)

#---------------------------------------------------------
# 15. VARIABLES LES PLUS DISTINCTIVES
#---------------------------------------------------------

profil_long <- profil_z %>%
  pivot_longer(
    -cluster,
    names_to = "variable",
    values_to = "zscore"
  )

top_variables <- profil_long %>%
  group_by(cluster) %>%
  arrange(
    desc(abs(zscore))
  ) %>%
  slice_head(n = 6)

print(top_variables, n=30)

#---------------------------------------------------------
# 16. VISUALISATION
#---------------------------------------------------------

fviz_cluster(
  list(
    data = X,
    cluster = cluster_final
  ),
  geom = "point"
)

table(cluster_final)
prop.table(table(cluster_final))

#Les ménages sénégalais ne se répartissent pas en catégories parfaitement distinctes ; 
# ils présentent des combinaisons de vulnérabilités structurelles, économiques et sociales.
# Le clustering met en évidence cinq profils dominants qui se chevauchent partiellement.


#---------------------------------------------------------
# 17. EXPORTS
#---------------------------------------------------------

write.csv(
  profil_dim,
  "profil_clusters_dimensions.csv",
  row.names = FALSE
)

write.csv(
  top_variables,
  "variables_distinctives_clusters.csv",
  row.names = FALSE
)

#---------------------------------------------------------
# 18. VARIABLE FINALE
#---------------------------------------------------------


library(e1071)

#---------------------------------------------------------
# 1. NOMMAGE DES CLUSTERS KMEANS (k = 5)
#---------------------------------------------------------

base_clustering <- base_clustering %>%
  mutate(
    groupe_kmeans = case_when(
      cluster == 1 ~ "precarite_capital_humain",
      cluster == 2 ~ "intermediaires_stables",
      cluster == 3 ~ "modestes_peu_precaires",
      cluster == 4 ~ "aises_qualifies",
      cluster == 5 ~ "vulnerabilite_sociale_elevee"
    )
  )

#---------------------------------------------------------
# 2. VARIABLES BINAIRES (ONE-HOT ENCODING)
#---------------------------------------------------------

base_clustering <- base_clustering %>%
  mutate(
    cluster_1 = ifelse(cluster == 1, 1, 0),
    cluster_2 = ifelse(cluster == 2, 1, 0),
    cluster_3 = ifelse(cluster == 3, 1, 0),
    cluster_4 = ifelse(cluster == 4, 1, 0),
    cluster_5 = ifelse(cluster == 5, 1, 0)
  )

#---------------------------------------------------------
# 3. FUZZY C-MEANS CLUSTERING
#---------------------------------------------------------

k <- 5

fcm <- cmeans(
  X,
  centers = k,
  m = 2,
  iter.max = 200,
  method = "cmeans"
)

#---------------------------------------------------------
# 4. MATRICE D'APPARTENANCE FUZZY
#---------------------------------------------------------

fuzzy_membership <- as.data.frame(fcm$membership)

colnames(fuzzy_membership) <- paste0("fuzzy_cluster_", 1:k)

base_clustering <- cbind(base_clustering, fuzzy_membership)

#---------------------------------------------------------
# 5. CLUSTER DOMINANT FUZZY
#---------------------------------------------------------

base_clustering$fuzzy_cluster_dominant <- apply(
  fuzzy_membership,
  1,
  which.max
)

#---------------------------------------------------------
# 6. INDICE DE PURETE (FORCE D'APPARTENANCE)
#---------------------------------------------------------

base_clustering$fuzzy_purete <- apply(
  fuzzy_membership,
  1,
  max
)

#---------------------------------------------------------
# 7. INTERPRETATION RAPIDE (OPTIONNEL)
#---------------------------------------------------------

base_clustering$fuzzy_type <- case_when(
  base_clustering$fuzzy_purete >= 0.8 ~ "Profil tres typé",
  base_clustering$fuzzy_purete >= 0.6 ~ "Profil dominant clair",
  TRUE ~ "Profil hybride / multi-vulnerable"
)

#---------------------------------------------------------
# 8. STATISTIQUES RAPIDES
#---------------------------------------------------------

table(base_clustering$fuzzy_cluster_dominant)

summary(base_clustering$fuzzy_purete)

#---------------------------------------------------------
# 9. EXPORT FINAL (OPTIONNEL)
#---------------------------------------------------------

write_xlsx(base_clustering, file.path(OUT, "base_finale_poster.xlsx"))