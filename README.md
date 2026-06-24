# Ménages, Chocs et Résilience : une lecture multidimensionnelle du Sénégal

### SYR 2026 — 2ᵉ Édition du Mois de la Statistique

> *La vulnérabilité des ménages ne se résume pas à la pauvreté. Elle est multidimensionnelle, dynamique et souvent hybride.*

## Contexte

Ce projet a été réalisé dans le cadre du concours scientifique **SYR 2026**, organisé par le **Bureau des Statistiques de l’Amicale des Élèves et Stagiaires de l’ENSAE** en partenariat avec le **CREG**, à l'occasion de la **2ᵉ édition du Mois de la Statistique**.

À partir des données de l'**Enquête Harmonisée sur les Conditions de Vie des Ménages (EHCVM 2021)**, nous proposons une nouvelle lecture de la vulnérabilité des ménages sénégalais en combinant réduction de dimension, apprentissage non supervisé et clustering flou.

---

## Objectif

Identifier et caractériser les différents profils de ménages au Sénégal afin de mieux comprendre les mécanismes de vulnérabilité, de résilience et d'exposition aux chocs.

Au-delà d'une opposition classique entre ménages pauvres et non pauvres, l'étude met en évidence des profils multidimensionnels où coexistent parfois précarité structurelle, vulnérabilité sociale, faibles dépenses, capital humain ou insertion économique.

---

## Approche méthodologique

### 1. Construction des dimensions latentes

* Analyse en Composantes Principales (ACP)
* Analyse des Correspondances Multiples (ACM)

### 2. Réduction de l'information

Création de six dimensions synthétiques :

* Précarité structurelle et conditions de vie
* Capital humain et insertion économique
* Position socioprofessionnelle et qualité de l'emploi
* Vulnérabilité sociale et familiale
* Dépenses globales du ménage
* Structure du ménage et consommation par tête

### 3. Typologie des ménages

* K-Means optimisé
* Identification automatique du nombre de groupes
* Construction d'une typologie nationale des ménages

### 4. Analyse de l'hybridité

* Fuzzy C-Means
* Mesure du degré d'appartenance à plusieurs profils
* Identification des ménages aux vulnérabilités multiples

---

## Principale contribution

L'analyse montre que les ménages sénégalais ne se répartissent pas dans des catégories rigides.

De nombreux ménages présentent des caractéristiques appartenant simultanément à plusieurs profils socio-économiques. Cette hybridité suggère que les politiques publiques gagneraient à dépasser les approches strictement catégorielles pour mieux prendre en compte la diversité des situations vécues.

---

## 📂 Contenu du dépôt

```text
.
├── data/                 # Données et bases intermédiaires
├── scripts/              # Scripts R
├── livrables/               # Poster scientifique final + Rapport complet
├── docs/                 # Documentation méthodologique
└── README.md
```

---

## Livrables

* Poster scientifique (format A1)
* Rapport complet

  * Présentation des données
  * Méthodologie
  * Résultats
  * Discussion
  * Recommandations

---

## Équipe

### Awa Diaw

GitHub : [https://github.com/awa-d](https://github.com/awa-d)

### Jeanne

GitHub : [https://github.com/lafleche06](https://github.com/lafleche06)

---

## Remerciements

Nous remercions le Bureau des Statistiques de l’Amicale des Élèves et Stagiaires de l’ENSAE ainsi que le CREG pour l'organisation de cette initiative qui contribue à la valorisation de la statistique, de la recherche appliquée et de la science des données au service du développement.

---

**Mots-clés :** Statistique, Machine Learning, Clustering, ACP, ACM, Fuzzy Clustering, Résilience, Vulnérabilité, Sénégal, EHCVM 2021.
