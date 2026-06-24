library(haven)
library(dplyr)

# ─── Chargement des bases ────────────────────────────────────────────────────

fichiers <- list.files(path = "./data", pattern = "\\.dta$", full.names = TRUE)
bases    <- lapply(fichiers, read_dta)
names(bases) <- tools::file_path_sans_ext(basename(fichiers))

# Vérification des bases disponibles
cat("Bases chargées :\n")
print(names(bases))

# ─── Clés de jointure ────────────────────────────────────────────────────────

cles <- c("grappe", "menage", "vague")

# ══════════════════════════════════════════════════════════════════════════════
# BASE DE PONDÉRATIONS — à joindre à TOUTES les bases avant estimation
# ══════════════════════════════════════════════════════════════════════════════

poids <- bases[["ehcvm_ponderations_SEN2021"]] %>%
  select(
    grappe, menage, vague,
    poids,          # poids de sondage lissé (à utiliser en priorité)
    poids_nonlisse  # poids brut (pour vérification et comparaison)
  )

# ══════════════════════════════════════════════════════════════════════════════
# BASE DE CONTRÔLE — identification géographique et filtre qualité
# ══════════════════════════════════════════════════════════════════════════════

controle <- bases[["s00_me_SEN2021"]] %>%
  select(
    all_of(cles),
    s00q01,   # région (1=Dakar … 14=Sédhiou)
    s00q02,   # département / arrondissement
    s00q04,   # milieu de résidence (1=Urbain / 2=Rural)
    s00q08    # résultat interview (1=rempli ménage sélectionné)
  ) %>%
  # Ne conserver que les ménages avec questionnaire effectivement rempli
  filter(s00q08 == 1)

# ══════════════════════════════════════════════════════════════════════════════
# VÉRIFICATION BASE WELFARE (agrégat officiel Banque Mondiale)
# Si disponible, contient pcexp (dépenses/tête) et poor (statut pauvreté)
# déjà calculés selon la méthodologie officielle EHCVM — gain de temps majeur
# ══════════════════════════════════════════════════════════════════════════════

if ("ehcvm_welfare_SEN2021" %in% names(bases)) {
  welfare <- bases[["ehcvm_welfare_SEN2021"]] %>%
    select(all_of(cles), any_of(c(
      "pcexp",      # dépenses annuelles par tête (FCFA)
      "poor",       # statut pauvreté monétaire (0/1)
      "poor_sev",   # pauvreté sévère (0/1)
      "zref",       # seuil de pauvreté de référence
      "hhsize",     # taille du ménage
      "hh_weight"   # poids ménage (si présent dans welfare)
    )))
  cat("✔ Base welfare trouvée et chargée.\n")
} else {
  welfare <- NULL
  cat("⚠ Base welfare absente — l'agrégat de consommation devra être reconstruit\n",
      "  manuellement à partir des sections 7A, 7B et 9A–9F.\n")
}

# ══════════════════════════════════════════════════════════════════════════════
# DIMENSION 1 — CAPITAL HUMAIN & DÉMOGRAPHIE
# Bases : s01 (démographie), s02 (éducation), s03 (santé)
# ══════════════════════════════════════════════════════════════════════════════

# ── s01 : Caractéristiques sociodémographiques ────────────────────────────────
# Rôle : identifier le chef de ménage, calculer la taille du ménage,
#        le ratio de dépendance, et les caractéristiques du chef
# Ajout remarque : s01q16 (ethnie) — disparités alimentaires documentées
#                  au Sénégal selon l'ethnie (Peul, Wolof, Diola)
#                  s01q17/s01q18/s01q21 — statut migratoire, précarité
d1_s01 <- bases[["s01_me_SEN2021"]] %>%
  select(
    all_of(cles),
    s01q00a,   # code ID du répondant de la section
    s01q01,    # sexe du membre (1=Masculin / 2=Féminin)
    s01q02,    # lien de parenté avec le chef (1=Chef → permet d'isoler le chef)
    s01q04a,   # âge en années révolues au dernier anniversaire
    s01q04b,   # âge en mois (pour enfants < 5 ans)
    s01q07,    # situation matrimoniale
    s01q14,    # religion
    s01q16,    # ethnie [AJOUT] — hétérogénéité culturelle et alimentaire
    s01q17,    # né dans cette localité (Oui/Non) [AJOUT] — mobilité résidentielle
    s01q18,    # a vécu ailleurs > 6 mois (Oui/Non) [AJOUT] — statut migratoire
    s01q21,    # raison principale de la migration [AJOUT] — précarité/déplacement
    s01q36,    # possède un téléphone portable (inclusion numérique/financière)
    s01q37     # a utilisé un téléphone dans les 7 derniers jours
  )

# ── s02 : Éducation (individus ≥ 3 ans) ──────────────────────────────────────
# Rôle : mesurer le capital humain du chef et des membres adultes
d1_s02 <- bases[["s02_me_SEN2021"]] %>%
  select(
    all_of(cles),
    s01q00a,    # code ID répondant (lien avec s01)
    s02q01__1,  # sait lire en français (Oui/Non)
    s02q01__2,  # sait lire en langue locale (Oui/Non)
    s02q02__1,  # sait écrire en français (Oui/Non)
    s02q02__2,  # sait écrire en langue locale (Oui/Non)
    s02q03,     # a fait des études formelles (Oui/Non)
    s02q29,     # niveau d'études le plus élevé atteint (0=aucun → 8=supérieur)
    s02q33      # diplôme le plus élevé obtenu (CEPE / BEPC / BAC / Licence...)
  )

# ── s03 : Santé générale ──────────────────────────────────────────────────────
# Rôle : chocs de santé, dépenses santé (effet d'éviction), couverture maladie
# Ajouts remarque :
#   s03q24b → frais transport sanitaire (part du coût total OMS)
#   s03q26/s03q27 → appareils médicaux (coût total de santé)
#   s03q34 → qui finance l'assurance (formel vs informel) — Gertler & Gruber 2002
d1_s03 <- bases[["s03_me_SEN2021"]] %>%
  select(
    all_of(cles),
    s01q00a,   # code ID répondant
    s03q01,    # problème de santé dans les 30 derniers jours hors hospi (Oui/Non)
    s03q02,    # principal problème de santé (type de maladie)
    s03q03,    # ce problème a empêché les activités quotidiennes (Oui/Non)
    s03q04,    # durée de l'empêchement (< 1 sem / 1-2 sem / > 2 sem)
    s03q12,    # a consulté un service de santé dans les 3 derniers mois (Oui/Non)
    s03q13,    # frais consultation médecin généraliste — 3 mois (FCFA)
    s03q14,    # frais consultation médecin spécialiste — 3 mois (FCFA)
    s03q15,    # frais consultation dentiste — 3 mois (FCFA)
    s03q16,    # frais guérisseur traditionnel — 3 mois (FCFA)
    s03q17,    # frais examens médicaux et soins — 3 mois (FCFA)
    s03q18a,   # frais médicaments traditionnels — 3 mois (FCFA)
    s03q18b,   # frais médicaments pharmacie publique — 3 mois (FCFA)
    s03q18c,   # frais médicaments pharmacie privée — 3 mois (FCFA)
    s03q19,    # hospitalisation dans les 12 derniers mois (Oui/Non)
    s03q20,    # nombre d'hospitalisations sur 12 mois
    s03q22,    # nombre de jours d'hospitalisation (dernier épisode)
    s03q24,    # montant frais d'hospitalisation (FCFA)
    s03q24a,   # a effectué des dépenses de transport sanitaire (Oui/Non)
    s03q24b,   # montant transport sanitaire [AJOUT] — coût total OMS
    s03q25,    # frais appareils médicaux thérapeutiques (Oui/Non)
    s03q26,    # montant verres correcteurs / prothèses auditives [AJOUT]
    s03q27,    # montant béquilles / fauteuil roulant [AJOUT]
    s03q32,    # couvert par une assurance maladie (Oui/Non)
    s03q33,    # taux de remboursement de l'assurance (%)
    s03q34     # qui finance l'assurance [AJOUT] (employeur/État/individuel)
  )

# ══════════════════════════════════════════════════════════════════════════════
# DIMENSION 2 — CONDITIONS ÉCONOMIQUES
# Bases : s04a, s04b, s04c (emploi), s05 (revenus hors emploi),
#         s06 (épargne & crédit), s10a + s10b (entreprises non agricoles)
# ══════════════════════════════════════════════════════════════════════════════

# ── s04a : Situation vis-à-vis de l'activité (individus ≥ 5 ans) ─────────────
# Rôle : statut d'activité, classification BIT, mode de subsistance si inactif
d2_s04a <- bases[["s04a_me_SEN2021"]] %>%
  select(
    all_of(cles),
    s01q00a,   # code ID répondant
    s04q06,    # travail champ / élevage / pêche pour soi-même — 7 derniers jours
    s04q07,    # travail commerce / services marchands — 7 derniers jours
    s04q08,    # travail salarié (entreprise / État / patron) — 7 derniers jours
    s04q09,    # apprenti / stagiaire rémunéré — 7 derniers jours
    s04q10,    # synthèse BIT : en emploi (1=oui / 2=non)
    s04q11,    # possède un emploi non exercé cette semaine (congé / maladie)
    s04q16,    # mode de subsistance si inactif (pension / transfert / ménagère...)
    s04q18a,   # branche d'activité (agriculture / commerce / services...)
    s04q18b,   # catégorie socioprofessionnelle (cadre sup / ouvrier / compte propre)
    s04q18c,   # secteur institutionnel (public / privé formel / informel / ménage)
    s04q27,    # a exercé au moins un emploi dans les 12 derniers mois (Oui/Non)
    s04q28a    # type d'emploi principal exercé sur 12 mois (salarié / agri / indép.)
  )

# ── s04b : Emploi principal (12 derniers mois) ────────────────────────────────
# Rôle : revenus salariaux, durée, qualité de l'emploi, impact COVID
# Note : s04q43_unite INDISPENSABLE pour annualiser correctement le salaire
#        Vérifier aussi s04q47 (avantages hors salaire) et s04q49 (nourriture)
#        qui peuvent représenter une part significative du revenu réel en zone rurale
d2_s04b <- bases[["s04b_me_SEN2021"]] %>%
  select(
    all_of(cles),
    s01q00a,       # code ID répondant
    s04q31,        # principal employeur (État / entreprise publique / privé / ménage)
    s04q32,        # nb mois travaillés dans cet emploi sur 12 mois
    s04q36,        # nb jours par mois consacrés à cet emploi
    s04q37,        # nb heures par jour consacrées à cet emploi
    s04q38,        # cotise à la CNSS / FNRB (formalité emploi)
    s04q39,        # catégorie socioprofessionnelle dans cet emploi
    s04q39a,       # l'entreprise tient une comptabilité formelle (formalité)
    s04q42,        # dispose d'un bulletin de salaire (formalité)
    s04q43,        # salaire brut déclaré (FCFA — unité variable selon q43_unite)
    s04q43_unite,  # unité de temps du salaire (SEMAINE=1/MOIS=2/TRIMESTRE=3/AN=4)
    s04q44,        # bénéficie de primes (Oui/Non)
    s04q45,        # montant des primes hors salaire (FCFA)
    s04q45_unite,  # unité de temps des primes
    s04q46,        # bénéficie d'autres avantages (transport / logement) (Oui/Non)
    s04q47,        # montant des avantages hors salaire [AJOUT] — revenu en nature
    s04q47_unite,  # unité de temps des avantages [AJOUT]
    s04q48,        # reçoit de la nourriture dans le cadre de cet emploi (Oui/Non)
    s04q49,        # valeur estimée de la nourriture reçue [AJOUT] — revenu en nature
    s04q49_unite,  # unité de temps de la nourriture
    s04q49a,       # exerçait un emploi rémunéré avant COVID-19 (Oui/Non)
    s04q49b,       # a perdu son emploi à cause du COVID-19 (Oui/Non)
    s04q49c_1,     # durée sans travailler pendant COVID (quantité)
    s04q49c_2,     # unité de temps (semaine / mois)
    s04q49d        # réduction du temps de travail pendant COVID (Oui/Non)
  )

# ── s04c : Emploi secondaire (12 derniers mois) ───────────────────────────────
# Rôle : diversification des revenus — Ellis (2000) Rural Livelihoods
d2_s04c <- bases[["s04c_me_SEN2021"]] %>%
  select(
    all_of(cles),
    s01q00a,       # code ID répondant
    s04q50,        # a exercé un emploi secondaire dans les 12 mois (Oui/Non)
    s04q57,        # CSP emploi secondaire
    s04q58,        # revenu emploi secondaire (FCFA)
    s04q58_unite,  # unité de temps du revenu secondaire
    s04q54,        # nb mois travaillés dans l'emploi secondaire
    s04q55,        # nb jours par mois
    s04q56         # nb heures par jour
  )

# ── s05 : Revenus hors emploi (12 derniers mois) ─────────────────────────────
# Rôle : pensions, loyers, revenus financiers — Morduch (1995)
d2_s05 <- bases[["s05_me_SEN2021"]] %>%
  select(
    all_of(cles),
    s01q00a,
    s05q01, s05q02,   # pension retraite (Oui/Non + montant annuel FCFA)
    s05q03, s05q04,   # pension veuvage / orphelinat
    s05q05, s05q06,   # pension invalidité
    s05q07, s05q08,   # pension alimentaire
    s05q09, s05q10,   # revenus locatifs logement
    s05q11, s05q12,   # revenus mobiliers et financiers
    s05q13, s05q14    # autres revenus hors emploi
  )

# ── s06 : Épargne et crédit ───────────────────────────────────────────────────
# Rôle : accès au système financier, résilience économique
# Note : s06q11 == 8 (crédit utilisé pour alimentation) = signal direct d'insécurité
#        alimentaire — à exploiter dans l'analyse descriptive
d2_s06 <- bases[["s06_me_SEN2021"]] %>%
  select(
    all_of(cles),
    s01q00a,
    s06q01__1,  # compte en banque classique (Oui/Non)
    s06q01__2,  # compte à la Poste (Oui/Non)
    s06q01__3,  # compte caisse rurale / IMF (Oui/Non)
    s06q01__4,  # mobile banking / Orange Money / Wave (Oui/Non)
    s06q01__5,  # carte prépayée (Oui/Non)
    s06q02,     # dispose d'une épargne dans ces comptes (Oui/Non)
    s06q03,     # a demandé un crédit dans les 12 mois (Oui/Non)
    s06q05,     # a obtenu un crédit dans les 12 mois (Oui/Non)
    s06q07,     # membre d'une tontine / association d'entraide (Oui/Non)
    s06q09,     # a un crédit en cours non remboursé (Oui/Non)
    s06q11,     # utilisation principale du crédit (alim=8 → signal insécurité)
    s06q12,     # source du crédit (banque / IMF / tontine / ménage / usurier)
    s06q14      # montant nominal du dernier crédit (FCFA)
  )

# ── s10a + s10b : Entreprises non agricoles [AJOUT REMARQUE] ─────────────────
# Rôle : revenus des indépendants non agricoles (commerçants, artisans, etc.)
# Indispensable pour les ménages dont le chef est à son compte — Ellis (2000)
# s10a → existence d'entreprise(s) dans le ménage
# s10b → caractéristiques et revenus de chaque entreprise

d2_s10a <- bases[["s10a_me_SEN2021"]] %>%
  select(
    all_of(cles),
    s10q02,   # restauration rapide / vente beignets / grillades (Oui/Non)
    s10q03,   # entreprise de confection (couture, artisanat) (Oui/Non)
    s10q04,   # entreprise de construction / BTP (Oui/Non)
    s10q05,   # commerce (boutique, épicerie, vente ambulante) (Oui/Non)
    s10q06,   # profession libérale (médecin, avocat...) (Oui/Non)
    s10q07,   # services (taxi, transport, réparation...) (Oui/Non)
    s10q08,   # restauration / bar / maquis (Oui/Non)
    s10q10,   # autre entreprise non agricole (Oui/Non)
    s10q12b   # nombre total d'entreprises dans le ménage
  )

d2_s10b <- bases[["s10b_me_SEN2021"]] %>%
  select(
    all_of(cles),
    s10q17a,   # branche d'activité de l'entreprise
    s10q23,    # type de local (bureau / domicile / ambulant...)
    s10q46,    # recettes marchandises achetées-revendues — dernier mois actif (FCFA)
    s10q47,    # achats matières premières marchandises — dernier mois (FCFA)
    s10q48,    # recettes produits transformés — dernier mois (FCFA)
    s10q49,    # achats matières premières production — dernier mois (FCFA)
    s10q50,    # recettes services — dernier mois (FCFA)
    s10q51,    # autres consommations intermédiaires — dernier mois (FCFA)
    s10q52,    # frais loyer / eau / électricité — dernier mois (FCFA)
    s10q58,    # entreprise actuellement en activité (Oui/Non)
    s10q59     # nb mois en activité sur les 12 derniers mois
  )

# ══════════════════════════════════════════════════════════════════════════════
# DIMENSION 3 — CONDITIONS DE VIE & ACCÈS AUX SERVICES
# Bases : s11 (logement), s12 (actifs), s13_1 + s13_2 (transferts)
# ══════════════════════════════════════════════════════════════════════════════

# ── s11 : Logement ────────────────────────────────────────────────────────────
# Ajouts remarque :
#   s11q02 → nb pièces occupées (ratio personnes/pièce = surpopulation ONU-Habitat)
#   s11q23a / s11q25 → montants factures eau / achat eau (accessibilité économique eau)
d3_s11 <- bases[["s11_me_SEN2021"]] %>%
  select(
    all_of(cles),
    s11q01,        # type de logement (appartement / maison / baraque / case)
    s11q02,        # nb pièces occupées [AJOUT] → ratio personnes/pièce (surpeuplement)
    s11q04,        # statut d'occupation (propriétaire / locataire / logé gratuitement)
    s11q05,        # valeur locative mensuelle estimée pour un logement similaire (FCFA)
    s11q06,        # loyer mensuel effectivement payé (FCFA) — si locataire
    s11q18,        # matériau principal des murs extérieurs (dur/banco/paille/récupération)
    s11q19,        # matériau principal du toit (dalle/tôle/paille/banco)
    s11q20,        # matériau de revêtement du sol (carreaux/ciment/terre battue)
    s11q21,        # connecté à un réseau d'eau courante (Oui/Non)
    s11q23a,       # montant de la dernière facture d'eau (FCFA) [AJOUT]
    s11q23b,       # périodicité de la facture eau (mensuel / bimestriel / trimestriel)
    s11q24,        # achète de l'eau auprès de vendeurs (Oui/Non)
    s11q25,        # montant dépenses eau auprès vendeurs — 30 derniers jours [AJOUT]
    s11q26a,       # source eau de boisson saison sèche (proxy eau améliorée JMP/OMS)
    s11q26b,       # source eau de boisson saison des pluies
    s11q27,        # distance domicile → source d'eau principale saison sèche (mètres)
    s11q33,        # connecté au réseau électrique (Oui / chez voisin / non connecté)
    s11q37,        # source principale d'éclairage (réseau / solaire / pétrole / pile)
    s11q52__1,     # combustible cuisson : bois ramassé (1er ou 2e choix / non utilisé)
    s11q52__2,     # combustible cuisson : bois acheté
    s11q52__3,     # combustible cuisson : charbon de bois
    s11q52__4,     # combustible cuisson : gaz
    s11q52__5,     # combustible cuisson : électricité
    s11q52__6,     # combustible cuisson : pétrole / kérosène
    s11q53,        # mode d'évacuation des ordures ménagères
    s11q54,        # type de sanitaires (WC chasse d'eau / latrines / fosse / nature)
    s11q55,        # partage des sanitaires avec d'autres ménages (Oui/Non)
    s11q56,        # nb de ménages partageant les sanitaires
    s11q57,        # mode d'évacuation des excréments (égout / fosse / nature)
    s11q60a,       # point de lavage des mains observable (Oui/Non + fixe ou non)
    s11q60b        # présence d'eau ET savon au point de lavage (JMP)
  )

# ── s12 : Actifs du ménage ────────────────────────────────────────────────────
# Rôle : construction de l'indice de richesse par ACP (Filmer & Pritchett 2001)
# Note : garder en format long (une ligne par article × ménage)
#        Pivoter en large (pivot_wider) avant l'ACP
#        Articles clés pour l'axe 1 au Sénégal : 16 (frigo), 20 (TV),
#        28 (voiture), 29 (moto), 35 (téléphone), 37 (ordinateur),
#        44 (immeuble/maison), 45 (terrain non bâti)
d3_s12 <- bases[["s12_me_SEN2021"]] %>%
  select(
    all_of(cles),
    s12q01,   # code article (1=salon, 3=lit, 16=frigo, 20=TV, 28=voiture...)
    s12q02,   # possède cet article en bon état de fonctionnement (Oui/Non)
    s12q03,   # nombre d'articles de ce type possédés
    s12q06,   # état à l'acquisition (neuf / occasion)
    s12q07,   # ancienneté de possession (nb d'années)
    s12q09    # valeur actuelle estimée / prix de revente (FCFA)
  )

# ── s13_1 : Vue d'ensemble des transferts reçus ───────────────────────────────
# Rôle : déterminer si le ménage est bénéficiaire de transferts (diaspora / intérieur)
d3_s13_1 <- bases[["s13_1_me_SEN2021"]] %>%
  select(
    all_of(cles),
    s13q01,   # a un parent proche à l'étranger (Oui/Non)
    s13q02,   # ce parent a envoyé de l'argent dans les 12 mois (Oui/Non)
    s13q06,   # a reçu argent de famille au pays non-membre du ménage (Oui/Non)
    s13q07,   # a reçu argent d'autre personne au pays non-membre (Oui/Non)
    s13q09    # synthèse : au moins un transfert reçu (variable calculée 0/1)
  )

# ── s13_2 : Détail de chaque transfert reçu ──────────────────────────────────
# Rôle : montant, origine, fréquence des transferts
# Ajout remarque : s13q23 → qui contrôle le revenu des transferts
#                  Contrôle féminin → meilleures dépenses alimentaires
#                  Smith et al. (2003) World Development
d3_s13_2 <- bases[["s13_2_me_SEN2021"]] %>%
  select(
    all_of(cles),
    s13q12,    # lien de parenté de l'expéditeur (enfant / parent / conjoint...)
    s13q13,    # sexe de l'expéditeur
    s13q15,    # niveau d'instruction de l'expéditeur
    s13q16,    # statut professionnel de l'expéditeur
    s13q19,    # lieu de résidence de l'expéditeur (diaspora / intérieur / région)
    s13q20,    # motif principal du transfert (soutien courant / santé / scolarité)
    s13q21,    # mode de transfert (mobile money / cash / banque / Western Union)
    s13q22a,   # montant envoyé à chaque fois (FCFA)
    s13q22b,   # fréquence des transferts (mensuel / trimestriel / irrégulier)
    s13q23     # qui contrôle le revenu de ces transferts [AJOUT] — dimension genre
  )

# ══════════════════════════════════════════════════════════════════════════════
# DIMENSION 4 — SÉCURITÉ ALIMENTAIRE & CHOCS
# Bases : s07a (repas ext.), s07b (consommation 7j), s08a (FIES),
#         s09a–s09f (dépenses non alim.), s14a (COVID), s14b (chocs), s15 (filets)
# ══════════════════════════════════════════════════════════════════════════════

# ── s07a : Repas pris à l'extérieur [AJOUT REMARQUE — base absente initialement]
# Rôle : composante nécessaire de l'agrégat de consommation alimentaire totale
# Note : base s07a_2_me_SEN2021 = module principal (une ligne par membre × repas)
#        s07a_1_me_SEN2021 = version complémentaire selon la version de l'enquête
#        Utiliser la base disponible selon le répertoire
if ("s07a_2_me_SEN2021" %in% names(bases)) {
  d4_s07a <- bases[["s07a_2_me_SEN2021"]] %>%
    select(
      all_of(cles),
      s01q00a,    # code ID répondant (lien individuel)
      s07aq01,    # petit déjeuner acheté / reçu hors du ménage (Oui/Non)
      s07aq02,    # montant dépensé pour le petit déjeuner (FCFA / 7j)
      s07aq03,    # valeur en cas de cadeau — petit déjeuner (FCFA)
      s07aq04,    # déjeuner acheté / reçu hors ménage (Oui/Non)
      s07aq05,    # montant dépensé pour le déjeuner (FCFA / 7j)
      s07aq06,    # valeur en cas de cadeau — déjeuner
      s07aq07,    # dîner acheté / reçu hors ménage (Oui/Non)
      s07aq08,    # montant dépensé pour le dîner (FCFA / 7j)
      s07aq09,    # valeur en cas de cadeau — dîner
      s07aq10,    # collation achetée / reçue hors ménage (Oui/Non)
      s07aq11,    # montant dépensé pour la collation (FCFA / 7j)
      s07aq13,    # boisson chaude achetée / reçue hors ménage (Oui/Non)
      s07aq14,    # montant dépensé pour boisson chaude (FCFA / 7j)
      s07aq16,    # boisson non alcoolisée achetée hors ménage (Oui/Non)
      s07aq17     # montant dépensé pour boisson non alc (FCFA / 7j)
    )
  cat("✔ Base s07a_2 chargée.\n")
} else if ("s07a_1_me_SEN2021" %in% names(bases)) {
  d4_s07a <- bases[["s07a_1_me_SEN2021"]] %>%
    select(
      all_of(cles),
      s07aq01b, s07aq02b, s07aq03b,   # petit déjeuner
      s07aq04b, s07aq05b, s07aq06b,   # déjeuner
      s07aq07b, s07aq08b, s07aq09b,   # dîner
      s07aq10b, s07aq11b,             # collation
      s07aq13b, s07aq14b,             # boisson chaude
      s07aq16b, s07aq17b              # boisson non alcoolisée
    )
  cat("✔ Base s07a_1 chargée (version alternative).\n")
} else {
  d4_s07a <- NULL
  cat("⚠ Base s07a absente — agrégat de consommation alimentaire incomplet.\n")
}

# ── s07b : Consommation alimentaire des 7 derniers jours ─────────────────────
# Rôle : variable dépendante principale — SCA et HDDS
# AVERTISSEMENT sur s07bq06 :
#   Cette variable indique la DERNIÈRE DATE D'ACHAT, pas la fréquence de
#   consommation sur 7 jours. Pour le calcul du SCA (WFP-VAM 2008), la
#   fréquence doit être le nombre de jours de consommation sur 7.
#   Approximation recommandée :
#     s07bq06 == 1 (hier)          → fréquence = 7
#     s07bq06 == 2 (7 derniers j.) → fréquence = médiane du groupe alimentaire
#     s07bq06 == 3 (30 derniers j.)→ fréquence = 1
#     s07bq06 == 4 (> 30 jours)   → fréquence = 0
#     s07bq02 == 2 (non consommé) → fréquence = 0
#   Cette approximation doit être documentée dans la note méthodologique.
d4_s07b <- bases[["s07b_me_SEN2021"]] %>%
  select(
    all_of(cles),
    s07bq01,    # code produit alimentaire (1 à 180 selon nomenclature EHCVM)
    s07bq02,    # le ménage a-t-il consommé ce produit dans les 7 jours (Oui/Non)
    s07bq03a,   # quantité totale consommée (valeur numérique)
    s07bq03b,   # unité de mesure de la quantité (kg / litre / tas / sac...)
    s07bq03c,   # taille de l'unité (petit / moyen / grand)
    s07bq04,    # quantité issue de la production propre / auto-consommation
    s07bq05,    # quantité reçue en cadeau / don / troc
    s07bq06,    # dernière date d'achat → proxy fréquence (voir avertissement ci-dessus)
    s07bq07a,   # quantité du produit acheté la dernière fois
    s07bq07b,   # unité de mesure de cet achat
    s07bq08     # valeur monétaire de cet achat (FCFA)
  )

# ── s08a : Sécurité alimentaire — Échelle FIES ───────────────────────────────
# Rôle : variable dépendante principale — FIES score et insécurité sévère
# Les 8 questions FIES validées par la FAO (Ballard et al. 2013)
# + variables de fréquence pour q7 et q8 (nécessaires pour le modèle de Rasch)
d4_s08a <- bases[["s08a_me_SEN2021"]] %>%
  select(
    all_of(cles),
    s08aq01,    # FIES1 : inquiet de ne pas avoir assez de nourriture (Oui/Non)
    s08aq02,    # FIES2 : incapable de manger une nourriture saine et nutritive
    s08aq03,    # FIES3 : a mangé une nourriture peu variée
    s08aq04,    # FIES4 : a sauté un repas
    s08aq05,    # FIES5 : a mangé moins que nécessaire
    s08aq06,    # FIES6 : ménage n'avait plus de nourriture
    s08aq07,    # FIES7 : a eu faim sans manger
    s08aq07a,   # FIES7 fréquence (1=1-2 fois / 2=qq mois / 3=presque tous les mois)
    s08aq08,    # FIES8 : a passé une journée entière sans manger
    s08aq08a    # FIES8 fréquence (même modalités que FIES7)
  )

# ── s09a–s09f : Dépenses non alimentaires ─────────────────────────────────────
# Rôle : reconstituer les dépenses totales du ménage pour calculer :
#         (a) la part des dépenses alimentaires (Loi d'Engel)
#         (b) le niveau de vie total (proxy revenu permanent — Deaton 1997)
# Méthode d'annualisation officielle EHCVM :
#   s09a (fêtes 12 mois)   × 1
#   s09b (7 jours)         × 52
#   s09c (30 jours)        × 12
#   s09d (3 mois)          × 4
#   s09e (6 mois)          × 2
#   s09f (12 mois)         × 1

d4_s09a <- bases[["s09a_me_SEN2021"]] %>%
  select(
    all_of(cles),
    s09aq01,   # code fête (ramadan / tabaski / mariage / baptême / Magal...)
    s09aq02,   # a fait des dépenses pour cette fête (Oui/Non)
    s09aq03,   # montant dépenses alimentation fête (FCFA)
    s09aq04,   # montant dépenses boissons fête (FCFA)
    s09aq05,   # montant habits / chaussures / coiffure / bijoux (FCFA)
    s09aq06,   # montant location salle / chaises / autre (FCFA)
    s09aq07    # montant autres dépenses non alimentaires fête (FCFA)
  )

d4_s09b <- bases[["s09b_me_SEN2021"]] %>%
  select(
    all_of(cles),
    s09bq01,   # code produit/service (carburant / transport / bois / charbon...)
    s09bq02,   # acheté au cours des 7 derniers jours (Oui/Non)
    s09bq03    # montant dépensé (FCFA / 7 jours)
  )

d4_s09c <- bases[["s09c_me_SEN2021"]] %>%
  select(
    all_of(cles),
    s09cq01,   # code produit/service (gaz / savon / télécom / hygiène...)
    s09cq02,   # acheté au cours des 30 derniers jours (Oui/Non)
    s09cq03    # montant dépensé (FCFA / 30 jours)
  )

d4_s09d <- bases[["s09d_me_SEN2021"]] %>%
  select(
    all_of(cles),
    s09dq01,   # code produit/service (réparations / transport inter-ville...)
    s09dq02,   # acheté au cours des 3 derniers mois (Oui/Non)
    s09dq03    # montant dépensé (FCFA / 3 mois)
  )

d4_s09e <- bases[["s09e_me_SEN2021"]] %>%
  select(
    all_of(cles),
    s09eq01,   # code produit/service (habillement / chaussures / tissus...)
    s09eq02,   # acheté au cours des 6 derniers mois (Oui/Non)
    s09eq03    # montant dépensé (FCFA / 6 mois)
  )

d4_s09f <- bases[["s09f_me_SEN2021"]] %>%
  select(
    all_of(cles),
    s09fq01,   # code produit/service (logement / équipements / transport / santé...)
    s09fq02,   # acheté au cours des 12 derniers mois (Oui/Non)
    s09fq03    # montant dépensé (FCFA / 12 mois)
  )

# ── s14a : COVID-19 et impact sur les ménages ─────────────────────────────────
# Rôle : choc covariant majeur — impact sur emploi, revenus, transferts
# (Josephson et al. 2021, World Development ; FAO 2021)
d4_s14a <- bases[["s14a_me_SEN2021"]] %>%
  select(
    all_of(cles),
    s14aq01,    # type de choc COVID (maladie / perte emploi / recul transferts...)
    s14aq02,    # au moins une personne du ménage affectée (Oui/Non)
    s14aq02a,   # nombre de personnes affectées
    s14aq08,    # le problème a-t-il trouvé une solution (Oui/Non)
    s14aq09     # délai de résolution (nb de mois)
  )

# ── s14b : Chocs et stratégies de survie (3 dernières années) ────────────────
# Rôle : vulnérabilité ex-post — Dercon (2002), Carter & Barrett (2006)
# Ajout remarque : s14bq04d → impact sur le cheptel
#                  Crucial pour ménages agropastoraux (Kolda, Matam, Tambacounda)
#                  Perte de bétail = choc économique le plus sévère en zone rurale
d4_s14b <- bases[["s14b_me_SEN2021"]] %>%
  select(
    all_of(cles),
    s14bq01,      # nature du choc (maladie / décès / sécheresse / inondation /
    #   perte emploi / vol / conflit / prix élevés aliments...)
    s14bq02,      # ménage négativement affecté par ce choc (Oui/Non)
    s14bq03a,     # mois du choc
    s14bq03b,     # année du choc
    s14bq04a,     # conséquence sur les revenus (augmenté/diminué/inchangé)
    s14bq04b,     # conséquence sur les avoirs (biens durables, actifs)
    s14bq04c,     # conséquence sur la production agricole
    s14bq04d,     # conséquence sur l'effectif du cheptel [AJOUT] — agropastoral
    s14bq04e,     # conséquence sur le stock de produits alimentaires
    s14bq04f,     # conséquence sur les achats de produits alimentaires
    s14bq05__6,   # stratégie : changement des habitudes de consommation alimentaire
    s14bq05__7,   # stratégie : achat d'aliments moins chers
    s14bq05__13,  # stratégie : réduction des dépenses de santé / éducation
    s14bq05__14,  # stratégie : obtention d'un crédit
    s14bq05__15,  # stratégie : vente des actifs agricoles (terres, outils)
    s14bq05__16,  # stratégie : vente des biens durables du ménage
    s14bq05__19,  # stratégie : vente du stock de vivres
    s14bq05__21,  # stratégie : vente de bétail
    s14bq05__26   # aucune stratégie adoptée
  )

# ── s15 : Filets de sécurité ──────────────────────────────────────────────────
# Rôle : rôle des politiques publiques — Grosh et al. (2008), MFSNFPE Sénégal
# Ajout remarque : s15q10a / s15q10b → durée de bénéfice
#                  Un ménage BSF depuis 3 ans ≠ bénéficiaire récent
#                  La durée d'exposition modifie l'impact sur la sécurité alim.
d4_s15 <- bases[["s15_me_SEN2021"]] %>%
  select(
    all_of(cles),
    s15q01,    # code programme (BSF=12 / vivres PAM=1 / cash transfer=7 /
    #   soins gratuits enfants <5 ans=9 / Plan Sésame=13...)
    s15q02,    # en a entendu parler dans les 12 mois (Oui/Non)
    s15q03,    # a fait une demande pour ce programme (Oui/Non)
    s15q05,    # a bénéficié de ce programme dans les 12 mois (Oui/Non)
    s15q07,    # niveau de bénéfice (ménage entier vs individu)
    s15q09,    # nombre de fois reçu dans les 12 mois
    s15q10a,   # durée pendant laquelle le ménage a bénéficié [AJOUT]
    s15q10b,   # unité de temps (mois / jours) [AJOUT]
    s15q11a,   # mois de la dernière réception de l'aide
    s15q11b    # année de la dernière réception
  )

# ══════════════════════════════════════════════════════════════════════════════
# RÉSUMÉ FINAL
# ══════════════════════════════════════════════════════════════════════════════

cat("\n=== RÉSUMÉ DES BASES FILTRÉES ===\n\n")
cat(sprintf("%-35s : %6d obs.\n", "Pondérations",          nrow(poids)))
cat(sprintf("%-35s : %6d obs.\n", "Contrôle / ID géo",     nrow(controle)))
if (!is.null(welfare))
  cat(sprintf("%-35s : %6d obs.\n", "Welfare (agrégat BM)",   nrow(welfare)))
cat(sprintf("%-35s : %6d obs.\n", "D1 – s01 démographie",  nrow(d1_s01)))
cat(sprintf("%-35s : %6d obs.\n", "D1 – s02 éducation",    nrow(d1_s02)))
cat(sprintf("%-35s : %6d obs.\n", "D1 – s03 santé",        nrow(d1_s03)))
cat(sprintf("%-35s : %6d obs.\n", "D2 – s04a emploi sit.", nrow(d2_s04a)))
cat(sprintf("%-35s : %6d obs.\n", "D2 – s04b emploi pr.",  nrow(d2_s04b)))
cat(sprintf("%-35s : %6d obs.\n", "D2 – s04c emploi sec.", nrow(d2_s04c)))
cat(sprintf("%-35s : %6d obs.\n", "D2 – s05 rev. hors emp",nrow(d2_s05)))
cat(sprintf("%-35s : %6d obs.\n", "D2 – s06 épargne/crédit",nrow(d2_s06)))
cat(sprintf("%-35s : %6d obs.\n", "D2 – s10a entreprises", nrow(d2_s10a)))
cat(sprintf("%-35s : %6d obs.\n", "D2 – s10b rev. entreprise",nrow(d2_s10b)))
cat(sprintf("%-35s : %6d obs.\n", "D3 – s11 logement",     nrow(d3_s11)))
cat(sprintf("%-35s : %6d obs.\n", "D3 – s12 actifs (long)",nrow(d3_s12)))
cat(sprintf("%-35s : %6d obs.\n", "D3 – s13_1 transferts", nrow(d3_s13_1)))
cat(sprintf("%-35s : %6d obs.\n", "D3 – s13_2 détail transf",nrow(d3_s13_2)))
if (!is.null(d4_s07a))
  cat(sprintf("%-35s : %6d obs.\n", "D4 – s07a repas ext.",   nrow(d4_s07a)))
cat(sprintf("%-35s : %6d obs.\n", "D4 – s07b conso alim.",  nrow(d4_s07b)))
cat(sprintf("%-35s : %6d obs.\n", "D4 – s08a FIES",         nrow(d4_s08a)))
cat(sprintf("%-35s : %6d obs.\n", "D4 – s09a fêtes (12m)",  nrow(d4_s09a)))
cat(sprintf("%-35s : %6d obs.\n", "D4 – s09b dép. 7j",      nrow(d4_s09b)))
cat(sprintf("%-35s : %6d obs.\n", "D4 – s09c dép. 30j",     nrow(d4_s09c)))
cat(sprintf("%-35s : %6d obs.\n", "D4 – s09d dép. 3 mois",  nrow(d4_s09d)))
cat(sprintf("%-35s : %6d obs.\n", "D4 – s09e dép. 6 mois",  nrow(d4_s09e)))
cat(sprintf("%-35s : %6d obs.\n", "D4 – s09f dép. 12 mois", nrow(d4_s09f)))
cat(sprintf("%-35s : %6d obs.\n", "D4 – s14a COVID",        nrow(d4_s14a)))
cat(sprintf("%-35s : %6d obs.\n", "D4 – s14b chocs",        nrow(d4_s14b)))
cat(sprintf("%-35s : %6d obs.\n", "D4 – s15 filets sécurité",nrow(d4_s15)))