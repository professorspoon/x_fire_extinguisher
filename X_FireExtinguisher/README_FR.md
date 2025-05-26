# X_FireExtinguisher

Une ressource FiveM qui permet aux joueurs de ramasser et d'utiliser les extincteurs trouvés dans le monde du jeu.

## Caractéristiques

- Ramasser n'importe quel extincteur trouvé dans le monde du jeu
- Performances optimisées avec une utilisation minimale des ressources
- Prise en charge des frameworks ESX et QBCore
- Sélection automatique de l'arme après avoir ramassé l'extincteur
- Système de temps de recharge pour éviter les abus
- Notifications et TextUI personnalisables
- Support multilingue

## Installation

1. Téléchargez la ressource
2. Placez-la dans le dossier resources de votre serveur
3. Ajoutez `ensure X_FireExtinguisher` à votre server.cfg
4. Configurez les paramètres dans `configuration/config.lua` selon vos préférences

## Configuration

Le script est hautement configurable via le fichier `configuration/config.lua` :

- Sélection du framework (ESX ou QBCore)
- Version ESX (nouvelle ou ancienne)
- Paramètres de temps de recharge
- Fonctions de notification personnalisables
- Intégration TextUI

## Utilisation

Les joueurs doivent simplement s'approcher d'un extincteur dans le monde du jeu et :

1. Une invite apparaîtra à l'écran
2. Appuyer sur la touche d'interaction (par défaut : E) pour ramasser l'extincteur
3. L'extincteur sera automatiquement équipé

## Prérequis

- Framework ESX ou QBCore (selon la configuration)