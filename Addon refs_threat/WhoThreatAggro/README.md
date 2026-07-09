# WhoThreatAggro (WTA)

**WhoThreatAggro** est un addon pour World of Warcraft léger et performant, conçu pour visualiser la menace (aggro) sur les cadres d'unité.

## 🚀 Fonctionnalités

* **Ultra Léger :** Zéro utilisation CPU au repos. Code optimisé pour la performance.
* **Retour Visuel :** Ajoute une lueur colorée aux cadres d'unité basée sur le niveau de menace.
    * 🟡 **Jaune :** Menace Élevée (Attention)
    * 🟠 **Orange :** Menace Critique (Transition)
    * 🔴 **Rouge :** Aggro (Vous êtes attaqué)
* **Large Compatibilité :** Fonctionne sur :
    * Portrait du Joueur
    * Cadre de la Cible (lueur dédiée quand vous avez l'aggro dessus)
    * Cadres de Groupe (Standard et Compact)
    * Cadres de Raid (Compact/Grid)
* **Couleurs personnalisables :** Couleur de lueur et de texte au choix par catégorie (Auto selon la menace, couleur de classe pour le Joueur, ou couleur fixe).
* **Frame "Aggro de" :** Cadre déplaçable indiquant sur quelle cible vous avez actuellement l'aggro, avec bordure/fond configurables et fusion possible avec le texte de pourcentage.
* **Seuil d'alerte réglable :** Force la couleur rouge et le clignotement dès qu'un seuil de menace personnalisé est atteint.
* **Effets visuels indépendants :** Intensité de la lueur, activation et vitesse du clignotement réglables séparément pour Joueur / Groupe / Raid / Cible.
* **Bouton minimap :** Accès rapide aux options (clic gauche) et au mode test (clic droit), déplaçable par glisser-déposer.
* **Sauvegarde par personnage :** Chaque personnage garde sa propre configuration.
* **Focus Combat :** Option pour désactiver l'addon hors combat afin d'économiser des ressources.
* **Optimisation automatique :** En raid de 25 joueurs ou plus, l'addon passe automatiquement à 30 FPS pour réduire la charge CPU.

## 📦 Installation

1. Téléchargez la dernière version.
2. Extrayez le dossier `WhoThreatAggro` dans votre répertoire WoW : `_anniversary_/Interface/AddOns/`.
3. (Optionnel) Renommez le dossier si nécessaire pour qu'il corresponde exactement à `WhoThreatAggro`.

## ⚙️ Configuration

Utilisez le panneau de configuration en jeu, organisé en 3 onglets (Apparence / Général / Alertes).

* **Ouvrir les options :** `/wta options`, ou clic gauche sur le bouton minimap.
* **Mode Test :** `/wta test`, ou clic droit sur le bouton minimap — simule l'aggro pour vérifier le rendu visuel sans être en combat.
* **Réinitialiser :** `/wta reset`, ou le bouton "Réinitialiser" du panneau.

## 🛠️ Options Disponibles

**Page Apparence**
* Activez/désactivez indépendamment les lueurs pour les cadres Joueur / Groupe / Raid.
* Choisissez la couleur de la lueur (Auto, Couleur de classe pour le Joueur, ou couleur fixe).
* Activez/désactivez indépendamment le texte de pourcentage de menace pour chaque cadre, avec couleur, taille (curseur) et position (9 points d'ancrage) par catégorie.

**Page Général**
* Mode **"Combat Uniquement"** (Recommandé) : l'addon est totalement silencieux hors combat.
* Intensité de lueur, clignotement et vitesse de clignotement, réglables séparément pour Joueur / Groupe / Raid / Cible.

**Page Alertes**
* Seuil d'alerte (%) : force rouge + clignotement dès ce seuil de menace atteint.
* Frame "Aggro de" : taille du texte, fusion avec le %, bordure et fond configurables.
* Lueur Cible : allume une lueur rouge sur le cadre de la cible quand vous avez l'aggro dessus.

## 📝 Licence

Cet addon est protégé par une licence **"All Rights Reserved"** (Tous droits réservés).
**Copyright (c) 2024-2026 Mr_Ghoosty.**

Toute redistribution, modification ou utilisation commerciale sans autorisation écrite est interdite. Veuillez consulter le fichier `LICENSE.txt` inclus pour les conditions complètes.
