<img src="https://r2cdn.perplexity.ai/pplx-full-logo-primary-dark%402x.png" style="height:64px;margin-right:32px"/>

# Je mène un projet de recherche appliquée à partir des données de l'EHCVM 2021-2022 du Sénégal.

Mon objectif est de construire une typologie des ménages selon leur niveau de vulnérabilité à l'aide d'une Analyse des Correspondances Multiples (ACM) suivie d'une méthode de clustering.
Je souhaite adopter une approche multidimensionnelle de la vulnérabilité.
Je ne cherche pas seulement une liste de variables. Je souhaite d'abord construire un cadre théorique et empirique solide.
Merci de produire une revue structurée répondant aux questions suivantes :
Quels sont les principaux cadres conceptuels de la vulnérabilité des ménages utilisés dans la littérature économique et en développement ?
Présenter les contributions majeures de Chambers, Sen, Dercon, Alwang, Siegel, Jorgensen, World Bank, FAO, WFP et autres références incontournables.
Comparer les définitions de la vulnérabilité.
Distinguer pauvreté, vulnérabilité, résilience et sécurité alimentaire.
Existe-t-il des études empiriques ayant construit une typologie multidimensionnelle des ménages vulnérables ?
Afrique de l'Ouest.
Sénégal.
Pays en développement.
Utilisation d'ACP, ACM, clustering, classification hiérarchique ou k-means.
Fournir les références complètes.
Quels sont les degrés ou profils de vulnérabilité généralement identifiés dans la littérature ?
ménages résilients
vulnérabilité faible
vulnérabilité modérée
vulnérabilité élevée
vulnérabilité chronique
autres catégories observées
Quelles dimensions (piliers) sont les plus fréquemment utilisées pour mesurer la vulnérabilité multidimensionnelle ?
Pour chaque dimension :
justification théorique
résultats empiriques
auteurs de référence
Construire un tableau synthétique :
| Dimension | Justification théorique | Références majeures | Variables généralement utilisées |
Pour chacune des dimensions identifiées, proposer des variables observables compatibles avec les enquêtes ménages de type EHCVM/LSMS.
À partir de ces résultats, proposer un cadre conceptuel adapté à une étude sur le Sénégal utilisant l'EHCVM 2021-2022.
Enfin, proposer plusieurs narratifs scientifiques forts pour un concours de poster de recherche :
angle politique publique ;
angle sécurité alimentaire ;
angle résilience ;
angle agriculture ;
angle inégalités territoriales.
Pour chaque narratif :
titre potentiel ;
question centrale ;
principaux résultats attendus ;
visualisations les plus impactantes ;
message final destiné aux décideurs publics.
Je privilégie les articles académiques, rapports FAO, WFP, Banque mondiale, PNUD et études utilisant explicitement des approches multidimensionnelles de la vulnérabilité.   On utilise ces bases de l'EHCVM welfare  <- import_base(file.path(RAW, "ehcvm_welfare_SEN2021.dta"),  "welfare")
menage   <- import_base(file.path(RAW, "ehcvm_menage_SEN2021.dta"),   "menage")
individu <- import_base(file.path(RAW, "ehcvm_individu_SEN2021.dta"), "individu")
conso    <- import_base(file.path(RAW, "ehcvm_conso_SEN2021.dta"),    "conso")

+ Base ponderation. base
variable
label
type
modalites
ehcvm_conso_SEN2021
country
Pays
character
SEN
ehcvm_conso_SEN2021
year
Annee enquete
numeric

ehcvm_conso_SEN2021
hhid
Identifiant unique menage
numeric

ehcvm_conso_SEN2021
vague
Vague
numeric

ehcvm_conso_SEN2021
grappe
Numero grappe
numeric

ehcvm_conso_SEN2021
menage
Numero menage
numeric

ehcvm_conso_SEN2021
region
Region résidence
haven_labelled
Dakar = 1 ; Ziguinchor = 2 ; Diourbel = 3 ; St-Louis = 4 ; Tambacounda = 5 ; Kaolack = 6 ; Thiès = 7 ; Louga = 8 ; Fatick = 9 ; Kolda = 10 ; Matam = 11 ; Kaffrine = 12 ; Kedougou = 13 ; Sedhiou = 14
ehcvm_conso_SEN2021
milieu
Milieu résidence
haven_labelled
Urbain = 1 ; Rural = 2
ehcvm_conso_SEN2021
hhweight
Ponderation
numeric

ehcvm_conso_SEN2021
codpr
Code produit
haven_labelled
Riz local brisé = 1 ; Riz local entier = 2 ; Riz importé brisé = 3 ; Riz importé entier = 4 ; Maïs en épi = 5 ; Maïs en grain = 6 ; Mil = 7 ; Sorgho = 8 ; Blé = 9 ; Fonio = 10 ; Autres céréales = 11 ; Farine de maïs = 12 ; semoule de mais = 13 ; Farine de mil = 14 ; semoule de mil = 15 ; Farine de blé local ou importé = 16 ; semoule de blé = 17 ; Autres farines de céréales = 18 ; Autres semoules de céréales = 19 ; Pâtes alimentaires = 20 ; Pain moderne = 21 ; Pain traditionnel = 22 ; Croissants = 23 ; Biscuits = 24 ; Gâteaux = 25 ; Beignets, galettes = 26 ; Viande de bœuf = 27 ; Viande de chameau = 28 ; Viande de mouton = 29 ; Viande de chèvre = 30 ; Abats rouges (foie, rognon,  poumon,  cœur, rate, etc.) = 31 ; Viande de porc = 32 ; Poulet sur pied = 33 ; Viande de poulet = 34 ; Viande d'autres volailles domestiques = 35 ; Charcuterie (jambon, saucisson), conserves de viandes = 36 ; Viande séchée (boeuf, mouton, chameau) = 37 ; Gibiers = 38 ; Autres viandes non-déclarées ailleurs = 39 ; Poisson frais yaboye ou obo (sardinelle) = 40 ; Poisson frais thiof/ seudeu (baracouda) = 41 ; Poisson frais wass = 42 ; Autre Poisson frais (dorade, youfouf, rouget, siket [capitaine], thiarumbekh [mollette], …..) = 43 ; Poisson fumé Kethiakh (sardinelle) = 44 ; Autre Poisson fumé (yaboye ou obo fumé, …) = 45 ; Poisson séché = 46 ; Crabes = 47 ; Crevettes fraiches = 48 ; Crevettes séchées = 49 ; Autres fruits de mer = 50 ; Conserves de poisson = 51 ; Lait frais industriel (Bridel, Vitalait, etc.) = 52 ; Lait caillé, yaourt = 53 ; Lait concentré sucré = 54 ; Lait concentré non-sucré = 55 ; Lait en poudre = 56 ; Fromage = 57 ; Lait et farines pour bébé = 58 ; Autres produits laitiers = 59 ; Œufs = 60 ; Beurre = 61 ; Beurre de karité = 62 ; Huile de palme rouge = 63 ; Huile d'arachide raffinée = 64 ; Huile d'arachide 'Segal' = 65 ; Huile de soja = 66 ; Huile de coton = 67 ; Huile de palme raffinée = 68 ; Noix de palme = 69 ; Autres huiles n.d.a. (maïs, huile palmiste, huile d'olive, huile de tournesol, huile de lait de vache etc.) = 70 ; Mangue = 71 ; Ananas = 72 ; Orange = 73 ; Citrons = 74 ; Autres agrumes (mandarine, pamplemousse, etc.) = 75 ; Banane douce = 76 ; Avocats = 77 ; Pastèque = 78 ; Melon = 79 ; Dattes = 80 ; Noix de coco = 81 ; Canne à sucre = 82 ; Pommes = 83 ; Papaye = 84 ; Fruit de baobab (bouye) = 85 ; Néré = 86 ; Autres fruits (tamarin noir, liane sauvage, raisin, fraise, pomme sauvage, etc.) = 87 ; Salade (laitue) = 88 ; Choux = 89 ; Carotte = 90 ; Haricot vert = 91 ; Concombre = 92 ; Aubergine, = 93 ; Courge/Courgette = 94 ; Poivron frais = 95 ; Tomate fraîche = 96 ; Tomate séchée = 97 ; Gombo frais = 98 ; Gombo sec = 99 ;  Oignon frais = 100 ;  Ail = 101 ;  Feuilles d'oseille (bissap) = 102 ;  Feuilles de baobab/ 'laalo' = 103 ;  Feuilles de haricot/ 'niébé' = 104 ;  Feuilles nébédaye (moringa) = 105 ;  Autres légumes en feuilles = 106 ;  Autre légumes frais n.d.a = 107 ;  Concentré de tomate = 108 ;  Petits pois = 109 ;  Petit pois secs = 110 ;  Autres légumes secs n.d.a = 111 ;  Niébé/Haricots secs = 112 ;  Arachides fraîches en coques = 113 ;  Arachides séchées en coques = 114 ;  Arachides décortiquées = 115 ;  Arachides pilées = 116 ;  Arachide grillée = 117 ;  Pâte d'arachide = 118 ;  Fromage à base de soja = 119 ;  Sésame = 120 ;  Noix de cajou = 121 ;  Noix de karité = 122 ;  Manioc = 123 ;  Igname = 124 ;  Plantain = 125 ;  Pomme de terre = 126 ;  Taro, macabo = 127 ;  Patate douce = 128 ;  Autres tubercules n.d.a = 129 ;  Farines de manioc = 130 ;  Gari, tapioca = 131 ;  Attiéke = 132 ;  Fruit de Kapokier = 133 ;  Sucre poudre = 134 ;  Sucre morceaux = 135 ;  Miel = 136 ;  Chocolat à croquer, pâte à tartiner = 137 ;  Caramel, bonbons, confiseries, etc = 138 ;  Sel = 139 ;  Piment séché = 140 ;  Piment frais = 141 ;  Gingembre frais = 142 ;  Gingembre moulu = 143 ;  Cube alimentaire (Maggi, Jumbo, ) = 144 ;  Arôme (Maggi, Jumbo, etc.) = 145 ;  Soumbala (nététou) = 146 ;  Mayonnaise = 147 ;  Vinaigre de citron = 148 ;  Autres vinaigres = 149 ;  Moutarde = 150 ;  Poivre = 151 ;  Autres condiments (laurier etc.) = 152 ;  Noix de cola = 153 ;  Autres produits alimentaires (noix de pomme sauvage) = 154 ;  Café en poudre = 155 ;  Café soluble = 156 ;  Thé (Ataya) = 157 ;  Chocolat en poudre = 158 ;  Autres tisanes et infusions n.d.a. (quinquelibat, citronelle, etc.) = 159 ;  Jus de fruits (orange, bissap, gingembre, jus de cajou,etc.) = 160 ;  Eau minérale/ filtrée = 161 ;  Boissons gazeuses (coca, etc.) = 162 ;  Jus en poudre = 163 ;  Bières et vins traditionnels (dolo, vin de palme, vin de raphia, vin de cajou, etc.) = 164 ; Bières industrielles = 165 ; Céréales de petit déjeuner = 169 ; Abats blancs (pieds, tête, etc.) et tripes (estomac, intestins, etc.) = 170 ; Autre volaille sur pied = 171 ; Con fumé = 172 ; Escargots = 173 ; Lait frais non industriel (méwou rate non fermenté) = 174 ; Huilde de karité = 175 ; Goyave = 176 ; Champignon frais = 177 ; Pâte de manioc = 178 ; Poisson séché en condiment = 179 ; Thé soluble ou infusion = 180 ; Petit déjeuner hors menage = 191 ; Déjeuner hors menage = 192 ; Dîner hors ménage = 193 ; Collation hors ménage = 194 ; Boissons chaudes hors ménage = 195 ; Boisson non alcoolisée hors ménage = 196 ; Boisson alcoolisée hors ménage = 197 ; Cigarettes, Tabac = 201 ; Pétrole lampant = 202 ; Charbon de bois/Charbon minéral = 203 ; Bois de chauffe acheté = 204 ; Bois de chauffe ramassé (estimer la valeur) = 205 ; Bougies = 206 ; Allumettes = 207 ; Carburant pour véhicule = 208 ; Carburant pour motocyclette = 209 ; Transport urbain en taxi = 210 ; Transport urbain en bus = 211 ; Transport urbain/rural en moto-taxi = 212 ; Transport urbain en train = 213 ; Transport urbain/rural par voie fluviale = 214 ; Transport urbain/rural par traction animale = 215 ; Journaux = 216 ; Frais de mouture des céréales = 217 ; Whisky et autres liqueurs = 301 ; Vins modernes = 302 ; Gaz domestique = 303 ; Carburant pour groupe electrogène à usage domestique = 304 ; Piles électriques, = 305 ; Savon de ménage, lessive en poudre, détergents (eau de javel, etc.) = 306 ; Insecticide, tortillon anti-moustique = 307 ; Salaire du personnel de maison (gardien, boy, chauffeur, cuisinier, etc.) = 308 ; Frais de blanchiment des vêtements, linge, etc. (Pressing) = 309 ; Frais de ramassage des ordures ménagères = 310 ; Lavage de véhicules = 311 ; Frais de parking = 312 ; Frais de communication téléphonique dans une cabine/ télécentre = 313 ; Billet de loterie nationale, billet de PMU et tout autre pari sportif = 314 ; Revues, journal ou magazine mensuel etc = 315 ; Frais de coiffure homme et femme (salon, tressage, mèches, coupe, etc.), manucure, pédicure = 316 ; Savon de toilette, shampoing = 317 ; Pâte dentifrice = 318 ; Papier toilette = 319 ; Serviettes hygiéniques, couches jetables pour bébé, etc = 320 ; Lait, lotion de toilette corporelle (glycérine, vaseline, etc.), produits de maquillage = 321 ; Masque facial jetable  contre le COVID-19 = 322 ; Gel hydro-alcoolique = 323 ; Autres produits de toilettes (rasoir, coton, crème/mousse à raser etc.) = 324 ; Loyer fictif autodeclaré = 330 ; Loyer maison = 331 ; Facture eau courante = 332 ; Eau aupres revendeur = 333 ; Facture electricite = 334 ; Facture telephone fixe = 335 ; Facture internet = 336 ; Facture abonnement cable = 337 ; Recharge telephone mobile = 338 ; Frais d'entretien et de réparation de chaussures: cirage, ressemelage, etc = 401 ; Ampoules électriques pour le logement = 402 ; Lubrifiants (huile moteur; huile de frein; liquide batterie (acide); graisses; autres lubrifiants n.d.a.) = 403 ; Services de réparation et d'entretien (vidange, graissage, etc.) de moyens de transport personnel (voitures, motos, bicyclette, etc.) = 404 ; Transport inter-localité par voitures = 405 ; Transport inter-localité à traction animale = 406 ; Transport  interlocalité par eau (bateau, pirogue, pinasse) = 407 ; Frais de timbre postaux, d'expédition de mandat, etc = 408 ; Frais d'envoi de fax = 409 ; Produits pour le jardinage (plantes et fleurs ornementales), pas pour l'agriculture = 410 ; Aliments, frais d'entretien, frais de vétérinaire des animaux de compagnie (chiens, chats, etc.) = 411 ; Droit d'entrée (achat d'un ticket) à des manifestations sportives = 412 ; Droit d'entrée (achat d'un ticket) pour cinéma, concert, pièce de théâtre, musée, expositions, etc = 413 ; Autres services récréatifs: services de photographe (développement, tirage), photo d'identité, etc = 414 ; Masque facial lavable contre le COVID-19 = 415 ; Médicaments achetés en pharmacie sans ordonnance: alcool, pansements, paracétamol, médicaments les affections courantes (paludisme, toux, rhume, diarrhée/disenterie, vers intestinaux, etc.) = 416 ; Parfums = 417 ; Brosse à dents = 418 ; Contraceptifs = 419 ; Frais de photocopies de document = 420 ; Ticket de peage et assimilé = 421 ; Tissus d'habillement: tissus pagne, tissu pagne du tisserand, tissu synthétique, etc = 501 ; Vêtements femmes (15 ans et plus): robe, jupe, pantalon, ensemble, etc = 502 ; Sous-vêtements femme (15 ans et plus): slip, jupon, tee shirt,soutien gorge, collant, etc = 503 ; Vêtements enfants (0-14 ans): layette pour bébé, chemise, pantalon garçon, robe fillette, slip enfant, blouses, etc. (Pas inclure les uniformes scolaires) = 504 ; Vêtements hommes (15 ans et plus): chemise, pantalon, veste, ensemble, vêtements de travail, etc = 505 ; Sous-vêtements homme (15 ans et plus): slip, chaussettes, tee shirt et maillot de corps, etc = 506 ; Frais de confection et de réparation de vêtements homme: ensemble, pantalon, chemise, réparation, location vêtemen = 507 ; Frais de confection et de réparation de vêtements femme: robe, pantalon, jupe, ensemble, réparation, location, etc = 508 ; Frais de confection et de réparation de vêtements enfants = 509 ; Chaussures hommes = 510 ; Chaussures femmes = 511 ; Chaussures enfants = 512 ; Accessoires des chaussures (chausse-pieds; brosses à chaussure, lacet) = 513 ; Habits/chauss. fêtes = 521 ; Matériel pour l'entretien et les petites réparations du logement = 601 ; Main-d'oeuvre et services d'entretien et de réparation courante du logement  (vidange fosse septique,main d'œuvre pour l'entretien du logement = 602 ; Matériaux de maçonnerie pour la construction ou les grosses réparations de logement: ciment, briques, fer à béton, sable, gravier, parpaings, = 603 ; Autres matériaux pour la construction ou les grosses réparations de logement: tôles, bois de charpente, planches, lattes, contre-plaqués, matériaux d'électricité,  plomberie, peinture, carreaux, tapis = 604 ; Main-d'oeuvre pour la construction et les grosses réparation de logement (maçonnerie, toiture et charpente, électricité, plomberi = 605 ; Frais pour creuser ee, menuiseriet aménager un puits ou pour construire un forage = 606 ; Frais d'acquisition d'un terrain ou d'un logement = 607 ; Frais d'études et d'architecte = 608 ; Frais d'abonnement au réseau de distribution d'eau = 609 ; Frais d'abonnement au réseau de distribution d'électricité = 610 ; Frais de connexion au réseau de distribution d'eau = 611 ; Frais de connexion au réseau de distribution d'électricité = 612 ; Meubles de salon et de salle à manger (fauteuils, table, chaises, armoires, etc.) = 613 ; Lit, matelas, armoire et autres meubles de chambre à coucher = 614 ; Réparation de meubles (fauteuils, chaises, lits, armoires, etc.) = 615 ; Linge de maison et articles associés (serviettes de bain, drap, couverture, couvre-lit, oreillers, moustiquaire, nattes, tapis, rideaux, éventail = 616 ; Appareils électro-ménagers: frigo, climatiseurs, réchaud, four, cuisinière, lave-linge, chauffe-eau, fer à repasser, = 617 ; Plaque solaire = 618 ; Batterie pour plaque solaire et autre équipement/matériel pour installation solaire = 619 ; Réparation d'appareils électro-ménagers (fer à repasser, frigo, cuisinière, four, réchaud, climatiseur, ventilateur, chauffe-eau = 620 ; Vaisselle: assiettes, couteau, fourchette, cuillère, gobelets, verres, = 621 ; Ustensiles de cuisine: casserole, marmite, tamis local, réparation d'ustensiles de cuisine = 622 ; Autres ustensiles de ménage: seau, bouilloire, biberon, poubelle, tasses, cafétière non électrique, théière, calebasse, louche, jarre, canari,mortier, pilon = 623 ; Outillage de maison: outils de bricolage (marteau, tournevis, etc.); outil de jardinage = 624 ; Lampes électriques, lampes tempêtes, torches = 625 ; Achat d'une voiture pour usage personnel = 626 ; Achat d'un motocycle (vélo, moto) pour usage personnel = 627 ; Pièces détachées de moyens de transport individuel: pneu, batterie, bougie, carburateur, etc = 628 ; Frais d'assurance d'un moyen de transport individuel (auto, moto, etc.), assurance de voyage = 629 ; Vignette automobile/ moto = 630 ; Location d'un véhicule pour usage personnel: voiture, moto/vélo, etc = 631 ; Transport inter-urbain en train dans le pays et à l'étranger = 632 ; Transport en avion dans le pays et à l'étranger = 633 ; Frais de déménagement = 634 ; Frais de visa, taxes d'aéroport = 635 ; Achat d'un téléphone portable = 636 ; Appareils de musique et d'images: radio, radio-cassette, chaîne de musique, TV, lecteur CD/DVD, MP3, MP4, caméra, camescope = 637 ; Ordinateur, imprimante, tablette,machine à écrire, etc = 638 ; Réparation d'appareils électroniques: radio, radio-cassettes, TV, camera, lecteur CD/DVD, ordinateur, = 639 ; Petit matériel électronique à usage personnel: cassettes, CD/DVD, clé USB, encre pour imprimante, papier d'impression photos, pellicule photos, = 640 ; Articles de sport et de détente: ballon, jeu ludo, poids (pétanque), jeu de carte, jouets pour enfants, jeux vidéo, petits instruments de musique, etc = 641 ; Livres non scolaires, bande dessinée = 642 ; Papier rame, enveloppes, articles de dessin (pinceaux, papier, peinture etc.), = 643 ; Frais de pélérinage = 644 ; Formation professionnelle (en particulier directement auprès des ateliers, maîtres, = 645 ; Frais de cours particuliers pour adultes (alphabétisation) et personnes non scolarisées = 646 ; Services d'hébergement: chambres d'hôtel, etc = 647 ; Montres, réveils = 648 ; Boucle d'oreilles, colliers, bracelets, bijoux, autres articles de bijouterie et joaillerie n.d.a = 649 ; Autres effets personnels: valise, sac de voyage, sac à main, perruques, chapeau, lunettes solaires, parapluies, parasol, canne, porte-monnaie,portefeuille, articles pour fumeurs  articles pour bébé , articles funéraires = 650 ; Frais d'assurance d'une maison ou tout autre bien qu'un moyen de transport = 651 ; Taxes d'habitation (immeubles bâties et non bâties), taxes de voiries = 652 ; Frais d'assurance vie = 653 ; Frais d'assurance maladie = 654 ; Frais d'évacuations sanitaires (hors du pays) = 655 ; Frais de légalisation (confection) de documents administratifs (actes d'Etat-civil,diplômes) = 656 ; Autres services: annonce à la radio, dans un journal/à la télévision, pompe funèbre = 657 ; Frais insc./scol. préscolaire = 701 ; Cotisations préscolaire = 702 ; Livres/cahiers préscolaire = 703 ; Aut. matériel préscolaire = 704 ; Uniformes préscolaire = 705 ; Frais cantine préscolaire = 706 ; Frais transport préscolaire = 707 ; Aut. (soutien, repet.) préscolaire = 708 ; Frais insc./scol. primaire = 709 ; Cotisations primaire = 710 ; Livres/cahiers primaire = 711 ; Aut. matériel primaire = 712 ; Uniformes primaire = 713 ; Frais cantine primaire = 714 ; Frais transport primaire = 715 ; Aut. (soutien, repet.) primaire = 716 ; Frais insc./scol. secondaire 1 = 717 ; Cotisations secondaire 1 = 718 ; Livres/cahiers secondaire 1 = 719 ; Aut. matériel secondaire 1 = 720 ; Uniformes secondaire 1 = 721 ; Frais cantine secondaire 1 = 722 ; Frais transport secondaire 1 = 723 ; Aut. (soutien, repet.) secondaire 1 = 724 ; Frais insc./scol. secondaire 2 = 725 ; Cotisations secondaire 2 = 726 ; Livres/cahiers secondaire 2 = 727 ; Aut. matériel secondaire 2 = 728 ; Uniformes secondaire 2 = 729 ; Frais cantine secondaire 2 = 730 ; Frais transport secondaire 2 = 731 ; Aut. (soutien, repet.) secondaire 2 = 732 ; Frais insc./scol. post-secondaire = 733 ; Cotisations post-secondaire = 734 ; Livres/cahiers post-secondaire = 735 ; Aut. matériel post-secondaire = 736 ; Uniformes post-secondaire = 737 ; Frais cantine post-secondaire = 738 ; Frais transport post-secondaire = 739 ; Aut. (soutien, repet.) post-secondaire = 740 ; Frais insc./scol. supérieur = 741 ; Cotisations supérieur = 742 ; Livres/cahiers supérieur = 743 ; Aut. matériel supérieur = 744 ; Uniformes supérieur = 745 ; Frais cantine supérieur = 746 ; Frais transport supérieur = 747 ; Aut. (soutien, repet.) supérieur = 748 ; Consultation generaliste = 761 ; Consultation specialiste = 762 ; Consultation dentiste = 763 ; Consultation guerisseur = 764 ; Examens medicaux hors hosp. = 765 ; Medic. modernes public hors hosp. = 766 ; Medic. modernes privé hors hosp. = 767 ; Medic. tradi. hors hosp. = 768 ; Vaccinations = 769 ; Circonsition = 770 ; Bilan santé = 771 ; Test Covid = 772 ; Transport ambulance, etc. = 773 ; Hospitalisation = 774 ; Frais accouchement = 775 ; Frais verres correcteurs/monture = 776 ; Béquil./chaises roul./prothèses, etc. = 777 ; Salon (Fauteuils et table basse) = 801 ; Table à manger (table + chaises) = 802 ; Lit = 803 ; Matelas simple = 804 ; Armoires et autres meubles = 805 ; Tapis = 806 ; Fer à repasser électrique = 807 ; Fer à repasser à charbon = 808 ; Cuisinière à gaz ou électrique = 809 ; Bonbonne de gaz = 810 ; Réchaud (plaque) à gaz ou électrique = 811 ; Four à micro-onde ou électrique = 812 ; Foyers améliorés = 813 ; Robot de cuisine électrique (Moulinex) = 814 ; Mixeur/Presse-fruits non électrique = 815 ; Réfrigérateur = 816 ; Congélateur = 817 ; Ventilateur sur pied = 818 ; Radio simple/Radiocassette = 819 ; Appareil TV = 820 ; Magnétoscope/CD/DVD = 821 ; Antenne parabolique / décodeur = 822 ; Lave-linge, sèche linge = 823 ; Aspirateur = 824 ; Climatiseurs/Splits amovibles = 825 ; Tondeuse à gazon et autre article de jardinage = 826 ; Groupe électrogène = 827 ; Voiture personnelle = 828 ; Cyclomoteur/Vélomoteur, motocyclette = 829 ; Bicyclette/Vélo de course = 830 ; Appareil photo = 831 ; Camescope = 832 ; Chaîne Hi Fi = 833 ; Téléphone fixe = 834 ; Téléphone portable = 835 ; Tablette = 836 ; Ordinateur = 837 ; Imprimante/Fax = 838 ; Caméra Vidéo = 839 ; Pirogue et hors-bord (bateaux de plaisance) = 840 ; Fusils de chasse = 841 ; Guitare = 842 ; Piano et autre appareil de musique = 843 ; Immeuble/Maison = 844 ; Terrain non bâti = 845 ; Alimentation fêtes = 901 ; Alimentation mariage/baptême/comm. = 902 ; Alimentation funérailles/autres = 903 ; Boisson fêtes = 904 ; Boisson mariage/baptême/comm. = 905 ; Boisson funérailles/autres = 906 ; Habits/chaussures mar./bapt./comm. = 908 ; Habits/chaussures funér./autres = 909 ; Location salle/chaise fêtes = 910 ; Location salle/chaise mar./bapt./comm. = 911 ; Location salle/chaise funér./autres = 912
ehcvm_conso_SEN2021
modep
Mode d'acquisition
haven_labelled
Achat = 1 ; Autoconso = 2 ; Don = 3 ; Valeur usage BD = 4 ; Loyer imputee = 5
ehcvm_conso_SEN2021
depan
Depense annuelle
numeric

ehcvm_individu_SEN2021
activ7j
Situation d'activite au cours des 7 derniers jours
haven_labelled
Occupe = 1 ; TF cherchant emploi = 2 ; TF cherchant pas = 3 ; Chomeur = 4 ; Inactif = 5 ; Moins de 5 ans = 6
ehcvm_individu_SEN2021
activ12m
Situation d'activite au cours des 12 derniers mois
haven_labelled
Occupe = 1 ; Trav. fam. = 2 ; Non occupe = 3 ; Moins de 5 ans = 4
ehcvm_individu_SEN2021
aff30j
probleme sante au cours des 30 derniers jours
haven_labelled
Fièvre/Paludisme = 1 ; Diarrhée = 2 ; Accident/Blessure = 3 ; Problème dentaire = 4 ; Problème de peau = 5 ; Maladie des yeux = 6 ; Problème de tension = 7 ; Fièvre typhoïde = 8 ; Problème d'estomac (ulcère, cancer, etc) = 9 ; Mal de gorge = 10 ; Toux, rhume = 11 ; Diabète = 12 ; Meningite = 13 ; COVID-19 = 14 ; Complications liées à grossesse ou à l'accouchement = 15 ; Douleurs/fatigue = 16 ; Anémie/drépanocytose = 17 ; Autre = 18 ; Maux de ventre = 19 ; Probleme respiratoire = 20
ehcvm_individu_SEN2021
age
Age en annees revolues
numeric

ehcvm_individu_SEN2021
agemar
Age au premier marriage
numeric

ehcvm_individu_SEN2021
alfa
Alphabet. sait lire/ecrire
haven_labelled
Non = 0 ; Oui = 1
ehcvm_individu_SEN2021
alfa2
Alphabet. sait lire/ecrire/comprend.
haven_labelled
Non = 0 ; Oui = 1
ehcvm_individu_SEN2021
arrmal
Arret activite pour maladie
haven_labelled
Non = 0 ; Oui = 1
ehcvm_individu_SEN2021
bank
compte banque ou autre
haven_labelled
Non = 0 ; Oui = 1
ehcvm_individu_SEN2021
branch
Branche activite
haven_labelled
Agriculture = 1 ; Elevage/syl./peche = 2 ; Indust. extr. = 3 ; Autr. indust. = 4 ; BTP = 5 ; Commerce = 6 ; Restaurant/Hotel = 7 ; Trans./Comm. = 8 ; Education/Sante = 9 ; Services perso. = 10 ; Aut. services = 11
ehcvm_individu_SEN2021
con30j
Consulte 30 dern. jours
haven_labelled
Non = 0 ; Oui = 1
ehcvm_individu_SEN2021
country
Code iso3 du Pays
character
SEN
ehcvm_individu_SEN2021
couvmal
Indivu possede unecouverture maladie
haven_labelled
Non = 0 ; Oui = 1
ehcvm_individu_SEN2021
csp
CSP dansl'emploi principal
haven_labelled
Cadre supérieur = 1 ; Cadre moyen/agent de maîtrise = 2 ; Ouvrier ou employé qualifié = 3 ; Ouvrier ou employé non qualifié = 4 ; Manœuvre, aide ménagère = 5 ; Stagiaire ou Apprenti rénuméré = 6 ; Stagiaire ou Apprenti non rénuméré = 7 ; Travailleur Familial contribuant pour une entreprise familial = 8 ; Travailleur pour compte propre = 9 ; Patron = 10
ehcvm_individu_SEN2021
csp_sec
CSP dansl'emploi secondaire
haven_labelled
Cadre supérieur = 1 ; Cadre moyen/agent de maîtrise = 2 ; Ouvrier ou employé qualifié = 3 ; Ouvrier ou employé non qualifié = 4 ; Manœuvre, aide-ménagère = 5 ; Stagiaire ou Apprenti rémunéré = 6 ; Stagiaire ou Apprenti non rémunéré = 7 ; Travailleur familial contribuant à une entreprise familiale = 8 ; Travailleur pour compte propre = 9 ; Patron = 10
ehcvm_individu_SEN2021
diplome
Diplome le plus eleve
haven_labelled
Aucun = 0 ; CEPE = 1 ; BEPC = 2 ; CAP = 3 ; BT = 4 ; BAC = 5 ; DEUG, DUT, BTS = 6 ; Licence = 7 ; Maitrise = 8 ; Master/DEA/DESS = 9 ; Doctorat/Phd = 10
ehcvm_individu_SEN2021
durarr
Duree d'arret activite pour raison de maladie
haven_labelled
Moins d'une semaine = 1 ; Entre une et deux semaines = 2 ; Plus de deux semaines = 3
ehcvm_individu_SEN2021
educ_hi
Niveau d'education acheve
haven_labelled
Aucun = 1 ; Maternelle = 2 ; Primaire = 3 ; Second. gl 1 = 4 ; Second. tech. 1 = 5 ; Second. gl 2 = 6 ; Second. tech. 2 = 7 ; Postsecondaire = 8 ; Superieur = 9
ehcvm_individu_SEN2021
educ_scol
Niveau d'education actuel
haven_labelled
Maternelle = 1 ; Primaire = 2 ; Secondaire 1  (Post Primaire) générale = 3 ; Secondaire 1  (Post Primaire) technique = 4 ; Secondaire 2 générale = 5 ; Secondaire 2 technique = 6 ; Post secondaire (préparation de diplômes de niveau BAC+2) = 7 ; Supérieur = 8
ehcvm_individu_SEN2021
grappe
Numero de grappe
numeric

ehcvm_individu_SEN2021
handig
Handicap majeur seul
haven_labelled
Non = 0 ; Oui = 1
ehcvm_individu_SEN2021
handit
Handicap tout niveau
haven_labelled
Non = 0 ; Oui = 1
ehcvm_individu_SEN2021
hhid
Idenfiant du menage
numeric

ehcvm_individu_SEN2021
hhweight
Ponderation menage
numeric

ehcvm_individu_SEN2021
hos12m
Hospitalisation au cours des 12 der. mois
haven_labelled
Non = 0 ; Oui = 1
ehcvm_individu_SEN2021
internet
Individu a acces a internet
haven_labelled
Non = 0 ; Oui = 1
ehcvm_individu_SEN2021
lien
Lien de parente
haven_labelled
Chef de ménage = 1 ; Conjoint ( e ) = 2 ; Fils, Fille = 3 ; Père, Mère = 4 ; Petit fils, petite fille = 5 ; Grand-parents = 6 ; Frère, sœur = 7 ; Neveu/Nièce = 8 ; Autres Parents du CM/Conjoint = 9 ; Personne non apparentée au CM/Conjoint = 10 ; Domestique ou parent du domestique = 11
ehcvm_individu_SEN2021
mal30j
Prob. sante 30 dern. jours
haven_labelled
Non = 0 ; Oui = 1
ehcvm_individu_SEN2021
menage
Numero du menage
numeric

ehcvm_individu_SEN2021
milieu
Milieu de résidence
haven_labelled
Urbain = 1 ; Rural = 2
ehcvm_individu_SEN2021
moustiq
A dormi sous moustiquire la nuit derniere
haven_labelled
Non = 0 ; Oui = 1
ehcvm_individu_SEN2021
mstat
Situation matrimoniale
haven_labelled
Célibataire = 1 ; Marié(e) monogame = 2 ; Marié(e) polygame = 3 ; Union libre = 4 ; Veuf(ve) = 5 ; Divorcé(e) = 6 ; Séparé(e) = 7
ehcvm_individu_SEN2021
nation
Nationalité de l'individu
haven_labelled
Bénin = 1 ; Burkina Faso = 2 ; Cape-vert = 3 ; Cote d'ivoire = 4 ; Gambie = 5 ; Ghana = 6 ; Guinee = 7 ; Guinée Bissau = 8 ; Liberia = 9 ; Mali = 10 ; Niger = 11 ; Nigeria = 12 ; Sénégal = 13 ; Serra-Leonne = 14 ; Togo = 15 ; Autre Afrique = 17 ; Autre pays hors Afrique = 18
ehcvm_individu_SEN2021
numind
Numero d'ordre de l'individu dans le menage
numeric

ehcvm_individu_SEN2021
persconsult
Personnel de santé consulté au cours des 30 dern. jrs
haven_labelled
Médecin = 1 ; Infirmier = 2 ; Autres = 3 ; Pas de consultation = 4
ehcvm_individu_SEN2021
region
Region de residence
haven_labelled
DAKAR = 1 ; ZIGUINCHOR = 2 ; DIOURBEL = 3 ; SAINT-LOUIS = 4 ; TAMBACOUNDA = 5 ; KAOLACK = 6 ; THIES = 7 ; LOUGA = 8 ; FATICK = 9 ; KOLDA = 10 ; MATAM = 11 ; KAFFRINE = 12 ; KEDOUGOU = 13 ; SEDHIOU = 14
ehcvm_individu_SEN2021
salaire
Salaire annuel dansl'emploi principal
numeric

ehcvm_individu_SEN2021
salaire_sec
Salaire annuel dansl'emploi secondaire
numeric

ehcvm_individu_SEN2021
scol
Frequente l'ecole en 2020/21
haven_labelled
Non = 0 ; Oui = 1
ehcvm_individu_SEN2021
sectins
Secteur institutionnel de l'emploi principal
haven_labelled
Etat/Collectivités locales = 1 ; Entreprise publique/ parapublique = 2 ; Entreprise Privée = 3 ; Entreprise associative = 4 ; Ménage comme employeur de personnel domestique = 5 ; Organisme international /Ambassade = 6
ehcvm_individu_SEN2021
sectins_sec
Secteur institutionnel de l'emploi secondaire
haven_labelled
Etat/Collectivités locales = 1 ; Entreprise publique/ parapublique = 2 ; Entreprise privée = 3 ; Entreprise associative = 4 ; Ménage comme employeur de personnel domestique = 5 ; Organisme international. /Ambassade = 6
ehcvm_individu_SEN2021
serviceconsult
Service de santé consulté  au cours des 30 dern. jrs
haven_labelled
Hôpital/Clinique = 1 ; Dispensaire = 2 ; Autres = 3 ; Pas de consultation = 4
ehcvm_individu_SEN2021
sexe
Genre
haven_labelled
Masculin = 1 ; Féminin = 2
ehcvm_individu_SEN2021
telpor
Individu possede un telephone portable
haven_labelled
Non = 0 ; Oui = 1
ehcvm_individu_SEN2021
vague
Vague
numeric

ehcvm_individu_SEN2021
volhor
Volume horaire annuel de travail dans l'emploi principal
numeric

ehcvm_individu_SEN2021
volhor_sec
Volume horaire annuel de travail dans l'emploi secondaire
numeric

ehcvm_individu_SEN2021
year
Annee de l'enquete
numeric

ehcvm_individu_SEN2021
resid
Statut de residence de l'individu dans le menage
haven_labelled
Non = 0 ; Oui = 1
ehcvm_menage_SEN2021
car
Menage a voiture
haven_labelled
Non = 0 ; Oui = 1
ehcvm_menage_SEN2021
country
Pays
character
SEN
ehcvm_menage_SEN2021
cuisin
Menage a cuisiniere elec/gaz
haven_labelled
Non = 0 ; Oui = 1
ehcvm_menage_SEN2021
decod
Menage a decodeur/antenne
haven_labelled
Non = 0 ; Oui = 1
ehcvm_menage_SEN2021
eauboi_sp
eau potable saison pluie
haven_labelled
Non = 0 ; Oui = 1
ehcvm_menage_SEN2021
eauboi_ss
eau potable saison seche
haven_labelled
Non = 0 ; Oui = 1
ehcvm_menage_SEN2021
elec_ac
Acces reseau electrique
haven_labelled
Non = 0 ; Oui = 1
ehcvm_menage_SEN2021
elec_ua
Utilise elec. solaire/groupe
haven_labelled
Non = 0 ; Oui = 1
ehcvm_menage_SEN2021
elec_ur
Utilise elec. reseau
haven_labelled
Non = 0 ; Oui = 1
ehcvm_menage_SEN2021
eva_eau
Eaux usées évacuées sainement
haven_labelled
Non = 0 ; Oui = 1
ehcvm_menage_SEN2021
eva_toi
Excréments évacués sainement
haven_labelled
Non = 0 ; Oui = 1
ehcvm_menage_SEN2021
fer
Menage a fer electrique
haven_labelled
Non = 0 ; Oui = 1
ehcvm_menage_SEN2021
frigo
Menage a frigo/congel
haven_labelled
Non = 0 ; Oui = 1
ehcvm_menage_SEN2021
grappe
grappe
numeric

ehcvm_menage_SEN2021
grosrum
Nbr gros ruminants
numeric

ehcvm_menage_SEN2021
hhid
Identifiant menage
numeric

ehcvm_menage_SEN2021
lapin
Nbr lapins
numeric

ehcvm_menage_SEN2021
logem
Occupation logement
haven_labelled
Proprietaire titre = 1 ; Proprietaire sans titre = 2 ; Locataire = 3 ; Autre = 4
ehcvm_menage_SEN2021
menage
Identifiant du ménage
numeric

ehcvm_menage_SEN2021
mur
Mur en materiaux definitifs
haven_labelled
Non = 0 ; Oui = 1
ehcvm_menage_SEN2021
ordin
Menage a ordinateur
haven_labelled
Non = 0 ; Oui = 1
ehcvm_menage_SEN2021
ordure
Déchets évacués sainement
haven_labelled
Non = 0 ; Oui = 1
ehcvm_menage_SEN2021
petitrum
Nbr petits ruminants
numeric

ehcvm_menage_SEN2021
porc
Nbr porcs
numeric

ehcvm_menage_SEN2021
sh_co_eco
Choc covariant économique
haven_labelled
Non = 0 ; Oui = 1
ehcvm_menage_SEN2021
sh_co_natu
Choc covariant naturel
haven_labelled
Non = 0 ; Oui = 1
ehcvm_menage_SEN2021
sh_co_oth
Autres Chocs
haven_labelled
Non = 0 ; Oui = 1
ehcvm_menage_SEN2021
sh_co_vio
Choc covariant violence
haven_labelled
Non = 0 ; Oui = 1
ehcvm_menage_SEN2021
sh_id_demo
Choc idio démographique
haven_labelled
Non = 0 ; Oui = 1
ehcvm_menage_SEN2021
sh_id_eco
Choc idio économique
haven_labelled
Non = 0 ; Oui = 1
ehcvm_menage_SEN2021
sol
Sol en materiaux definitifs
haven_labelled
Non = 0 ; Oui = 1
ehcvm_menage_SEN2021
superf
Superficie agricole (en ha)
numeric

ehcvm_menage_SEN2021
toilet
Toilettes saines
haven_labelled
Non = 0 ; Oui = 1
ehcvm_menage_SEN2021
toit
toit en materiaux definitifs
haven_labelled
Non = 0 ; Oui = 1
ehcvm_menage_SEN2021
tv
Menage a TV
haven_labelled
Non = 0 ; Oui = 1
ehcvm_menage_SEN2021
vague
Vague
numeric

ehcvm_menage_SEN2021
volail
Nbr volailles
numeric

ehcvm_menage_SEN2021
year
Annee enquete
numeric

ehcvm_ponderations_SEN2021
vague

numeric

ehcvm_ponderations_SEN2021
grappe

numeric

ehcvm_ponderations_SEN2021
menage

numeric

ehcvm_ponderations_SEN2021
poids
PS poids de sondage lissé pop_2021
numeric

ehcvm_ponderations_SEN2021
poids_nonlisse
PBrut poids de sondage lissé pop_2021
numeric

ehcvm_welfare_SEN2021
country
Code iso3 du Pays
character
SEN
ehcvm_welfare_SEN2021
dali
Consommation annuelle alim. Du menage
numeric

ehcvm_welfare_SEN2021
dnal
Consommation annuelle non alim. du menage
numeric

ehcvm_welfare_SEN2021
dtot
Consommation annuelle totale du menage
numeric

ehcvm_welfare_SEN2021
grappe
Numero de la grappe
numeric

ehcvm_welfare_SEN2021
hactiv7j
Activite 7 jours du CM
haven_labelled
Occupe = 1 ; TF cherchant emploi = 2 ; TF cherchant pas = 3 ; Chomeur = 4 ; Inactif = 5 ; Moins de 5 ans = 6
ehcvm_welfare_SEN2021
hactiv12m
Activite 12 mois du CM
haven_labelled
Occupe = 1 ; Trav. fam. = 2 ; Non occupe = 3 ; Moins de 5 ans = 4
ehcvm_welfare_SEN2021
hage
Age du CM
numeric

ehcvm_welfare_SEN2021
halfa
Alpha. lire/ecr. CM
haven_labelled
Non = 0 ; Oui = 1
ehcvm_welfare_SEN2021
halfa2
Alpha. lire/ecr./comp. CM
haven_labelled
Non = 0 ; Oui = 1
ehcvm_welfare_SEN2021
hbranch
Branche d'activite du CM
haven_labelled
Agriculture = 1 ; Elevage/syl./peche = 2 ; Indust. extr. = 3 ; Autr. indust. = 4 ; BTP = 5 ; Commerce = 6 ; Restaurant/Hotel = 7 ; Trans./Comm. = 8 ; Education/Sante = 9 ; Services perso. = 10 ; Aut. services = 11
ehcvm_welfare_SEN2021
hcsp
categorie socioprofessionnelle du CM
haven_labelled
Cadre supérieur = 1 ; Cadre moyen/agent de maîtrise = 2 ; Ouvrier ou employé qualifié = 3 ; Ouvrier ou employé non qualifié = 4 ; Manœuvre, aide ménagère = 5 ; Stagiaire ou Apprenti rénuméré = 6 ; Stagiaire ou Apprenti non rénuméré = 7 ; Travailleur Familial contribuant pour une entreprise familial = 8 ; Travailleur pour compte propre = 9 ; Patron = 10
ehcvm_welfare_SEN2021
hdiploma
Diplome du CM
haven_labelled
Aucun = 0 ; CEPE = 1 ; BEPC = 2 ; CAP = 3 ; BT = 4 ; BAC = 5 ; DEUG, DUT, BTS = 6 ; Licence = 7 ; Maitrise = 8 ; Master/DEA/DESS = 9 ; Doctorat/Phd = 10
ehcvm_welfare_SEN2021
heduc
Education du CM
haven_labelled
Aucun = 1 ; Maternelle = 2 ; Primaire = 3 ; Second. gl 1 = 4 ; Second. tech. 1 = 5 ; Second. gl 2 = 6 ; Second. tech. 2 = 7 ; Postsecondaire = 8 ; Superieur = 9
ehcvm_welfare_SEN2021
hgender
Genre du CM
haven_labelled
Masculin = 1 ; Féminin = 2
ehcvm_welfare_SEN2021
hhandig
Handicap majeur CM
haven_labelled
Non = 0 ; Oui = 1
ehcvm_welfare_SEN2021
hhid
Idenfiant menage
numeric

ehcvm_welfare_SEN2021
hhsize
Taille menage
numeric

ehcvm_welfare_SEN2021
hhweight
Ponderation menage
numeric

ehcvm_welfare_SEN2021
hmstat
Situation matrimoniale du CM
haven_labelled
Célibataire = 1 ; Marié(e) monogame = 2 ; Marié(e) polygame = 3 ; Union libre = 4 ; Veuf(ve) = 5 ; Divorcé(e) = 6 ; Séparé(e) = 7
ehcvm_welfare_SEN2021
hnation
Nationalite du CM
haven_labelled
Bénin = 1 ; Burkina Faso = 2 ; Cape-vert = 3 ; Cote d'ivoire = 4 ; Gambie = 5 ; Ghana = 6 ; Guinee = 7 ; Guinée Bissau = 8 ; Liberia = 9 ; Mali = 10 ; Niger = 11 ; Nigeria = 12 ; Sénégal = 13 ; Serra-Leonne = 14 ; Togo = 15 ; Autre Afrique = 17 ; Autre pays hors Afrique = 18
ehcvm_welfare_SEN2021
hreligion
Religion du CM
haven_labelled
Musulman = 1 ; Chrétien = 2 ; Animiste = 3 ; Autre Réligion = 4 ; Sans Réligion = 5
ehcvm_welfare_SEN2021
hsectins
Secteur institutionnel du CM
haven_labelled
Etat/Collectivités locales = 1 ; Entreprise publique/ parapublique = 2 ; Entreprise Privée = 3 ; Entreprise associative = 4 ; Ménage comme employeur de personnel domestique = 5 ; Organisme international /Ambassade = 6
ehcvm_welfare_SEN2021
menage
Numero du menage
numeric

ehcvm_welfare_SEN2021
milieu
Milieu de résidence
haven_labelled
Urbain = 1 ; Rural = 2
ehcvm_welfare_SEN2021
pcexp
Indicateur de bien-être
numeric

ehcvm_welfare_SEN2021
region
Region de residence
haven_labelled
DAKAR = 1 ; ZIGUINCHOR = 2 ; DIOURBEL = 3 ; SAINT-LOUIS = 4 ; TAMBACOUNDA = 5 ; KAOLACK = 6 ; THIES = 7 ; LOUGA = 8 ; FATICK = 9 ; KOLDA = 10 ; MATAM = 11 ; KAFFRINE = 12 ; KEDOUGOU = 13 ; SEDHIOU = 14
ehcvm_welfare_SEN2021
vague
Vague
numeric

ehcvm_welfare_SEN2021
year
Annee enquete
numeric

ehcvm_welfare_SEN2021
zref
Seuil de pauvrete national
numeric

Merci — très utile d’avoir fourni la base de données et vos objectifs. Je vous fournis ci‑dessous une revue structurée, ciblée sur la construction d’un cadre conceptuel et empirique pour une typologie multidimensionnelle de la vulnérabilité des ménages (ACM + clustering) appliquée à l’EHCVM 2021–2022 (Sénégal). La revue privilégie articles académiques et rapports d’agences (Banque mondiale, FAO, WFP, PNUD) et contient : cadres conceptuels, comparaisons définitions, études empiriques pertinentes (Afrique de l’Ouest, Sénégal, pays en développement) utilisant ACP/ACM/clustering, dimensions usuelles, variables compatibles EHCVM, proposition de cadre adapté, profils types et narratifs scientifiques pour un poster. Références complètes en fin.

1) Principaux cadres conceptuels de la vulnérabilité des ménages

- Vulnerability as expected poverty (ex ante risk of becoming poor)
    - Approche économétrique : mesurer probabilité que ménage tombe sous seuil de pauvreté (vulnerability as expected poverty, VEP) — Chaudhuri, Jalan \& Suryahadi (2002); Pritchett, Suryahadi \& Sumarto variants.
    - Forces : clair, utilisable avec panel/économétrie; Limites : centré sur revenu/consommation, statique.
- Vulnerability as low expected utility / downside risk
    - Périmètre utilitariste : exposition à perte d’utilité (vulnerability as low expected utility — VEU) (e.g., Ligon \& Schechter).
    - Met l’accent sur la gestion du risque (préférences inter-temporelles).
- Vulnerability as uninsured exposure to shocks (Dercon)
    - Dercon (2004, 2005) et travaux apparentés : vulnérabilité liée à fréquence et gravité des chocs, capacité d’absorption (coping) et d’adaptation (assets, markets, institutions).
    - Articule risques covariants vs idiosyncratiques, marchés incomplets et actifs de protection.
- Multidimensional vulnerability / Capabilities approach
    - Inspirations Sen (capabilities), Chambers (vulnérabilité et pauvreté vue de l’« intérieur »), PNUD multidimensional poverty approach.
    - Focalise non seulement sur revenus mais sur accès aux capacités (santé, éducation, sécurité alimentaire, actifs, réseaux sociaux).
- Asset‑based and livelihood frameworks
    - Sustainable Livelihoods Framework (DFID), Alwang, Siegel \& Jorgensen (2001): vulnérabilité liée à actifs (humains, sociaux, naturels, physiques, financiers), contextes et transformations (institutions et politiques).
- Food security / resilience frameworks
    - FAO/WFP/IFPRI/PNUD: sécurité alimentaire (availability, access, utilization, stability) liée à vulnérabilité; résilience (capacité à anticiper, absorber, adapter, transformer).
- Social vulnerability / exposure‑sensitivity adaptive capacity
    - Approches issues du changement climatique/disaster risk reduction : vulnérabilité = f(exposition, sensibilité, capacité d’adaptation) (IPCC framing).

Contributions majeures (sélection)

- Robert Chambers — “Vulnerability, coping and policy” (1989), et travaux sur participatory poverty assessment : insiste sur voix/expériences locales, facteurs subjectifs, diversité des stratégies de survie.
- Amartya Sen — Capabilities approach (e.g., Development as Freedom, 1999): pauvreté et vulnérabilité comme manque de capacités de fonctionnement, pas seulement revenu.
- Stefan Dercon — Nombreux travaux 1998–2014 : marchés incomplets, chocs et risques, micro‑assurance, rôle des actifs; “Poverty and Risk” (2004) et articles empiriques sur East Africa.
- Erick Alwang, Paul Siegel, Seth Jorgensen — “Vulnerability: A View from Different Disciplines” (2001, World Bank/IFPRI style) : propose taxonomie et méthodes de mesure, distingue exposition, susceptibility, coping.
- Banque mondiale — Rapports (World Development Report 2014 on risk \& opportunity) et travaux sur vulnerabilité et pauvreté ; VEP methodology (Hoddinott et al. variants).
- FAO — Cadres sur sécurité alimentaire et vulnérabilité (VAC analyses, Food Security and Nutrition conceptual work).
- WFP — Cadres VAM (Vulnerability Analysis and Mapping), Integrated Phase Classification (IPC) ; métriques de vulnérabilité alimentaire (HHS, rCSI, FCS).
- PNUD — Human Development Reports, Human Development Index et indices multidimensionnels (MPI) ; rapports sur résilience.
- IFPRI — Analyses d’impact des chocs alimentaires/prix ; travaux méthodologiques sur indices multidimensionnels.
- Chaudhuri, Jalan \& Suryahadi — formalisation VEP et implémentations empiriques.
- Ligon \& Schechter — discussion VEU et critères alternatifs.

2) Comparer les définitions : pauvreté vs vulnérabilité vs résilience vs sécurité alimentaire

- Pauvreté : statut actuel ; mesuré par revenu/consommation ou dimensions (MPI). Ex post : état observé (consommation < seuil). Référence : Ravallion (1992), Alkire \& Foster (MPI).
- Vulnérabilité : risque futur d’être dans la pauvreté ou d’expérimenter une dégradation importante ; peut être ex ante (probabilité) ou ex post (exposition/impact). Définitions se ramènent à : (i) probabiliste (VEP, VEU), (ii) exposition à chocs sans protection (Dercon), (iii) multidimensionnelle (perte de capacités).
- Résilience : capacité d’un ménage/communauté à anticiper, absorber, adapter et transformer après un choc pour retrouver/maintenir le niveau de bien‑être. Mesure centrée sur capacités, trajectoires et vitesse de reprise (Adger, 2000; FAO, 2016; USAID/Rapid).
- Sécurité alimentaire : disponibilité, accès, utilisation et stabilité des ressources alimentaires. Sécurité alimentaire peut être résultat d’une faible vulnérabilité alimentaire ; mais un ménage peut être non‑pauvre mais food insecure (instabilité). Référence : FAO (1996 instituant la définition), WFP/VAM.
- Relations :
    - Pauvreté est un état ; vulnérabilité est un risque/propension ; résilience est une capacité (à réduire vulnérabilité) ; sécurité alimentaire est un domaine de bien‑être spécifique (liée mais distincte).
    - Exemple : ménage non pauvre aujourd’hui (consommation>seuil) mais vulnérable s’il dépend d’une seule culture rainfed exposée aux chocs climatiques ; ce ménage a faible résilience et risque de devenir food insecure.

3) Études empiriques construisant typologies multidimensionnelles (ACP/ACM/clustering)
Résumé des études pertinentes (Afrique de l’Ouest, Sénégal, pays en développement) qui utilisent ACP/ACM/PCA, clustering, classification hiérarchique, k‑means.

- Afrique de l’Ouest / Sahel
    - Barrett, Reardon, Webb (2001–2006) — typologies de moyens de subsistance, souvent par MFA/PCA et clustering pour segmenter ménages vulnérables (tropicaux/AGRICULTURE, salariales, pastorales). Référence : Barrett et al., “Household Livelihood Diversification” (JDE).
    - Hoddinott \& Yohannes (2002) — uses PCA for household food security indicators; not exactly vulnerability typology but methodologically relevant.
    - Dercon \& Krishnan (2000) — Ethiopia, use of multidimensional indicators and typologies of risk-coping; applied cluster analysis in some follow-ups.
    - FAO/IFPRI country studies often use PCA + cluster to produce livelihood typologies (e.g., Niger, Mali).
- Sénégal
    - Études nationales et rapports (FAO, WFP VAM) ont construit classifications de ménages selon vulnérabilité alimentaire et moyens de subsistance en combinant indicateurs (active laine). Exemples :
        - WFP Senegal VAM reports (2010s–2020s) — cartographies vulnérabilité alimentaire, typologies par zone et système de production.
        - IFPRI/ANSD/NIAE household studies using PCA to build asset indices and cluster households by livelihood.
    - Articles académiques précis : certains travaux locaux (universités sénégalaises) appliquent ACP/ACM + clustering sur ENSAN/ESAM pour profiler pauvreté ; révisions bibliographiques suggèrent que l’usage d’ACM (variables catégorielles) est approprié pour EHCVM. (Références ci‑dessous).
- Pays en développement (Asie, Afrique, Amérique latine)
    - Alkire \& Foster (2011) — MPI methodology (multidimensional poverty) uses categorical indicators and cutoff aggregation; segmentation studies use clustering on deprivation vectors.
    - Sabates‑Wheeler \& Devereux — Livelihood typologies using PCA/cluster.
    - Studies applying MCA/ACM: Filmer \& Pritchett (asset index via PCA); for categorical assets MCA/ACM (Greenacre) recommended. Recent applied papers use ACM + clustering to form household types for targeting social protection (e.g., Latin America).
- Méthodologie : la littérature montre l’efficacité d’un pipeline « sélection multidimensionnelle de variables → codage (catégories) → ACM (pour variables catégorielles) ou PCA (pour variables continues) → réduction dimensionnelle → clustering (k‑means, hierarchical, partitioning around medoids) → validation (silhouette, stability, external variables) ».

Références d’études empiriques (exemples concrets)

- Chaudhuri, S., Jalan, J., \& Suryahadi, A. (2002). “Assessing Vulnerability to Poverty”: Theory and Empirical Evidence from Indonesia. World Bank Policy Research Working Paper 2307.
- Dercon, S. (2004). “Vulnerability: A Micro Perspective.” Background paper for the World Development Report 2004.
- Alwang, J., Siegel, P.B., \& Jørgensen, S.L. (2001). “Vulnerability: A View from Different Disciplines.” World Bank/IFPRI.
- Barrett, C. B., Reardon, T., \& Webb, P. (2001). “Nonfarm Income Diversification and Household Livelihood Strategies in Rural Africa.” Food Policy.
- Alkire, S., \& Foster, J. (2011). “Counting and Multidimensional Poverty Measurement.” Journal of Public Economics.
- WFP Vulnerability Analysis and Mapping (VAM) reports — country briefs (Sénégal reports, various years).
- FAO, IFPRI country vulnerability assessments (Niger/Mali/Senegal) — rapports techniques.
- Filmer, D., \& Pritchett, L. (2001). “Estimating wealth effects without expenditure data — or tears: An application to educational enrollments in states of India.” Demography.
- Greenacre, M. (2007). “Correspondence Analysis in Practice.” (méthodologie ACM/CA).
- Ligon, E., \& Schechter, L. (2003). “Measuring Vulnerability.” Economic Journal.

(Plus bas : liste de références complètes.)

4) Profils / degrés de vulnérabilité identifiés dans la littérature
Typologies fréquentes (noms varient selon études) :

- Ménages résilients / non vulnérables : diversification des revenus, actifs agricoles et non agricoles, accès marchés, peu exposés à chocs ou capables d’absorber/recouvrer rapidement.
- Vulnérabilité faible / faible risque : sécurisé en termes de consommation, actifs, certaines fragilités saisonnières.
- Vulnérabilité modérée / transitoire : revenus proches du seuil, exposition saisonnière aux chocs; coping mécanismes limités, usage modéré des actifs.
- Vulnérabilité élevée / aiguë : consommation souvent sous seuil après choc, actifs faibles, endettement élevé, sécurité alimentaire instable.
- Vulnérabilité chronique / persistent poor : pauvreté persistante liée à manque d’actifs, marginalisation (géographique/ethnique), handicaps structurels.
- Profils additionnels observés :
    - « Middle households » with decent consumption but high exposure (asset poor but income-seasonal).
    - « Asset-poor but cash-rich » (peu commun) — ménages urbains avec crédit.
    - Ménages dépendants d’un seul revenu agricole (mono‑source) versus diversifiés.
    - Ménages « coping but vulnerable » qui utilisent stratégies dommageables (sale of productive assets, child labor).
Exemples d’étiquettes issues de rapports WFP/FAO: Highly food insecure, Moderately food insecure, Marginally food secure, Food secure.

5) Dimensions (piliers) fréquemment utilisées pour mesurer vulnérabilité multidimensionnelle
Dimensions usuelles : (je présente chaque dimension avec justification théorique, résultats empiriques et auteurs de référence)

- A. Biens et richesse / actifs (physiques et financiers)
    - Justification : actifs déterminent buffer contre chocs, capacité d’investissement, et accès au crédit ; fondamentaux pour absorption.
    - Empirique : asset index corrèle fortement avec consommation et sécurité alimentaire (Filmer \& Pritchett; Hoddinott).
    - Références : Filmer \& Pritchett (2001), Dercon (2004), Alwang et al. (2001).
    - Variables typiques : possession de frigo, TV, ordinateur, véhicules; propriété du logement; superficie agricole; nombre de bétails; accès au crédit.
- B. Revenus et diversification des sources (livelihood diversification)
    - Justification : diversifier réduit exposition à chocs covariants; flux monétaires réguliers améliorent résilience.
    - Empirique : ménages diversifiés montrent moins de volatilité de consommation (Barrett et al.).
    - Variables : part des revenus agricoles vs non agricoles, nombre d’activités, salaires, travail migrant, transferts.
- C. Consommation / niveau de bien‑être (ex post welfare)
    - Justification : mesure directe du statut actuel et base pour VEP.
    - Empirique : consommation annuelle par adulte équivalent; sécurité alimentaire (FCS, rCSI) corrélée.
    - Variables : dtot, dail, pcexp, seuil pauvreté (zref).
- D. Sécurité alimentaire et nutrition
    - Justification : composante centrale de bien‑être, sensible aux chocs climatiques/prix.
    - Empirique : HHS, rCSI, FCS, consommation calorique; forte littérature (WFP/FAO).
    - Variables : fréquence repas, rCSI proxies, partage dépenses alimentaires, consommation calorique (poss. calculable à partir conso).
- E. Capital humain (éducation, santé)
    - Justification : compétences, productivité, capacité d’emploi, mortalité/morbidity affectent vulnérabilité.
    - Empirique : niveau d’éducation chef de ménage corrélé à consommation et probabilité d’être pauvre; santé (maladie) cause perte de revenu.
    - Variables : niveau d’éducation CM (heduc/hdiploma), santé (mal30j, hos12m), couverture maladie.
- F. Accès aux services de base / infrastructures (eau, assainissement, électricité)
    - Justification : réduit coûts de transaction, améliore santé, productivité ; signale inclusion.
    - Empirique : logement durable, accès eau potable, toilette, électricité corrélés à faible vulnérabilité.
    - Variables : elec_ur, elec_ua, eau potable saison sèche/ pluie (eauboi_ss/eauboi_sp), toilet, eva_eau, mur/toit/sol.
- G. Réseaux sociaux et transferts (social protection, remittances)
    - Justification : filets sociaux et transferts forment filets de sécurité ; social capital facilite partage de risque.
    - Empirique : transferts et remittances réduisent volatilité; participation programmes sociaux (variable souvent absent) réduit probabilité de chute.
    - Variables : bank (compte), transferts reçus (si disponibles), indicateurs de choc covariant \& d’aide.
- H. Chocs et exposition (exposition aux risques naturels, économiques, santé)
    - Justification : exposition directe qui déclenche vulnérabilité ; évalue fréquence \& type de chocs.
    - Empirique : sh_co_natu, sh_co_eco, sh_id_* dans EHCVM ; corrélation fortes avec détérioration de consommation.
    - Variables : sh_co_natu, sh_co_eco, sh_co_vio, sh_id_demo, sh_id_eco, pertes récoltes signalées.
- I. Capacités financières / liquidité (épargne, crédit)
    - Justification : accès au crédit/épargne permet lissage; absence mène à ventes d’actifs.
    - Empirique : accès aux comptes (bank, telpor?), possession d’actifs facilement monétisables.
    - Variables : bank, possession telpor (proxy d’accès mobile money), dettes (si disponible).
- J. Gouvernance locale / accès marché et institutions
    - Justification : marchés fonctionnels et institutions publiques réduisent risque.
    - Empirique : études montrent importance d’accès routes, marchés, extension agricole, prix stables.
    - Variables proxys : distance marché (si dispo), région/zone, densité urbaine/rurale (milieu, region), grappe.

Synthèse tableau (format textuel demandé)

- Je fournis ci‑dessous le tableau synthétique demandé (chaque ligne = Dimension | Justification | Références majeures | Variables généralement utilisées (compatibles EHCVM)).

Dimension | Justification théorique | Références majeures | Variables généralement utilisées (EHCVM compatibles)

- Biens / Actifs physiques \& productifs | Les actifs servent de cushion: production, vente, collatéral et capital de reproduction, déterminent capacité d’absorption | Filmer \& Pritchett (2001); Dercon (2004); DFID SLF; Alwang et al. (2001) | frigo, tv, ordin, voiture (car), moto (volonté), loyer imputé, mur/toit/sol, superf (superficie agricole), nb bétail (grosrum, petitrum, volail), porc, lapin
- Revenus \& diversification | Diversification réduit l’exposition aux chocs covariants; revenus stables améliorent résilience | Barrett et al. (2001); Dercon; Hoddinott | hactiv7j/hactiv12m, hbranch, salaire, salaire_sec, volhor, part revenu agricole (construction à partir conso ou activité), transferts (si dispo)
- Consommation / bien‑être (welfare) | Mesure du niveau actuel et base pour VEP; indicateur principal de pauvreté | Chaudhuri et al. (2002); Ravallion | dtot, dail, dnal, pcexp, zref (seuil)
- Sécurité alimentaire \& nutrition | Domaine central du bien‑être; directement sensible aux chocs et saisonnalité | FAO (1996); WFP VAM; Maxwell, Webb | consommation alimentaire (conso items → calories), FCS/rCSI (calculable), fréquence repas (si dispo), share alim. (dali/dtot)
- Capital humain (éducation \& santé) | Education et santé déterminent productivité, opportunités et coût de choc | Sen; Dercon; Hoddinott | heduc/hdiploma/halfa, age CM (hage), mal30j, hos12m, couverture maladie (couvmal)
- Accès services de base (infrastructures) | Influence santé, productivité, coûts de reproduction, signale inclusion | World Bank WDR; DFID | elec_ac/elec_ur/elec_ua, eauboi_ss/sp, toilet, eva_eau, eva_toi, loyer, ordure
- Réseaux sociaux \& transferts | Transferts/solidarité réduisent pertes; filets garantissent lissage | Dercon; Adger | bank (compte), remittances (si dispo), indicateurs aide, composition ménage (hhsize)
- Exposition aux chocs | Chocs déclenchent basculement; nature des chocs informe mécanismes de protection | Dercon; IPCC (vulnerability) | sh_co_natu, sh_co_eco, sh_co_vio, sh_co_oth, sh_id_demo, sh_id_eco
- Liquidité \& accès crédit | Permet lissage, investissement; absence cause ventes d’actifs | Dercon; World Bank | bank, telpor (mobile money prox), dettes (si dispo)
- Marchés \& institutions locales | Accès marché et institutions modèrent impacts des chocs | Barrett; World Bank | region, milieu, grappe, distance marché proxy (si disposée), accès internet (internet), hsectins

6) Variables observables compatibles avec EHCVM (pour chaque dimension)
Je liste variables précises extraites de votre description EHCVM (nom var entre parenthèses) ; celles-ci sont directement utilisables ou calculables :

- Actifs / richesse
    - biens durables : frigo, tv, ordin (ordinateur), car (voiture), fer, decod, cuisin (cuisinière), plaque solaire (indice), mobilier (si dispo).
    - logement \& matériaux : mur, toit, sol, logem (type d’occupation), loyer (imputed), superficie agricole (superf).
    - bétail et production : grosrum, petitrum, volail, porc, lapin.
- Revenus \& diversification
    - activité chef mén. (hbranch, hactiv7j/hactiv12m), salaire, salaire_sec, volhor, csp/hcsp (cat socio‑pro), branche/branch.
- Consommation \& bien‑être
    - dtot (consommation totale), dali (aliments), dnal (non‑aliments), pcexp or pcexp indicator, zref (threshold).
    - calculer consommation par adulte équivalent (household size = hhsize).
- Sécurité alimentaire
    - conso items détaillés (codpr + depan leads to annual expenditure per item → compute FCS/rCSI if frequencies present; otherwise use share of food consumption).
    - Food share = dali/dtot.
- Capital humain
    - niveau éducation CM (heduc/hdiploma/halfa), age CM (hage), mal30j, hos12m, couverture maladie (couvmal), handicap (handig/handit).
- Services de base /infrastructures
    - elec_ur/elec_ac/elec_ua, eauboi_sp/eauboi_ss, toilet, eva_eau, eva_toi, ordure.
- Réseaux \& transferts
    - bank (compte bancaire), telpor (possède portable), indications sur transferts (si variable dispo dans conso ou welfare).
- Exposition aux chocs
    - sh_co_natu, sh_co_eco, sh_co_vio, sh_co_oth, sh_id_demo, sh_id_eco (variables prêtes dans menage).
- Liquidité \& crédit
    - bank (compte), salaire, salaire_sec, possesions monétisables (car, tv).
- Institutions \& marché (proxies)
    - region, milieu (urbain/rural), internet (accès individuel), grappe.

7) Proposition de cadre conceptuel adapté pour l’EHCVM Sénégal (2021–2022) — orienté ACM + clustering

- Objectif : construire une typologie multidimensionnelle des ménages selon vulnérabilité ex ante et ex post, intégrant exposition, capacités (actifs), niveau de bien‑être et sécurité alimentaire.
- Etapes conceptuelles :

1. Définir finalité : typologie utile pour ciblage politique (filets) et compréhension des trajectoires vulnérables (résilience).
2. Sélection multidimensionnelle d’indicateurs (voir dimensions/variables ci‑dessus). Inclure indicateurs d’exposition (sh_co_*), actif/productif (bétail, superf), services (eau, électricité), capital humain (éducation, santé), consommation et sécurité alimentaire.
3. Préparation des variables : coder variables catégorielles (possession d’actifs, accès services) et discrétiser continues (superficie, consommation p.c. quintiles ou bins), traiter valeurs manquantes, appliquer pondérations d’enquête (hhweight).
4. Réduction dimensionnelle adaptée aux types de variables :
        - Pour variables majoritairement catégorielles/ binaires : Utiliser Analyse des Correspondances Multiples (ACM) — adapté à vos objectifs.
        - Pour variables continues (consommation per capita, superficie) : standardiser et inclure par PCA, ou discretiser et inclure dans ACM.
        - Alternative : combiner résultat ACM (axes principaux) et PCA axes via concaténation puis clustering.
5. Clustering : appliquer plusieurs méthodes (k‑means sur axes continus, partitioning around medoids (PAM), clustering hiérarchique avec linkage Ward) ; choisir k via gap statistic, silhouette, stability bootstrap. Tenir compte poids d’enquête lors de calcul distances (ou poststratifier clusters).
6. Validation : internes (silhouette, within‑cluster sum of squares), externes (corrélation clusters avec pcexp, zref, sécurité alimentaire), robustness (various k, methods), et interprétabilité (profils moyens par cluster).
7. Nommage et interprétation : labelliser profils (résilient, faible vulnérabilité, modérée, élevée, chronique) selon règles transparentes (ex : cluster avec dtot>1.25*zref + faible exposition = résilient).
8. Analyse spatiale et politique : cartographier prévalence par region/grappe, évaluer ciblage programmes.
- Mesure ex ante (vulnérabilité probabiliste) complémentaire :
    - Estimer VEP (E[pov_{t+1}]) via modèles économétriques (e.g., log consumption regressions, estimate variance of shocks) pour produire risque de basculement, et l’ajouter comme variable dans typologie ou comme critère de classement.
- Mesure résilience :
    - Construire indices proxies (diversification des revenus, assets liquidables, accès aux services, banques) ; combiner dans score résilience.

8) Méthodologie pratique recommandée (pipeline détaillé rapide)

- Sélection variables (voir tableau).
- Traitement : imputation ponctuelle, création d’indicateurs binaires/ cat.
- Réduction dimensions : ACM (package FactoMineR / CA / ade4), garder axes cumulant ~60–80% inertie utile (pragmatique).
- Clustering : standardiser axes, essayer kmeans, PAM, hierarchical(Ward), déterminer k par gap statistic, silhouette, bootstrap.
- Post‑hoc : profiler clusters (moyennes, part de ménages pauvre, food share, exposition chocs), tests statistiques (chi2, ANOVA) pour différences.
- Robustesse : sensibilité à pondérations (use hhweight), imputations, découpage variables.
- Visualisations : biplot ACM axes, dendrogramme, cartes régionales, heatmap des indicateurs par cluster, distribution consommation par cluster, spider/radar charts résilience dimensions.

9) Profils types et critères de classification (exemples de règles opérationnelles)

- Ménages « résilients » : dtot/adult > 1.5*zref, faibles chocs signalés, actifs productifs (superf > X, bétail), diversification revenus, accès services (électricité, eau), bank=1.
- Vulnérabilité faible : consommation > zref, faible exposition mais actifs limités.
- Vulnérabilité modérée : consommation proche du seuil (0.75–1.25*zref), chocs récents sporadiques, vente occasionnelle d’actifs.
- Vulnérabilité élevée : dtot < zref, forte exposition (sh_co_natu=1 ou sh_co_eco=1), faibles actifs, sécur. alimentaire instable.
- Vulnérabilité chronique : dtot << zref, taille mén large, faible capital humain, santé/maladie récurrente, peu de diversification.
- Autres catégories observées : « urbain non‑poor but food insecure » ; « pastoraux exposés » ; « migrants-receiver ».
(Choisir seuils empiriques selon distribution dtot, pcexp et zref.)

10) Narratifs scientifiques pour un concours de poster (5 angles)
Je propose pour chaque angle : titre potentiel, question centrale, principaux résultats attendus, visualisations, message final aux décideurs.

Angle politique publique

- Titre potentiel : “Cibler l’aide au Sénégal : typologies multidimensionnelles pour un meilleur ciblage des filets sociaux”
- Question centrale : Quels types de ménages sont les plus susceptibles de basculer en pauvreté et comment prioriser l’action publique ?
- Résultats attendus : identification de clusters à forte probabilité de basculement (vulnérabilité élevée \& exposition), cartes régionales de concentration, évaluation capacité cible actuelle couvre (ex : % pauvres non couverts).
- Visualisations : carte choroplèthe régionale des parts de ménages vulnérables; heatmap variables par cluster; barres part de bénéficiaires actuels vs besoin.
- Message final : cibler au-delà du revenu — inclure indicateurs d’exposition et actifs pour améliorer efficacité des transferts.

Angle sécurité alimentaire

- Titre potentiel : “Qui est food insecure au Sénégal ? Une typologie multidimensionnelle basée sur l’EHCVM 2021”
- Question centrale : Comment les formes de vulnérabilité multidimensionnelle expliquent la sécurité alimentaire ?
- Résultats attendus : clusters fortement corrélés à scores FCS/rCSI et share_food; identification de ménages urbains non‑pauvres mais food insecure.
- Visualisations : boxplots consommation alimentaire par cluster; radar chart des facteurs (actifs, exposition, capital humain) pour clusters food insecure; carte.
- Message final : interventions nutritionnelles doivent prendre en compte exposition saisonnière et accès services, pas seulement le revenu.

Angle résilience

- Titre potentiel : “Mesurer la résilience des ménages : vers une carte des capacités d’absorption au Sénégal”
- Question centrale : Quels ménages ont les capacités d’absorption et d’adaptation face aux chocs climatiques et économiques ?
- Résultats attendus : construction d’indice résilience composite, gradient entre résilients et chronically vulnerable ; politiques recommandées (accès crédit, assurances climatiques).
- Visualisations : index résilience distribution by cluster; scatter pcexp vs resilience index; case study spider plots.
- Message final : renforcer actifs productifs et systèmes financiers locaux pour améliorer résilience.

Angle agriculture

- Titre potentiel : “Systèmes de production et vulnérabilité : comment l’agriculture détermine les trajectoires des ménages ruraux”
- Question centrale : Quels types d’exploitations agricoles (taille, diversification) sont associés à vulnérabilité élevée ?
- Résultats attendus : clusters ruraux mono‑culture rainfed plus vulnérables ; superficie faible + peu de bétail = risque élevé.
- Visualisations : cluster map pour rural; boxplots superf, bétail par cluster; trajectoire schématique.
- Message final : politiques agricoles doivent promouvoir diversification, stockage, assurances et accès marché.

Angle inégalités territoriales

- Titre potentiel : “Territoires et vulnérabilité : cartographie des inégalités au Sénégal selon une typologie multidimensionnelle”
- Question centrale : Comment la vulnérabilité varie‑t‑elle spatialement et quelles régions nécessitent prioritairement interventions ?
- Résultats attendus : concentration des ménages chroniquement vulnérables (ex: zones arides Sud‑est?), différences urbain/rural.
- Visualisations : carte de densité de clusters par région; barres part cluster by region; bubble plot cluster share vs region GDP proxy.
- Message final : prioriser investissements infrastructurels et services dans régions à forte prévalence de vulnérabilité chronique.

11) Recommandations opérationnelles pour l’analyse EHCVM

- Utiliser pondérations (hhweight / poids) dès la réduction dimensionnelle et lors du calcul de statistiques par cluster.
- Favoriser ACM pour variables catégorielles, fusionner avec PCA sur variables continues si nécessaire.
- Tester inclusion d’un score VEP (estimation econométrique) comme variable additionnelle pour capturer risque ex ante.
- Documenter et justifier choix de variables et seuils pour labellisation des clusters ; faire sensibilité.
- Produire outputs reproductibles (R scripts : FactoMineR pour ACM, cluster, fpc, clValid, NbClust, silhouette; cartographie: tmap/ggplot2; prdata weighting via survey package).

12) Références complètes (sélection priorisée)
(Je donne ci‑dessous références complètes essentielles ; je peux fournir un fichier BibTeX sur demande.)

- Alwang, J., Siegel, P. B., \& Jørgensen, S. L. (2001). Vulnerability: A View from Different Disciplines. World Bank Technical Paper No. 211. The World Bank.
- Barrett, C. B., Reardon, T., \& Webb, P. (2001). Nonfarm Income Diversification and Household Livelihood Strategies in Rural Africa: Concepts, Dynamics and Policy Implications. Food Policy, 26(4), 315–331.
- Chaudhuri, S., Jalan, J., \& Suryahadi, A. (2002). Assessing Vulnerability to Poverty: Concepts, Empirical Methods and Illustrative Examples. World Development, 30(3), 499–524. (World Bank Policy Research WP 2307 earlier)
- Dercon, S. (2004). Growth and shocks: evidence from rural Ethiopia. Journal of Development Economics, 74(2), 309–329. Also: Dercon, S. (2004). “Vulnerability: A Micro Perspective.” Background paper for WDR 2004.
- Filmer, D., \& Pritchett, L. (2001). Estimating Wealth Effects Without Expenditure Data — or Tears: An Application to Educational Enrollments in States of India. Demography, 38(1), 115–132.
- Greenacre, M. (2007). Correspondence Analysis in Practice. Chapman \& Hall/CRC.
- Hoddinott, J., \& Yohannes, Y. (2002). Dietary Diversity as a Food Security Indicator. IFPRI FCND Discussion Paper 136.
- Ligon, E., \& Schechter, L. (2003). Measuring Vulnerability. Economic Journal, 113(486), C95–C102.
- Maxwell, D., \& Caldwell, R. (2008). The Coping Strategies Index: Field Methods Manual. CARE \& WFP.
- Pritchett, L., Suryahadi, A., \& Sumarto, S. (2000). Quantifying vulnerability to poverty: a proposed measure, applied to Indonesia. SMU Economics Discussion Paper.
- Sen, A. (1999). Development as Freedom. Oxford University Press.
- World Bank (2004). World Development Report 2004: Making services work for poor. (See risk background materials.)
- WFP — VAM reports (Vulnerability Analysis and Mapping) — country briefs and methodological notes (various years).
- FAO (2016). The State of Food and Agriculture — resilience in the context of food security.
- Alkire, S., \& Foster, J. (2011). Counting and Multidimensional Poverty Measurement. Journal of Public Economics, 95(7–8), 476–487.
- Dercon, S., \& Krishnan, P. (2000). In Sickness and in Health: Risk Sharing within Households in Rural Ethiopia. Journal of Political Economy, 108(4), 688–727.
- Adger, W. N. (2000). Social and ecological resilience: are they related? Progress in Human Geography, 24(3), 347–364.
- IFPRI \& FAO country vulnerability assessments and methodological notes (relevant country reports: Senegal, Mali, Niger — check FAO and IFPRI websites)
- Greenacre, M., \& Blasius, J. (2006). Multiple Correspondence Analysis and Related Methods. Chapman \& Hall/CRC.

13) Prochaine étape — proposition d’analyse R \& checklist
Si vous souhaitez, je peux :

- Fournir un script R de départ (prétraitement, ACM via FactoMineR, clustering, validation, mapping) adapté à vos tables (ehcvm_welfare_SEN2021, menage, individu, conso) et en tenant compte des pondérations.
- Produire une liste finale de variables (colonnes) codées, avec instructions de discretisation (seuils) et suggestions de pondération.
- Aider à définir règles d’étiquetage des clusters (seuils pcexp, food share, exposition) et proposer tests statistiques.

Souhaitez‑vous que je vous fournisse :

1) un script R commenté pour implémenter l’ACM + clustering sur votre EHCVM (avec pondérations) ? ou
2) une liste finale de variables (fichier CSV des noms et transformations recommandées) prête à être importée dans R ?

Quelle option préférez‑vous ?

