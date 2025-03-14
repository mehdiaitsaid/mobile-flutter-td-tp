# API REST en `Express.js` 🚀

Ce dossier contient les fichiers relatifs à la gestion des produits et des commandes, ainsi que la documentation associée 📋.

## Structure du projet 📂

Le dossier **TP_Tasks** contient les éléments suivants :

- **backend_tp/** : Contient le code backend, notamment l'API REST en Express.js pour la gestion des produits et des commandes.
- **client_api/** : Contient le code du client Dart qui interagit avec l'API backend 📱.
- **Tasks.md** : Fichier de documentation contenant des explications et des captures d'écran des étapes réalisées dans le TP 📸.
- **images** : Images utilisées dans le fichier **Tasks.md** pour illustrer les étapes du TP 🖼️.

## Instructions 📑

### Backend ⚙️

Le backend est une API REST réalisée avec **Express.js**. Elle permet de :
- Récupérer les produits via la route GET `/products` 🛍️.
- Ajouter un nouveau produit via la route POST `/products` ➕.
- Récupérer les commandes via la route GET `/orders` 📝.
- Créer une commande via la route POST `/orders` 🛒.

### Client Dart 💻

Le client Dart permet de :
- Afficher les produits récupérés via l'API 👀.
- Ajouter un produit via une requête POST ➕.
- Afficher les commandes récupérées depuis l'API 📑.
- Créer une commande via une requête POST 🛍️.

## Installation et exécution 🛠️

### 1. Backend

#### Prérequis :
- Assurez-vous que **Node.js** est installé 🌐.

#### Installation du Backend :
- Allez dans le dossier **backend_tp** et exécutez la commande suivante pour installer les dépendances :
   ```bash
   npm install
   ```

### 2. Client Dart
#### Prérequis :
- Assurez-vous que Dart est installé 🏗️
- Allez dans le dossier client_api et exécutez le client Dart selon votre environnement.

### 3. Utilisation avec Postman 📨
Postman est un outil pratique pour tester et interagir avec votre API REST sans avoir à développer de code client. Voici comment utiliser Postman pour tester l'API :

#### Installation de Postman :
- Téléchargez et installez Postman depuis leur site officiel.
- Ouvrez Postman après l'installation.
### Tester les Routes de l'API :
#### Récupérer les produits :

- Méthode : `GET`
- URL : http://localhost:3000/products
- Cliquez sur `SEND` pour voir la liste des produits.
#### Ajouter un produit :

- Méthode : `POST`
- URL : http://localhost:3000/products
- Dans l'onglet Body, sélectionnez raw et JSON puis entrez un objet produit, par exemple :
```json
{
  "name": "Produit Exemple",
  "price": 20.5
}
```
- Cliquez sur `SEND` pour ajouter le produit.

#### Récupérer les commandes :

- Méthode : `GET`
- URL : http://localhost:3000/orders
- Cliquez sur `SEND` pour voir la liste des commandes.

#### Créer une commande :

- Méthode : `POST`
- URL : http://localhost:3000/orders
- Dans l'onglet Body, sélectionnez raw et JSON puis entrez un objet commande, par exemple :

```json
{
  "productId": 1,
  "quantity": 3
}
```
- Cliquez sur `SEND` pour créer la commande.

## Contribuer 🤝
Si vous souhaitez contribuer, merci de forker ce projet, faire vos modifications et proposer un pull request 🔄.