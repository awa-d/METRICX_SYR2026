# Packages nécessaires
library(haven)
library(dplyr)
library(purrr)
library(tibble)
library(openxlsx)

#--------------------------------------------------
# 1. Lister et importer les bases
#--------------------------------------------------

fichiers <- list.files(
  path = "./data",
  pattern = "\\.dta$",
  full.names = TRUE
)

bases <- lapply(fichiers, read_dta)
names(bases) <- tools::file_path_sans_ext(basename(fichiers))

#--------------------------------------------------
# 2. Fonction extraction metadata
#--------------------------------------------------

extraire_metadata <- function(df, nom_base) {
  
  map_dfr(names(df), function(var) {
    
    x <- df[[var]]
    
    #---------------------------
    # Label variable
    #---------------------------
    
    label_var <- attr(x, "label")
    
    if (is.null(label_var)) {
      label_var <- ""
    }
    
    label_var <- as.character(label_var)
    
    #---------------------------
    # Type variable
    #---------------------------
    
    type_var <- class(x)[1]
    
    #---------------------------
    # Modalités
    #---------------------------
    
    val_labels <- attr(x, "labels")
    
    modalites <- ""
    
    # Cas variables labellisées Stata
    if (!is.null(val_labels)) {
      
      modalites <- paste(
        paste0(
          names(val_labels),
          " = ",
          as.character(unname(val_labels))
        ),
        collapse = " ; "
      )
      
      # Cas variables texte/factor
    } else if (is.character(x) || is.factor(x)) {
      
      vals_uniques <- unique(x)
      vals_uniques <- vals_uniques[!is.na(vals_uniques)]
      
      modalites <- paste(
        as.character(head(vals_uniques, 50)),
        collapse = " ; "
      )
    }
    
    modalites <- as.character(modalites)
    
    tibble(
      base = as.character(nom_base),
      variable = as.character(var),
      label = label_var,
      type = as.character(type_var),
      modalites = modalites
    )
  })
}

#--------------------------------------------------
# 3. Construire documentation
#--------------------------------------------------

documentation <- map2_dfr(
  bases,
  names(bases),
  extraire_metadata
)

#--------------------------------------------------
# 4. Créer dossier outputs
#--------------------------------------------------

if (!dir.exists("./outputs")) {
  dir.create("./outputs")
}

#--------------------------------------------------
# 5. Export Excel
#--------------------------------------------------

fichier_sortie <- "./outputs/documentation_bases.xlsx"

write.xlsx(
  documentation,
  fichier_sortie,
  overwrite = TRUE
)

cat("Fichier exporté :", fichier_sortie)